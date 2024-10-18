// lib/features/session_timer/presentation/bloc/session_timer_state.dart
part of 'session_timer_bloc.dart';

abstract class SessionTimerState extends Equatable {
  const SessionTimerState();

  @override
  List<Object> get props => [];
}

class SessionTimerInitial extends SessionTimerState {}

class SessionTimerRunInProgress extends SessionTimerState {
  final Duration duration;

  const SessionTimerRunInProgress(this.duration);

  @override
  List<Object> get props => [duration];
}

class SessionTimerRunPause extends SessionTimerState {
  final Duration duration;

  const SessionTimerRunPause(this.duration);

  @override
  List<Object> get props => [duration];
}

class SessionTimerRunComplete extends SessionTimerState {}
