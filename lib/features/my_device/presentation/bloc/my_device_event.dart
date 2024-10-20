// lib/features/my_device/presentation/bloc/my_device_event.dart
part of 'my_device_bloc.dart';

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

class DisconnectDeviceEvent extends MyDeviceEvent {
  final BleDevice device;

  const DisconnectDeviceEvent(this.device);

  @override
  List<Object> get props => [device];
}

class CheckConnectionStatusEvent extends MyDeviceEvent {}
