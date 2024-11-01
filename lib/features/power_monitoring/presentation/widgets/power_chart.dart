// lib/features/power_monitoring/presentation/widgets/power_chart.dart
import 'package:flutter/material.dart';
import 'package:collection/collection.dart';

class PowerChart extends StatefulWidget {
  final List<double> data;
  final Color? lineColor;
  final double strokeWidth;
  final Duration animationDuration;

  const PowerChart({
    super.key,
    required this.data,
    this.lineColor,
    this.strokeWidth = 2,
    this.animationDuration = const Duration(milliseconds: 300),
  });

  @override
  State<PowerChart> createState() => _PowerChartState();
}

class _PowerChartState extends State<PowerChart>
    with SingleTickerProviderStateMixin {
  late List<double> _previousData;
  late List<double> _currentData;
  late AnimationController _animationController;
  late Animation<double> _animation;
  Offset? _tooltipPosition;
  double? _tooltipValue;
  bool _isFirstBuild = true;

  @override
  void initState() {
    super.initState();
    _initializeData();
    _setupAnimation();
  }

  void _initializeData() {
    if (widget.data.isEmpty) {
      _previousData = [];
      _currentData = [];
    } else {
      _previousData = List.filled(widget.data.length, widget.data.first);
      _currentData = List.from(widget.data);
    }
  }

  void _setupAnimation() {
    _animationController = AnimationController(
      vsync: this,
      duration: widget.animationDuration,
    );

    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );

    // Add status listener to handle animation completion
    _animationController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _previousData = List.from(_currentData);
      }
    });

    if (_isFirstBuild) {
      _animationController.forward();
      _isFirstBuild = false;
    }
  }

  @override
  void didUpdateWidget(PowerChart oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Check if data has actually changed
    if (!const ListEquality().equals(oldWidget.data, widget.data)) {
      if (widget.data.isEmpty) {
        _previousData = [];
        _currentData = [];
      } else {
        // Keep current values as previous for smooth transition
        if (_currentData.isEmpty) {
          _previousData = List.filled(widget.data.length, widget.data.first);
        } else {
          _previousData = List.from(_currentData);
        }
        _currentData = List.from(widget.data);
      }

      // Reset animation
      _animationController.reset();
      _animationController.forward();
    }
  }

  List<double> _getInterpolatedData() {
    if (_currentData.isEmpty || _previousData.isEmpty) {
      return [];
    }

    try {
      final interpolatedData = List<double>.filled(_currentData.length, 0);
      for (var i = 0; i < _currentData.length; i++) {
        final prev = _previousData[i];
        final curr = _currentData[i];

        if (prev.isNaN || curr.isNaN || prev.isInfinite || curr.isInfinite) {
          interpolatedData[i] = 0;
          continue;
        }

        final interpolated = prev + (curr - prev) * _animation.value;
        interpolatedData[i] = interpolated.isNaN ? 0 : interpolated;
      }
      return interpolatedData;
    } catch (e) {
      return List.from(_currentData);
    }
  }

  void _handleTapDown(TapDownDetails details, Size size) {
    if (_currentData.isEmpty) return;

    final box = context.findRenderObject() as RenderBox;
    final localPosition = box.globalToLocal(details.globalPosition);

    if (localPosition.dx < 0 ||
        localPosition.dx > size.width ||
        localPosition.dy < 0 ||
        localPosition.dy > size.height) {
      return;
    }

    final horizontalStep = size.width / (_currentData.length - 1);
    final index = (localPosition.dx / horizontalStep)
        .round()
        .clamp(0, _currentData.length - 1);

    setState(() {
      _tooltipPosition = Offset(
          index * horizontalStep,
          size.height *
              (1 -
                  (_currentData[index] /
                      _currentData.reduce((a, b) => a > b ? a : b))));
      _tooltipValue = _currentData[index];
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (details) =>
          _handleTapDown(details, MediaQuery.of(context).size),
      onTapUp: (_) => setState(() {
        _tooltipPosition = null;
        _tooltipValue = null;
      }),
      onTapCancel: () => setState(() {
        _tooltipPosition = null;
        _tooltipValue = null;
      }),
      child: AnimatedBuilder(
        animation: _animation,
        builder: (context, child) {
          final data = _getInterpolatedData();
          return CustomPaint(
            size: Size.infinite,
            painter: PowerChartPainter(
              dataPoints: data,
              color: widget.lineColor ?? const Color(0xFF2691A5),
              strokeWidth: widget.strokeWidth,
              tooltipPosition: _tooltipPosition,
              tooltipValue: _tooltipValue,
            ),
          );
        },
      ),
    );
  }
}

