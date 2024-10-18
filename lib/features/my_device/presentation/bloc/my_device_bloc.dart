// lib/features/my_device/presentation/bloc/my_device_bloc.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/scan_devices.dart';
import '../../domain/usecases/connect_device.dart';
import '../../../../core/usecases/usecase.dart';
import 'package:logger/logger.dart';
import 'my_device_event.dart';
import 'my_device_state.dart';

class MyDeviceBloc extends Bloc<MyDeviceEvent, MyDeviceState> {
  final ScanDevices scanDevices;
  final ConnectDevice connectDevice;
  final Logger _logger = Logger();

  MyDeviceBloc({
    required this.scanDevices,
    required this.connectDevice,
  }) : super(MyDeviceInitial()) {
    on<ScanDevicesEvent>(_onScanDevices);
    on<ConnectDeviceEvent>(_onConnectDevice);
    on<DisconnectDeviceEvent>(_onDisconnectDevice);
  }

  Future<void> _onScanDevices(
      ScanDevicesEvent event, Emitter<MyDeviceState> emit) async {
    _logger.d('Starting device scan');
    emit(const MyDeviceScanning());

    final result = await scanDevices(NoParams());
    _logger.d('Scan completed, processing results');

    result.fold(
      (failure) {
        _logger.e('Scan failed: $failure');
        emit(const MyDeviceError('Failed to scan devices'));
      },
      (devices) {
        _logger.d('Scan successful. Found ${devices.length} devices');
        emit(MyDeviceScanned(devices));
      },
    );

    _logger.d('Scan process finished, current state: ${state.runtimeType}');
  }

  Future<void> _onConnectDevice(
      ConnectDeviceEvent event, Emitter<MyDeviceState> emit) async {
    _logger.d('Connecting to device: ${event.device.name}');
    emit(MyDeviceConnecting());
    final result = await connectDevice(event.device);
    result.fold(
      (failure) {
        _logger.e('Connection failed: $failure');
        emit(const MyDeviceError('Failed to connect to device'));
      },
      (success) {
        _logger.i('Successfully connected to device: ${event.device.name}');
        emit(MyDeviceConnected(event.device));
      },
    );
  }

  Future<void> _onDisconnectDevice(
      DisconnectDeviceEvent event, Emitter<MyDeviceState> emit) async {
    // TODO: Implement disconnect logic here
    _logger.d('Disconnecting device');
    emit(MyDeviceDisconnected());
  }
}
