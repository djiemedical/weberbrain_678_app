// lib/features/my_device/domain/entities/ble_device.dart
import 'package:equatable/equatable.dart';

class BleDevice extends Equatable {
  final String id;
  final String name;

  const BleDevice({required this.id, required this.name});

  @override
  List<Object> get props => [id];

  @override
  bool get stringify => true;

  @override
  int get hashCode => id.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BleDevice && runtimeType == other.runtimeType && id == other.id;
}
