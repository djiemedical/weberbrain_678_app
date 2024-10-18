// lib/features/authentication/domain/usecases/forgot_password_usecase.dart
import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../repositories/auth_repository.dart';

class ForgotPasswordUseCase {
  final AuthRepository repository;

  ForgotPasswordUseCase(this.repository);

  Future<Either<Failure, void>> call(ForgotPasswordParams params) async {
    return await repository.forgotPassword(params.email);
  }
}

class ForgotPasswordParams {
  final String email;

  ForgotPasswordParams({required this.email});
}
