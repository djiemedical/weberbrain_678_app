// lib/core/services/ble/data/models/ble_packet.dart
import 'package:logger/logger.dart';

class BlePacket {
  final String command;
  static final Logger _logger = Logger();

  BlePacket(this.command) {
    _logger.d('Created BLE packet with command: $command');
  }

  static String _getSectionCode(String region) {
    final regionLower = region.toLowerCase();
    switch (regionLower) {
      case 'front':
      case 'frontal':
      case 'front/prefrontal':
        return '0';
      case 'left':
      case 'temporal left':
      case 'left/temporal':
        return '1';
      case 'top':
      case 'parietal':
      case 'top/parietal':
        return '2';
      case 'right':
      case 'temporal right':
      case 'right/temporal':
        return '3';
      case 'back':
      case 'occipital':
      case 'back/occipital':
        return '4';
      case 'all':
        return '9';
      default:
        _logger.w('Unknown region: $region, defaulting to "all"');
        return '9';
    }
  }

  static int _scaleOutputPower(String wavelength, int originalPower) {
    // Only scale power for 650nm wavelength
    if (wavelength == '650nm') {
      // For 650nm: Scale to 0-132 range
      return (originalPower * 1.32).round();
    }
    // For 808nm and 1064nm: Use direct percentage to 255 conversion
    return (originalPower * 2.55).round();
  }

  static String _getWavelengthCode(String wavelength) {
    switch (wavelength) {
      case '650nm':
        return '1';
      case '808nm':
        return '2';
      case '1064nm':
        return '3';
      default:
        _logger.w('Unknown wavelength: $wavelength, defaulting to "650nm"');
        return '1';
    }
  }

  factory BlePacket.fromParameters({
    required String region,
    required String wavelength,
    required int outputPower,
    required int frequency,
  }) {
    // Convert region to section code
    final sectionCode = _getSectionCode(region);

    // Scale output power based on wavelength
    final scaledPower = _scaleOutputPower(wavelength, outputPower);
    final powerHex =
        scaledPower.toRadixString(16).padLeft(2, '0').toUpperCase();

    // Convert frequency to hex
    final freqHex = frequency.toRadixString(16).padLeft(2, '0').toUpperCase();

    // Get wavelength code
    final wavelengthCode = _getWavelengthCode(wavelength);

    final command = '[$sectionCode,FFF,FF,$wavelengthCode,$powerHex,$freqHex]';

    _logger.d('Constructing BLE packet:');
    _logger.d('  Region: $region -> Section Code: $sectionCode');
    _logger.d('  Wavelength: $wavelength -> Code: $wavelengthCode');
    _logger.d(
        '  Output Power: $outputPower% -> Scaled: $scaledPower (0x$powerHex)');
    _logger.d('  Frequency: $frequency Hz -> Hex: $freqHex');
    _logger.d('  Final command: $command');

    return BlePacket(command);
  }

  factory BlePacket.sessionControl({required bool isStart}) {
    // When starting or stopping a session, we use:
    // - Region 9 (all)
    // - 650nm wavelength (code 1)
    // - Power FF for start, 00 for stop
    // - Frequency 00
    final command = isStart ? '[9,FFF,FF,1,FF,00]' : '[9,FFF,FF,1,00,00]';
    _logger.d('Creating session control command: $command (isStart: $isStart)');
    return BlePacket(command);
  }

  @override
  String toString() => command;
}
