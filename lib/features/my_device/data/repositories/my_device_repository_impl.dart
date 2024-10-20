// lib/features/my_device/data/repositories/my_device_repository_impl.dart
import 'package:weberbrain_678_app/features/my_device/domain/entities/ble_device.dart';
import 'package:weberbrain_678_app/features/my_device/domain/repositories/my_device_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:weberbrain_678_app/core/error/failures.dart';
import 'package:weberbrain_678_app/features/my_device/data/datasources/ble_device_data_source.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

class MyDeviceRepositoryImpl implements MyDeviceRepository {
  final BleDeviceDataSource dataSource;

  MyDeviceRepositoryImpl({required this.dataSource});

  @override
  Future<Either<Failure, List<BleDevice>>> scanDevices() async {
    try {
      final devices = await dataSource.scanDevices();
      return Right(devices);
    } catch (e) {
      return Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, bool>> connectDevice(BleDevice device) async {
    try {
      final result = await dataSource.connectDevice(device);
      return Right(result);
    } catch (e) {
      return Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, bool>> disconnectDevice() async {
    try {
      await dataSource.disconnectDevice();
      return const Right(true);
    } catch (e) {
      return Left(ServerFailure());
    }
  }

  @override
  Stream<BluetoothConnectionState> get connectionStateStream {
    return dataSource.connectionStateStream;
  }
}
