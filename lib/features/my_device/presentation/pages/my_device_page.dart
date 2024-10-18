// lib/features/my_device/presentation/pages/my_device_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:auto_route/auto_route.dart';
import '../bloc/my_device_bloc.dart';
import '../../domain/entities/ble_device.dart';
import 'package:logger/logger.dart';
import '../../../../config/routes/app_router.dart';

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
    _logger.d('Starting device scan');
    context.read<MyDeviceBloc>().add(ScanDevicesEvent());
  }

  Future<void> _handleRefresh() async {
    _startScan();
    return Future.delayed(const Duration(seconds: 15));
  }

  String _maskDeviceName(String name) {
    return name.replaceAll('_', '-');
  }

  void _showConnectionSuccessDialog(BuildContext context, BleDevice device) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Connection Successful'),
          content:
              Text('Successfully connected to ${_maskDeviceName(device.name)}'),
          actions: <Widget>[
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(dialogContext).pop();
                context.router.replace(const HomeRoute());
              },
            ),
          ],
        );
      },
    );
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
          if (state is MyDeviceConnected) {
            _showConnectionSuccessDialog(context, state.device);
          }
        },
        builder: (context, state) {
          return RefreshIndicator(
            onRefresh: _handleRefresh,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('WEH Devices',
                        style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white)),
                    const SizedBox(height: 8),
                    _buildContent(state),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildContent(MyDeviceState state) {
    if (state is MyDeviceScanning) {
      return const Center(
        child: Column(
          children: [
            CircularProgressIndicator(color: Color(0xFF2691A5)),
            SizedBox(height: 8),
            Text('Scanning for devices...',
                style: TextStyle(color: Colors.white)),
          ],
        ),
      );
    } else if (state is MyDeviceScanned) {
      return _buildDeviceList(state.devices);
    } else if (state is MyDeviceError) {
      return Center(
        child: Text(
          state.message,
          style: const TextStyle(color: Colors.red),
        ),
      );
    } else {
      return const Center(
        child: Text(
          'Pull down to scan for devices',
          style: TextStyle(color: Colors.white),
        ),
      );
    }
  }

  Widget _buildDeviceList(List<BleDevice> devices) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: devices.length,
      itemBuilder: (context, index) {
        final device = devices[index];
        final deviceType = device.name.substring(4, 7);
        final iconColor = deviceType == '678' ? Colors.blue : Colors.green;

        return Card(
          margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
          color: const Color(0xFF2A2D30),
          child: ListTile(
            leading: Icon(Icons.bluetooth, color: iconColor),
            title: Text(
              _maskDeviceName(device.name),
              style: const TextStyle(color: Colors.white),
            ),
            subtitle: Text(
              device.id,
              style: TextStyle(color: Colors.white.withOpacity(0.7)),
            ),
            trailing: ElevatedButton(
              onPressed: () {
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