class PowerChartPainter extends CustomPainter {
  final List<double> dataPoints;
  final Color color;
  final double strokeWidth;
  final Offset? tooltipPosition;
  final double? tooltipValue;

  // Grid configuration
  static const int horizontalLines = 6;
  static const int verticalLines = 20;
  static const Color gridColor = Color(0xFF8E8E8E);
  static const double gridStrokeWidth = 0.3;
  static const double gridOpacity = 0.15;

  // Value label configuration
  static const bool showLabels = true;
  static const double labelFontSize = 10;
  static const Color labelColor = Color(0xFF8E8E8E);
  static const double labelPadding = 8.0;

  // Tooltip configuration
  static const double tooltipRadius = 4.0;
  static const double tooltipPadding = 8.0;
  static const double tooltipArrowSize = 6.0;
  static const double tooltipHeight = 28.0;
  static const double tooltipWidth = 65.0;

  PowerChartPainter({
    required this.dataPoints,
    required this.color,
    required this.strokeWidth,
    this.tooltipPosition,
    this.tooltipValue,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (dataPoints.isEmpty) {
      _drawGrid(canvas, size);
      return;
    }

    final clipRect = Rect.fromLTWH(0, 0, size.width, size.height);
    canvas.save();
    canvas.clipRect(clipRect);

    _drawGrid(canvas, size);

    try {
      _drawGradient(canvas, size);
      _drawDataLine(canvas, size);
      _drawDataPoints(canvas, size);

      if (showLabels) {
        canvas.restore();
        canvas.save();
        canvas.clipRect(clipRect);
        _drawLabels(canvas, size);
      }

      if (tooltipPosition != null && tooltipValue != null) {
        _drawTooltip(canvas, size);
      }
    } catch (e) {
      // If any error occurs, ensure we restore the canvas
      canvas.restore();
      return;
    } finally {
      canvas.restore();
    }
  }

  void _drawGrid(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = gridColor.withOpacity(gridOpacity)
      ..strokeWidth = gridStrokeWidth
      ..style = PaintingStyle.stroke;

    // Draw horizontal grid lines
    final horizontalSpacing = size.height / horizontalLines;
    for (var i = 0; i <= horizontalLines; i++) {
      final y = i * horizontalSpacing;
      canvas.drawLine(
        Offset(0, y),
        Offset(size.width, y),
        paint,
      );
    }

    // Draw vertical grid lines
    final verticalSpacing = size.width / verticalLines;
    for (var i = 0; i <= verticalLines; i++) {
      final x = i * verticalSpacing;
      canvas.drawLine(
        Offset(x, 0),
        Offset(x, size.height),
        paint,
      );
    }
  }

  void _drawGradient(Canvas canvas, Size size) {
    final path = _createDataPath(size);
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();

    final gradient = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        color.withOpacity(0.2),
        color.withOpacity(0.05),
        color.withOpacity(0.0),
      ],
      stops: const [0.0, 0.7, 1.0],
    );

    final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    final paint = Paint()
      ..shader = gradient.createShader(rect)
      ..style = PaintingStyle.fill;

