// lib/features/authentication/data/repositories/auth_repository_impl.dart
import 'package:dartz/dartz.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_data_source.dart';
import '../../../../core/error/failures.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;

  AuthRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, User>> login(String email, String password) async {
    try {
      final user = await remoteDataSource.login(email, password);
      return Right(user);
    } catch (e) {
      return Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, User>> register(
      String email, String password, String name) async {
    try {
      final user = await remoteDataSource.register(email, password, name);
      return Right(user);
    } catch (e) {
      return Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, void>> forgotPassword(String email) async {
    try {
      await remoteDataSource.forgotPassword(email);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure());
    }
  }
}
