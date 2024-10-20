// lib/features/session_timer/presentation/widgets/circular_timer_display.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:math';
import '../bloc/background_session_bloc.dart';

class CircularTimerDisplay extends StatelessWidget {
  const CircularTimerDisplay({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BackgroundSessionBloc, BackgroundSessionState>(
      builder: (context, state) {
        final totalDuration =
            context.read<BackgroundSessionBloc>().initialDuration;
        final progress =
            totalDuration > 0 ? state.remainingDuration / totalDuration : 0.0;
        return Stack(
          alignment: Alignment.center,
          children: [
            CustomPaint(
              size: const Size(300, 300),
              painter: CircularTimerPainter(
                progress: progress,
                colors: const [
                  Color(0xFF7B1E1E),
                  Color(0xFF5E3AB3),
                  Color(0xFFE55F48),
                ],
              ),
            ),
            Text(
              _formatDuration(state.remainingDuration),
              style: const TextStyle(
                fontSize: 48,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        );
      },
    );
  }

  String _formatDuration(int seconds) {
    final minutes = (seconds / 60).floor();
    final remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }
}

class CircularTimerPainter extends CustomPainter {
  final double progress;
  final List<Color> colors;

  CircularTimerPainter({required this.progress, required this.colors});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = min(size.width, size.height) / 2;

    for (int i = 0; i < 3; i++) {
      final paint = Paint()
        ..color = colors[i]
        ..style = PaintingStyle.stroke
        ..strokeWidth = 10.0
        ..strokeCap = StrokeCap.round;

      final sweepAngle = 2 * pi * progress;
      final startAngle = -pi / 2 + (i * 2 * pi / 3);

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius - (i * 20)),
        startAngle,
        sweepAngle,
        false,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}
