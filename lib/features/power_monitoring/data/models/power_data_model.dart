// lib/features/power_monitoring/data/models/power_data_model.dart
import '../../domain/entities/power_data.dart';

class PowerDataModel extends PowerData {
  const PowerDataModel({
    required super.powerLevels,
    required super.timestamp,
  });

  factory PowerDataModel.fromJson(Map<String, dynamic> json) {
    Map<String, dynamic> powerData =
        json['power_levels'] as Map<String, dynamic>;
    return PowerDataModel(
      powerLevels: {
        '650nm': powerData['650nm']?.toDouble() ?? 0.0,
        '808nm': powerData['808nm']?.toDouble() ?? 0.0,
        '1064nm': powerData['1064nm']?.toDouble() ?? 0.0,
      },
      timestamp: DateTime.parse(json['timestamp'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'power_levels': powerLevels,
      'timestamp': timestamp.toIso8601String(),
    };
  }
}
