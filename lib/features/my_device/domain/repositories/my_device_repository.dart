// lib/features/my_device/domain/repositories/my_device_repository.dart
import 'package:dartz/dartz.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import '../../../../core/error/failures.dart';
import '../entities/ble_device.dart';

abstract class MyDeviceRepository {
  Future<Either<Failure, List<BleDevice>>> scanDevices();
  Future<Either<Failure, bool>> connectDevice(BleDevice device);
  Future<Either<Failure, bool>> disconnectDevice();
  Stream<BluetoothConnectionState> get connectionStateStream;
}
