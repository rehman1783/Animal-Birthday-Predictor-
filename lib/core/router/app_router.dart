import 'package:flutter/material.dart';
import '../../features/onboarding/presentation/screens/onboarding_screen.dart';
import '../../features/auth/presentation/screens/sign_up_screen.dart';
import '../../features/auth/presentation/screens/sign_in_screen.dart';
import '../../features/auth/presentation/screens/password_reset_screen.dart';
import '../../features/auth/presentation/screens/update_password_screen.dart';
import '../../features/auth/presentation/screens/email_verification_screen.dart';
import '../../features/main/presentation/screens/main_navigation_screen.dart';
import '../../features/animals/presentation/screens/animal_detail_screen.dart';
import '../../features/profile/presentation/screens/settings_screen.dart';

abstract class AppRouter {
  static Route<dynamic>? onGenerateRoute(RouteSettings settings) {
    if (settings.name == '/email-verification') {
      final email = (settings.arguments as String?) ?? '';
      return MaterialPageRoute(
        builder: (_) => EmailVerificationScreen(email: email),
        settings: settings,
      );
    }
    final builder = routes[settings.name];
    if (builder != null) {
      return MaterialPageRoute(
        builder: builder,
        settings: settings,
      );
    }
    return null;
  }

  static Map<String, WidgetBuilder> get routes {
    return {
      '/onboarding': (context) => const OnboardingScreen(),
      '/signup': (context) => const SignUpScreen(),
      '/signin': (context) => const SignInScreen(),
      '/reset-password': (context) => const PasswordResetScreen(),
      '/update-password': (context) => const UpdatePasswordScreen(),
      '/email-verification': (context) {
        final email = ModalRoute.of(context)?.settings.arguments as String? ?? '';
        return EmailVerificationScreen(email: email);
      },
      '/home': (context) => const MainNavigationScreen(),
      '/animal-detail': (context) => const AnimalDetailScreen(),
      '/settings': (context) => const SettingsScreen(),
    };
  }
}
