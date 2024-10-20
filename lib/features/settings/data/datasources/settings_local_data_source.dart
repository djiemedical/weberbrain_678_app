// lib/features/settings/data/datasources/settings_local_data_source.dart
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

abstract class SettingsLocalDataSource {
  Future<Set<String>> getRegions();
  Future<void> setRegions(Set<String> regions);
  Future<Set<String>> getWavelengths();
  Future<void> setWavelengths(Set<String> wavelengths);
  Future<Map<String, int>> getOutputPower();
  Future<void> setOutputPower(Map<String, int> powerLevels);
  Future<int> getFrequency();
  Future<void> setFrequency(int frequency);
}

class SettingsLocalDataSourceImpl implements SettingsLocalDataSource {
  final SharedPreferences sharedPreferences;

  SettingsLocalDataSourceImpl({required this.sharedPreferences});

  @override
  Future<Set<String>> getRegions() async {
    return sharedPreferences.getStringList('regions')?.toSet() ?? {'All'};
  }

  @override
  Future<void> setRegions(Set<String> regions) async {
    await sharedPreferences.setStringList('regions', regions.toList());
  }

  @override
  Future<Set<String>> getWavelengths() async {
    return sharedPreferences.getStringList('wavelengths')?.toSet() ?? {'All'};
  }

  @override
  Future<void> setWavelengths(Set<String> wavelengths) async {
    await sharedPreferences.setStringList('wavelengths', wavelengths.toList());
  }

  @override
  Future<Map<String, int>> getOutputPower() async {
    final String? jsonString = sharedPreferences.getString('outputPower');
    if (jsonString != null) {
      Map<String, dynamic> jsonMap = json.decode(jsonString);
      return jsonMap.map((key, value) => MapEntry(key, value as int));
    }
    return {'650nm': 50, '808nm': 50, '1064nm': 50};
  }

  @override
  Future<void> setOutputPower(Map<String, int> powerLevels) async {
    await sharedPreferences.setString('outputPower', json.encode(powerLevels));
  }

  @override
  Future<int> getFrequency() async {
    return sharedPreferences.getInt('frequency') ?? 10;
  }

  @override
  Future<void> setFrequency(int frequency) async {
    await sharedPreferences.setInt('frequency', frequency);
  }
}
