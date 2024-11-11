// lib/features/power_monitoring/presentation/widgets/optical_power_chart.dart
import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math';

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
          // Add random variation within a small range
          final variation =
              (_random.nextDouble() - 0.5) * 2.0; // ±1.0W variation
          double newPower = currentPower + variation;

          // Ensure power stays within reasonable bounds
          newPower = newPower.clamp(0.0, _getMaxPower(wavelength));

          return MapEntry(wavelength, newPower);
        });
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxHeight: widget.maxHeight,
        minHeight: 100.0,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFF2A2D30),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
      ),
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Output Power',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20, // Increased from 16
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final barWidth =
                    (constraints.maxWidth - 32) / _powerLevels.length;
                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: _powerLevels.entries.map((entry) {
                    return _buildPowerBar(
                      wavelength: entry.key,
                      power: entry.value,
                      barWidth: barWidth,
                      maxBarHeight: constraints.maxHeight -
                          55, // Adjusted for larger text
                      maxPower: _getMaxPower(entry.key),
                    );
                  }).toList(),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPowerBar({
    required String wavelength,
    required double power,
    required double barWidth,
    required double maxBarHeight,
    required double maxPower,
  }) {
    final percentage = (power / maxPower).clamp(0.0, 1.0);
    final barHeight = maxBarHeight * percentage;

    return SizedBox(
      width: barWidth,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
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
          const SizedBox(height: 8),
          Text(
            wavelength,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 17, // Increased from 12
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Text(
            '${power.toStringAsFixed(1)}W',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 17, // Increased from 12
              fontWeight: FontWeight.bold,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  double _getMaxPower(String wavelength) {
    // Maximum power levels in Watts
    const maxPowerLevels = {
      '650nm': 18.318,
      '808nm': 10.440,
      '1064nm': 13.305,
    };
    return maxPowerLevels[wavelength] ?? 100.0;
  }
}
