// lib/features/settings/domain/usecases/set_wavelengths.dart
import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../repositories/settings_repository.dart';

class SetWavelengths {
  final SettingsRepository repository;

  SetWavelengths(this.repository);

  Future<Either<Failure, void>> call(Set<String> wavelengths) async {
    return await repository.setWavelengths(wavelengths);
  }
}
