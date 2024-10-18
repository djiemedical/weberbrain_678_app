// lib/features/my_device/domain/usecases/scan_devices.dart
import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/ble_device.dart';
import '../repositories/my_device_repository.dart';

class ScanDevices implements UseCase<List<BleDevice>, NoParams> {
  final MyDeviceRepository repository;

  ScanDevices(this.repository);

  @override
  Future<Either<Failure, List<BleDevice>>> call(NoParams params) {
    return repository.scanDevices();
  }
}
