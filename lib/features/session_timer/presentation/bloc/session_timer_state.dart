// Part file: session_timer_state.dart
part of 'session_timer_bloc.dart';

abstract class SessionTimerState extends Equatable {
  final int duration;

  const SessionTimerState(this.duration);

  @override
  List<Object> get props => [duration];
}

class SessionTimerInitial extends SessionTimerState {
  const SessionTimerInitial(super.duration);
}

class SessionTimerRunInProgress extends SessionTimerState {
  const SessionTimerRunInProgress(super.duration);
}

class SessionTimerRunPause extends SessionTimerState {
  const SessionTimerRunPause(super.duration);
}

class SessionTimerRunComplete extends SessionTimerState {
  const SessionTimerRunComplete() : super(0);
}
