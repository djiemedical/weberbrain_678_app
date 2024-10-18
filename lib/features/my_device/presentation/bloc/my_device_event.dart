part of 'my_device_bloc.dart';

abstract class MyDeviceEvent {}

class ScanDevicesEvent extends MyDeviceEvent {}

class ConnectDeviceEvent extends MyDeviceEvent {
  final BleDevice device;
  ConnectDeviceEvent(this.device);
}

class DisconnectDeviceEvent extends MyDeviceEvent {}
