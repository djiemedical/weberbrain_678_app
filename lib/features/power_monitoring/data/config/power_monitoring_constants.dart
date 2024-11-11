// lib/features/power_monitoring/data/config/power_monitoring_constants.dart
class PowerMonitoringConstants {
  // Maximum power levels in Watts
  static const Map<String, double> maxPowerLevels = {
    '650nm': 28.318, // ~28.3W
    '808nm': 13.440, // ~13.4W
    '1064nm': 17.305, // ~17.3W
  };

  // Base power levels for mock data (as percentage of max)
  static const Map<String, double> basePowerLevels = {
    '650nm': 20.0, // ~70% of max
    '808nm': 9.0, // ~67% of max
    '1064nm': 12.0, // ~69% of max
  };

  // Variation range for mock data
  static const double mockVariationRange = 2.0; // Watts
}
