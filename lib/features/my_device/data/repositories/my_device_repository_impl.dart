// lib/features/my_device/data/repositories/my_device_repository_impl.dart
import 'package:weberbrain_678_app/core/services/ble/domain/repositories/ble_repository.dart';
import 'package:weberbrain_678_app/core/services/ble/domain/entities/ble_device.dart'
    as core_ble;
import 'package:weberbrain_678_app/features/my_device/domain/entities/ble_device.dart';
import 'package:weberbrain_678_app/features/my_device/domain/repositories/my_device_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:weberbrain_678_app/core/error/failures.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

class MyDeviceRepositoryImpl implements MyDeviceRepository {
  final BleRepository bleRepository;

  MyDeviceRepositoryImpl({required this.bleRepository});

  @override
  Future<Either<Failure, List<BleDevice>>> scanDevices() async {
    final result = await bleRepository.scanDevices();
    return result.fold(
      (failure) => Left(failure),
      (devices) => Right(devices
          .map((device) => BleDevice(id: device.id, name: device.name, rssi: device.rssi))
          .toList()),
    );
  }

  @override
  Future<Either<Failure, bool>> connectDevice(BleDevice device) async {
    final coreDevice = core_ble.BleDevice(
      id: device.id,
      name: device.name,
    );
    return bleRepository.connectDevice(coreDevice);
  }

  @override
  Future<Either<Failure, bool>> disconnectDevice() {
    return bleRepository.disconnectDevice();
  }

  @override
  Stream<BluetoothConnectionState> get connectionStateStream {
    return bleRepository.connectionStateStream;
  }
}
