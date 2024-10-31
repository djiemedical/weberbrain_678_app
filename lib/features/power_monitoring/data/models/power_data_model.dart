// lib/features/power_monitoring/data/models/power_data_model.dart
import '../../domain/entities/power_data.dart';

class PowerDataModel extends PowerData {
  const PowerDataModel({
    required super.inputPower,
    required super.outputPower,
    required super.timestamp,
  });

  factory PowerDataModel.fromJson(Map<String, dynamic> json) {
    return PowerDataModel(
      inputPower: json['input_power']?.toDouble() ?? 0.0,
      outputPower: json['output_power']?.toDouble() ?? 0.0,
      timestamp: DateTime.parse(json['timestamp'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'input_power': inputPower,
      'output_power': outputPower,
      'timestamp': timestamp.toIso8601String(),
    };
  }
}
