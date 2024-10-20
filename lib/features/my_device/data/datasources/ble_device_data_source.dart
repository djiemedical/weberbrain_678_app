// lib/features/my_device/data/datasources/ble_device_data_source.dart
import 'dart:async';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:logger/logger.dart';
import '../../domain/entities/ble_device.dart';

abstract class BleDeviceDataSource {
  Future<List<BleDevice>> scanDevices();
  Future<bool> connectDevice(BleDevice device);
  Future<bool> disconnectDevice();
  Stream<BluetoothConnectionState> get connectionStateStream;
  BleDevice? get connectedDevice;
}

class BleDeviceDataSourceImpl implements BleDeviceDataSource {
  final Logger _logger = Logger();
  BluetoothDevice? _connectedBluetoothDevice;
  BleDevice? _connectedBleDevice;
  bool _isScanning = false;
  StreamSubscription<List<ScanResult>>? _scanResultsSubscription;

  @override
  Future<List<BleDevice>> scanDevices() async {
    List<BleDevice> discoveredDevices = [];
    if (_isScanning) return discoveredDevices;

    _logger.d('Starting BLE scan');
    _isScanning = true;

    try {
      await FlutterBluePlus.startScan(timeout: const Duration(seconds: 15));
      _scanResultsSubscription = FlutterBluePlus.scanResults.listen((results) {
        discoveredDevices = results
            .where((r) => r.device.platformName.startsWith('WEH'))
            .map((r) => BleDevice(
                  id: r.device.remoteId.str,
                  name: r.device.platformName,
                ))
            .toList();
        _logger.d('Found ${discoveredDevices.length} WEH devices');
      }, onError: (e) {
        _logger.e('Error during scan: $e');
      });

      await Future.delayed(const Duration(seconds: 15));
      await FlutterBluePlus.stopScan();
    } catch (e) {
      _logger.e('Error starting scan: $e');
    } finally {
      _isScanning = false;
      await _scanResultsSubscription?.cancel();
    }

    return discoveredDevices;
  }

  @override
  Future<bool> connectDevice(BleDevice device) async {
    try {
      _logger
          .d('Attempting to connect to device: ${device.name} (${device.id})');
      _connectedBluetoothDevice =
          BluetoothDevice(remoteId: DeviceIdentifier(device.id));
      await _connectedBluetoothDevice!.connect();
      _connectedBleDevice = device;
      _logger.i('Successfully connected to device: ${device.name}');
      return true;
    } catch (e) {
      _logger.e('Error connecting to device: $e');
      return false;
    }
  }

  @override
  Future<bool> disconnectDevice() async {
    if (_connectedBluetoothDevice != null) {
      try {
        _logger.d(
            'Attempting to disconnect from device: ${_connectedBluetoothDevice!.remoteId}');
        await _connectedBluetoothDevice!.disconnect();
        _logger.i('Successfully disconnected from device');
        _connectedBluetoothDevice = null;
        _connectedBleDevice = null;
        return true;
      } catch (e) {
        _logger.e('Error disconnecting from device: $e');
        return false;
      }
    }
    return false;
  }

  @override
  Stream<BluetoothConnectionState> get connectionStateStream {
    if (_connectedBluetoothDevice != null) {
      return _connectedBluetoothDevice!.connectionState;
    } else {
      return const Stream.empty();
    }
  }

  @override
  BleDevice? get connectedDevice => _connectedBleDevice;
}
