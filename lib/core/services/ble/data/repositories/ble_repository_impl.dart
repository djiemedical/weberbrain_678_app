// lib/core/services/ble/data/repositories/ble_repository_impl.dart
import 'package:dartz/dartz.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import '../../../../../core/error/failures.dart';
import '../../domain/entities/ble_device.dart';
import '../../domain/repositories/ble_repository.dart';
import '../../infrastructure/ble_service.dart';
import '../../domain/usecases/set_parameters.dart';

class BleRepositoryImpl implements BleRepository {
  final BleService bleService;

  BleRepositoryImpl({required this.bleService});

  @override
  Future<Either<Failure, List<BleDevice>>> scanDevices() async {
    try {
      final devices = await bleService.scanDevices();
      return Right(devices);
    } catch (e) {
      return Left(BluetoothFailure());
    }
  }

  @override
  Future<Either<Failure, bool>> connectDevice(BleDevice device) async {
    try {
      final result = await bleService.connectDevice(device);
      return Right(result);
    } catch (e) {
      return Left(BluetoothFailure());
    }
  }

  @override
  Future<Either<Failure, bool>> disconnectDevice() async {
    try {
      final result = await bleService.disconnectDevice();
      return Right(result);
    } catch (e) {
      return Left(BluetoothFailure());
    }
  }

  @override
  Future<Either<Failure, bool>> setParameters(
      SetParametersParams params) async {
    try {
      // Implementation for setting parameters
      return const Right(true);
    } catch (e) {
      return Left(BluetoothFailure());
    }
  }

  @override
  Stream<BluetoothConnectionState> get connectionStateStream {
    return bleService.connectionStateStream;
  }

  @override
  BleDevice? get connectedDevice => bleService.connectedDevice;
}
