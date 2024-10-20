import 'package:equatable/equatable.dart';

class RegionSettings {
  Map<String, int> outputPower;
  int frequency;

  RegionSettings({
    required this.outputPower,
    required this.frequency,
  });

  RegionSettings copyWith({
    Map<String, int>? outputPower,
    int? frequency,
  }) {
    return RegionSettings(
      outputPower: outputPower ?? this.outputPower,
      frequency: frequency ?? this.frequency,
    );
  }
}

class DefaultSettingsState extends Equatable {
  final Map<String, RegionSettings> regionSettings;
  final String selectedRegion;
  final int duration;
  final bool isLoading;

  const DefaultSettingsState({
    required this.regionSettings,
    required this.selectedRegion,
    required this.duration,
    this.isLoading = false,
  });

  DefaultSettingsState copyWith({
    Map<String, RegionSettings>? regionSettings,
    String? selectedRegion,
    int? duration,
    bool? isLoading,
  }) {
    return DefaultSettingsState(
      regionSettings: regionSettings ?? this.regionSettings,
      selectedRegion: selectedRegion ?? this.selectedRegion,
      duration: duration ?? this.duration,
      isLoading: isLoading ?? this.isLoading,
    );
  }

  @override
  List<Object> get props =>
      [regionSettings, selectedRegion, duration, isLoading];
}
