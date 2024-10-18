// lib/features/splash/data/repositories/splash_repository_impl.dart
import 'package:shared_preferences/shared_preferences.dart';
import 'package:logger/logger.dart';
import '../../domain/repositories/splash_repository.dart';

class SplashRepositoryImpl implements SplashRepository {
  final SharedPreferences sharedPreferences;
  final logger = Logger();

  SplashRepositoryImpl(this.sharedPreferences);

  @override
  Future<bool> isFirstLaunch() async {
    try {
      bool isFirstLaunch = sharedPreferences.getBool('is_first_launch') ?? true;
      if (isFirstLaunch) {
        await sharedPreferences.setBool('is_first_launch', false);
      }
      return isFirstLaunch;
    } catch (e) {
      logger.e('Error checking first launch: $e');
      return true; // Assume it's the first launch if there's an error
    }
  }

  @override
  Future<bool> isUserLoggedIn() async {
    try {
      String? userToken = sharedPreferences.getString('user_token');
      return userToken != null && userToken.isNotEmpty;
    } catch (e) {
      logger.e('Error checking user login status: $e');
      return false; // Assume user is not logged in if there's an error
    }
  }
}
