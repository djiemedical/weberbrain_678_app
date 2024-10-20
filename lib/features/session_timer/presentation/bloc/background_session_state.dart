// Part: background_session_state.dart
part of 'background_session_bloc.dart';

class BackgroundSessionState extends Equatable {
  final int remainingDuration;
  final bool isRunning;
  final bool isCompleted;

  const BackgroundSessionState._({
    required this.remainingDuration,
    required this.isRunning,
    required this.isCompleted,
  });

  const BackgroundSessionState.initial()
      : this._(remainingDuration: 0, isRunning: false, isCompleted: false);

  const BackgroundSessionState.running(int duration)
      : this._(
            remainingDuration: duration, isRunning: true, isCompleted: false);

  const BackgroundSessionState.paused(int duration)
      : this._(
            remainingDuration: duration, isRunning: false, isCompleted: false);

  const BackgroundSessionState.completed()
      : this._(remainingDuration: 0, isRunning: false, isCompleted: true);

  BackgroundSessionState copyWith({
    int? remainingDuration,
    bool? isRunning,
    bool? isCompleted,
  }) {
    return BackgroundSessionState._(
      remainingDuration: remainingDuration ?? this.remainingDuration,
      isRunning: isRunning ?? this.isRunning,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }

  @override
  List<Object> get props => [remainingDuration, isRunning, isCompleted];
}
