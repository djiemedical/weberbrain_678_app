// lib/features/settings/domain/usecases/get_output_power.dart
import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../repositories/settings_repository.dart';

class SetOutputPower {
  final SettingsRepository repository;

  SetOutputPower(this.repository);

  Future<Either<Failure, void>> call(Map<String, int> powerLevels) async {
    return await repository.setOutputPower(powerLevels);
  }
}
