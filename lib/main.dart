// lib/main.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:permission_handler/permission_handler.dart';
import 'config/routes/app_router.dart';
import 'core/di/injection_container.dart' as di;
import 'features/my_device/presentation/bloc/my_device_bloc.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await di.init();
  await _requestPermissions();
  runApp(MyApp());
}

Future<void> _requestPermissions() async {
  await Permission.bluetooth.request();
  await Permission.bluetoothScan.request();
  await Permission.bluetoothConnect.request();
  await Permission.location.request();
}

class MyApp extends StatelessWidget {
  MyApp({super.key});

  final _appRouter = AppRouter();

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<MyDeviceBloc>(
          create: (context) => di.getIt<MyDeviceBloc>(),
        ),
        // Add other BlocProviders here if needed
      ],
      child: MaterialApp.router(
        title: 'WeberBrain 678',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          scaffoldBackgroundColor: const Color(0xFF1F2225),
        ),
        routerDelegate: _appRouter.delegate(),
        routeInformationParser: _appRouter.defaultRouteParser(),
      ),
    );
  }
}
