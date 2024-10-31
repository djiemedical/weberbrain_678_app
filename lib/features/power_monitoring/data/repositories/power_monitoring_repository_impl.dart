// lib/features/power_monitoring/data/repositories/power_monitoring_repository_impl.dart
import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/power_data.dart';
import '../../domain/repositories/power_monitoring_repository.dart';
import '../datasources/power_monitoring_data_source.dart';

class PowerMonitoringRepositoryImpl implements PowerMonitoringRepository {
  final PowerMonitoringDataSource dataSource;

  PowerMonitoringRepositoryImpl({required this.dataSource});

  @override
  Stream<Either<Failure, PowerData>> getPowerData() async* {
    try {
      await for (final powerData in dataSource.getPowerData()) {
        yield Right(powerData);
      }
    } catch (e) {
      yield Left(DeviceFailure());
    }
  }
}
