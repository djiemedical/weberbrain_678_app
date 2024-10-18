// lib/config/routes/app_router.dart
import 'package:auto_route/auto_route.dart';
import '../../features/splash/presentation/pages/splash_page.dart';
import '../../features/onboarding/presentation/pages/onboarding_page.dart';
import '../../features/authentication/presentation/pages/login_page.dart';
import '../../features/authentication/presentation/pages/register_page.dart';
import '../../features/authentication/presentation/pages/forgot_password_page.dart';
import '../../features/home/presentation/pages/home_page.dart';
import '../../features/journal/presentation/pages/journal_page.dart';
import '../../features/my_device/presentation/pages/my_device_page.dart';

part 'app_router.gr.dart';

@AutoRouterConfig()
class AppRouter extends _$AppRouter {
  @override
  List<AutoRoute> get routes => [
        AutoRoute(page: SplashRoute.page, initial: true),
        AutoRoute(page: OnboardingRoute.page),
        AutoRoute(page: LoginRoute.page),
        AutoRoute(page: RegisterRoute.page),
        AutoRoute(page: ForgotPasswordRoute.page),
        AutoRoute(page: HomeRoute.page),
        AutoRoute(page: JournalRoute.page),
        AutoRoute(page: MyDeviceRoute.page),
      ];
}
