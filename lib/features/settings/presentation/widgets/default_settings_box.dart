// lib/features/settings/presentation/widgets/default_settings_box.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flash/flash.dart';
import 'dart:async';
import '../../../session_timer/presentation/bloc/background_session_bloc.dart';
import '../../domain/usecases/get_regions.dart';
import '../../domain/usecases/get_output_power.dart';
import '../../domain/usecases/get_frequency.dart';
import '../../../../config/routes/app_router.dart';
import '../../../../core/di/injection_container.dart';

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
  Timer? _powerUpdateTimer;
  final Map<String, Map<String, int>> _pendingPowerUpdates = {};

  final Map<String, RegionSettings> _regionSettings = <String, RegionSettings>{
    'All': RegionSettings(
        outputPower: <String, int>{'650nm': 50, '808nm': 50, '1064nm': 50},
        frequency: 0),
    'Front': RegionSettings(
        outputPower: <String, int>{'650nm': 50, '808nm': 50, '1064nm': 50},
        frequency: 0),
    'Left': RegionSettings(
        outputPower: <String, int>{'650nm': 50, '808nm': 50, '1064nm': 50},
        frequency: 0),
    'Right': RegionSettings(
        outputPower: <String, int>{'650nm': 50, '808nm': 50, '1064nm': 50},
        frequency: 0),
    'Top': RegionSettings(
        outputPower: <String, int>{'650nm': 50, '808nm': 50, '1064nm': 50},
        frequency: 0),
    'Back': RegionSettings(
        outputPower: <String, int>{'650nm': 50, '808nm': 50, '1064nm': 50},
        frequency: 0),
  };

  Set<String> _selectedRegions = <String>{'All'};

  final Map<String, String> _regionMasks = <String, String>{
    'Front': 'Front/Prefrontal',
    'Left': 'Left/Temporal',
    'Right': 'Right/Temporal',
    'Top': 'Top/Parietal',
    'Back': 'Back/Occipital',
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
          _selectedRegions = <String>{'All'};
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
            value.outputPower = Map<String, int>.from(power);
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

    if (_selectedRegions.isNotEmpty) {
      _updateParametersForRegion(_selectedRegions.first);
    }
  }

  void _updateFrequencyForAllSelectedRegions(int frequency) {
    // If 'All' is selected, only send command for region 'All'
    final regions =
        _selectedRegions.contains('All') ? {'All'} : _selectedRegions;

    for (final region in regions) {
      if (_regionSettings.containsKey(region)) {
        _regionSettings[region]!.frequency = frequency;
        _updateParametersForRegion(region, force: true);
      }
    }
  }

  void _updateParametersForRegion(String region, {bool force = false}) {
    final settings = _regionSettings[region];
    if (settings == null) return;

    final mappedRegion = _getMappedRegion(region);

    if (!force) {
      _pendingPowerUpdates[region] = Map.from(settings.outputPower);
      return;
    }

    if (region == 'All') {
      settings.outputPower.forEach((wavelength, power) {
        context.read<BackgroundSessionBloc>().sendParameters(
              region: 'all',
              wavelength: wavelength,
              outputPower: power,
              frequency: settings.frequency,
            );
      });
    } else {
      settings.outputPower.forEach((wavelength, power) {
        context.read<BackgroundSessionBloc>().sendParameters(
              region: mappedRegion,
              wavelength: wavelength,
              outputPower: power,
              frequency: settings.frequency,
            );
      });
    }
  }

  void _debouncedPowerUpdate() {
    _powerUpdateTimer?.cancel();
    _powerUpdateTimer = Timer(const Duration(milliseconds: 200), () {
      _pendingPowerUpdates.forEach((region, _) {
        _updateParametersForRegion(region, force: true);
      });
      _pendingPowerUpdates.clear();
    });
  }

  String _getMappedRegion(String region) {
    switch (region.toLowerCase()) {
      case 'front':
      case 'front/prefrontal':
        return 'Front/Prefrontal';
      case 'left':
      case 'left/temporal':
        return 'Left/Temporal';
      case 'top':
      case 'top/parietal':
        return 'Top/Parietal';
      case 'right':
      case 'right/temporal':
        return 'Right/Temporal';
      case 'back':
      case 'back/occipital':
        return 'Back/Occipital';
      case 'all':
        return 'all';
      default:
        return region;
    }
  }

  void _updatePowerForRegion(String region, int power,
      {String? specificWavelength}) {
    final settings = _regionSettings[region];
    if (settings == null) return;

    if (specificWavelength != null) {
      settings.outputPower[specificWavelength] = power;
    } else {
      settings.outputPower = {
        '650nm': power,
        '808nm': power,
        '1064nm': power,
      };
    }

    _updateParametersForRegion(region);
    _debouncedPowerUpdate();
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
                          final isSelected = _selectedRegions.contains(region);

                          return CheckboxListTile(
                            title: Text(region,
                                style: const TextStyle(color: Colors.white)),
                            subtitle: region != 'All'
                                ? Text(_regionMasks[region] ?? '',
                                    style: const TextStyle(color: Colors.grey))
                                : null,
                            value: isSelected,
                            onChanged: (bool? value) {
                              if (value == null) return;

                              setModalState(() {
                                if (region == 'All') {
                                  if (value) {
                                    _selectedRegions = {'All'};
                                    _updateParametersForRegion('All');
                                  } else {
                                    _selectedRegions.clear();
                                  }
                                } else {
                                  if (value) {
                                    _selectedRegions.remove('All');
                                    _selectedRegions.add(region);
                                    _updateParametersForRegion(region);
                                  } else {
                                    _selectedRegions.remove(region);
                                    if (_selectedRegions.isEmpty) {
                                      _selectedRegions.add('All');
                                      _updateParametersForRegion('All');
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
              height: 500,
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
                        onPressed: () {
                          _pendingPowerUpdates.forEach((region, _) {
                            _updateParametersForRegion(region, force: true);
                          });
                          _pendingPowerUpdates.clear();
                          Navigator.pop(context);
                        },
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

                              if (_selectedRegions.contains('All')) {
                                _updatePowerForRegion('All', allPower);
                              } else {
                                for (var region in _selectedRegions) {
                                  _updatePowerForRegion(region, allPower);
                                }
                              }
                            });
                          },
                          onChangeEnd: (value) {
                            _debouncedPowerUpdate();
                          },
                        ),
                        const Divider(color: Colors.grey),
                        ...[
                          {'label': '650nm (Red)', 'key': '650nm'},
                          {'label': '808nm (NIR)', 'key': '808nm'},
                          {'label': '1064nm (NIR)', 'key': '1064nm'},
                        ].map((wavelengthData) {
                          return _buildPowerSlider(
                            wavelengthData['label']!,
                            _regionSettings[referenceRegion]!
                                .outputPower[wavelengthData['key']]!,
                            (value) {
                              setModalState(() {
                                if (isAllControlled) {
                                  isAllControlled = false;
                                  allPower = 0;
                                }
                                final newPower = value.round();

                                if (_selectedRegions.contains('All')) {
                                  _updatePowerForRegion(
                                    'All',
                                    newPower,
                                    specificWavelength: wavelengthData['key'],
                                  );
                                } else {
                                  for (var region in _selectedRegions) {
                                    _updatePowerForRegion(
                                      region,
                                      newPower,
                                      specificWavelength: wavelengthData['key'],
                                    );
                                  }
                                }
                              });
                            },
                            onChangeEnd: (value) {
                              _debouncedPowerUpdate();
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

  Widget _buildPowerSlider(
      String label, int power, ValueChanged<double> onChanged,
      {ValueChanged<double>? onChangeEnd}) {
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
              onChangeEnd: onChangeEnd,
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
                      child: GestureDetector(
                        onTap: _showRegionSelector,
                        child: Column(
                          children: [
                            const Text(
                              'Region',
                              style:
                                  TextStyle(color: Colors.grey, fontSize: 20),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _getDisplayRegions(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 17,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ),
                    Expanded(
                      child: GestureDetector(
                        onTap: _showOutputPowerSelector,
                        child: Column(
                          children: [
                            const Text(
                              'Power',
                              style:
                                  TextStyle(color: Colors.grey, fontSize: 20),
                            ),
                            const SizedBox(height: 4),
                            Column(
                              children: [
                                Text(
                                  '650: ${_regionSettings[_selectedRegions.first]!.outputPower['650nm']}%',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                Text(
                                  '808: ${_regionSettings[_selectedRegions.first]!.outputPower['808nm']}%',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                Text(
                                  '1064: ${_regionSettings[_selectedRegions.first]!.outputPower['1064nm']}%',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    Expanded(
                      child: GestureDetector(
                        onTap: _showFrequencySelector,
                        child: Column(
                          children: [
                            const Text(
                              'Frequency',
                              style:
                                  TextStyle(color: Colors.grey, fontSize: 20),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${_regionSettings[_selectedRegions.first]!.frequency} Hz',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 17,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
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

  @override
  void dispose() {
    _powerUpdateTimer?.cancel();
    super.dispose();
  }
}
