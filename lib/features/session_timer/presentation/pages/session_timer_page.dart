// lib/features/session_timer/presentation/pages/session_timer_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:auto_route/auto_route.dart';
import '../bloc/session_timer_bloc.dart';
import '../widgets/timer_display.dart';
import '../widgets/control_buttons.dart';
import '../../../../config/routes/app_router.dart';

@RoutePage()
class SessionTimerPage extends StatelessWidget {
  final int durationInSeconds;

  const SessionTimerPage(
      {super.key,
      @PathParam('durationInSeconds') required this.durationInSeconds});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => SessionTimerBloc(initialDuration: durationInSeconds)
        ..add(StartSession(Duration(seconds: durationInSeconds))),
      child: BlocListener<SessionTimerBloc, SessionTimerState>(
        listener: (context, state) {
          if (state is SessionTimerRunComplete) {
            _showSessionCompleteDialog(context);
          }
        },
        child: Scaffold(
          appBar: AppBar(
            title: const Text('Session Timer'),
            backgroundColor: const Color(0xFF1F2225),
          ),
          backgroundColor: const Color(0xFF1F2225),
          body: const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TimerDisplay(),
                SizedBox(height: 40),
                ControlButtons(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showSessionCompleteDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Session Complete'),
          content: const Text(
              'Your session has finished. What would you like to do?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Home'),
              onPressed: () {
                Navigator.of(dialogContext).pop();
                context.router.push(const HomeRoute());
              },
            ),
            TextButton(
              child: const Text('Repeat'),
              onPressed: () {
                Navigator.of(dialogContext).pop();
                context.read<SessionTimerBloc>().add(RepeatSession());
              },
            ),
          ],
        );
      },
    );
  }
}
