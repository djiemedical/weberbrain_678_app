// lib/features/settings/domain/usecases/set_regions.dart
import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../repositories/settings_repository.dart';

class SetRegions {
  final SettingsRepository repository;

  SetRegions(this.repository);

  Future<Either<Failure, void>> call(Set<String> regions) async {
    return await repository.setRegions(regions);
  }
}
