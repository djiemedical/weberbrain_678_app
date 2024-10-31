// lib/features/power_monitoring/presentation/bloc/power_monitoring_event.dart
import 'package:equatable/equatable.dart';

abstract class PowerMonitoringEvent extends Equatable {
  const PowerMonitoringEvent();

  @override
  List<Object> get props => [];
}

class StartPowerMonitoring extends PowerMonitoringEvent {
  const StartPowerMonitoring();
}

class StopPowerMonitoring extends PowerMonitoringEvent {
  const StopPowerMonitoring();
}
