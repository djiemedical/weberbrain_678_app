// lib/core/services/ble/infrastructure/ble_service.dart
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import '../domain/entities/ble_device.dart';

abstract class BleService {
  Future<List<BleDevice>> scanDevices();
  Future<bool> connectDevice(BleDevice device);
  Future<bool> disconnectDevice();
  Future<bool> writeCharacteristic(
      String serviceUuid, String characteristicUuid, List<int> value);
  Future<bool> writeCommand(List<int> value);
  Future<bool> isBluetoothAvailable();
  Future<void> dispose();
  Stream<BluetoothConnectionState> get connectionStateStream;
  Stream<BluetoothAdapterState> get bluetoothState;
  BleDevice? get connectedDevice;
}
