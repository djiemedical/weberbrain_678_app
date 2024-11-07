// lib/features/power_monitoring/domain/entities/power_data.dart
import 'package:equatable/equatable.dart';

class PowerData extends Equatable {
  final Map<String, double> powerLevels;
  final DateTime timestamp;

  const PowerData({
    required this.powerLevels,
    required this.timestamp,
  });

  @override
  List<Object> get props => [powerLevels, timestamp];
}
