// lib/features/my_device/presentation/pages/my_device_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:auto_route/auto_route.dart';
import '../bloc/my_device_bloc.dart';
import '../bloc/my_device_event.dart';
import '../bloc/my_device_state.dart';
import '../../domain/entities/ble_device.dart';
import 'package:logger/logger.dart';

@RoutePage()
class MyDevicePage extends StatefulWidget {
  const MyDevicePage({super.key});

  @override
  State<MyDevicePage> createState() => _MyDevicePageState();
}

class _MyDevicePageState extends State<MyDevicePage> {
  final Logger _logger = Logger();

  @override
  void initState() {
    super.initState();
    _startScan();
  }

  void _startScan() {
    _logger.d('Triggering scan from MyDevicePage');
    context.read<MyDeviceBloc>().add(ScanDevicesEvent());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Device'),
        backgroundColor: const Color(0xFF1F2225),
      ),
      backgroundColor: const Color(0xFF1F2225),
      body: BlocConsumer<MyDeviceBloc, MyDeviceState>(
        listener: (context, state) {
          _logger.d('State changed in MyDevicePage: ${state.runtimeType}');
          if (state is MyDeviceError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          }
        },
        builder: (context, state) {
          return RefreshIndicator(
            onRefresh: () async {
              _logger.d('Pull-to-refresh triggered');
              _startScan();
            },
            child: _buildContent(state),
          );
        },
      ),
    );
  }

  Widget _buildContent(MyDeviceState state) {
    _logger.d('Building content for state: ${state.runtimeType}');
    return ListView(
      children: [
        if (state is MyDeviceScanning)
          _buildScanningIndicator()
        else if (state is MyDeviceScanned)
          _buildScanResult(state.devices)
        else if (state is MyDeviceError)
          _buildErrorMessage(state.message)
        else
          _buildEmptyList(),
      ],
    );
  }

  Widget _buildScanningIndicator() {
    return const Column(
      children: [
        SizedBox(height: 20),
        CircularProgressIndicator(color: Color(0xFF2691A5)),
        SizedBox(height: 20),
        Text(
          'Scanning for devices...',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.white),
        ),
        SizedBox(height: 20),
      ],
    );
  }

  Widget _buildScanResult(List<BleDevice> devices) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            'Found ${devices.length} devices',
            style: const TextStyle(color: Colors.white, fontSize: 18),
          ),
        ),
        _buildDeviceList(devices),
      ],
    );
  }

  Widget _buildErrorMessage(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Text(
          'Error: $message\nPull down to try again.',
          textAlign: TextAlign.center,
          style: const TextStyle(color: Colors.red),
        ),
      ),
    );
  }

  Widget _buildEmptyList() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Text(
          'No devices found.\nPull down to scan for devices.',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.white.withOpacity(0.7)),
        ),
      ),
    );
  }

  Widget _buildDeviceList(List<BleDevice> devices) {
    _logger.d('Building device list with ${devices.length} devices');
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: devices.length,
      itemBuilder: (context, index) {
        final device = devices[index];
        _logger
            .d('Building list item for device: ${device.name} (${device.id})');
        return Card(
          margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
          color: const Color(0xFF2A2D30),
          child: ListTile(
            title: Text(
              device.name,
              style: const TextStyle(color: Colors.white),
            ),
            subtitle: Text(
              device.id,
              style: TextStyle(color: Colors.white.withOpacity(0.7)),
            ),
            trailing: ElevatedButton(
              onPressed: () {
                _logger.d('Connect button pressed for device: ${device.name}');
                context.read<MyDeviceBloc>().add(ConnectDeviceEvent(device));
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2691A5),
              ),
              child: const Text('Connect'),
            ),
          ),
        );
      },
    );
  }
}
