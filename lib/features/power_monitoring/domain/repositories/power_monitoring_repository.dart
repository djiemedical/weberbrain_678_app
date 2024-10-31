// lib/features/power_monitoring/domain/repositories/power_monitoring_repository.dart
import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/power_data.dart';

abstract class PowerMonitoringRepository {
  Stream<Either<Failure, PowerData>> getPowerData();
}
