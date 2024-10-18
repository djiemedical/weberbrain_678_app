part of 'session_timer_bloc.dart';

abstract class SessionTimerEvent extends Equatable {
  const SessionTimerEvent();

  @override
  List<Object> get props => [];
}

class StartSession extends SessionTimerEvent {
  final Duration duration;

  const StartSession(this.duration);

  @override
  List<Object> get props => [duration];
}

class PauseSession extends SessionTimerEvent {}

class ResumeSession extends SessionTimerEvent {}

class StopSession extends SessionTimerEvent {}

class RepeatSession extends SessionTimerEvent {}

class _TimerTick extends SessionTimerEvent {}
