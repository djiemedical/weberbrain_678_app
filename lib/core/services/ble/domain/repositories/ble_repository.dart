// lib/core/services/ble/domain/repositories/ble_repository.dart
import 'package:dartz/dartz.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import '../../../../../core/error/failures.dart';
import '../entities/ble_device.dart';
import '../usecases/set_parameters.dart';

abstract class BleRepository {
  Future<Either<Failure, List<BleDevice>>> scanDevices();
  Future<Either<Failure, bool>> connectDevice(BleDevice device);
  Future<Either<Failure, bool>> disconnectDevice();
  Future<Either<Failure, bool>> setParameters(SetParametersParams params);
  Stream<BluetoothConnectionState> get connectionStateStream;
  BleDevice? get connectedDevice;
}
