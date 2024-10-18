// lib/features/my_device/presentation/bloc/my_device_event.dart
import 'package:equatable/equatable.dart';
import '../../domain/entities/ble_device.dart';

abstract class MyDeviceEvent extends Equatable {
  const MyDeviceEvent();

  @override
  List<Object> get props => [];
}

class ScanDevicesEvent extends MyDeviceEvent {}

class ConnectDeviceEvent extends MyDeviceEvent {
  final BleDevice device;

  const ConnectDeviceEvent(this.device);

  @override
  List<Object> get props => [device];
}

class DisconnectDeviceEvent extends MyDeviceEvent {}
