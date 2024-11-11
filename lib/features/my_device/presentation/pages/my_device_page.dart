// lib/features/my_device/presentation/pages/my_device_page.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:auto_route/auto_route.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'dart:io';

import '../bloc/my_device_bloc.dart';
import '../../domain/entities/ble_device.dart';
import '../../../../config/routes/app_router.dart';
import '../../../../core/services/ble/infrastructure/ble_service.dart';

@RoutePage()
class MyDevicePage extends StatefulWidget {
  const MyDevicePage({super.key});

  @override
  State<MyDevicePage> createState() => _MyDevicePageState();
}

class _MyDevicePageState extends State<MyDevicePage>
    with WidgetsBindingObserver {
  final Logger _logger = Logger();
  StreamSubscription<BluetoothAdapterState>? _bluetoothStateSubscription;
  final BleService _bleService = GetIt.instance<BleService>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _setupBluetoothStateMonitoring();
    _checkConnectionStatus();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _bluetoothStateSubscription?.cancel();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _checkBluetoothAndPermissions();
    }
  }

  Future<void> _checkBluetoothAndPermissions() async {
    if (!mounted) return;

    // Check Bluetooth state
    final bluetoothState = await FlutterBluePlus.adapterState.first;
    if (bluetoothState == BluetoothAdapterState.off) {
      if (!mounted) return;
      _showEnableBluetoothDialog();
      return;
    }

    // Check permissions
    if (await _checkPermissions()) {
      if (!mounted) return;
      _checkConnectionStatus();
    }
  }

  Future<bool> _checkPermissions() async {
    final bluetoothScan = await Permission.bluetoothScan.status;
    final bluetoothConnect = await Permission.bluetoothConnect.status;
    final location = await Permission.location.status;

    _logger.d('Permission status check:'
        '\nBluetooth Scan: $bluetoothScan'
        '\nBluetooth Connect: $bluetoothConnect'
        '\nLocation: $location');

    return bluetoothScan.isGranted &&
        bluetoothConnect.isGranted &&
        location.isGranted;
  }

  void _setupBluetoothStateMonitoring() {
    _bluetoothStateSubscription = _bleService.bluetoothState.listen((state) {
      if (!mounted) return;
      if (state == BluetoothAdapterState.off) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Bluetooth is turned off'),
            duration: Duration(seconds: 3),
          ),
        );
      }
    });
  }

  void _checkConnectionStatus() {
    _logger.d('Checking connection status');
    context.read<MyDeviceBloc>().add(CheckConnectionStatusEvent());
  }

  Future<bool> _requestPermissions() async {
    _logger.d('Starting permission checks...');

    // Check Location Permission first (required for BLE scanning on Android)
    var locationStatus = await Permission.location.request();
    if (locationStatus.isDenied || locationStatus.isPermanentlyDenied) {
      _logger.w('Location permission denied: $locationStatus');
      if (!mounted) return false;
      if (locationStatus.isPermanentlyDenied) {
        final shouldOpenSettings =
            await _showPermissionSettingsDialog('Location');
        if (shouldOpenSettings) {
          await openAppSettings();
        }
      }
      return false;
    }

    // Check Bluetooth permissions (only on Android)
    if (Platform.isAndroid) {
      var bluetoothScan = await Permission.bluetoothScan.request();
      var bluetoothConnect = await Permission.bluetoothConnect.request();

      // Log the results
      _logger.d('Permission request results:'
          '\nBluetooth Scan: $bluetoothScan'
          '\nBluetooth Connect: $bluetoothConnect'
          '\nLocation: $locationStatus');

      return bluetoothScan.isGranted &&
          bluetoothConnect.isGranted &&
          locationStatus.isGranted;
    }

    // On iOS, assume Bluetooth permissions are granted
    return true;
  }

  Future<bool> _showPermissionSettingsDialog(String permissionType) async {
    return await showDialog<bool>(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return AlertDialog(
              backgroundColor: const Color(0xFF2A2D30),
              title: const Text(
                'Permissions Required',
                style: TextStyle(color: Colors.white),
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '$permissionType permission is required for scanning and connecting to WeH devices. '
                      'Please enable it in Settings.',
                      style: const TextStyle(color: Colors.white),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text(
                    'Cancel',
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  child: const Text(
                    'Open Settings',
                    style: TextStyle(color: Color(0xFF2691A5)),
                  ),
                ),
              ],
            );
          },
        ) ??
        false;
  }

  void _showEnableBluetoothDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF2A2D30),
          title: const Text(
            'Bluetooth Required',
            style: TextStyle(color: Colors.white),
          ),
          content: const Text(
            'Please enable Bluetooth to scan and connect to devices.',
            style: TextStyle(color: Colors.white),
          ),
          actions: [
            TextButton(
              child: const Text(
                'OK',
                style: TextStyle(color: Color(0xFF2691A5)),
              ),
              onPressed: () => Navigator.pop(context),
            ),
          ],
        );
      },
    );
  }

  Future<void> _startScan() async {
    _logger.d('Starting scan process...');

    if (!mounted) return;

    // Check Bluetooth availability first
    if (!await _bleService.isBluetoothAvailable()) {
      if (!mounted) return;
      _logger.d('Bluetooth is not available');
      _showEnableBluetoothDialog();
      return;
    }

    // Request permissions if not already granted
    if (!await _checkPermissions()) {
      if (!mounted) return;
      _logger.d('Requesting permissions...');
      if (!await _requestPermissions()) {
        if (!mounted) return;
        _logger.w('Required permissions not granted');
        return;
      }
    }

    // Double check Bluetooth state before scanning
    final bluetoothState = await FlutterBluePlus.adapterState.first;
    if (bluetoothState != BluetoothAdapterState.on) {
      if (!mounted) return;
      _logger.w('Bluetooth is not enabled. Current state: $bluetoothState');
      _showEnableBluetoothDialog();
      return;
    }

    // Start scanning
    if (!mounted) return;
    _logger.d('All checks passed, starting device scan');
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
              child: const Text(
                'OK',
                style: TextStyle(color: Color(0xFF2691A5)),
              ),
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

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: const Color(0xFF1F2225),
      leadingWidth: 150,
      leading: Padding(
        padding: const EdgeInsets.all(8.0),
        child: SvgPicture.asset(
          'assets/images/logoNavigation.svg',
          fit: BoxFit.contain,
          width: 85,
          height: 85,
        ),
      ),
      actions: [
        BlocBuilder<MyDeviceBloc, MyDeviceState>(
          builder: (context, state) {
            return IconButton(
              icon: Icon(
                Icons.bluetooth,
                color: state is MyDeviceConnected ? Colors.blue : Colors.grey,
              ),
              onPressed: () {
                context.router.push(const MyDeviceRoute());
              },
            );
          },
        ),
        IconButton(
          icon: const Icon(Icons.notifications, color: Colors.white),
          onPressed: () {
            // Handle notification action
          },
        ),
        IconButton(
          icon: const Icon(Icons.account_circle, color: Colors.white),
          onPressed: () {
            // Handle avatar action
          },
        ),
        IconButton(
          icon: const Icon(Icons.logout, color: Colors.white),
          onPressed: () {
            context.router.replaceAll([const LoginRoute()]);
          },
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(context),
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
              await _startScan();
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
    if (devices.isEmpty) {
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
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              device.id,
              style: TextStyle(color: Colors.white.withOpacity(0.7)),
            ),
            // Signal strength display removed as rssi is not defined
          ],
        ),
        trailing: ElevatedButton(
          onPressed: () {
            context.read<MyDeviceBloc>().add(ConnectDeviceEvent(device));
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF2691A5),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
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
                    fontWeight: FontWeight.bold,
                  ),
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
              style: TextStyle(
                color: Colors.white.withOpacity(0.7),
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      context
                          .read<MyDeviceBloc>()
                          .add(DisconnectDeviceEvent(device));
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: const Text('Disconnect'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
