// lib/features/power_monitoring/presentation/widgets/optical_power_chart.dart
import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math';
import '../../../../core/config/feature_flags.dart';

class OpticalPowerChart extends StatefulWidget {
  final double maxHeight;
  final Map<String, Color> wavelengthColors;

  const OpticalPowerChart({
    super.key,
    required this.maxHeight,
    this.wavelengthColors = const {
      '650nm': Color(0xFFFF4D4D), // Red
      '808nm': Color(0xFF4D4DFF), // Blue
      '1064nm': Color(0xFF4DFFFF), // Cyan
    },
  });

  @override
  State<OpticalPowerChart> createState() => _OpticalPowerChartState();
}

class _OpticalPowerChartState extends State<OpticalPowerChart> {
  late Timer _updateTimer;
  final _random = Random();
  Map<String, double> _powerLevels = {
    '650nm': 20.5,
    '808nm': 10.2,
    '1064nm': 15.7,
  };

  // Constants for layout calculations
  static const double _titleHeight = 20.0;
  static const double _titleSpacing = 6.0;
  static const double _labelHeight = 17.0;
  static const double _labelSpacing = 1.0;
  static const double _valueHeight = 17.0;
  static const double _containerPadding = 12.0;
  static const double _barBottomSpacing = 3.0;
  static const double _horizontalSpacing = 8.0;

  double get _minHeight {
    return _containerPadding * 2 +
        _titleHeight +
        _titleSpacing +
        _labelHeight +
        _labelSpacing +
        _valueHeight;
  }

  @override
  void initState() {
    super.initState();
    _startUpdating();
  }

  @override
  void dispose() {
    _updateTimer.cancel();
    super.dispose();
  }

  void _startUpdating() {
    _updateTimer = Timer.periodic(const Duration(milliseconds: 500), (timer) {
      setState(() {
        _powerLevels = _powerLevels.map((wavelength, currentPower) {
          final variation = (_random.nextDouble() - 0.5) * 2.0;
          double newPower = currentPower + variation;
          newPower = newPower.clamp(0.0, _getMaxPower(wavelength));
          return MapEntry(wavelength, newPower);
        });
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final containerHeight =
        FeatureFlags.showPowerMonitoringChart ? widget.maxHeight : _minHeight;

    return Container(
      constraints: BoxConstraints(
        maxHeight: containerHeight,
        minHeight: _minHeight,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFF2A2D30),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
      ),
      padding: const EdgeInsets.all(_containerPadding),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Output Power',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: _titleSpacing),
          if (FeatureFlags.showPowerMonitoringChart)
            Expanded(child: _buildBarChart())
          else
            _buildPowerValues(),
        ],
      ),
    );
  }

  Widget _buildBarChart() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final availableWidth = constraints.maxWidth;
        final barWidth = (availableWidth -
                (_horizontalSpacing * (_powerLevels.length - 1))) /
            _powerLevels.length;

        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: _powerLevels.entries.map((entry) {
            return _buildPowerBar(
              wavelength: entry.key,
              power: entry.value,
              barWidth: barWidth,
              maxBarHeight: constraints.maxHeight -
                  (_labelHeight +
                      _labelSpacing +
                      _valueHeight +
                      _barBottomSpacing),
              maxPower: _getMaxPower(entry.key),
              showBar: true,
            );
          }).toList(),
        );
      },
    );
  }

  Widget _buildPowerValues() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final availableWidth = constraints.maxWidth;
        final barWidth = (availableWidth -
                (_horizontalSpacing * (_powerLevels.length - 1))) /
            _powerLevels.length;

        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: _powerLevels.entries.map((entry) {
            return _buildPowerBar(
              wavelength: entry.key,
              power: entry.value,
              barWidth: barWidth,
              maxBarHeight: 0,
              maxPower: _getMaxPower(entry.key),
              showBar: false,
            );
          }).toList(),
        );
      },
    );
  }

  Widget _buildPowerBar({
    required String wavelength,
    required double power,
    required double barWidth,
    required double maxBarHeight,
    required double maxPower,
    required bool showBar,
  }) {
    final percentage = (power / maxPower).clamp(0.0, 1.0);
    final barHeight = maxBarHeight * percentage;

    return SizedBox(
      width: barWidth,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          if (showBar) ...[
            TweenAnimationBuilder<double>(
              duration: const Duration(milliseconds: 500),
              curve: Curves.easeInOut,
              tween: Tween<double>(
                begin: 0,
                end: barHeight,
              ),
              builder: (context, value, child) {
                return Container(
                  width: barWidth * 0.6,
                  height: value,
                  decoration: BoxDecoration(
                    color: widget.wavelengthColors[wavelength],
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(4),
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: _barBottomSpacing),
          ],
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              wavelength,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 17,
              ),
            ),
          ),
          const SizedBox(height: _labelSpacing),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              '${power.toStringAsFixed(1)}W',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 17,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  double _getMaxPower(String wavelength) {
    const maxPowerLevels = {
      '650nm': 18.318,
      '808nm': 10.440,
      '1064nm': 13.305,
    };
    return maxPowerLevels[wavelength] ?? 100.0;
  }
}
