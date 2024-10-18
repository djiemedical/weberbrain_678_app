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
      : super(SessionTimerInitial()) {
    on<StartSession>(_onStartSession);
    on<PauseSession>(_onPauseSession);
    on<ResumeSession>(_onResumeSession);
    on<StopSession>(_onStopSession);
    on<RepeatSession>(_onRepeatSession);
    on<_TimerTick>(_onTimerTick);
  }

  void _onStartSession(StartSession event, Emitter<SessionTimerState> emit) {
    emit(SessionTimerRunInProgress(event.duration));
    _startTimer(event.duration);
  }

  void _onPauseSession(PauseSession event, Emitter<SessionTimerState> emit) {
    if (state is SessionTimerRunInProgress) {
      _timer?.cancel();
      emit(SessionTimerRunPause((state as SessionTimerRunInProgress).duration));
    }
  }

  void _onResumeSession(ResumeSession event, Emitter<SessionTimerState> emit) {
    if (state is SessionTimerRunPause) {
      emit(SessionTimerRunInProgress((state as SessionTimerRunPause).duration));
      _startTimer((state as SessionTimerRunPause).duration);
    }
  }

  void _onStopSession(StopSession event, Emitter<SessionTimerState> emit) {
    _timer?.cancel();
    emit(SessionTimerRunComplete());
  }

  void _onRepeatSession(RepeatSession event, Emitter<SessionTimerState> emit) {
    emit(SessionTimerRunInProgress(Duration(seconds: initialDuration)));
    _startTimer(Duration(seconds: initialDuration));
  }

  void _onTimerTick(_TimerTick event, Emitter<SessionTimerState> emit) {
    if (state is SessionTimerRunInProgress) {
      final newDuration = (state as SessionTimerRunInProgress).duration -
          const Duration(seconds: 1);
      if (newDuration.inSeconds > 0) {
        emit(SessionTimerRunInProgress(newDuration));
      } else {
        _timer?.cancel();
        emit(SessionTimerRunComplete());
      }
    }
  }

  void _startTimer(Duration duration) {
    _timer?.cancel();
    _timer = Timer.periodic(
      const Duration(seconds: 1),
      (timer) => add(_TimerTick()),
    );
  }

  @override
  Future<void> close() {
    _timer?.cancel();
    return super.close();
  }
}
