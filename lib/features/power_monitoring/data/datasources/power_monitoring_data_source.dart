// lib/features/power_monitoring/data/datasources/power_monitoring_data_source.dart
import 'dart:async';
import 'dart:typed_data';
import 'dart:math';
import 'package:rxdart/rxdart.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import '../models/power_data_model.dart';
import '../../../my_device/presentation/bloc/my_device_bloc.dart';
import '../config/power_monitoring_config.dart';

abstract class PowerMonitoringDataSource {
  Stream<PowerDataModel> getPowerData();
  void dispose();
}

class PowerMonitoringDataSourceImpl implements PowerMonitoringDataSource {
  final MyDeviceBloc deviceBloc;
  final _random = Random();
  StreamController<PowerDataModel>? _mockStreamController;
  Timer? _mockTimer;

  // Mock data parameters
  double _baseValue = 65.0; // Base power value
  double _phase = 0.0; // For creating smooth wave patterns
  static const double _maxPower = 78.0; // Maximum power limit
  static const double _minPower = 55.0; // Minimum power
  static const double _phaseIncrement = 0.1; // Controls wave frequency
  static const double _noiseAmplitude = 0.5; // Random noise amplitude

  // BLE UUIDs
  static const String _powerServiceUuid = "YOUR_POWER_SERVICE_UUID";
  static const String _inputPowerCharacteristicUuid =
      "YOUR_INPUT_POWER_CHARACTERISTIC_UUID";
  static const String _outputPowerCharacteristicUuid =
      "YOUR_OUTPUT_POWER_CHARACTERISTIC_UUID";

  PowerMonitoringDataSourceImpl({required this.deviceBloc});

  double _generateNextPowerValue() {
    // Generate a smooth wave pattern with some random noise
    _phase += _phaseIncrement;

    // Create a smooth sine wave oscillation
    double wave = sin(_phase) * 5.0;

    // Add some random noise
    double noise = (_random.nextDouble() * 2 - 1) * _noiseAmplitude;

    // Combine base value, wave, and noise
    double newValue = _baseValue + wave + noise;

    // Ensure value stays within bounds
    newValue = newValue.clamp(_minPower, _maxPower);

    // Occasionally shift the base value to simulate power level changes
    if (_random.nextDouble() < 0.02) {
      // 2% chance each second
      double shift = (_random.nextDouble() * 2 - 1) * 3.0; // Shift by up to ±3W
      _baseValue = (_baseValue + shift).clamp(_minPower, _maxPower);
    }

    return double.parse(
        newValue.toStringAsFixed(1)); // Round to 1 decimal place
  }

  @override
  Stream<PowerDataModel> getPowerData() {
    if (PowerMonitoringConfig.useMockData) {
      _mockStreamController?.close();
      _mockTimer?.cancel();

      _mockStreamController = StreamController<PowerDataModel>.broadcast();

      _mockTimer = Timer.periodic(const Duration(milliseconds: 1000), (timer) {
        if (_mockStreamController?.isClosed ?? true) {
          timer.cancel();
          return;
        }

        // Generate synchronized power value with sophisticated pattern
        final powerValue = _generateNextPowerValue();

        final powerData = PowerDataModel(
          inputPower: powerValue,
          outputPower: powerValue, // Keep input and output synchronized
          timestamp: DateTime.now(),
        );

        _mockStreamController?.add(powerData);
      });

      return _mockStreamController!.stream;
    } else {
      return _getRealDeviceStream();
    }
  }

  Stream<PowerDataModel> _getRealDeviceStream() async* {
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

        final inputCharacteristic = powerService.characteristics.firstWhere(
          (char) => char.uuid.toString() == _inputPowerCharacteristicUuid,
          orElse: () => throw Exception('Input power characteristic not found'),
        );

        final outputCharacteristic = powerService.characteristics.firstWhere(
          (char) => char.uuid.toString() == _outputPowerCharacteristicUuid,
          orElse: () =>
              throw Exception('Output power characteristic not found'),
        );

        await inputCharacteristic.setNotifyValue(true);
        await outputCharacteristic.setNotifyValue(true);

        final inputStream = inputCharacteristic.lastValueStream;
        final outputStream = outputCharacteristic.lastValueStream;

        yield* Rx.combineLatest2(
          inputStream,
          outputStream,
          (List<int> inputValue, List<int> outputValue) {
            final input = _parseCharacteristicValue(inputValue);
            final output = _parseCharacteristicValue(outputValue);
            return PowerDataModel(
              inputPower: input,
              outputPower: output,
              timestamp: DateTime.now(),
            );
          },
        );
      } else {
        throw Exception('Device is not connected');
      }
    } catch (e) {
      throw Exception('Failed to setup BLE monitoring: $e');
    }
  }

  double _parseCharacteristicValue(List<int> value) {
    if (value.isEmpty) return 0.0;

    final bytes = Uint8List.fromList(value);
    final buffer = ByteData.view(bytes.buffer);
    return buffer.getFloat32(0, Endian.little);
  }

  @override
  void dispose() {
    _mockTimer?.cancel();
    _mockStreamController?.close();
  }
}
