// lib/features/power_monitoring/presentation/bloc/power_monitoring_bloc.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dartz/dartz.dart';
import '../../domain/entities/power_data.dart';
import '../../domain/repositories/power_monitoring_repository.dart';
import '../../../../core/error/failures.dart';
import 'power_monitoring_event.dart';
import 'power_monitoring_state.dart';

class PowerMonitoringBloc
    extends Bloc<PowerMonitoringEvent, PowerMonitoringState> {
  final PowerMonitoringRepository repository;

  PowerMonitoringBloc({required this.repository})
      : super(PowerMonitoringInitial()) {
    on<StartPowerMonitoring>(_onStartPowerMonitoring);
    on<StopPowerMonitoring>(_onStopPowerMonitoring);
  }

  Future<void> _onStartPowerMonitoring(
    StartPowerMonitoring event,
    Emitter<PowerMonitoringState> emit,
  ) async {
    emit(PowerMonitoringLoading());

    try {
      await emit.forEach<Either<Failure, PowerData>>(
        repository.getPowerData(),
        onData: (result) => result.fold(
          (failure) => PowerMonitoringError(),
          (powerData) {
            if (state is PowerMonitoringLoaded) {
              final currentState = state as PowerMonitoringLoaded;
              return PowerMonitoringLoaded(
                inputPower: powerData.inputPower,
                outputPower: powerData.outputPower,
                inputHistory: List<double>.from(
                        [...currentState.inputHistory, powerData.inputPower])
                    .take(20)
                    .toList(),
                outputHistory: List<double>.from(
                        [...currentState.outputHistory, powerData.outputPower])
                    .take(20)
                    .toList(),
              );
            }
            return PowerMonitoringLoaded(
              inputPower: powerData.inputPower,
              outputPower: powerData.outputPower,
              inputHistory: [powerData.inputPower],
              outputHistory: [powerData.outputPower],
            );
          },
        ),
      );
    } catch (e) {
      emit(PowerMonitoringError());
    }
  }

  void _onStopPowerMonitoring(
    StopPowerMonitoring event,
    Emitter<PowerMonitoringState> emit,
  ) {
    emit(PowerMonitoringInitial());
  }
}
