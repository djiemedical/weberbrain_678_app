// lib/features/authentication/presentation/bloc/auth_state.dart
import '../../domain/entities/user.dart';

abstract class AuthState {}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class AuthSuccess extends AuthState {
  final User? user;
  final String? message;

  AuthSuccess({this.user, this.message});
}

class AuthFailure extends AuthState {
  final String message;

  AuthFailure({required this.message});
}
