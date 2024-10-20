// lib/features/settings/domain/usecases/set_frequency.dart
import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../repositories/settings_repository.dart';

class SetFrequency {
  final SettingsRepository repository;

  SetFrequency(this.repository);

  Future<Either<Failure, void>> call(int frequency) async {
    return await repository.setFrequency(frequency);
  }
}
