// lib/features/home/presentation/pages/home_page.dart
import 'package:flutter/material.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../config/routes/app_router.dart';
import '../../../../core/di/injection_container.dart';
import '../../../my_device/presentation/bloc/my_device_bloc.dart';
import '../../../session_timer/presentation/bloc/background_session_bloc.dart';
import '../../../settings/presentation/widgets/default_settings_box.dart';
import '../../../power_monitoring/presentation/widgets/power_monitoring_display.dart';
import '../../../power_monitoring/presentation/bloc/power_monitoring_bloc.dart';
import '../../../power_monitoring/presentation/bloc/power_monitoring_event.dart';

@RoutePage()
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _sessionDuration = 30; // Default duration in minutes

  @override
  void initState() {
    super.initState();
    context.read<MyDeviceBloc>().add(CheckConnectionStatusEvent());
  }

  void _showNoDeviceConnectedDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF2A2D30),
          title: const Text('No Device Connected',
              style: TextStyle(color: Colors.white)),
          content: const Text(
            'Please connect to a device before starting a session.',
            style: TextStyle(color: Colors.white),
          ),
          actions: <Widget>[
            TextButton(
              child:
                  const Text('OK', style: TextStyle(color: Color(0xFF2691A5))),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Connect Device',
                  style: TextStyle(color: Color(0xFF2691A5))),
              onPressed: () {
                Navigator.of(context).pop();
                context.router.push(const MyDeviceRoute());
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
      backgroundColor: const Color(0xFF1F2225),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1F2225),
        elevation: 0,
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
              // Handle avatar action if needed
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: () {
              context.router.replaceAll([const LoginRoute()]);
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 600),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    BlocBuilder<MyDeviceBloc, MyDeviceState>(
                      builder: (context, state) {
                        if (state is MyDeviceConnected) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8.0),
                            child: Text(
                              'Connected to: ${state.device.name}',
                              style: const TextStyle(
                                  color: Colors.white, fontSize: 16),
                              textAlign: TextAlign.center,
                            ),
                          );
                        }
                        return const SizedBox.shrink();
                      },
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Default Setting',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),
                    BlocBuilder<MyDeviceBloc, MyDeviceState>(
                      builder: (context, deviceState) {
                        return BlocBuilder<BackgroundSessionBloc,
                            BackgroundSessionState>(
                          builder: (context, sessionState) {
                            return DefaultSettingsBox(
                              isDeviceConnected:
                                  deviceState is MyDeviceConnected,
                              onStartPressed: () {
                                if (deviceState is MyDeviceConnected) {
                                  final durationInSeconds =
                                      _sessionDuration * 60;
                                  if (!sessionState.isRunning) {
                                    context.read<BackgroundSessionBloc>().add(
                                          StartBackgroundSession(
                                              durationInSeconds),
                                        );
                                  }
                                  context.router
                                      .push(const SessionTimerRoute());
                                } else {
                                  _showNoDeviceConnectedDialog();
                                }
                              },
                              onDurationChanged: (int newDuration) {
                                setState(() {
                                  _sessionDuration = newDuration;
                                });
                              },
                            );
                          },
                        );
                      },
                    ),
                    const SizedBox(height: 20),
                    BlocBuilder<MyDeviceBloc, MyDeviceState>(
                      builder: (context, state) {
                        if (state is MyDeviceConnected) {
                          return BlocProvider<PowerMonitoringBloc>(
                            create: (context) => getIt<PowerMonitoringBloc>()
                              ..add(const StartPowerMonitoring()),
                            child: const PowerMonitoringDisplay(),
                          );
                        }
                        return const SizedBox.shrink();
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: const Color(0xFF2A2D30),
        selectedItemColor: const Color(0xFF2691A5),
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
              icon: Icon(Icons.medical_services), label: 'Treatments'),
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(
              icon: Icon(Icons.pie_chart), label: 'Journals'),
        ],
        currentIndex: 1,
        onTap: (index) {
          if (index == 2) {
            context.router.push(const JournalRoute());
          }
        },
      ),
    );
  }
}
