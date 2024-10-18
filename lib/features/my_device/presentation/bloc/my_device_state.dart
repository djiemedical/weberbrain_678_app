// lib/features/my_device/presentation/bloc/my_device_state.dart
import 'package:equatable/equatable.dart';
import '../../domain/entities/ble_device.dart';

abstract class MyDeviceState extends Equatable {
  const MyDeviceState();

  @override
  List<Object> get props => [];
}

class MyDeviceInitial extends MyDeviceState {}

class MyDeviceScanning extends MyDeviceState {
  final List<BleDevice> devices;

  const MyDeviceScanning([this.devices = const []]);

  @override
  List<Object> get props => [devices];
}

class MyDeviceScanned extends MyDeviceState {
  final List<BleDevice> devices;

  const MyDeviceScanned(this.devices);

  @override
  List<Object> get props => [devices];
}

class MyDeviceConnecting extends MyDeviceState {}

class MyDeviceConnected extends MyDeviceState {
  final BleDevice device;

  const MyDeviceConnected(this.device);

  @override
  List<Object> get props => [device];
}

class MyDeviceDisconnected extends MyDeviceState {}

class MyDeviceError extends MyDeviceState {
  final String message;

  const MyDeviceError(this.message);

  @override
  List<Object> get props => [message];
}
