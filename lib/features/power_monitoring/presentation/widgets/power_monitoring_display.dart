// lib/features/power_monitoring/presentation/widgets/power_monitoring_display.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/power_monitoring_bloc.dart';
import '../bloc/power_monitoring_state.dart';
import '../bloc/power_monitoring_event.dart';
import 'optical_power_chart.dart';

class PowerMonitoringDisplay extends StatelessWidget {
  static const double _defaultHeight = 200.0;

  const PowerMonitoringDisplay({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PowerMonitoringBloc, PowerMonitoringState>(
      builder: (context, state) {
        if (state is PowerMonitoringLoading) {
          return _buildLoadingState();
        }

        if (state is PowerMonitoringError) {
          return _buildErrorState(context, state);
        }

        if (state is PowerMonitoringLoaded) {
          return _buildLoadedState(context, state);
        }

        return _buildInitialState();
      },
    );
  }

  Widget _buildLoadingState() {
    return Container(
      height: _defaultHeight,
      decoration: BoxDecoration(
        color: const Color(0xFF2A2D30),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: const Center(
        child: CircularProgressIndicator(
          color: Color(0xFF2691A5),
        ),
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, PowerMonitoringError state) {
    return Container(
      height: _defaultHeight,
      decoration: BoxDecoration(
        color: const Color(0xFF2A2D30),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.error_outline,
            color: Colors.red,
            size: 32,
          ),
          const SizedBox(height: 8),
          Text(
            state.message ?? 'Error monitoring power levels',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
            ),
          ),
          TextButton(
            onPressed: () {
              context
                  .read<PowerMonitoringBloc>()
                  .add(const PowerMonitoringStarted());
            },
            child: const Text(
              'Retry',
              style: TextStyle(
                color: Color(0xFF2691A5),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadedState(BuildContext context, PowerMonitoringLoaded state) {
    return const OpticalPowerChart(
      maxHeight: _defaultHeight,
    );
  }

  Widget _buildInitialState() {
    return const OpticalPowerChart(
      maxHeight: _defaultHeight,
    );
  }
}
