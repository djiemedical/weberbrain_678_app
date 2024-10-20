// lib/features/session_timer/presentation/pages/session_timer_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../widgets/circular_timer_display.dart';
import '../widgets/control_buttons.dart';
import '../../../../config/routes/app_router.dart';
import '../../../my_device/presentation/bloc/my_device_bloc.dart';
import '../bloc/background_session_bloc.dart';

@RoutePage()
class SessionTimerPage extends StatelessWidget {
  const SessionTimerPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<BackgroundSessionBloc, BackgroundSessionState>(
      listener: (context, state) {
        if (state.isCompleted) {
          _showSessionEndDialog(context);
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xFF1F2225),
        appBar: _buildAppBar(context),
        body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 600),
                  child: const Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      SizedBox(height: 20),
                      Text(
                        'Session Timer',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 40),
                      SizedBox(
                        width: 300,
                        height: 300,
                        child: CircularTimerDisplay(),
                      ),
                      SizedBox(height: 40),
                      ControlButtons(),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
        bottomNavigationBar: _buildBottomNavigationBar(context),
      ),
    );
  }

  void _showSessionEndDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Session Ended'),
          content:
              const Text('Your session has ended. What would you like to do?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Home'),
              onPressed: () {
                context.router.popUntilRoot();
              },
            ),
            TextButton(
              child: const Text('Repeat'),
              onPressed: () {
                final bloc = context.read<BackgroundSessionBloc>();
                bloc.add(StartBackgroundSession(bloc.initialDuration));
                Navigator.of(context).pop();
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
            context.router.replaceAll([const LoginRoute()]);
          },
        ),
      ],
    );
  }

  Widget _buildBottomNavigationBar(BuildContext context) {
    return BottomNavigationBar(
      backgroundColor: const Color(0xFF2A2D30),
      selectedItemColor: const Color(0xFF2691A5),
      unselectedItemColor: Colors.grey,
      items: const [
        BottomNavigationBarItem(
            icon: Icon(Icons.medical_services), label: 'Treatments'),
        BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
        BottomNavigationBarItem(icon: Icon(Icons.pie_chart), label: 'Journals'),
      ],
      currentIndex: 1,
      onTap: (index) {
        if (index == 1) {
          context.router.push(const HomeRoute());
        } else if (index == 2) {
          context.router.push(const JournalRoute());
        }
      },
    );
  }
}
