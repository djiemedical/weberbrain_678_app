// lib/main.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:weberbrain_678_app/config/routes/app_router.dart';
import 'package:weberbrain_678_app/core/di/injection_container.dart' as di;
import 'package:weberbrain_678_app/features/my_device/presentation/bloc/my_device_bloc.dart';
import 'package:weberbrain_678_app/features/session_timer/presentation/bloc/background_session_bloc.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await di.init();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  MyApp({super.key});

  final _appRouter = AppRouter();

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<MyDeviceBloc>(
          create: (_) => di.getIt<MyDeviceBloc>(),
        ),
        BlocProvider<BackgroundSessionBloc>(
          create: (_) => di.getIt<BackgroundSessionBloc>(),
        ),
      ],
      child: MaterialApp.router(
        routerDelegate: _appRouter.delegate(),
        routeInformationParser: _appRouter.defaultRouteParser(),
        title: 'WeberBrain 678',
        theme: ThemeData(primarySwatch: Colors.blue),
      ),
    );
  }
}
