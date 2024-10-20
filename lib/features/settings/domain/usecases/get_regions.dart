// lib/features/settings/domain/usecases/get_regions.dart
import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../repositories/settings_repository.dart';

class GetRegions {
  final SettingsRepository repository;

  GetRegions(this.repository);

  Future<Either<Failure, Set<String>>> call() async {
    return await repository.getRegions();
  }
}
