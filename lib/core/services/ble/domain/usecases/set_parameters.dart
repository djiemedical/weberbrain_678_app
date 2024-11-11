// lib/core/services/ble/domain/usecases/set_parameters.dart
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../../core/error/failures.dart';
import '../../../../../core/usecases/usecase.dart';
import '../repositories/ble_repository.dart';

class SetParametersParams extends Equatable {
  final String region;
  final Map<String, int> outputPower;
  final int frequency;

  const SetParametersParams({
    required this.region,
    required this.outputPower,
    required this.frequency,
  });

  @override
  List<Object> get props => [region, outputPower, frequency];
}

class SetParameters implements UseCase<bool, SetParametersParams> {
  final BleRepository repository;

  SetParameters(this.repository);

  @override
  Future<Either<Failure, bool>> call(SetParametersParams params) {
    return repository.setParameters(params);
  }
}
