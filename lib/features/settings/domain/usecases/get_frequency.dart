// lib/features/settings/domain/usecases/get_frequency.dart
import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../repositories/settings_repository.dart';

class GetFrequency {
  final SettingsRepository repository;

  GetFrequency(this.repository);

  Future<Either<Failure, int>> call() async {
    return await repository.getFrequency();
  }
}
