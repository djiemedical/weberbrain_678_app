// lib/features/settings/presentation/widgets/default_settings_box.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flash/flash.dart';
import '../../../session_timer/presentation/bloc/background_session_bloc.dart';
import '../../domain/usecases/get_regions.dart';
import '../../domain/usecases/get_output_power.dart';
import '../../domain/usecases/get_frequency.dart';
import '../../../../config/routes/app_router.dart';
import '../../../../core/di/injection_container.dart';
import '../bloc/default_settings_state.dart';

class DefaultSettingsBox extends StatefulWidget {
  final bool isDeviceConnected;
  final VoidCallback onStartPressed;
  final Function(int) onDurationChanged;
  final double maxHeight;
  final double? maxWidth;

  const DefaultSettingsBox({
    super.key,
    required this.isDeviceConnected,
    required this.onStartPressed,
    required this.onDurationChanged,
    required this.maxHeight,
    this.maxWidth,
  });

  @override
  State<DefaultSettingsBox> createState() => _DefaultSettingsBoxState();
}

class _DefaultSettingsBoxState extends State<DefaultSettingsBox> {
  int _duration = 30;
  final Map<String, RegionSettings> _regionSettings = {
    'All': RegionSettings(outputPower: {}, frequency: 0),
    'Frontal': RegionSettings(outputPower: {}, frequency: 0),
    'Temporal Left': RegionSettings(outputPower: {}, frequency: 0),
    'Temporal Right': RegionSettings(outputPower: {}, frequency: 0),
    'Parietal': RegionSettings(outputPower: {}, frequency: 0),
    'Occipital': RegionSettings(outputPower: {}, frequency: 0),
  };
  Set<String> _selectedRegions = {'All'};

  final Map<String, String> _regionMasks = {
    'Frontal': 'Front',
    'Temporal Left': 'Left',
    'Temporal Right': 'Right',
    'Parietal': 'Top',
    'Occipital': 'Back',
  };

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final regionsResult = await getIt<GetRegions>().call();
    final outputPowerResult = await getIt<GetOutputPower>().call();
    final frequencyResult = await getIt<GetFrequency>().call();

