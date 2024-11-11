// lib/core/services/ble/infrastructure/ble_service.dart
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import '../domain/entities/ble_device.dart';

abstract class BleService {
  Future<bool> isBluetoothAvailable();
  Stream<BluetoothAdapterState> get bluetoothState;
  Future<List<BleDevice>> scanDevices();
  Future<bool> connectDevice(BleDevice device);
  Future<bool> disconnectDevice();
  Future<bool> writeCharacteristic(
      String serviceUuid, String characteristicUuid, List<int> value);
  Stream<BluetoothConnectionState> get connectionStateStream;
  BleDevice? get connectedDevice;
  Future<void> dispose();
}
