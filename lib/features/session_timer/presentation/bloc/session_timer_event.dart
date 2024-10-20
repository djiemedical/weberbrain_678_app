// Part file: session_timer_event.dart
part of 'session_timer_bloc.dart';

abstract class SessionTimerEvent extends Equatable {
  const SessionTimerEvent();

  @override
  List<Object> get props => [];
}

class StartSession extends SessionTimerEvent {}

class PauseSession extends SessionTimerEvent {}

class ResumeSession extends SessionTimerEvent {}

class ResetSession extends SessionTimerEvent {}

class TickSession extends SessionTimerEvent {}
