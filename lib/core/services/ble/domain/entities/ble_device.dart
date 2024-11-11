// lib/core/services/ble/domain/entities/ble_device.dart
class BleDevice {
  final String id;
  final String name;
  final int rssi;
  final Map<String, dynamic> advertisementData;

  const BleDevice({
    required this.id,
    required this.name,
    this.rssi = 0,
    this.advertisementData = const {},
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BleDevice && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() =>
      'BleDevice(id: $id, name: $name, rssi: $rssi, advertisementData: $advertisementData)';
}
