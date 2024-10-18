// lib/features/my_device/data/repositories/my_device_repository_impl.dart
import 'package:dartz/dartz.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import '../../domain/entities/ble_device.dart';
import '../../domain/repositories/my_device_repository.dart';
import '../datasources/ble_device_data_source.dart';
import '../../../../core/error/failures.dart';

class MyDeviceRepositoryImpl implements MyDeviceRepository {
  final BleDeviceDataSource dataSource;

  MyDeviceRepositoryImpl({required this.dataSource});

  @override
  Future<Either<Failure, List<BleDevice>>> scanDevices() async {
    try {
      final devices = await dataSource.scanDevices();
      return Right(devices);
    } catch (e) {
      return Left(BluetoothFailure());
    }
  }

  @override
  Future<Either<Failure, bool>> connectDevice(BleDevice device) async {
    try {
      final result = await dataSource.connectDevice(device);
      return Right(result);
    } catch (e) {
      return Left(BluetoothFailure());
    }
  }

  @override
  Future<Either<Failure, bool>> disconnectDevice() async {
    try {
      final result = await dataSource.disconnectDevice();
      return Right(result);
    } catch (e) {
      return Left(BluetoothFailure());
    }
  }

  @override
  Stream<BluetoothConnectionState> get connectionStateStream =>
      dataSource.connectionStateStream;
}
