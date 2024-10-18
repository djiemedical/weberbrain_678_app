// lib/features/my_device/domain/usecases/connect_device.dart
import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/ble_device.dart';
import '../repositories/my_device_repository.dart';

class ConnectDevice implements UseCase<bool, BleDevice> {
  final MyDeviceRepository repository;

  ConnectDevice(this.repository);

  @override
  Future<Either<Failure, bool>> call(BleDevice params) {
    return repository.connectDevice(params);
  }
}
