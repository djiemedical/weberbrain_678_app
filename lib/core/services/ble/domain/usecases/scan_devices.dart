// lib/core/services/ble/domain/usecases/scan_devices.dart
import 'package:dartz/dartz.dart';
import '../../../../../core/error/failures.dart';
import '../../../../../core/usecases/usecase.dart';
import '../repositories/ble_repository.dart';
import '../entities/ble_device.dart';

class ScanDevices extends UseCase<List<BleDevice>, NoParams> {
  final BleRepository repository;

  ScanDevices(this.repository);

  @override
  Future<Either<Failure, List<BleDevice>>> call(NoParams params) {
    return repository.scanDevices();
  }
}
