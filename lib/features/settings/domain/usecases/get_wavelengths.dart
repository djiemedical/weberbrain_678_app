// lib/features/settings/domain/usecases/get_wavelengths.dart
import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../repositories/settings_repository.dart';

class GetWavelengths {
  final SettingsRepository repository;

  GetWavelengths(this.repository);

  Future<Either<Failure, Set<String>>> call() async {
    return await repository.getWavelengths();
  }
}
