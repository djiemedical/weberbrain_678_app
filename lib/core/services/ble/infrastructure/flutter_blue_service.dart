// lib/core/services/ble/infrastructure/flutter_blue_service.dart
import 'dart:async';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:logger/logger.dart';
import 'ble_service.dart';
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
                r.rssi >= -80 // Filter out devices with weak signal
            )
        .map((r) => BleDevice(
              id: r.device.remoteId.str,
              name: r.device.platformName,
              rssi: r.rssi,
              advertisementData: {
                'localName':
                    r.advertisementData.advName, // Updated from localName
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

      // Disconnect from any existing device first
      await disconnectDevice();

      _connectedDevice = BluetoothDevice(remoteId: DeviceIdentifier(device.id));

      // Set up connection state monitoring
      _connectionStateSubscription?.cancel();
      _connectionStateSubscription = _connectedDevice!.connectionState.listen(
        (state) {
          _logger.d('Connection state changed: $state');
          if (state == BluetoothConnectionState.disconnected) {
            _handleDisconnection();
          }
        },
        onError: (error) {
          _logger.e('Connection state error: $error');
          _handleDisconnection();
        },
        onDone: () {
          _logger.d('Connection state subscription ended');
          _handleDisconnection();
        },
      );

      // Connect to device
      await _connectedDevice!.connect(
        timeout: const Duration(seconds: 15),
        autoConnect: false,
      );

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
    _connectedDevice = null;
    _connectedBleDevice = null;
    _connectionStateSubscription?.cancel();
    _connectionStateSubscription = null;
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
  Future<bool> writeCharacteristic(
      String serviceUuid, String characteristicUuid, List<int> value) async {
    if (_connectedDevice == null) return false;

    try {
      final services = await _connectedDevice!.discoverServices();
      final service = services.firstWhere(
        (s) => s.uuid.toString() == serviceUuid,
        orElse: () => throw Exception('Service not found: $serviceUuid'),
      );

      final characteristic = service.characteristics.firstWhere(
        (c) => c.uuid.toString() == characteristicUuid,
        orElse: () =>
            throw Exception('Characteristic not found: $characteristicUuid'),
      );

      await characteristic.write(value);
      return true;
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
