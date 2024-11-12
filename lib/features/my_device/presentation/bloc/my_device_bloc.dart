// lib/features/my_device/presentation/bloc/my_device_bloc.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../domain/usecases/scan_devices.dart';
import '../../domain/usecases/connect_device.dart';
import '../../domain/usecases/disconnect_device.dart';
import '../../../../core/usecases/usecase.dart';
import '../../domain/entities/ble_device.dart';
import 'package:logger/logger.dart';

part 'my_device_event.dart';
part 'my_device_state.dart';

class MyDeviceBloc extends Bloc<MyDeviceEvent, MyDeviceState> {
  final ScanDevices scanDevices;
  final ConnectDevice connectDevice;
  final DisconnectDevice disconnectDevice;
  final Logger _logger = Logger();
  BleDevice? _lastConnectedDevice;

  MyDeviceBloc({
    required this.scanDevices,
    required this.connectDevice,
    required this.disconnectDevice,
  }) : super(MyDeviceInitial()) {
    on<ScanDevicesEvent>(_onScanDevices);
    on<ConnectDeviceEvent>(_onConnectDevice);
    on<DisconnectDeviceEvent>(_onDisconnectDevice);
    on<CheckConnectionStatusEvent>(_onCheckConnectionStatus);
  }

  Future<void> _onScanDevices(
      ScanDevicesEvent event, Emitter<MyDeviceState> emit) async {
    _logger.d('Starting device scan');

    // If there's a connected device, maintain that state
    if (_lastConnectedDevice != null) {
      emit(MyDeviceConnected(_lastConnectedDevice!));
      return;
    }

    emit(MyDeviceScanning());

    final result = await scanDevices(NoParams());
    result.fold(
      (failure) {
        _logger.e('Scan failed: $failure');
        emit(const MyDeviceError('Failed to scan devices'));
      },
      (devices) {
        _logger.d('Scan completed. Found ${devices.length} devices');
        emit(MyDeviceScanned(devices));
      },
    );
  }

  Future<void> _onConnectDevice(
      ConnectDeviceEvent event, Emitter<MyDeviceState> emit) async {
    _logger.d('Connecting to device: ${event.device.name}');
    emit(MyDeviceConnecting(event.device));

    final result = await connectDevice(event.device);
    result.fold(
      (failure) {
        _logger.e('Connection failed: $failure');
        _lastConnectedDevice = null;
        emit(const MyDeviceError('Failed to connect to device'));
      },
      (success) {
        _logger.i('Successfully connected to device: ${event.device.name}');
        _lastConnectedDevice = event.device;
        emit(MyDeviceConnected(event.device));
      },
    );
  }

  Future<void> _onDisconnectDevice(
      DisconnectDeviceEvent event, Emitter<MyDeviceState> emit) async {
    _logger.d('Disconnecting from device: ${event.device.name}');
    emit(MyDeviceDisconnecting(event.device));

    final result = await disconnectDevice(NoParams());
    result.fold(
      (failure) {
        _logger.e('Disconnection failed: $failure');
        emit(const MyDeviceError('Failed to disconnect from device'));
      },
      (success) {
        _logger
            .i('Successfully disconnected from device: ${event.device.name}');
        _lastConnectedDevice = null;
        emit(MyDeviceDisconnected(event.device));
        add(ScanDevicesEvent());
      },
    );
  }

  Future<void> _onCheckConnectionStatus(
      CheckConnectionStatusEvent event, Emitter<MyDeviceState> emit) async {
    if (_lastConnectedDevice != null) {
      _logger.d(
          'Restoring connection state for device: ${_lastConnectedDevice!.name}');
      emit(MyDeviceConnected(_lastConnectedDevice!));
    } else {
      _logger.d('No previous connection found, starting scan');
      add(ScanDevicesEvent());
    }
  }
}
