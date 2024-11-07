// lib/features/power_monitoring/data/datasources/power_monitoring_data_source.dart
import 'dart:async';
import 'dart:math';
import 'dart:typed_data';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:rxdart/rxdart.dart';
import '../models/power_data_model.dart';
import '../../../my_device/presentation/bloc/my_device_bloc.dart';
import '../config/power_monitoring_config.dart';
import '../config/power_monitoring_constants.dart';

abstract class PowerMonitoringDataSource {
  Stream<PowerDataModel> getPowerData();
}

class PowerMonitoringDataSourceImpl implements PowerMonitoringDataSource {
  final MyDeviceBloc deviceBloc;
  final _random = Random();
  StreamController<PowerDataModel>? _mockStreamController;
  Timer? _mockTimer;

  // BLE UUIDs
  static const String _powerServiceUuid = "YOUR_POWER_SERVICE_UUID";
  static const String _wavelength650CharacteristicUuid = "650NM_POWER_UUID";
  static const String _wavelength808CharacteristicUuid = "808NM_POWER_UUID";
  static const String _wavelength1064CharacteristicUuid = "1064NM_POWER_UUID";

  PowerMonitoringDataSourceImpl({required this.deviceBloc});

  @override
  Stream<PowerDataModel> getPowerData() {
    if (PowerMonitoringConfig.useMockData) {
      return _getMockData();
    }
    return _getRealDeviceData();
  }

  Stream<PowerDataModel> _getMockData() {
    _mockStreamController?.close();
    _mockTimer?.cancel();

    _mockStreamController = StreamController<PowerDataModel>.broadcast();

    _mockTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_mockStreamController?.isClosed ?? true) {
        timer.cancel();
        return;
      }

      final mockPowerLevels = {
        '650nm': (PowerMonitoringConstants.basePowerLevels['650nm']! +
                (_random.nextDouble() * 2 - 1) *
                    PowerMonitoringConstants.mockVariationRange)
            .clamp(0.0, PowerMonitoringConstants.maxPowerLevels['650nm']!),
        '808nm': (PowerMonitoringConstants.basePowerLevels['808nm']! +
                (_random.nextDouble() * 2 - 1) *
                    PowerMonitoringConstants.mockVariationRange)
            .clamp(0.0, PowerMonitoringConstants.maxPowerLevels['808nm']!),
        '1064nm': (PowerMonitoringConstants.basePowerLevels['1064nm']! +
                (_random.nextDouble() * 2 - 1) *
                    PowerMonitoringConstants.mockVariationRange)
            .clamp(0.0, PowerMonitoringConstants.maxPowerLevels['1064nm']!),
      };

      _mockStreamController?.add(
        PowerDataModel(
          powerLevels: Map<String, double>.from(mockPowerLevels),
          timestamp: DateTime.now(),
        ),
      );
    });

    return _mockStreamController!.stream;
  }

  Stream<PowerDataModel> _getRealDeviceData() async* {
    if (deviceBloc.state is! MyDeviceConnected) {
      throw Exception('Device not connected');
    }

    final bleDevice = (deviceBloc.state as MyDeviceConnected).device;
    BluetoothDevice? device;

    try {
      final devices = FlutterBluePlus.connectedDevices;
      device = devices.firstWhere(
        (d) => d.platformName == bleDevice.name,
        orElse: () => throw Exception('Device not found in connected devices'),
      );

      if (device.isConnected) {
        final services = await device.discoverServices();
        final powerService = services.firstWhere(
          (service) => service.uuid.toString() == _powerServiceUuid,
          orElse: () => throw Exception('Power service not found'),
        );

        final characteristic650 = powerService.characteristics.firstWhere(
          (char) => char.uuid.toString() == _wavelength650CharacteristicUuid,
          orElse: () => throw Exception('650nm characteristic not found'),
        );

        final characteristic808 = powerService.characteristics.firstWhere(
          (char) => char.uuid.toString() == _wavelength808CharacteristicUuid,
          orElse: () => throw Exception('808nm characteristic not found'),
        );

        final characteristic1064 = powerService.characteristics.firstWhere(
          (char) => char.uuid.toString() == _wavelength1064CharacteristicUuid,
          orElse: () => throw Exception('1064nm characteristic not found'),
        );

        await characteristic650.setNotifyValue(true);
        await characteristic808.setNotifyValue(true);
        await characteristic1064.setNotifyValue(true);

        final stream650 = characteristic650.lastValueStream;
        final stream808 = characteristic808.lastValueStream;
        final stream1064 = characteristic1064.lastValueStream;

        // Combine all wavelength streams
        await for (final combined in Rx.combineLatest3(
          stream650,
          stream808,
          stream1064,
          (List<int> value650, List<int> value808, List<int> value1064) {
            return PowerDataModel(
              powerLevels: {
                '650nm': _parseCharacteristicValue(value650, '650nm'),
                '808nm': _parseCharacteristicValue(value808, '808nm'),
                '1064nm': _parseCharacteristicValue(value1064, '1064nm'),
              },
              timestamp: DateTime.now(),
            );
          },
        )) {
          yield combined;
        }
      } else {
        throw Exception('Device is not connected');
      }
    } catch (e) {
      throw Exception('Failed to setup BLE monitoring: $e');
    }
  }

  double _parseCharacteristicValue(List<int> value, String wavelength) {
    if (value.isEmpty) return 0.0;

    final bytes = Uint8List.fromList(value);
    final buffer = ByteData.view(bytes.buffer);
    final maxPower = PowerMonitoringConstants.maxPowerLevels[wavelength] ?? 0.0;
    return buffer.getFloat32(0, Endian.little).clamp(0.0, maxPower);
  }

  void dispose() {
    _mockTimer?.cancel();
    _mockStreamController?.close();
  }
}
