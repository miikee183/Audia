import 'package:go_router/go_router.dart';
import 'screens/splash_screen.dart';
import 'screens/phone_screen.dart';
import 'screens/login_screen.dart';
import 'screens/sign_up_screen.dart';
import 'screens/personalization_screen.dart';
import 'screens/code_verification_screen.dart';
import 'screens/home_screen.dart';

class AppRouter {
  AppRouter._();

  static const splash = '/';
  static const phone = '/phone';
  static const login = '/login';
  static const signUp = '/sign-up';
  static const personalization = '/personalization';
  static const codeVerification = '/verify-code';
  static const home = '/home';

  static final GoRouter router = GoRouter(
    initialLocation: splash,
    routes: [
      GoRoute(
        path: splash,
        pageBuilder: (_, _) => const NoTransitionPage(child: SplashScreen()),
      ),
      GoRoute(
        path: phone,
        pageBuilder: (_, _) => const NoTransitionPage(child: PhoneScreen()),
      ),
      GoRoute(
        path: codeVerification,
        builder: (_, state) => CodeVerificationScreen(
          telefono: state.uri.queryParameters['telefono'] ?? '',
        ),
      ),
      GoRoute(
        path: login,
        builder: (_, state) => LoginScreen(
          telefono: state.uri.queryParameters['telefono'],
        ),
      ),
      GoRoute(
        path: signUp,
        builder: (_, state) => SignUpScreen(
          telefono: state.uri.queryParameters['telefono'],
        ),
      ),
      GoRoute(
        path: personalization,
        builder: (_, _) => const PersonalizationScreen(),
      ),
      GoRoute(
        path: home,
        builder: (_, _) => const HomeScreen(),
      ),
    ],
  );

}
