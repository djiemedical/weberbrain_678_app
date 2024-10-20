// lib/features/my_device/domain/usecases/disconnect_device.dart
import 'package:dartz/dartz.dart';
import 'package:weberbrain_678_app/core/error/failures.dart';
import 'package:weberbrain_678_app/core/usecases/usecase.dart';
import 'package:weberbrain_678_app/features/my_device/domain/repositories/my_device_repository.dart';

class DisconnectDevice implements UseCase<void, NoParams> {
  final MyDeviceRepository repository;

  DisconnectDevice(this.repository);

  @override
  Future<Either<Failure, void>> call(NoParams params) async {
    return await repository.disconnectDevice();
  }
}