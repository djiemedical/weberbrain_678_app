// lib/features/power_monitoring/domain/entities/power_data.dart
import 'package:equatable/equatable.dart';

class PowerData extends Equatable {
  final double inputPower;
  final double outputPower;
  final DateTime timestamp;

  const PowerData({
    required this.inputPower,
    required this.outputPower,
    required this.timestamp,
  });

  @override
  List<Object> get props => [inputPower, outputPower, timestamp];
}
