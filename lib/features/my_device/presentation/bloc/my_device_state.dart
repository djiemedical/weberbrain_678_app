// lib/features/my_device/presentation/bloc/my_device_state.dart
part of 'my_device_bloc.dart';

abstract class MyDeviceState extends Equatable {
  const MyDeviceState();

  @override
  List<Object> get props => [];
}

class MyDeviceInitial extends MyDeviceState {}

class MyDeviceScanning extends MyDeviceState {}

class MyDeviceScanned extends MyDeviceState {
  final List<BleDevice> devices;

  const MyDeviceScanned(this.devices);

  @override
  List<Object> get props => [devices];
}

class MyDeviceConnecting extends MyDeviceState {
  final BleDevice device;

  const MyDeviceConnecting(this.device);

  @override
  List<Object> get props => [device];
}

class MyDeviceConnected extends MyDeviceState {
  final BleDevice device;

  const MyDeviceConnected(this.device);

  @override
  List<Object> get props => [device];
}

class MyDeviceDisconnecting extends MyDeviceState {
  final BleDevice device;

  const MyDeviceDisconnecting(this.device);

  @override
  List<Object> get props => [device];
}

class MyDeviceDisconnected extends MyDeviceState {
  final BleDevice device;

  const MyDeviceDisconnected(this.device);

  @override
  List<Object> get props => [device];
}

class MyDeviceError extends MyDeviceState {
  final String message;

  const MyDeviceError(this.message);

  @override
  List<Object> get props => [message];
}
