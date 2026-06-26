import 'package:go_router/go_router.dart';
import 'screens/splash_screen.dart';
import 'screens/phone_screen.dart';
import 'screens/login_screen.dart';
import 'screens/sign_up_screen.dart';
import 'screens/personalization_screen.dart';

import 'screens/home_screen.dart';

class AppRouter {
  AppRouter._();

  static const splash = '/';
  static const phone = '/phone';
  static const login = '/login';
  static const signUp = '/sign-up';
  static const personalization = '/personalization';
  static const home = '/home';

  static final GoRouter router = GoRouter(
    initialLocation: splash,
    routes: [
      GoRoute(
        path: splash,
        pageBuilder: (_, __) => const NoTransitionPage(child: SplashScreen()),
      ),
      GoRoute(
        path: phone,
        pageBuilder: (_, __) => const NoTransitionPage(child: PhoneScreen()),
      ),
      GoRoute(
        path: login,
        builder: (_, __) => const LoginScreen(),
      ),
      GoRoute(
        path: signUp,
        builder: (_, __) => const SignUpScreen(),
      ),
      GoRoute(
        path: personalization,
        builder: (_, __) => const PersonalizationScreen(),
      ),
      GoRoute(
        path: home,
        builder: (_, __) => const HomeScreen(),
      ),
    ],
  );

}
