// Part: background_session_event.dart
part of 'background_session_bloc.dart';

abstract class BackgroundSessionEvent extends Equatable {
  const BackgroundSessionEvent();

  @override
  List<Object> get props => [];
}

class StartBackgroundSession extends BackgroundSessionEvent {
  final int duration;

  const StartBackgroundSession(this.duration);

  @override
  List<Object> get props => [duration];
}

class PauseBackgroundSession extends BackgroundSessionEvent {}

class ResumeBackgroundSession extends BackgroundSessionEvent {}

class StopBackgroundSession extends BackgroundSessionEvent {}

class UpdateBackgroundSession extends BackgroundSessionEvent {}
