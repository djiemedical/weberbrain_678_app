// lib/features/home/presentation/widgets/default_settings_box.dart
import 'package:flutter/material.dart';

class DefaultSettingsBox extends StatelessWidget {
  final bool isDeviceConnected;
  final VoidCallback onStartPressed;

  const DefaultSettingsBox({
    super.key,
    required this.isDeviceConnected,
    required this.onStartPressed,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final buttonWidth = constraints.maxWidth * 0.9;
        return SizedBox(
          width: buttonWidth,
          child: Column(
            children: [
              Container(
                width: buttonWidth,
                decoration: BoxDecoration(
                  color: const Color(0xFF2A2D30),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                      color: Colors.white.withOpacity(0.2), width: 1),
                ),
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    ElevatedButton(
                      onPressed: isDeviceConnected ? onStartPressed : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isDeviceConnected
                            ? const Color(0xFF2691A5)
                            : Colors.grey,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding: const EdgeInsets.symmetric(
                            vertical: 15, horizontal: 80),
                      ),
                      child: const Text(
                        'Start',
                        style: TextStyle(fontSize: 24, color: Colors.white),
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Duration',
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                    const Text(
                      '30 mins',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 20),
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _SettingItem(label: 'Region', value: 'All'),
                        _SettingItem(label: 'Wavelength', value: 'All'),
                        _SettingItem(label: 'Output Power', value: '50 %'),
                        _SettingItem(label: 'Frequency', value: '10 Hz'),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: buttonWidth,
                child: ElevatedButton(
                  onPressed: () {
                    // Add manual setting functionality
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2691A5),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: const Text(
                    'Manual Setting',
                    style: TextStyle(fontSize: 16, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _SettingItem extends StatelessWidget {
  final String label;
  final String value;

  const _SettingItem({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(color: Colors.grey, fontSize: 12),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
              color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}
