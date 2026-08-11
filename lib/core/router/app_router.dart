import 'package:flutter/material.dart';
import '../../features/onboarding/presentation/screens/onboarding_screen.dart';
import '../../features/auth/presentation/screens/sign_up_screen.dart';
import '../../features/auth/presentation/screens/sign_in_screen.dart';
import '../../features/auth/presentation/screens/password_reset_screen.dart';
import '../../features/auth/presentation/screens/update_password_screen.dart';
import '../../features/auth/presentation/screens/home_placeholder_screen.dart';

abstract class AppRouter {
  static Map<String, WidgetBuilder> get routes {
    return {
      '/onboarding': (context) => const OnboardingScreen(),
      '/signup': (context) => const SignUpScreen(),
      '/signin': (context) => const SignInScreen(),
      '/reset-password': (context) => const PasswordResetScreen(),
      '/update-password': (context) => const UpdatePasswordScreen(),
      '/home': (context) => const HomePlaceholderScreen(),
    };
  }
}
