import 'package:equatable/equatable.dart';

class DeviceParameters extends Equatable {
  final String region;
  final String wavelength;
  final int outputPower;
  final int frequency;
  final int duration;

  const DeviceParameters({
    required this.region,
    required this.wavelength,
    required this.outputPower,
    required this.frequency,
    required this.duration,
  });

  @override
  List<Object?> get props =>
      [region, wavelength, outputPower, frequency, duration];
}
