// lib/features/settings/data/repositories/settings_repository_impl.dart
import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../domain/repositories/settings_repository.dart';
import '../datasources/settings_local_data_source.dart';

class SettingsRepositoryImpl implements SettingsRepository {
  final SettingsLocalDataSource localDataSource;

  SettingsRepositoryImpl({required this.localDataSource});

  @override
  Future<Either<Failure, Set<String>>> getRegions() async {
    try {
      final regions = await localDataSource.getRegions();
      return Right(regions);
    } catch (e) {
      return Left(CacheFailure());
    }
  }

  @override
  Future<Either<Failure, void>> setRegions(Set<String> regions) async {
    try {
      await localDataSource.setRegions(regions);
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure());
    }
  }

  @override
  Future<Either<Failure, Set<String>>> getWavelengths() async {
    try {
      final wavelengths = await localDataSource.getWavelengths();
      return Right(wavelengths);
    } catch (e) {
      return Left(CacheFailure());
    }
  }

  @override
  Future<Either<Failure, void>> setWavelengths(Set<String> wavelengths) async {
    try {
      await localDataSource.setWavelengths(wavelengths);
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure());
    }
  }

  @override
  Future<Either<Failure, Map<String, int>>> getOutputPower() async {
    try {
      final outputPower = await localDataSource.getOutputPower();
      return Right(outputPower);
    } catch (e) {
      return Left(CacheFailure());
    }
  }

  @override
  Future<Either<Failure, void>> setOutputPower(
      Map<String, int> powerLevels) async {
    try {
      await localDataSource.setOutputPower(powerLevels);
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure());
    }
  }

  @override
  Future<Either<Failure, int>> getFrequency() async {
    try {
      final frequency = await localDataSource.getFrequency();
      return Right(frequency);
    } catch (e) {
      return Left(CacheFailure());
    }
  }

  @override
  Future<Either<Failure, void>> setFrequency(int frequency) async {
    try {
      await localDataSource.setFrequency(frequency);
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure());
    }
  }
}
