// lib/features/settings/domain/usecases/get_output_power.dart
import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../repositories/settings_repository.dart';

class GetOutputPower {
  final SettingsRepository repository;

  GetOutputPower(this.repository);

  Future<Either<Failure, Map<String, int>>> call() async {
    return await repository.getOutputPower();
  }
}
