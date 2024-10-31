// lib/features/power_monitoring/presentation/bloc/power_monitoring_state.dart
import 'package:equatable/equatable.dart';

abstract class PowerMonitoringState extends Equatable {
  const PowerMonitoringState();

  @override
  List<Object> get props => [];
}

class PowerMonitoringInitial extends PowerMonitoringState {}

class PowerMonitoringLoading extends PowerMonitoringState {}

class PowerMonitoringError extends PowerMonitoringState {}

class PowerMonitoringLoaded extends PowerMonitoringState {
  final double inputPower;
  final double outputPower;
  final List<double> inputHistory;
  final List<double> outputHistory;

  const PowerMonitoringLoaded({
    required this.inputPower,
    required this.outputPower,
    required this.inputHistory,
    required this.outputHistory,
  });

  PowerMonitoringLoaded copyWith({
    double? inputPower,
    double? outputPower,
    List<double>? inputHistory,
    List<double>? outputHistory,
  }) {
    return PowerMonitoringLoaded(
      inputPower: inputPower ?? this.inputPower,
      outputPower: outputPower ?? this.outputPower,
      inputHistory: inputHistory ?? this.inputHistory,
      outputHistory: outputHistory ?? this.outputHistory,
    );
  }

  @override
  List<Object> get props =>
      [inputPower, outputPower, inputHistory, outputHistory];
}
