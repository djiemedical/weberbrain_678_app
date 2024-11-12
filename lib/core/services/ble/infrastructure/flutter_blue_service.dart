// lib/core/services/ble/infrastructure/flutter_blue_service.dart
import 'dart:async';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:logger/logger.dart';
import 'ble_service.dart';
import 'ble_constants.dart';
import '../domain/entities/ble_device.dart';

class FlutterBlueService implements BleService {
  final Logger _logger = Logger();
  BluetoothDevice? _connectedDevice;
  BleDevice? _connectedBleDevice;
  bool _isScanning = false;
  StreamSubscription? _connectionStateSubscription;
  StreamSubscription? _scanSubscription;

  // Singleton pattern
  static final FlutterBlueService _instance = FlutterBlueService._internal();
  factory FlutterBlueService() => _instance;
  FlutterBlueService._internal();

  @override
  Future<bool> isBluetoothAvailable() async {
    try {
      // Check if Bluetooth is supported on this device
      final isSupported = await FlutterBluePlus.isSupported;
      if (!isSupported) {
        _logger.w('Bluetooth is not supported on this device');
        return false;
      }

      // Check Bluetooth adapter state
      final adapterState = await FlutterBluePlus.adapterState.first;
      final isAvailable = adapterState == BluetoothAdapterState.on;

      if (!isAvailable) {
        _logger.w('Bluetooth is not enabled. Current state: $adapterState');
      }

      return isAvailable;
    } catch (e) {
      _logger.e('Error checking Bluetooth availability: $e');
      return false;
    }
  }

  @override
  Stream<BluetoothAdapterState> get bluetoothState =>
      FlutterBluePlus.adapterState;

  @override
  Future<List<BleDevice>> scanDevices() async {
    if (!await isBluetoothAvailable()) {
      _logger.w('Bluetooth is not available');
      return [];
    }

    if (_isScanning) {
      _logger.w('Scan already in progress');
      return [];
    }

    List<BleDevice> discoveredDevices = [];
    final Completer<List<BleDevice>> completer = Completer();

    try {
      _isScanning = true;
      _logger.d('Starting BLE scan');

      // Clear any existing scan results and subscriptions
      await _cleanupScan();

      // Set up scan results subscription
      _scanSubscription = FlutterBluePlus.scanResults.listen(
        (results) {
          _logger.d('Raw scan results: ${results.length} devices found');
          for (var result in results) {
            _logger.d('Device found: '
                'Name: ${result.device.platformName}, '
                'ID: ${result.device.remoteId.str}, '
                'RSSI: ${result.rssi}');
          }

          discoveredDevices = _processScanResults(results);
          _logger.d('Filtered devices: ${discoveredDevices.length}');
        },
        onError: (error) {
          _logger.e('Error during scan: $error');
          if (!completer.isCompleted) {
            completer.complete(discoveredDevices);
          }
        },
      );

      // Start scanning
      await FlutterBluePlus.startScan(
        timeout: const Duration(seconds: 10),
        androidUsesFineLocation: true,
      );

      // Wait for scan to complete
      await Future.delayed(const Duration(seconds: 10));

      if (!completer.isCompleted) {
        completer.complete(discoveredDevices);
      }

      return await completer.future;
    } catch (e) {
      _logger.e('Error during scan setup: $e');
      return discoveredDevices;
    } finally {
      await _cleanupScan();
    }
  }

  List<BleDevice> _processScanResults(List<ScanResult> results) {
    return results
        .where((r) =>
                r.device.platformName.isNotEmpty &&
                r.device.platformName.startsWith('WEH_678') &&
                r.rssi >= -90 // Filter out devices with weak signal
            )
        .map((r) => BleDevice(
              id: r.device.remoteId.str,
              name: r.device.platformName,
              rssi: r.rssi,
              advertisementData: {
                'localName': r.advertisementData.advName,
                'txPowerLevel': r.advertisementData.txPowerLevel,
                'serviceUuids': r.advertisementData.serviceUuids,
              },
            ))
        .toList();
  }

