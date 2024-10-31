// lib/features/power_monitoring/presentation/widgets/power_monitoring_display.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/power_monitoring_bloc.dart';
import '../bloc/power_monitoring_state.dart';
import 'power_chart.dart';

class PowerMonitoringDisplay extends StatelessWidget {
  const PowerMonitoringDisplay({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final containerWidth = constraints.maxWidth * 0.9;
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: containerWidth / 2 - 8,
                child: const PowerMonitorBox(
                  title: 'Total Input',
                  isInput: true,
                ),
              ),
              const SizedBox(width: 16),
              SizedBox(
                width: containerWidth / 2 - 8,
                child: const PowerMonitorBox(
                  title: 'Total Output',
                  isInput: false,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class PowerMonitorBox extends StatelessWidget {
  final String title;
  final bool isInput;

  const PowerMonitorBox({
    super.key,
    required this.title,
    required this.isInput,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PowerMonitoringBloc, PowerMonitoringState>(
      builder: (context, state) {
        double value = 0;
        List<double> data = [];

        if (state is PowerMonitoringLoaded) {
          value = isInput ? state.inputPower : state.outputPower;
          data = isInput ? state.inputHistory : state.outputHistory;
        }

        return Container(
          decoration: BoxDecoration(
            color: const Color(0xFF2A2D30),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: Colors.white.withOpacity(0.2),
              width: 1,
            ),
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Text(
                    state is PowerMonitoringLoaded
                        ? value.toStringAsFixed(0)
                        : '--',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'W',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.7),
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: 100,
                child: state is PowerMonitoringLoading
                    ? const Center(
                        child: CircularProgressIndicator(),
                      )
                    : PowerChart(
                        data: data,
                        lineColor: const Color(0xFF2691A5),
                      ),
              ),
            ],
          ),
        );
      },
    );
  }
}
