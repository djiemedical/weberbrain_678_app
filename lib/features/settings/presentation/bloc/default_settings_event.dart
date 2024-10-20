import 'package:equatable/equatable.dart';

abstract class DefaultSettingsEvent extends Equatable {
  const DefaultSettingsEvent();

  @override
  List<Object> get props => [];
}

class LoadDefaultSettings extends DefaultSettingsEvent {}

class SelectRegion extends DefaultSettingsEvent {
  final String region;

  const SelectRegion(this.region);

  @override
  List<Object> get props => [region];
}

class UpdateDuration extends DefaultSettingsEvent {
  final int duration;

  const UpdateDuration(this.duration);

  @override
  List<Object> get props => [duration];
}

class UpdateOutputPower extends DefaultSettingsEvent {
  final String region;
  final String wavelength;
  final int power;

  const UpdateOutputPower(this.region, this.wavelength, this.power);

  @override
  List<Object> get props => [region, wavelength, power];
}

class UpdateFrequency extends DefaultSettingsEvent {
  final String region;
  final int frequency;

  const UpdateFrequency(this.region, this.frequency);

  @override
  List<Object> get props => [region, frequency];
}
