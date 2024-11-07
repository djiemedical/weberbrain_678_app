// lib/features/power_monitoring/data/repositories/power_monitoring_repository_impl.dart
import 'package:dartz/dartz.dart';
import 'package:logger/logger.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/power_data.dart';
import '../../domain/repositories/power_monitoring_repository.dart';
import '../datasources/power_monitoring_data_source.dart';
import '../config/power_monitoring_constants.dart';

class PowerMonitoringRepositoryImpl implements PowerMonitoringRepository {
  final PowerMonitoringDataSource dataSource;
  final _logger = Logger();

  PowerMonitoringRepositoryImpl({required this.dataSource});

  @override
  Stream<Either<Failure, PowerData>> getPowerData() async* {
    try {
      await for (final powerData in dataSource.getPowerData()) {
        if (_validatePowerData(powerData)) {
          yield Right(powerData);
        } else {
          _logger.w('Invalid power data received: ${powerData.powerLevels}');
          yield Left(InvalidDataFailure());
        }
      }
    } on DeviceConnectionException catch (e) {
      _logger.e('Device connection error: ${e.message}');
      yield Left(DeviceConnectionFailure());
    } on DeviceCommunicationException catch (e) {
      _logger.e('Device communication error: ${e.message}');
      yield Left(DeviceCommunicationFailure());
    } on InvalidPowerDataException catch (e) {
      _logger.e('Invalid power data error: ${e.message}');
      yield Left(InvalidDataFailure());
    } catch (e) {
      _logger.e('Unexpected error in power monitoring: $e');
      yield Left(UnexpectedFailure());
    }
  }

  bool _validatePowerData(PowerData data) {
    try {
      // Check if all required wavelengths are present
      if (!data.powerLevels.containsKey('650nm') ||
          !data.powerLevels.containsKey('808nm') ||
          !data.powerLevels.containsKey('1064nm')) {
        return false;
      }

      // Validate power levels
      for (final entry in data.powerLevels.entries) {
        final wavelength = entry.key;
        final power = entry.value;

        // Check if power is within valid range
        final maxPower =
            PowerMonitoringConstants.maxPowerLevels[wavelength] ?? 0.0;
        if (power < 0 || power > maxPower) {
          _logger.w('Power level out of range for $wavelength: $power');
          return false;
        }

        // Check for NaN or infinite values
        if (power.isNaN || power.isInfinite) {
          _logger.w('Invalid power value for $wavelength: $power');
          return false;
        }
      }

      // Validate timestamp
      if (data.timestamp
              .isAfter(DateTime.now().add(const Duration(minutes: 1))) ||
          data.timestamp
              .isBefore(DateTime.now().subtract(const Duration(minutes: 1)))) {
        _logger.w('Invalid timestamp: ${data.timestamp}');
        return false;
      }

      return true;
    } catch (e) {
      _logger.e('Error validating power data: $e');
      return false;
    }
  }
}

// Custom exceptions for better error handling
class DeviceConnectionException implements Exception {
  final String message;
  DeviceConnectionException(this.message);
}

class DeviceCommunicationException implements Exception {
  final String message;
  DeviceCommunicationException(this.message);
}

class InvalidPowerDataException implements Exception {
  final String message;
  InvalidPowerDataException(this.message);
}

// Failure classes
class DeviceConnectionFailure extends Failure {
  @override
  List<Object> get props => [];
}

class DeviceCommunicationFailure extends Failure {
  @override
  List<Object> get props => [];
}

class InvalidDataFailure extends Failure {
  @override
  List<Object> get props => [];
}

class UnexpectedFailure extends Failure {
  @override
  List<Object> get props => [];
}
