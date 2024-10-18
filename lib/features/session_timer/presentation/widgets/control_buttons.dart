// lib/features/session_timer/presentation/widgets/control_buttons.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:auto_route/auto_route.dart';
import '../bloc/session_timer_bloc.dart';
import '../../../../config/routes/app_router.dart';

class ControlButtons extends StatelessWidget {
  const ControlButtons({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SessionTimerBloc, SessionTimerState>(
      builder: (context, state) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (state is SessionTimerRunInProgress) ...[
              _ControlButton(
                icon: Icons.pause,
                onPressed: () =>
                    context.read<SessionTimerBloc>().add(PauseSession()),
              ),
              const SizedBox(width: 20),
              _ControlButton(
                icon: Icons.stop,
                onPressed: () => _showStopConfirmationDialog(context),
              ),
            ] else if (state is SessionTimerRunPause) ...[
              _ControlButton(
                icon: Icons.play_arrow,
                onPressed: () =>
                    context.read<SessionTimerBloc>().add(ResumeSession()),
              ),
              const SizedBox(width: 20),
              _ControlButton(
                icon: Icons.stop,
                onPressed: () => _showStopConfirmationDialog(context),
              ),
            ] else if (state is SessionTimerRunComplete) ...[
              _ControlButton(
                icon: Icons.replay,
                onPressed: () =>
                    context.read<SessionTimerBloc>().add(RepeatSession()),
              ),
            ],
          ],
        );
      },
    );
  }

  void _showStopConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Stop Session'),
          content: const Text('Are you sure you want to stop the session?'),
          actions: <Widget>[
            TextButton(
              child: const Text('No'),
              onPressed: () {
                Navigator.of(dialogContext).pop(); // Close the dialog
              },
            ),
            TextButton(
              child: const Text('Yes'),
              onPressed: () {
                Navigator.of(dialogContext).pop(); // Close the dialog
                context.read<SessionTimerBloc>().add(StopSession());
                context.router
                    .push(const HomeRoute()); // Navigate back to home page
              },
            ),
          ],
        );
      },
    );
  }
}

class _ControlButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;

  const _ControlButton({
    required this.icon,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        shape: const CircleBorder(),
        padding: const EdgeInsets.all(20),
        backgroundColor: const Color(0xFF2691A5),
      ),
      child: Icon(icon, size: 36, color: Colors.white),
    );
  }
}
