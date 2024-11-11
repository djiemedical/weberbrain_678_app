// lib/core/services/ble/data/models/ble_device_model.dart
import '../../domain/entities/ble_device.dart';

class BleDeviceModel extends BleDevice {
  BleDeviceModel({
    required super.id,
    required super.name,
  });

  factory BleDeviceModel.fromDevice(BleDevice device) {
    return BleDeviceModel(
      id: device.id,
      name: device.name,
    );
  }

  factory BleDeviceModel.fromJson(Map<String, dynamic> json) {
    return BleDeviceModel(
      id: json['id'] as String,
      name: json['name'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
    };
  }
}
