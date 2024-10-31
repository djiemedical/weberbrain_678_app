// lib/features/power_monitoring/presentation/widgets/power_chart.dart
import 'package:flutter/material.dart';

class PowerChart extends StatelessWidget {
  final List<double> data;
  final Color? lineColor;
  final double strokeWidth;

  const PowerChart({
    super.key,
    required this.data,
    this.lineColor,
    this.strokeWidth = 2,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size.infinite,
      painter: PowerChartPainter(
        dataPoints: data,
        color: lineColor ?? const Color(0xFF2691A5),
        strokeWidth: strokeWidth,
      ),
    );
  }
}

class PowerChartPainter extends CustomPainter {
  final List<double> dataPoints;
  final Color color;
  final double strokeWidth;

  PowerChartPainter({
    required this.dataPoints,
    required this.color,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (dataPoints.isEmpty) return;

    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke;

    final shadowPaint = Paint()
      ..color = color.withOpacity(0.1)
      ..strokeWidth = strokeWidth
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3)
      ..style = PaintingStyle.stroke;

    final path = Path();
    final width = size.width;
    final height = size.height;
    final horizontalStep = width / (dataPoints.length - 1);

    // Calculate min and max for scaling
    final maxValue =
        dataPoints.reduce((max, value) => value > max ? value : max);
    final minValue =
        dataPoints.reduce((min, value) => value < min ? value : min);
    final range = (maxValue - minValue).abs();

    // Add padding to the visualization
    const paddingPercent = 0.1;
    final paddedMin = minValue - (range * paddingPercent);
    final paddedMax = maxValue + (range * paddingPercent);
    final paddedRange = (paddedMax - paddedMin).abs();

    for (var i = 0; i < dataPoints.length; i++) {
      final x = i * horizontalStep;
      final normalizedValue = (dataPoints[i] - paddedMin) / paddedRange;
      final y = height - (normalizedValue * height);

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        final prevX = (i - 1) * horizontalStep;
        final prevY =
            height - ((dataPoints[i - 1] - paddedMin) / paddedRange * height);

        // Use quadratic bezier curves for smoother lines
        final controlX = (x + prevX) / 2;
        path.quadraticBezierTo(controlX, prevY, x, y);
      }
    }

    // Draw shadow
    canvas.drawPath(path, shadowPaint);
    // Draw line
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(PowerChartPainter oldDelegate) {
    return oldDelegate.dataPoints != dataPoints ||
        oldDelegate.color != color ||
        oldDelegate.strokeWidth != strokeWidth;
  }
}
