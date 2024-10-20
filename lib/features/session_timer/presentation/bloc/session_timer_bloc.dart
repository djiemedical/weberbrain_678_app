// lib/features/session_timer/presentation/bloc/session_timer_bloc.dart
import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

part 'session_timer_event.dart';
part 'session_timer_state.dart';

class SessionTimerBloc extends Bloc<SessionTimerEvent, SessionTimerState> {
  Timer? _timer;
  final int initialDuration;

  SessionTimerBloc({required this.initialDuration})
      : super(SessionTimerInitial(initialDuration)) {
    on<StartSession>(_onStartSession);
    on<PauseSession>(_onPauseSession);
    on<ResumeSession>(_onResumeSession);
    on<ResetSession>(_onResetSession);
    on<TickSession>(_onTickSession);
  }

  void _onStartSession(StartSession event, Emitter<SessionTimerState> emit) {
    emit(SessionTimerRunInProgress(initialDuration));
    _startTimer();
  }

  void _onPauseSession(PauseSession event, Emitter<SessionTimerState> emit) {
    if (state is SessionTimerRunInProgress) {
      _timer?.cancel();
      emit(SessionTimerRunPause(state.duration));
    }
  }

  void _onResumeSession(ResumeSession event, Emitter<SessionTimerState> emit) {
    if (state is SessionTimerRunPause) {
      emit(SessionTimerRunInProgress(state.duration));
      _startTimer();
    }
  }

  void _onResetSession(ResetSession event, Emitter<SessionTimerState> emit) {
    _timer?.cancel();
    emit(SessionTimerInitial(initialDuration));
  }

  void _onTickSession(TickSession event, Emitter<SessionTimerState> emit) {
    if (state is SessionTimerRunInProgress) {
      final newDuration = state.duration - 1;
      if (newDuration > 0) {
        emit(SessionTimerRunInProgress(newDuration));
      } else {
        _timer?.cancel();
        emit(const SessionTimerRunComplete());
      }
    }
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      add(TickSession());
    });
  }

  @override
  Future<void> close() {
    _timer?.cancel();
    return super.close();
  }
}