    setState(() {
      regionsResult.fold(
        (failure) {
          _selectedRegions = {'All'};
        },
        (regions) {
          if (regions.isNotEmpty) {
            _selectedRegions = regions;
          }
        },
      );
      outputPowerResult.fold(
        (failure) {},
        (power) {
          _regionSettings.forEach((key, value) {
            value.outputPower = Map.from(power);
          });
        },
      );
      frequencyResult.fold(
        (failure) {},
        (frequency) {
          _regionSettings.forEach((key, value) {
            value.frequency = frequency;
          });
        },
      );
    });
  }

  void _showDurationPicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF2A2D30),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return SizedBox(
              height: 250,
              child: Column(
                children: [
                  AppBar(
                    title: const Text('Set Duration',
                        style: TextStyle(color: Colors.white)),
                    backgroundColor: Colors.transparent,
                    elevation: 0,
                    automaticallyImplyLeading: false,
                    actions: [
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.white),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                  Slider(
                    value: _duration.toDouble(),
                    min: 2,
                    max: 60,
                    divisions: 13,
                    label: '${_duration.round()} mins',
                    onChanged: (double value) {
                      setModalState(() {
                        if (value <= 10) {
                          _duration = (value / 2).round() * 2;
                        } else {
                          _duration = ((value - 10) / 10).round() * 10 + 10;
                        }
                      });
                      setState(() {});
                      widget.onDurationChanged(_duration);
                    },
                    activeColor: const Color(0xFF2691A5),
                    inactiveColor: Colors.grey,
                  ),
                  Text(
                    '${_duration.round()} minutes',
                    style: const TextStyle(color: Colors.white, fontSize: 18),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showRegionSelector() {
    final regions = ['All', ..._regionMasks.keys];

    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF2A2D30),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      isScrollControlled: true,
      builder: (BuildContext context) {
        return DraggableScrollableSheet(
          expand: false,
          builder: (BuildContext context, ScrollController scrollController) {
            return StatefulBuilder(
              builder: (context, setModalState) {
                return Column(
                  children: [
                    AppBar(
                      title: const Text('Select Regions',
                          style: TextStyle(color: Colors.white)),
                      backgroundColor: Colors.transparent,
                      elevation: 0,
                      automaticallyImplyLeading: false,
                      actions: [
                        TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: const Text('Done',
                              style: TextStyle(color: Color(0xFF2691A5))),
                        ),
                      ],
                    ),
                    Expanded(
                      child: ListView.builder(
                        controller: scrollController,
                        itemCount: regions.length,
                        itemBuilder: (context, index) {
                          final region = regions[index];
                          return CheckboxListTile(
                            title: Text(region,
                                style: const TextStyle(color: Colors.white)),
                            subtitle: region != 'All'
                                ? Text(_regionMasks[region]!,
                                    style: const TextStyle(color: Colors.grey))
                                : null,
                            value: _selectedRegions.contains(region),
                            onChanged: (bool? value) {
                              setModalState(() {
                                if (region == 'All') {
                                  if (value == true) {
                                    _selectedRegions = {'All'};
                                  } else {
                                    _selectedRegions.clear();
                                  }
                                } else {
                                  if (value == true) {
                                    _selectedRegions.remove('All');
                                    _selectedRegions.add(region);
                                  } else {
                                    _selectedRegions.remove(region);
                                    if (_selectedRegions.isEmpty) {
                                      _selectedRegions.add('All');
                                    }
                                  }
                                }
                              });
                              setState(() {});
                            },
                            activeColor: const Color(0xFF2691A5),
                            checkColor: Colors.white,
                          );
                        },
                      ),
                    ),
                  ],
                );
              },
            );
          },
        );
      },
    );
  }

  void _updateFrequencyForAllSelectedRegions(int frequency) {
    final regions = _selectedRegions.contains('All')
        ? _regionSettings.keys.toSet()
        : _selectedRegions;

    for (final region in regions) {
      _regionSettings[region]!.frequency = frequency;
    }
  }

  void _showOutputPowerSelector() {
    int allPower = 0;
    bool isAllControlled = false;

    final referenceRegion =
        _selectedRegions.contains('All') ? 'All' : _selectedRegions.first;
    Map<String, int> currentPower =
        Map.from(_regionSettings[referenceRegion]!.outputPower);

    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF2A2D30),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return SizedBox(
              height: 400,
              child: Column(
                children: [
                  AppBar(
                    title: Text(
                      'Set Power (${_getDisplayRegions()})',
                      style: const TextStyle(color: Colors.white),
                    ),
                    backgroundColor: Colors.transparent,
                    elevation: 0,
                    automaticallyImplyLeading: false,
                    actions: [
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.white),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                  Expanded(
                    child: ListView(
                      children: [
                        _buildPowerSlider(
                          'All',
                          allPower,
                          (value) {
                            setModalState(() {
                              allPower = value.round();
                              isAllControlled = true;
                              currentPower.updateAll((key, _) => allPower);
                              for (var region
                                  in _selectedRegions.contains('All')
                                      ? _regionSettings.keys
                                      : _selectedRegions) {
                                _regionSettings[region]!
                                    .outputPower
                                    .updateAll((key, _) => allPower);
                              }
                            });
                            setState(() {});
                          },
                        ),
                        const Divider(color: Colors.grey),
                        ...currentPower.entries.map((entry) {
                          final wavelength = entry.key;
                          return _buildPowerSlider(
                            wavelength,
                            _regionSettings[referenceRegion]!
                                .outputPower[wavelength]!,
                            (value) {
                              setModalState(() {
                                if (isAllControlled) {
                                  isAllControlled = false;
                                  allPower = 0;
                                }
                                final newPower = value.round();
                                for (var region
                                    in _selectedRegions.contains('All')
                                        ? _regionSettings.keys
                                        : _selectedRegions) {
                                  _regionSettings[region]!
                                      .outputPower[wavelength] = newPower;
                                }
                              });
                              setState(() {});
                            },
                          );
                        }),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildPowerSlider(
      String label, int power, ValueChanged<double> onChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          SizedBox(
            width: 70,
            child: Padding(
              padding: const EdgeInsets.only(left: 16.0),
              child: Text(label, style: const TextStyle(color: Colors.white)),
            ),
          ),
          Expanded(
            child: Slider(
              value: power.toDouble(),
              min: 0,
              max: 100,
              divisions: 20,
              onChanged: onChanged,
              activeColor: const Color(0xFF2691A5),
              inactiveColor: Colors.grey,
            ),
          ),
          SizedBox(
            width: 50,
            child: Text('$power%', style: const TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showFrequencySelector() {
    final referenceRegion =
        _selectedRegions.contains('All') ? 'All' : _selectedRegions.first;
    int currentFrequency = _regionSettings[referenceRegion]!.frequency;

    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF2A2D30),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return SizedBox(
              height: 350,
              child: Column(
                children: [
                  AppBar(
                    title: Text(
                      'Set Frequency (${_getDisplayRegions()})',
                      style: const TextStyle(color: Colors.white),
                    ),
                    backgroundColor: Colors.transparent,
                    elevation: 0,
                    automaticallyImplyLeading: false,
                    actions: [
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.white),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                  Slider(
                    value: currentFrequency.toDouble(),
                    min: 0,
                    max: 1200,
                    divisions: 120,
                    label: '$currentFrequency Hz',
                    onChanged: (double value) {
                      setModalState(() {
                        if (value <= 250) {
                          currentFrequency = (value / 10).round() * 10;
                        } else {
                          currentFrequency =
                              ((value - 250) / 50).round() * 50 + 250;
                        }
                        _updateFrequencyForAllSelectedRegions(currentFrequency);
                      });
                      setState(() {});
                    },
                    activeColor: const Color(0xFF2691A5),
                    inactiveColor: Colors.grey,
                  ),
                  Text('$currentFrequency Hz',
                      style: const TextStyle(color: Colors.white)),
                  const SizedBox(height: 20),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    alignment: WrapAlignment.center,
                    children: [0, 10, 20, 30, 40, 50, 100, 250, 500, 1000, 1200]
                        .map((preset) {
                      return ElevatedButton(
                        onPressed: () {
                          setModalState(() {
                            currentFrequency = preset;
                            _updateFrequencyForAllSelectedRegions(
                                currentFrequency);
                          });
                          setState(() {});
                        },
                        style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.white,
                          backgroundColor: const Color(0xFF2691A5),
                        ),
                        child: Text('$preset Hz'),
                      );
                    }).toList(),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  String _getDisplayRegions() {
    if (_selectedRegions.contains('All')) {
      return 'All';
    }
    if (_selectedRegions.length <= 3) {
      return _selectedRegions.join(', ');
    }
    return '${_selectedRegions.length} regions';
  }

  void _showConnectToast(BuildContext context) {
    showFlash(
      context: context,
      duration: const Duration(seconds: 3),
      persistent: true,
      builder: (_, controller) {
        return FlashBar(
          controller: controller,
          backgroundColor: Colors.red,
          content: const Text(
            'Please connect to device',
            style: TextStyle(color: Colors.white),
          ),
          primaryAction: TextButton(
            onPressed: () {
              controller.dismiss();
              context.router.push(const MyDeviceRoute());
            },
            child: const Text(
              'Connect',
              style: TextStyle(color: Colors.white),
            ),
          ),
          icon: const Icon(
            Icons.warning,
            color: Colors.white,
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BackgroundSessionBloc, BackgroundSessionState>(
      builder: (context, state) {
        return SizedBox(
          width: widget.maxWidth,
          child: Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: const Color(0xFF2A2D30),
              borderRadius: BorderRadius.circular(20),
              border:
                  Border.all(color: Colors.white.withOpacity(0.2), width: 1),
            ),
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ElevatedButton(
                  onPressed: widget.isDeviceConnected && !state.isRunning
                      ? () {
                          if (state.remainingDuration > 0) {
                            context
                                .read<BackgroundSessionBloc>()
                                .add(ResumeBackgroundSession());
                          } else {
                            widget.onStartPressed();
                          }
                          context.router.push(const SessionTimerRoute());
                        }
                      : widget.isDeviceConnected
                          ? null
                          : () => _showConnectToast(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        widget.isDeviceConnected && !state.isRunning
                            ? const Color(0xFF2691A5)
                            : Colors.grey,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                    padding: const EdgeInsets.symmetric(
                        vertical: 15, horizontal: 80),
                  ),
                  child: Text(
                    state.isRunning
                        ? 'In Session'
                        : (state.remainingDuration > 0 ? 'Resume' : 'Start'),
                    style: const TextStyle(fontSize: 24, color: Colors.white),
                  ),
                ),
                const SizedBox(height: 20),
                GestureDetector(
                  onTap: state.isRunning || state.remainingDuration > 0
                      ? () => context.router.push(const SessionTimerRoute())
                      : _showDurationPicker,
                  child: Column(
                    children: [
                      Text(
                        state.isRunning || state.remainingDuration > 0
                            ? 'Remaining Time'
                            : 'Duration',
                        style:
                            const TextStyle(color: Colors.white, fontSize: 20),
                      ),
                      Text(
                        state.isRunning || state.remainingDuration > 0
                            ? _formatDuration(state.remainingDuration)
                            : '$_duration mins',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: SettingItem(
                        label: 'Region',
                        values: [_getDisplayRegions()],
                        onTap: _showRegionSelector,
                      ),
                    ),
                    Expanded(
                      child: SettingItem(
                        label: 'Power',
                        values: _regionSettings[_selectedRegions.first]!
                            .outputPower
                            .entries
                            .map((e) => '${e.key}: ${e.value}%')
                            .toList(),
                        onTap: _showOutputPowerSelector,
                      ),
                    ),
                    Expanded(
                      child: SettingItem(
                        label: 'Frequency',
                        values: [
                          '${_regionSettings[_selectedRegions.first]!.frequency} Hz'
                        ],
                        onTap: _showFrequencySelector,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  String _formatDuration(int seconds) {
    int minutes = seconds ~/ 60;
    int remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }
}

class SettingItem extends StatelessWidget {
  final String label;
  final List<String> values;
  final VoidCallback? onTap;

  const SettingItem({
    super.key,
    required this.label,
    required this.values,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            label,
            style: const TextStyle(color: Colors.grey, fontSize: 20),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          ...values.map((value) => Text(
                value,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              )),
        ],
      ),
    );
  }
}
