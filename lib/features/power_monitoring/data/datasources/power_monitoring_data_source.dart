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
}

class PowerMonitoringDataSourceImpl implements PowerMonitoringDataSource {
  final MyDeviceBloc deviceBloc;
  final _random = Random();

  // BLE UUIDs
  static const String _powerServiceUuid = "YOUR_POWER_SERVICE_UUID";
  static const String _inputPowerCharacteristicUuid =
      "YOUR_INPUT_POWER_CHARACTERISTIC_UUID";
  static const String _outputPowerCharacteristicUuid =
      "YOUR_OUTPUT_POWER_CHARACTERISTIC_UUID";

  PowerMonitoringDataSourceImpl({required this.deviceBloc});

  @override
  Stream<PowerDataModel> getPowerData() async* {
    if (PowerMonitoringConfig.useMockData) {
      // Simulated data
      while (true) {
        await Future.delayed(const Duration(seconds: 1));
        // Generate a single power value for both input and output
        final powerValue =
            135 + _random.nextDouble() * 10; // Random between 135-145
        yield PowerDataModel(
          inputPower: powerValue,
          outputPower: powerValue, // Use same value for synchronization
          timestamp: DateTime.now(),
        );
      }
    } else {
      // Real device implementation
      if (deviceBloc.state is! MyDeviceConnected) {
        throw Exception('Device not connected');
      }

      final bleDevice = (deviceBloc.state as MyDeviceConnected).device;
      BluetoothDevice? device;

      try {
        final devices = FlutterBluePlus.connectedDevices;
        device = devices.firstWhere(
          (d) => d.platformName == bleDevice.name,
          orElse: () =>
              throw Exception('Device not found in connected devices'),
        );

        if (device.isConnected) {
          final services = await device.discoverServices();

          final powerService = services.firstWhere(
            (service) => service.uuid.toString() == _powerServiceUuid,
            orElse: () => throw Exception('Power service not found'),
          );

          final inputCharacteristic = powerService.characteristics.firstWhere(
            (char) => char.uuid.toString() == _inputPowerCharacteristicUuid,
            orElse: () =>
                throw Exception('Input power characteristic not found'),
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
  }

  double _parseCharacteristicValue(List<int> value) {
    if (value.isEmpty) return 0.0;

    final bytes = Uint8List.fromList(value);
    final buffer = ByteData.view(bytes.buffer);
    return buffer.getFloat32(0, Endian.little);
  }
}
