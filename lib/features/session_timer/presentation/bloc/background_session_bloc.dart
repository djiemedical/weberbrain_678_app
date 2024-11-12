// lib/features/session_timer/presentation/bloc/background_session_bloc.dart
import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:logger/logger.dart';
import 'dart:convert' show ascii;
import '../../../../core/services/ble/data/models/ble_packet.dart';
import '../../../../core/services/ble/infrastructure/ble_service.dart';

part 'background_session_event.dart';
part 'background_session_state.dart';

class BackgroundSessionBloc
    extends Bloc<BackgroundSessionEvent, BackgroundSessionState> {
  Timer? _timer;
  int initialDuration = 0;
  final BleService _bleService;
  final Logger _logger = Logger();

  // Store current parameters
  String _currentRegion = 'all';
  String _currentWavelength = '650nm';
  int _currentOutputPower = 100; // Default to 100% (FF)
  int _currentFrequency = 0;

  BackgroundSessionBloc({required BleService bleService})
      : _bleService = bleService,
        super(const BackgroundSessionState.initial()) {
    on<StartBackgroundSession>(_onStartBackgroundSession);
    on<PauseBackgroundSession>(_onPauseBackgroundSession);
    on<ResumeBackgroundSession>(_onResumeBackgroundSession);
    on<StopBackgroundSession>(_onStopBackgroundSession);
    on<UpdateBackgroundSession>(_onUpdateBackgroundSession);
  }

  Future<void> sendParameters({
    required String region,
    required String wavelength,
    required int outputPower,
    required int frequency,
  }) async {
    _logger.i('================================');
    _logger.i('PARAMETER UPDATE TRIGGERED');
    _logger.i('Previous parameters:');
    _logger.i('  Region: $_currentRegion');
    _logger.i('  Wavelength: $_currentWavelength');
    _logger.i('  Output Power: $_currentOutputPower%');
    _logger.i('  Frequency: $_currentFrequency Hz');

    _logger.i('New parameters:');
    _logger.i('  Region: $region');
    _logger.i('  Wavelength: $wavelength');
    _logger.i('  Output Power: $outputPower%');
    _logger.i('  Frequency: $frequency Hz');

    // Check if parameters actually changed
    bool parametersChanged = _currentRegion != region ||
        _currentWavelength != wavelength ||
        _currentOutputPower != outputPower ||
        _currentFrequency != frequency;

    if (!parametersChanged) {
      _logger.i('No parameter changes detected, skipping update');
      _logger.i('================================');
      return;
    }

    // Update stored parameters
    _currentRegion = region;
    _currentWavelength = wavelength;
    _currentOutputPower = outputPower;
    _currentFrequency = frequency;

    _logger.i('Parameters updated in memory');

    // Send the parameters immediately
    await _sendCurrentParameters();
    _logger.i('================================');
  }

  Future<void> _sendCurrentParameters() async {
    _logger.i('Preparing to send current parameters:');
    _logger.i('  Region: $_currentRegion');
    _logger.i('  Wavelength: $_currentWavelength');
    _logger.i('  Output Power: $_currentOutputPower%');
    _logger.i('  Frequency: $_currentFrequency Hz');

    final packet = BlePacket.fromParameters(
      region: _currentRegion,
      wavelength: _currentWavelength,
      outputPower: _currentOutputPower,
      frequency: _currentFrequency,
    );

    _logger.i('Generated BLE packet command: ${packet.command}');

    try {
      final result =
          await _bleService.writeCommand(ascii.encode(packet.command));
      if (result) {
        _logger
            .i('Successfully sent parameters with command: ${packet.command}');
      } else {
        _logger.e('Failed to send parameters with command: ${packet.command}');
      }
    } catch (e) {
      _logger.e('Error sending parameters: $e');
    }
  }

  void _onStartBackgroundSession(StartBackgroundSession event,
      Emitter<BackgroundSessionState> emit) async {
    _timer?.cancel();
    initialDuration = event.duration;

    _logger.i('Starting session with current parameters:');
    _logger.i('  Region: $_currentRegion');
    _logger.i('  Wavelength: $_currentWavelength');
    _logger.i('  Output Power: $_currentOutputPower%');
    _logger.i('  Frequency: $_currentFrequency Hz');

    await _sendCurrentParameters();

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      add(UpdateBackgroundSession());
    });
    emit(BackgroundSessionState.running(event.duration));
  }

  void _onStopBackgroundSession(
      StopBackgroundSession event, Emitter<BackgroundSessionState> emit) async {
    _timer?.cancel();

    // For stop, use all regions with zero power
    final packet = BlePacket.fromParameters(
      region: 'all',
      wavelength: _currentWavelength,
      outputPower: 0, // Always 0 for stop
      frequency: 0, // Always 0 for stop
    );

    _logger.i('Sending stop command with parameters:');
    _logger.i('  Region: all');
    _logger.i('  Output Power: 0%');
    _logger.i('  Frequency: 0 Hz');
    _logger.i('Generated command: ${packet.command}');

    try {
      final result =
          await _bleService.writeCommand(ascii.encode(packet.command));
      if (result) {
        _logger.i('Successfully sent stop command: ${packet.command}');
      } else {
        _logger.e('Failed to send stop command: ${packet.command}');
      }
    } catch (e) {
      _logger.e('Error sending stop command: $e');
    }

    emit(const BackgroundSessionState.initial());
  }

  void _onUpdateBackgroundSession(UpdateBackgroundSession event,
      Emitter<BackgroundSessionState> emit) async {
    if (state.isRunning && state.remainingDuration > 0) {
      emit(state.copyWith(remainingDuration: state.remainingDuration - 1));
    } else if (state.isRunning && state.remainingDuration == 0) {
      _timer?.cancel();

      // Session complete - stop all regions
      final packet = BlePacket.fromParameters(
        region: 'all',
        wavelength: _currentWavelength,
        outputPower: 0,
        frequency: 0,
      );

      _logger.i('Sending session complete command:');
      _logger.i('Generated command: ${packet.command}');

      try {
        final result =
            await _bleService.writeCommand(ascii.encode(packet.command));
        if (result) {
          _logger.i(
              'Successfully sent session complete command: ${packet.command}');
        } else {
          _logger
              .e('Failed to send session complete command: ${packet.command}');
        }
      } catch (e) {
        _logger.e('Error sending session complete command: $e');
      }

      emit(const BackgroundSessionState.completed());
    }
  }

  void _onPauseBackgroundSession(
      PauseBackgroundSession event, Emitter<BackgroundSessionState> emit) {
    _timer?.cancel();
    emit(BackgroundSessionState.paused(state.remainingDuration));
  }

  void _onResumeBackgroundSession(
      ResumeBackgroundSession event, Emitter<BackgroundSessionState> emit) {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      add(UpdateBackgroundSession());
    });
    emit(BackgroundSessionState.running(state.remainingDuration));
  }

  @override
  Future<void> close() {
    _timer?.cancel();
    return super.close();
  }
}
