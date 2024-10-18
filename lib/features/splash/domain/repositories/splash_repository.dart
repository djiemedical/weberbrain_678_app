// lib/features/splash/domain/repositories/splash_repository.dart
abstract class SplashRepository {
  Future<bool> isFirstLaunch();
  Future<bool> isUserLoggedIn();
}
