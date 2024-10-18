// lib/features/splash/presentation/pages/splash_page.dart
import 'package:flutter/material.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../bloc/splash_bloc.dart';
import 'package:logger/logger.dart';
import '../../../../config/routes/app_router.dart';
import '../../../../core/di/injection_container.dart';
import 'dart:async';

@RoutePage()
class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage>
    with SingleTickerProviderStateMixin {
  final logger = Logger();
  late AnimationController _controller;
  late Animation<double> _animation;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeIn,
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) {
        final bloc = getIt<SplashBloc>();
        bloc.checkInitialStatus();
        return bloc;
      },
      child: BlocListener<SplashBloc, SplashState>(
        listener: (context, state) {
          if (state.status == SplashStatus.completed) {
            _timer = Timer(const Duration(seconds: 5), () {
              _navigateBasedOnState(context, state);
            });
          }
        },
        child: Scaffold(
          backgroundColor: const Color(0xFF1F2225),
          body: SafeArea(
            child: Center(
              child: FadeTransition(
                opacity: _animation,
                child: SvgPicture.asset(
                  'assets/images/weber_brain_logo.svg',
                  height: 50,
                  colorFilter:
                      const ColorFilter.mode(Colors.white, BlendMode.srcIn),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _navigateBasedOnState(BuildContext context, SplashState state) {
    if (state.isFirstLaunch) {
      logger.d('Navigating to Onboarding');
      context.router.replace(const OnboardingRoute());
    } else if (state.isUserLoggedIn) {
      logger.d('Navigating to Home');
      context.router.replace(const HomeRoute());
    } else {
      logger.d('Navigating to Login');
      context.router.replace(const LoginRoute());
    }
  }
}
