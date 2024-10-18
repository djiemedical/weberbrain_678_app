// lib/features/splash/presentation/bloc/splash_bloc.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/splash_repository.dart';
import 'package:logger/logger.dart';

enum SplashStatus { initial, loading, completed, error }

class SplashState {
  final SplashStatus status;
  final bool isFirstLaunch;
  final bool isUserLoggedIn;

  SplashState({
    this.status = SplashStatus.initial,
    this.isFirstLaunch = false,
    this.isUserLoggedIn = false,
  });

  SplashState copyWith({
    SplashStatus? status,
    bool? isFirstLaunch,
    bool? isUserLoggedIn,
  }) {
    return SplashState(
      status: status ?? this.status,
      isFirstLaunch: isFirstLaunch ?? this.isFirstLaunch,
      isUserLoggedIn: isUserLoggedIn ?? this.isUserLoggedIn,
    );
  }

  @override
  String toString() =>
      'SplashState(status: $status, isFirstLaunch: $isFirstLaunch, isUserLoggedIn: $isUserLoggedIn)';
}

class SplashBloc extends Cubit<SplashState> {
  final SplashRepository repository;
  final logger = Logger();

  SplashBloc(this.repository) : super(SplashState());

  Future<void> checkInitialStatus() async {
    logger.d('Checking initial status');
    emit(state.copyWith(status: SplashStatus.loading));

    try {
      final isFirstLaunch = await repository.isFirstLaunch();
      final isUserLoggedIn = await repository.isUserLoggedIn();

      logger
          .d('isFirstLaunch: $isFirstLaunch, isUserLoggedIn: $isUserLoggedIn');

      emit(state.copyWith(
        status: SplashStatus.completed,
        isFirstLaunch: isFirstLaunch,
        isUserLoggedIn: isUserLoggedIn,
      ));
    } catch (e) {
      logger.e('Error checking initial status: $e');
      emit(state.copyWith(status: SplashStatus.error));
    }
  }
}
