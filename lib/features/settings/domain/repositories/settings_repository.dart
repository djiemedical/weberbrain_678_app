// lib/features/settings/domain/repositories/settings_repository.dart
import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';

abstract class SettingsRepository {
  Future<Either<Failure, Set<String>>> getRegions();
  Future<Either<Failure, void>> setRegions(Set<String> regions);
  Future<Either<Failure, Set<String>>> getWavelengths();
  Future<Either<Failure, void>> setWavelengths(Set<String> wavelengths);
  Future<Either<Failure, Map<String, int>>> getOutputPower();
  Future<Either<Failure, void>> setOutputPower(Map<String, int> powerLevels);
  Future<Either<Failure, int>> getFrequency();
  Future<Either<Failure, void>> setFrequency(int frequency);
}
