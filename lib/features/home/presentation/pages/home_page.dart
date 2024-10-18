// lib/features/home/presentation/pages/home_page.dart
import 'package:flutter/material.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../config/routes/app_router.dart';
import '../../../my_device/presentation/bloc/my_device_bloc.dart';
import '../widgets/default_settings_box.dart';

@RoutePage()
class HomePage extends StatelessWidget {
  const HomePage({super.key});

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
              // Handle logout action
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
                        return Column(
                          children: [
                            Text(
                              'Device Status: ${_getConnectionStatus(state)}',
                              style: const TextStyle(
                                  color: Colors.white, fontSize: 18),
                            ),
                            const SizedBox(height: 10),
                            if (state is! MyDeviceConnected)
                              ElevatedButton(
                                onPressed: () {
                                  context.router.push(const MyDeviceRoute());
                                },
                                child: const Text('My Device'),
                              ),
                          ],
                        );
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
                      builder: (context, state) {
                        return DefaultSettingsBox(
                          isDeviceConnected: state is MyDeviceConnected,
                          onStartPressed: () {
                            if (state is MyDeviceConnected) {
                              context.router.push(SessionTimerRoute(
                                  durationInSeconds:
                                      30 * 60)); // 30 minutes in seconds
                            }
                          },
                        );
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

  String _getConnectionStatus(MyDeviceState state) {
    if (state is MyDeviceConnected) {
      return 'Connected';
    } else if (state is MyDeviceConnecting) {
      return 'Connecting...';
    } else {
      return 'Disconnected';
    }
  }
}
