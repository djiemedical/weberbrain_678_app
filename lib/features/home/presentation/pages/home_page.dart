// lib/features/home/presentation/pages/home_page.dart
import 'package:flutter/material.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../config/routes/app_router.dart';
import '../../../my_device/presentation/bloc/my_device_bloc.dart';

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
                            if (_getConnectionStatus(state) == 'Disconnected')
                              ElevatedButton(
                                onPressed: () {
                                  context.pushRoute(const MyDeviceRoute());
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
                          fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),
                    LayoutBuilder(
                      builder: (context, constraints) {
                        final buttonWidth = constraints.maxWidth * 0.9;
                        return SizedBox(
                          width: buttonWidth,
                          child: Column(
                            children: [
                              Container(
                                width: buttonWidth,
                                decoration: BoxDecoration(
                                  color: const Color(0xFF2A2D30),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                      color: Colors.white.withOpacity(0.2),
                                      width: 1),
                                ),
                                padding: const EdgeInsets.all(20),
                                child: Column(
                                  children: [
                                    ElevatedButton(
                                      onPressed: () {
                                        // Add start functionality
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor:
                                            const Color(0xFF2691A5),
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                        ),
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 15, horizontal: 80),
                                      ),
                                      child: const Text(
                                        'Start',
                                        style: TextStyle(
                                            fontSize: 24, color: Colors.white),
                                      ),
                                    ),
                                    const SizedBox(height: 20),
                                    const Text(
                                      'Duration',
                                      style: TextStyle(
                                          color: Colors.white, fontSize: 16),
                                    ),
                                    const Text(
                                      '30 mins',
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 24,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    const SizedBox(height: 20),
                                    const Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        _SettingItem(
                                            label: 'Region', value: 'All'),
                                        _SettingItem(
                                            label: 'Wavelength', value: 'All'),
                                        _SettingItem(
                                            label: 'Output Power',
                                            value: '50 %'),
                                        _SettingItem(
                                            label: 'Frequency', value: '10 Hz'),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 20),
                              SizedBox(
                                width: buttonWidth,
                                child: ElevatedButton(
                                  onPressed: () {
                                    // Add manual setting functionality
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF2691A5),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 12),
                                  ),
                                  child: const Text(
                                    'Manual Setting',
                                    style: TextStyle(
                                        fontSize: 16, color: Colors.white),
                                  ),
                                ),
                              ),
                            ],
                          ),
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
            context.pushRoute(const JournalRoute());
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

class _SettingItem extends StatelessWidget {
  final String label;
  final String value;

  const _SettingItem({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(color: Colors.grey, fontSize: 12),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
              color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}
