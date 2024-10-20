// lib/features/my_device/presentation/pages/my_device_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:auto_route/auto_route.dart';
import '../bloc/my_device_bloc.dart';
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
    _checkConnectionStatus();
  }

  void _checkConnectionStatus() {
    _logger.d('Checking connection status');
    context.read<MyDeviceBloc>().add(CheckConnectionStatusEvent());
  }

  void _startScan() {
    _logger.d('Starting device scan');
    context.read<MyDeviceBloc>().add(ScanDevicesEvent());
  }

  String _maskDeviceName(String name) {
    return name.replaceAll('_', '-');
  }

  void _showConnectionDialog(
      BuildContext context, BleDevice device, bool isConnecting) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          backgroundColor: const Color(0xFF2A2D30),
          title: Text(
            isConnecting ? 'Connecting' : 'Disconnecting',
            style: const TextStyle(color: Colors.white),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(color: Color(0xFF2691A5)),
              const SizedBox(height: 16),
              Text(
                isConnecting
                    ? 'Connecting to ${_maskDeviceName(device.name)}...'
                    : 'Disconnecting from ${_maskDeviceName(device.name)}...',
                style: const TextStyle(color: Colors.white),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showConnectionSuccessDialog(
      BuildContext context, BleDevice device, bool isConnected) {
    Navigator.of(context).pop(); // Dismiss the connection/disconnection dialog
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          backgroundColor: const Color(0xFF2A2D30),
          title: Text(
            isConnected ? 'Connection Successful' : 'Disconnection Successful',
            style: const TextStyle(color: Colors.white),
          ),
          content: Text(
            isConnected
                ? 'Successfully connected to ${_maskDeviceName(device.name)}'
                : 'Successfully disconnected from ${_maskDeviceName(device.name)}',
            style: const TextStyle(color: Colors.white),
          ),
          actions: <Widget>[
            TextButton(
              child:
                  const Text('OK', style: TextStyle(color: Color(0xFF2691A5))),
              onPressed: () {
                Navigator.of(dialogContext).pop();
                if (!isConnected) {
                  _startScan(); // Restart scanning after disconnection
                }
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
        title: const Text('My Device', style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF1F2225),
        iconTheme: const IconThemeData(
            color: Colors.white), // This makes the back icon white
      ),
      backgroundColor: const Color(0xFF1F2225),
      body: BlocConsumer<MyDeviceBloc, MyDeviceState>(
        listener: (context, state) {
          if (state is MyDeviceConnecting) {
            _showConnectionDialog(context, state.device, true);
          } else if (state is MyDeviceConnected) {
            _showConnectionSuccessDialog(context, state.device, true);
          } else if (state is MyDeviceDisconnecting) {
            _showConnectionDialog(context, state.device, false);
          } else if (state is MyDeviceDisconnected) {
            _showConnectionSuccessDialog(context, state.device, false);
          }
        },
        builder: (context, state) {
          return RefreshIndicator(
            onRefresh: () async {
              _startScan();
              await Future.delayed(const Duration(seconds: 2));
            },
            child: CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Paired Devices',
                          style: Theme.of(context)
                              .textTheme
                              .titleLarge
                              ?.copyWith(color: Colors.white),
                        ),
                        const SizedBox(height: 16),
                        _buildContent(state),
                      ],
                    ),
                  ),
                ),
              ],
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
            SizedBox(height: 16),
            Text('Scanning for devices...',
                style: TextStyle(color: Colors.white)),
          ],
        ),
      );
    } else if (state is MyDeviceScanned) {
      return _buildDeviceList(state.devices);
    } else if (state is MyDeviceConnected) {
      return _buildConnectedDevice(state.device);
    } else if (state is MyDeviceError) {
      return Center(
        child: Text(
          state.message,
          style: const TextStyle(color: Colors.red),
        ),
      );
    } else {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'No devices found',
              style: TextStyle(color: Colors.white),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _startScan,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2691A5),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20)),
              ),
              child: const Text('Scan for Devices'),
            ),
          ],
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
        return _buildDeviceCard(device);
      },
    );
  }

  Widget _buildDeviceCard(BleDevice device) {
    final deviceType = device.name.substring(4, 7);
    final iconColor = deviceType == '678' ? Colors.blue : Colors.green;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 0),
      color: const Color(0xFF2A2D30),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: CircleAvatar(
          backgroundColor: iconColor.withOpacity(0.2),
          child: Icon(Icons.bluetooth, color: iconColor),
        ),
        title: Text(
          _maskDeviceName(device.name),
          style:
              const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
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
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          ),
          child: const Text('Connect'),
        ),
      ),
    );
  }

  Widget _buildConnectedDevice(BleDevice device) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 0),
      color: const Color(0xFF2A2D30),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.bluetooth_connected, color: Colors.green),
                SizedBox(width: 8),
                Text(
                  'Connected Device',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              _maskDeviceName(device.name),
              style: const TextStyle(color: Colors.white, fontSize: 16),
            ),
            Text(
              device.id,
              style:
                  TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 14),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                context.read<MyDeviceBloc>().add(DisconnectDeviceEvent(device));
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20)),
              ),
              child: const Text('Disconnect'),
            ),
          ],
        ),
      ),
    );
  }
}
