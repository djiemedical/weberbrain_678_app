// lib/features/power_monitoring/presentation/bloc/power_monitoring_bloc.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dartz/dartz.dart';
import '../../domain/repositories/power_monitoring_repository.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/power_data.dart';
import 'power_monitoring_event.dart';
import 'power_monitoring_state.dart';

class PowerMonitoringBloc
    extends Bloc<PowerMonitoringEvent, PowerMonitoringState> {
  final PowerMonitoringRepository repository;

  PowerMonitoringBloc({required this.repository})
      : super(PowerMonitoringInitial()) {
    on<PowerMonitoringStarted>(_onStarted);
    on<PowerMonitoringUpdated>(_onUpdated);
    on<PowerMonitoringStopped>(_onStopped);
  }

  Future<void> _onStarted(
    PowerMonitoringStarted event,
    Emitter<PowerMonitoringState> emit,
  ) async {
    emit(PowerMonitoringLoading());
    try {
      await emit.forEach<Either<Failure, PowerData>>(
        repository.getPowerData(),
        onData: (result) => result.fold(
          (failure) => PowerMonitoringError(failure.toString()),
          (powerData) => PowerMonitoringLoaded(
            powerLevels: {
              '650nm': powerData.powerLevels['650nm'] ?? 0.0,
              '808nm': powerData.powerLevels['808nm'] ?? 0.0,
              '1064nm': powerData.powerLevels['1064nm'] ?? 0.0,
            },
          ),
        ),
      );
    } catch (e) {
      emit(PowerMonitoringError(e.toString()));
    }
  }

  void _onUpdated(
    PowerMonitoringUpdated event,
    Emitter<PowerMonitoringState> emit,
  ) {
    if (state is PowerMonitoringLoaded) {
      emit(PowerMonitoringLoaded(powerLevels: event.powerLevels));
    }
  }

  void _onStopped(
    PowerMonitoringStopped event,
    Emitter<PowerMonitoringState> emit,
  ) {
    emit(PowerMonitoringInitial());
  }
}
