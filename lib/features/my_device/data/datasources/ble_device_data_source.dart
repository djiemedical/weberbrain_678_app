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
}

class BleDeviceDataSourceImpl implements BleDeviceDataSource {
  final Logger _logger = Logger();
  BluetoothDevice? _connectedDevice;

  @override
  Future<List<BleDevice>> scanDevices() async {
    Set<BleDevice> deviceSet = {}; // Use a Set to prevent duplicates
    _logger.d('Starting BLE scan');

    try {
      await FlutterBluePlus.startScan(timeout: const Duration(seconds: 10));

      await for (final results in FlutterBluePlus.scanResults) {
        for (ScanResult r in results) {
          _logger.d(
              'Found device: ${r.device.platformName} (${r.device.remoteId})');
          if (r.device.platformName.startsWith('WEH_678')) {
            BleDevice device = BleDevice(
              id: r.device.remoteId.str,
              name: r.device.platformName,
            );
            if (deviceSet.add(device)) {
              // add() returns true if the element was added to the set
              _logger.i('Adding new WEH device: ${device.name}');
            }
          }
        }
      }
    } catch (e) {
      _logger.e('Error scanning for devices: $e');
    } finally {
      await FlutterBluePlus.stopScan();
      _logger.d(
          'BLE scan completed. Found ${deviceSet.length} unique WEH devices');
    }

    return deviceSet.toList();
  }

  @override
  Future<bool> connectDevice(BleDevice device) async {
    try {
      _logger
          .d('Attempting to connect to device: ${device.name} (${device.id})');
      _connectedDevice = BluetoothDevice(remoteId: DeviceIdentifier(device.id));
      await _connectedDevice!.connect();
      _logger.i('Successfully connected to device: ${device.name}');
      return true;
    } catch (e) {
      _logger.e('Error connecting to device: $e');
      return false;
    }
  }

  @override
  Future<bool> disconnectDevice() async {
    if (_connectedDevice != null) {
      try {
        _logger.d(
            'Attempting to disconnect from device: ${_connectedDevice!.platformName}');
        await _connectedDevice!.disconnect();
        _logger.i(
            'Successfully disconnected from device: ${_connectedDevice!.platformName}');
        _connectedDevice = null;
        return true;
      } catch (e) {
        _logger.e('Error disconnecting device: $e');
        return false;
      }
    } else {
      _logger.w('No device connected to disconnect');
      return false;
    }
  }

  @override
  Stream<BluetoothConnectionState> get connectionStateStream {
    if (_connectedDevice != null) {
      _logger.d(
          'Starting to listen to connection state for device: ${_connectedDevice!.platformName}');
      return _connectedDevice!.connectionState.asBroadcastStream().map((state) {
        _logger.d('Connection state changed: $state');
        return state;
      }).handleError((error) {
        _logger.e('Error in connection state stream: $error');
        return BluetoothConnectionState.disconnected;
      });
    } else {
      _logger.w('No device connected, returning disconnected state stream');
      return Stream.value(BluetoothConnectionState.disconnected);
    }
  }
}
