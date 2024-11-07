// lib/features/power_monitoring/presentation/bloc/power_monitoring_event.dart
import 'package:equatable/equatable.dart';

abstract class PowerMonitoringEvent extends Equatable {
  const PowerMonitoringEvent();

  @override
  List<Object?> get props => [];
}

class PowerMonitoringStarted extends PowerMonitoringEvent {
  const PowerMonitoringStarted();
}

class PowerMonitoringUpdated extends PowerMonitoringEvent {
  final Map<String, double> powerLevels;

  const PowerMonitoringUpdated(this.powerLevels);

  @override
  List<Object?> get props => [powerLevels];
}

class PowerMonitoringStopped extends PowerMonitoringEvent {
  const PowerMonitoringStopped();
}
