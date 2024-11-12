// lib/features/home/presentation/pages/home_page.dart
import 'package:flutter/material.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../shared/presentation/widgets/navigation/app_top_bar.dart';
import '../../../shared/presentation/widgets/navigation/app_bottom_bar.dart';
import '../../../shared/presentation/widgets/app_scaffold.dart';
import '../../../../config/routes/app_router.dart';
import '../../../../core/config/feature_flags.dart';
import '../../../my_device/presentation/bloc/my_device_bloc.dart';
import '../../../session_timer/presentation/bloc/background_session_bloc.dart';
import '../../../settings/presentation/widgets/default_settings_box.dart';
import '../../../power_monitoring/presentation/widgets/optical_power_chart.dart';

@RoutePage()
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _sessionDuration = 30;
  static const double _boxHeight = 200.0;
  static const double _spacing = 20.0;

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
          title: const Text(
            'No Device Connected',
            style: TextStyle(color: Colors.white),
          ),
          content: const Text(
            'Please connect to a device before starting a session.',
            style: TextStyle(color: Colors.white),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text(
                'OK',
                style: TextStyle(color: Color(0xFF2691A5)),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text(
                'Connect Device',
                style: TextStyle(color: Color(0xFF2691A5)),
              ),
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
    return AppScaffold(
      appBar: const AppTopBar(),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: constraints.maxHeight - kBottomNavigationBarHeight,
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 600),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const SizedBox(
                                height: 4), // Minimal spacing from app bar
                            // Logo Section
                            Center(
                              child: SvgPicture.asset(
                                'assets/images/logoNavigation.svg',
                                fit: BoxFit.contain,
                                width: 50,
                                height: 50,
                              ),
                            ),
                            const SizedBox(height: _spacing),
                            // Settings Box
                            BlocBuilder<MyDeviceBloc, MyDeviceState>(
                              builder: (context, deviceState) {
                                return BlocBuilder<BackgroundSessionBloc,
                                    BackgroundSessionState>(
                                  builder: (context, sessionState) {
                                    return DefaultSettingsBox(
                                      maxHeight: _boxHeight,
                                      maxWidth: double.infinity,
                                      isDeviceConnected:
                                          deviceState is MyDeviceConnected,
                                      onStartPressed: () {
                                        if (deviceState is MyDeviceConnected) {
                                          final durationInSeconds =
                                              _sessionDuration * 60;
                                          if (!sessionState.isRunning) {
                                            context
                                                .read<BackgroundSessionBloc>()
                                                .add(StartBackgroundSession(
                                                    durationInSeconds));
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
                            const SizedBox(height: _spacing),
                            if (FeatureFlags.showPowerMonitoring) ...[
                              const SizedBox(
                                width: double.infinity,
                                child: OpticalPowerChart(
                                  maxHeight: _boxHeight,
                                ),
                              ),
                              const SizedBox(height: _spacing),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
      bottomNavigationBar: const AppBottomBar(
        currentItem: AppBottomBarItem.home,
      ),
    );
  }
}
