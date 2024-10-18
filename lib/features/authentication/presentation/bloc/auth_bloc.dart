// lib/features/authentication/presentation/bloc/auth_bloc.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/login_usecase.dart';
import '../../domain/usecases/register_usecase.dart';
import '../../domain/usecases/forgot_password_usecase.dart';
import '../../../../core/error/failures.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final LoginUseCase loginUseCase;
  final RegisterUseCase registerUseCase;
  final ForgotPasswordUseCase forgotPasswordUseCase;

  AuthBloc({
    required this.loginUseCase,
    required this.registerUseCase,
    required this.forgotPasswordUseCase,
  }) : super(AuthInitial()) {
    on<LoginRequested>(_onLoginRequested);
    on<RegisterRequested>(_onRegisterRequested);
    on<ForgotPasswordRequested>(_onForgotPasswordRequested);
  }

  Future<void> _onLoginRequested(
    LoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    final result = await loginUseCase(
        LoginParams(email: event.email, password: event.password));
    result.fold(
      (failure) => emit(AuthFailure(message: _mapFailureToMessage(failure))),
      (user) => emit(AuthSuccess(user: user)),
    );
  }

  Future<void> _onRegisterRequested(
    RegisterRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    final result = await registerUseCase(RegisterParams(
      email: event.email,
      password: event.password,
      name: event.name,
    ));
    result.fold(
      (failure) => emit(AuthFailure(message: _mapFailureToMessage(failure))),
      (user) => emit(AuthSuccess(user: user)),
    );
  }

  Future<void> _onForgotPasswordRequested(
    ForgotPasswordRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    final result =
        await forgotPasswordUseCase(ForgotPasswordParams(email: event.email));
    result.fold(
      (failure) => emit(AuthFailure(message: _mapFailureToMessage(failure))),
      (_) => emit(AuthSuccess(message: 'Password reset email sent')),
    );
  }

  String _mapFailureToMessage(Failure failure) {
    return switch (failure) {
      ServerFailure() => 'Server error occurred',
      NetworkFailure() => 'Network error occurred',
      _ => 'Unexpected error occurred',
    };
  }
}
