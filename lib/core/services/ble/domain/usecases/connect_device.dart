// lib/core/services/ble/domain/usecases/connect_device.dart
import 'package:dartz/dartz.dart';
import 'package:weberbrain_678_app/core/usecases/usecase.dart';
import 'package:weberbrain_678_app/core/error/failures.dart';
import 'package:weberbrain_678_app/core/services/ble/domain/entities/ble_device.dart';
import 'package:weberbrain_678_app/core/services/ble/domain/repositories/ble_repository.dart';

class ConnectDevice implements UseCase<bool, BleDevice> {
  final BleRepository repository;

  ConnectDevice(this.repository);

  @override
  Future<Either<Failure, bool>> call(BleDevice params) {
    return repository.connectDevice(params);
  }
}