    canvas.drawPath(path, paint);
  }

  Path _createDataPath(Size size) {
    final path = Path();
    if (dataPoints.isEmpty) return path;

    final width = size.width;
    final height = size.height;

    // Validate data points
    final validDataPoints =
        dataPoints.where((value) => !value.isNaN && !value.isInfinite).toList();

    if (validDataPoints.isEmpty) return path;

    // Calculate scaling with validation
    final maxValue =
        validDataPoints.reduce((max, value) => value > max ? value : max);
    final minValue =
        validDataPoints.reduce((min, value) => value < min ? value : min);

    if (maxValue == minValue) return path;

    final range = (maxValue - minValue).abs();
    const paddingPercent = 0.1;
    final paddedMin = minValue - (range * paddingPercent);
    final paddedRange = range * (1 + 2 * paddingPercent);

    if (paddedRange == 0) return path;

    final horizontalStep = width / (dataPoints.length - 1);
    bool isFirstValidPoint = true;

    for (var i = 0; i < dataPoints.length; i++) {
      if (dataPoints[i].isNaN || dataPoints[i].isInfinite) continue;

      final x = i * horizontalStep;
      final normalizedValue = (dataPoints[i] - paddedMin) / paddedRange;

      if (normalizedValue.isNaN || normalizedValue.isInfinite) continue;

      final y = height - (normalizedValue * height);

      if (x.isNaN || y.isNaN || x.isInfinite || y.isInfinite) continue;

      if (isFirstValidPoint) {
        path.moveTo(x, y);
        isFirstValidPoint = false;
      } else {
        final prevIndex = i - 1;
        var prevX = prevIndex * horizontalStep;
        var prevY = height -
            ((dataPoints[prevIndex] - paddedMin) / paddedRange * height);

        // Validate previous point
        if (!prevX.isNaN &&
            !prevY.isNaN &&
            !prevX.isInfinite &&
            !prevY.isInfinite) {
          final controlX = (x + prevX) / 2;
          path.quadraticBezierTo(controlX, prevY, x, y);
        } else {
          // If previous point is invalid, just move to current point
          path.moveTo(x, y);
        }
      }
    }

    return path;
  }

  void _drawDataLine(Canvas canvas, Size size) {
    final path = _createDataPath(size);

    // Draw line shadow
    final shadowPaint = Paint()
      ..color = color.withOpacity(0.3)
      ..strokeWidth = strokeWidth + 2
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4)
      ..style = PaintingStyle.stroke;
    canvas.drawPath(path, shadowPaint);

    // Draw main line
    final linePaint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke;
    canvas.drawPath(path, linePaint);
  }

  void _drawDataPoints(Canvas canvas, Size size) {
    if (dataPoints.isEmpty) return;

    final pointPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    final pointStrokePaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    final width = size.width;
    final height = size.height;

    // Validate data points
    final validDataPoints =
        dataPoints.where((value) => !value.isNaN && !value.isInfinite).toList();

    if (validDataPoints.isEmpty) return;

    // Calculate scaling with validation
    final maxValue =
        validDataPoints.reduce((max, value) => value > max ? value : max);
    final minValue =
        validDataPoints.reduce((min, value) => value < min ? value : min);

    if (maxValue == minValue) return; // Avoid division by zero

    final range = (maxValue - minValue).abs();
    const paddingPercent = 0.1;
    final paddedMin = minValue - (range * paddingPercent);
    final paddedRange = range * (1 + 2 * paddingPercent);

    if (paddedRange == 0) return; // Avoid division by zero

    final horizontalStep = width / (dataPoints.length - 1);

    for (var i = 0; i < dataPoints.length; i++) {
      if (dataPoints[i].isNaN || dataPoints[i].isInfinite) continue;

      final x = i * horizontalStep;
      final normalizedValue = (dataPoints[i] - paddedMin) / paddedRange;

      if (normalizedValue.isNaN || normalizedValue.isInfinite) continue;

      final y = height - (normalizedValue * height);

      // Validate final coordinates
      if (x.isNaN || y.isNaN || x.isInfinite || y.isInfinite) continue;

      final point = Offset(x, y);
      canvas.drawCircle(point, 2, pointPaint);
      canvas.drawCircle(point, 2, pointStrokePaint);
    }
  }

  void _drawLabels(Canvas canvas, Size size) {
    if (dataPoints.isEmpty) return;

    // Validate data points
    final validDataPoints =
        dataPoints.where((value) => !value.isNaN && !value.isInfinite).toList();

    if (validDataPoints.isEmpty) return;

    const textStyle = TextStyle(
      color: labelColor,
      fontSize: labelFontSize,
      fontWeight: FontWeight.w500,
    );

    try {
      // Calculate scaling with validation
      final maxValue =
          validDataPoints.reduce((max, value) => value > max ? value : max);
      final minValue =
          validDataPoints.reduce((min, value) => value < min ? value : min);

      if (maxValue == minValue) return;

      final range = (maxValue - minValue).abs();
      const paddingPercent = 0.1;
      final paddedMin = minValue - (range * paddingPercent);
      final paddedRange = range * (1 + 2 * paddingPercent);

      if (paddedRange == 0) return;

      // Draw current value label if available
      final currentValue = validDataPoints.last;
      if (!currentValue.isNaN && !currentValue.isInfinite) {
        final textSpan = TextSpan(
          text: '${currentValue.toStringAsFixed(1)}W',
          style: textStyle,
        );
        final textPainter = TextPainter(
          text: textSpan,
          textDirection: TextDirection.ltr,
        );
        textPainter.layout();

        final normalizedValue = (currentValue - paddedMin) / paddedRange;
        if (!normalizedValue.isNaN && !normalizedValue.isInfinite) {
          final y = size.height - (normalizedValue * size.height);
          if (!y.isNaN && !y.isInfinite) {
            final xPos = size.width - textPainter.width - labelPadding;
            final yPos = y - textPainter.height - labelPadding;

            if (!xPos.isNaN &&
                !yPos.isNaN &&
                !xPos.isInfinite &&
                !yPos.isInfinite &&
                yPos >= 0 &&
                yPos <= size.height &&
                xPos >= 0 &&
                xPos <= size.width) {
              textPainter.paint(canvas, Offset(xPos, yPos));
            }
          }
        }
      }

      // Draw max and min labels
      if (!maxValue.isNaN && !maxValue.isInfinite) {
        final maxLabel = TextSpan(
          text: '${maxValue.toStringAsFixed(1)}W',
          style: textStyle,
        );
        final maxPainter = TextPainter(
          text: maxLabel,
          textDirection: TextDirection.ltr,
        )..layout();

        const maxX = labelPadding;
        const maxY = labelPadding;

        if (maxX >= 0 &&
            maxY >= 0 &&
            maxX <= size.width &&
            maxY <= size.height) {
          maxPainter.paint(canvas, const Offset(maxX, maxY));
        }
      }

      if (!minValue.isNaN && !minValue.isInfinite) {
        final minLabel = TextSpan(
          text: '${minValue.toStringAsFixed(1)}W',
          style: textStyle,
        );
        final minPainter = TextPainter(
          text: minLabel,
          textDirection: TextDirection.ltr,
        )..layout();

        const minX = labelPadding;
        final minY = size.height - minPainter.height - labelPadding;

        if (minX >= 0 &&
            minY >= 0 &&
            minX <= size.width &&
            minY <= size.height) {
          minPainter.paint(canvas, Offset(minX, minY));
        }
      }
    } catch (e) {
      // If any error occurs during label drawing, silently fail
      return;
    }
  }

  void _drawTooltip(Canvas canvas, Size size) {
    if (tooltipPosition == null || tooltipValue == null) return;

    final tooltipPaint = Paint()
      ..color = const Color(0xFF2A2D30)
      ..style = PaintingStyle.fill;

    final tooltipBorderPaint = Paint()
      ..color = Colors.white.withOpacity(0.1)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    // Draw point highlight
    final highlightPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    canvas.drawCircle(tooltipPosition!, tooltipRadius, highlightPaint);

    // Calculate tooltip position
    var tooltipX = tooltipPosition!.dx - tooltipWidth / 2;
    var tooltipY = tooltipPosition!.dy - tooltipHeight - tooltipArrowSize;
    bool isAbovePoint = true;

    // Adjust if tooltip would go off screen
    tooltipX = tooltipX.clamp(0, size.width - tooltipWidth);
    if (tooltipY < 0) {
      tooltipY = tooltipPosition!.dy + tooltipArrowSize;
      isAbovePoint = false;
    }

    // Draw tooltip background
    final rrect = RRect.fromRectAndRadius(
      Rect.fromLTWH(tooltipX, tooltipY, tooltipWidth, tooltipHeight),
      const Radius.circular(4),
    );
    canvas.drawRRect(rrect, tooltipPaint);
    canvas.drawRRect(rrect, tooltipBorderPaint);

    // Draw tooltip arrow
    final arrowPath = Path();
    if (isAbovePoint) {
      arrowPath.moveTo(
          tooltipPosition!.dx, tooltipPosition!.dy - tooltipArrowSize);
      arrowPath.lineTo(tooltipPosition!.dx - tooltipArrowSize, tooltipY);
      arrowPath.lineTo(tooltipPosition!.dx + tooltipArrowSize, tooltipY);
    } else {
      arrowPath.moveTo(
          tooltipPosition!.dx, tooltipPosition!.dy + tooltipArrowSize);
      arrowPath.lineTo(tooltipPosition!.dx - tooltipArrowSize, tooltipY);
      arrowPath.lineTo(tooltipPosition!.dx + tooltipArrowSize, tooltipY);
    }
    arrowPath.close();
    canvas.drawPath(arrowPath, tooltipPaint);

    // Draw tooltip text
    final textSpan = TextSpan(
      text: '${tooltipValue!.toStringAsFixed(1)}W',
      style: const TextStyle(
        color: Colors.white,
        fontSize: 12,
        fontWeight: FontWeight.w500,
      ),
    );
    final textPainter = TextPainter(
      text: textSpan,
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
    );
    textPainter.layout();

    textPainter.paint(
      canvas,
      Offset(
        tooltipX + (tooltipWidth - textPainter.width) / 2,
        tooltipY + (tooltipHeight - textPainter.height) / 2,
      ),
    );
  }

  @override
  bool shouldRepaint(PowerChartPainter oldDelegate) {
    return oldDelegate.dataPoints != dataPoints ||
        oldDelegate.color != color ||
        oldDelegate.strokeWidth != strokeWidth ||
        oldDelegate.tooltipPosition != tooltipPosition ||
        oldDelegate.tooltipValue != tooltipValue;
  }
}
