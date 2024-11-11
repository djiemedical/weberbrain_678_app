// lib/core/services/ble/domain/usecases/disconnect_device.dart
import 'package:dartz/dartz.dart';
import 'package:weberbrain_678_app/core/usecases/usecase.dart';
import 'package:weberbrain_678_app/core/services/ble/domain/repositories/ble_repository.dart';
import 'package:weberbrain_678_app/core/error/failures.dart';

class DisconnectDevice implements UseCase<bool, NoParams> {
  final BleRepository repository;

  DisconnectDevice(this.repository);

  @override
  Future<Either<Failure, bool>> call(NoParams params) {
    return repository.disconnectDevice();
  }
}