  @override
  Future<bool> connectDevice(BleDevice device) async {
    if (!await isBluetoothAvailable()) {
      return false;
    }

    try {
      _logger
          .d('Attempting to connect to device: ${device.name} (${device.id})');

      // Create BluetoothDevice instance first
      _connectedDevice = BluetoothDevice(remoteId: DeviceIdentifier(device.id));

      // Then attempt connection
      await _connectedDevice!.connect(
        timeout: const Duration(seconds: 15),
        autoConnect: false,
      );

      // Set up connection state monitoring
      _connectionStateSubscription?.cancel();
      _connectionStateSubscription =
          _connectedDevice!.connectionState.listen((state) {
        _logger.d('Connection state changed: $state');
        if (state == BluetoothConnectionState.disconnected) {
          _handleDisconnection();
        }
      });

      _connectedBleDevice = device;
      _logger.i('Successfully connected to device: ${device.name}');
      return true;
    } catch (e) {
      _logger.e('Error connecting to device: $e');
      _handleDisconnection();
      return false;
    }
  }

  void _handleDisconnection() {
    _logger.d('Handling disconnection');
    _connectionStateSubscription?.cancel();
    _connectionStateSubscription = null;
    _connectedDevice = null;
    _connectedBleDevice = null;
  }

  @override
  Future<bool> disconnectDevice() async {
    if (_connectedDevice != null) {
      try {
        _logger.d(
            'Attempting to disconnect from device: ${_connectedDevice!.remoteId}');
        await _connectedDevice!.disconnect();
        _logger.i('Successfully disconnected from device');
        return true;
      } catch (e) {
        _logger.e('Error disconnecting from device: $e');
        return false;
      } finally {
        _handleDisconnection();
      }
    }
    return true;
  }

  Future<void> _cleanupScan() async {
    _isScanning = false;
    await _scanSubscription?.cancel();
    _scanSubscription = null;
    try {
      await FlutterBluePlus.stopScan();
    } catch (e) {
      _logger.e('Error stopping scan: $e');
    }
  }

  @override
  Future<bool> writeCommand(List<int> value) async {
    try {
      final String command = String.fromCharCodes(value);
      _logger.i('Writing command to device: $command');
      return writeCharacteristic(
          BleConstants.serviceUuid, BleConstants.characteristicUuid, value);
    } catch (e) {
      _logger.e('Error in writeCommand: $e');
      return false;
    }
  }

  @override
  Future<bool> writeCharacteristic(
      String serviceUuid, String characteristicUuid, List<int> value) async {
    if (_connectedDevice == null) {
      _logger.e('No device connected');
      return false;
    }

    try {
      _logger.d('Discovering services...');
      final services = await _connectedDevice!.discoverServices();
      _logger.d('Found ${services.length} services');

      for (var service in services) {
        if (service.uuid.toString().toUpperCase() ==
            serviceUuid.toUpperCase()) {
          _logger.d('Found matching service: ${service.uuid}');

          for (var characteristic in service.characteristics) {
            if (characteristic.uuid.toString().toUpperCase() ==
                characteristicUuid.toUpperCase()) {
              _logger
                  .d('Found matching characteristic: ${characteristic.uuid}');

              final String command = String.fromCharCodes(value);
              _logger.i('Writing to characteristic:');
              _logger.i('  Service UUID: $serviceUuid');
              _logger.i('  Characteristic UUID: $characteristicUuid');
              _logger.i('  Command: $command');
              _logger.i(
                  '  Raw bytes: ${value.map((b) => '0x${b.toRadixString(16).padLeft(2, '0').toUpperCase()}').join(', ')}');

              await characteristic.write(value, withoutResponse: true);
              _logger.i('Successfully wrote command: $command');
              return true;
            }
          }
        }
      }

      _logger.e('Service or characteristic not found');
      return false;
    } catch (e) {
      _logger.e('Error writing characteristic: $e');
      return false;
    }
  }

  @override
  Stream<BluetoothConnectionState> get connectionStateStream {
    if (_connectedDevice != null) {
      return _connectedDevice!.connectionState;
    }
    return const Stream.empty();
  }

  @override
  BleDevice? get connectedDevice => _connectedBleDevice;

  @override
  Future<void> dispose() async {
    _logger.d('Disposing BLE service');
    await _cleanupScan();
    await disconnectDevice();
    await _connectionStateSubscription?.cancel();
    _connectionStateSubscription = null;
  }
}
