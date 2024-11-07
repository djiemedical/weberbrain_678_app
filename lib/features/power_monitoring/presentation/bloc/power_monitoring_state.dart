// lib/features/power_monitoring/presentation/bloc/power_monitoring_state.dart
import 'package:equatable/equatable.dart';

abstract class PowerMonitoringState extends Equatable {
  const PowerMonitoringState();

  @override
  List<Object?> get props => [];
}

class PowerMonitoringInitial extends PowerMonitoringState {}

class PowerMonitoringLoading extends PowerMonitoringState {}

class PowerMonitoringError extends PowerMonitoringState {
  final String? message;

  const PowerMonitoringError([this.message]);

  @override
  List<Object?> get props => [message];
}

class PowerMonitoringLoaded extends PowerMonitoringState {
  final Map<String, double> powerLevels;
  final String? errorMessage;

  const PowerMonitoringLoaded({
    required this.powerLevels,
    this.errorMessage,
  });

  @override
  List<Object?> get props => [powerLevels, errorMessage];

  PowerMonitoringLoaded copyWith({
    Map<String, double>? powerLevels,
    String? errorMessage,
  }) {
    return PowerMonitoringLoaded(
      powerLevels: powerLevels ?? this.powerLevels,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}
