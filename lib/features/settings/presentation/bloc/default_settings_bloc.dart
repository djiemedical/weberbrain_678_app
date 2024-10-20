import 'package:flutter_bloc/flutter_bloc.dart';
import 'default_settings_event.dart';
import 'default_settings_state.dart';
import '../../domain/usecases/get_regions.dart';
import '../../domain/usecases/set_regions.dart';
import '../../domain/usecases/get_output_power.dart';
import '../../domain/usecases/set_output_power.dart';
import '../../domain/usecases/get_frequency.dart';
import '../../domain/usecases/set_frequency.dart';

class DefaultSettingsBloc
    extends Bloc<DefaultSettingsEvent, DefaultSettingsState> {
  final GetRegions getRegions;
  final SetRegions setRegions;
  final GetOutputPower getOutputPower;
  final SetOutputPower setOutputPower;
  final GetFrequency getFrequency;
  final SetFrequency setFrequency;

  DefaultSettingsBloc({
    required this.getRegions,
    required this.setRegions,
    required this.getOutputPower,
    required this.setOutputPower,
    required this.getFrequency,
    required this.setFrequency,
  }) : super(DefaultSettingsState(
          regionSettings: {
            'All': RegionSettings(
              outputPower: {'650nm': 0, '808nm': 0, '1064nm': 0},
              frequency: 10,
            ),
          },
          selectedRegion: 'All',
          duration: 30,
        )) {
    on<LoadDefaultSettings>(_onLoadDefaultSettings);
    on<SelectRegion>(_onSelectRegion);
    on<UpdateDuration>(_onUpdateDuration);
    on<UpdateOutputPower>(_onUpdateOutputPower);
    on<UpdateFrequency>(_onUpdateFrequency);
  }

  void _onLoadDefaultSettings(
      LoadDefaultSettings event, Emitter<DefaultSettingsState> emit) async {
    emit(state.copyWith(isLoading: true));

    final regionsResult = await getRegions();
    final outputPowerResult = await getOutputPower();
    final frequencyResult = await getFrequency();

    final Map<String, RegionSettings> newRegionSettings = {};

    regionsResult.fold(
      (failure) {
        // Handle failure
      },
      (regions) {
        for (var region in regions) {
          newRegionSettings[region] = RegionSettings(
            outputPower: {'650nm': 0, '808nm': 0, '1064nm': 0},
            frequency: 10,
          );
        }
      },
    );

    outputPowerResult.fold(
      (failure) {
        // Handle failure
      },
      (outputPower) {
        for (var entry in newRegionSettings.entries) {
          entry.value.outputPower = Map.from(outputPower);
        }
      },
    );

    frequencyResult.fold(
      (failure) {
        // Handle failure
      },
      (frequency) {
        for (var entry in newRegionSettings.entries) {
          entry.value.frequency = frequency;
        }
      },
    );

    emit(state.copyWith(
      regionSettings: newRegionSettings,
      selectedRegion: newRegionSettings.keys.first,
      isLoading: false,
    ));
  }

  void _onSelectRegion(SelectRegion event, Emitter<DefaultSettingsState> emit) {
    emit(state.copyWith(selectedRegion: event.region));
  }

  void _onUpdateDuration(
      UpdateDuration event, Emitter<DefaultSettingsState> emit) {
    emit(state.copyWith(duration: event.duration));
  }

  void _onUpdateOutputPower(
      UpdateOutputPower event, Emitter<DefaultSettingsState> emit) {
    final updatedRegionSettings =
        Map<String, RegionSettings>.from(state.regionSettings);
    final updatedRegion = updatedRegionSettings[event.region]!;
    final updatedOutputPower = Map<String, int>.from(updatedRegion.outputPower);
    updatedOutputPower[event.wavelength] = event.power;

    updatedRegionSettings[event.region] = RegionSettings(
      outputPower: updatedOutputPower,
      frequency: updatedRegion.frequency,
    );

    emit(state.copyWith(regionSettings: updatedRegionSettings));
    setOutputPower(updatedOutputPower);
  }

  void _onUpdateFrequency(
      UpdateFrequency event, Emitter<DefaultSettingsState> emit) {
    final updatedRegionSettings =
        Map<String, RegionSettings>.from(state.regionSettings);
    updatedRegionSettings[event.region] = RegionSettings(
      outputPower: updatedRegionSettings[event.region]!.outputPower,
      frequency: event.frequency,
    );

    emit(state.copyWith(regionSettings: updatedRegionSettings));
    setFrequency(event.frequency);
  }
}