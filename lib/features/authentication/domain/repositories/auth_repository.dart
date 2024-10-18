// lib/features/authentication/domain/repositories/auth_repository.dart
import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/user.dart';

abstract class AuthRepository {
  Future<Either<Failure, User>> login(String email, String password);
  Future<Either<Failure, User>> register(
      String email, String password, String name);
  Future<Either<Failure, void>> forgotPassword(String email);
}
