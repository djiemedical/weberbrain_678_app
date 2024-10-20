// lib/features/session_timer/presentation/widgets/control_buttons.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:auto_route/auto_route.dart';
import '../bloc/background_session_bloc.dart';
import '../../../../config/routes/app_router.dart';

class ControlButtons extends StatelessWidget {
  const ControlButtons({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BackgroundSessionBloc, BackgroundSessionState>(
      builder: (context, state) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            _buildButton(
              context,
              icon: state.isRunning ? Icons.pause : Icons.play_arrow,
              color: const Color(0xFF2691A5),
              onPressed: () {
                if (state.isRunning) {
                  context
                      .read<BackgroundSessionBloc>()
                      .add(PauseBackgroundSession());
                } else {
                  context
                      .read<BackgroundSessionBloc>()
                      .add(ResumeBackgroundSession());
                }
              },
            ),
            _buildButton(
              context,
              icon: Icons.stop,
              color: const Color(0xFF2691A5),
              onPressed: () => _showStopConfirmationDialog(context),
            ),
          ],
        );
      },
    );
  }

  Widget _buildButton(BuildContext context,
      {required IconData icon,
      required Color color,
      required VoidCallback onPressed}) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        padding: const EdgeInsets.all(20),
      ),
      child: Icon(icon, size: 32, color: Colors.white),
    );
  }

  void _showStopConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          backgroundColor: const Color(0xFF2A2D30),
          title:
              const Text('Stop Session', style: TextStyle(color: Colors.white)),
          content: const Text(
              'Are you sure you want to stop the current session?',
              style: TextStyle(color: Colors.white)),
          actions: <Widget>[
            TextButton(
              child:
                  const Text('No', style: TextStyle(color: Color(0xFF2691A5))),
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
            ),
            TextButton(
              child:
                  const Text('Yes', style: TextStyle(color: Color(0xFF2691A5))),
              onPressed: () {
                context
                    .read<BackgroundSessionBloc>()
                    .add(StopBackgroundSession());
                Navigator.of(dialogContext).pop();
                context.router.replace(const HomeRoute());
              },
            ),
          ],
        );
      },
    );
  }
}
