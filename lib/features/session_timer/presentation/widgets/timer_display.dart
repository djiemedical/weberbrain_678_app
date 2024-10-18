// lib/features/session_timer/presentation/widgets/timer_display.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/session_timer_bloc.dart';

class TimerDisplay extends StatelessWidget {
  const TimerDisplay({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SessionTimerBloc, SessionTimerState>(
      builder: (context, state) {
        final duration = state is SessionTimerRunInProgress
            ? state.duration
            : state is SessionTimerRunPause
                ? state.duration
                : const Duration(seconds: 0);
        final minutes =
            duration.inMinutes.remainder(60).toString().padLeft(2, '0');
        final seconds =
            duration.inSeconds.remainder(60).toString().padLeft(2, '0');
        return Text(
          '$minutes:$seconds',
          style: const TextStyle(
            fontSize: 80,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        );
      },
    );
  }
}
