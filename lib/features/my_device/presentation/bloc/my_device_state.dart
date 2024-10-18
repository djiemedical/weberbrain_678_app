part of 'my_device_bloc.dart';

abstract class MyDeviceState {}

class MyDeviceInitial extends MyDeviceState {}

class MyDeviceScanning extends MyDeviceState {}

class MyDeviceScanned extends MyDeviceState {
  final List<BleDevice> devices;
  MyDeviceScanned(this.devices);
}

class MyDeviceConnecting extends MyDeviceState {}

class MyDeviceConnected extends MyDeviceState {
  final BleDevice device;
  MyDeviceConnected(this.device);
}

class MyDeviceDisconnected extends MyDeviceState {}

class MyDeviceError extends MyDeviceState {
  final String message;
  MyDeviceError(this.message);
}
