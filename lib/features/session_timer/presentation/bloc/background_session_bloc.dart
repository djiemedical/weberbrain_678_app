// lib/features/session_timer/presentation/bloc/background_session_bloc.dart
import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

part 'background_session_event.dart';
part 'background_session_state.dart';

class BackgroundSessionBloc
    extends Bloc<BackgroundSessionEvent, BackgroundSessionState> {
  Timer? _timer;
  int initialDuration = 0;

  BackgroundSessionBloc() : super(const BackgroundSessionState.initial()) {
    on<StartBackgroundSession>(_onStartBackgroundSession);
    on<PauseBackgroundSession>(_onPauseBackgroundSession);
    on<ResumeBackgroundSession>(_onResumeBackgroundSession);
    on<StopBackgroundSession>(_onStopBackgroundSession);
    on<UpdateBackgroundSession>(_onUpdateBackgroundSession);
  }

  void _onStartBackgroundSession(
      StartBackgroundSession event, Emitter<BackgroundSessionState> emit) {
    _timer?.cancel();
    initialDuration = event.duration;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      add(UpdateBackgroundSession());
    });
    emit(BackgroundSessionState.running(event.duration));
  }

  void _onPauseBackgroundSession(
      PauseBackgroundSession event, Emitter<BackgroundSessionState> emit) {
    _timer?.cancel();
    emit(BackgroundSessionState.paused(state.remainingDuration));
  }

  void _onResumeBackgroundSession(
      ResumeBackgroundSession event, Emitter<BackgroundSessionState> emit) {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      add(UpdateBackgroundSession());
    });
    emit(BackgroundSessionState.running(state.remainingDuration));
  }

  void _onStopBackgroundSession(
      StopBackgroundSession event, Emitter<BackgroundSessionState> emit) {
    _timer?.cancel();
    emit(const BackgroundSessionState.initial());
  }

  void _onUpdateBackgroundSession(
      UpdateBackgroundSession event, Emitter<BackgroundSessionState> emit) {
    if (state.isRunning && state.remainingDuration > 0) {
      emit(state.copyWith(remainingDuration: state.remainingDuration - 1));
    } else if (state.isRunning && state.remainingDuration == 0) {
      _timer?.cancel();
      emit(const BackgroundSessionState.completed());
    }
  }

  @override
  Future<void> close() {
    _timer?.cancel();
    return super.close();
  }
}
