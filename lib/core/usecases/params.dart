// lib/core/usecases/params.dart
import 'package:equatable/equatable.dart';
import 'package:weberbrain_678_app/features/my_device/domain/entities/ble_device.dart';

class Params extends Equatable {
  final BleDevice device;

  const Params({required this.device});

  @override
  List<Object> get props => [device];
}
