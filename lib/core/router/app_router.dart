import 'package:flutter/material.dart';

import '../../features/onboarding/presentation/screens/onboarding_screen.dart';
import '../../features/auth/presentation/screens/sign_up_screen.dart';
import '../../features/auth/presentation/screens/sign_in_screen.dart';
import '../../features/auth/presentation/screens/password_reset_screen.dart';
import '../../features/auth/presentation/screens/update_password_screen.dart';
import '../../features/auth/presentation/screens/email_verification_screen.dart';
import '../../features/main/presentation/screens/main_navigation_screen.dart';
import '../../features/animals/presentation/screens/animal_detail_screen.dart';
import '../../features/animals/presentation/screens/mare_details_screen.dart';
import '../../features/animals/presentation/screens/markings_screen.dart';
import '../../features/animals/domain/mare.dart';
import '../../features/pregnancy/presentation/screens/breeding_details_screen.dart';
import '../../features/pregnancy/presentation/screens/pregnancy_details_screen.dart';
import '../../features/pregnancy/presentation/screens/advanced_pregnancy_info_screen.dart';
import '../../features/pregnancy/presentation/screens/recipient_mare_details_screen.dart';
import '../../features/pregnancy/presentation/screens/mare_preventative_care_screen.dart';
import '../../features/foal/presentation/screens/foal_details_screen.dart';
import '../../features/foal/presentation/screens/foal_preventative_care_screen.dart';
import '../../features/foal/presentation/screens/congratulations_screen.dart';
import '../../features/foal/domain/foal_record.dart';
import '../../features/profile/presentation/screens/settings_screen.dart';

abstract class AppRouter {
  static Route<dynamic>? onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/email-verification':
        final email = (settings.arguments as String?) ?? '';
        return MaterialPageRoute(
          builder: (_) => EmailVerificationScreen(email: email),
          settings: settings,
        );

      case '/mare-details':
        final mare = settings.arguments as Mare?;
        return MaterialPageRoute(
          builder: (_) => MareDetailsScreen(mare: mare),
          settings: settings,
        );

      case '/markings':
        final args = settings.arguments as Map<String, dynamic>? ?? {};
        return MaterialPageRoute(
          builder: (_) => MarkingsScreen(
            ownerType: args['ownerType'] as String? ?? 'mare',
            ownerId: args['ownerId'] as String? ?? '',
          ),
          settings: settings,
        );

      case '/breeding-details':
        final mareId = (settings.arguments as String?) ?? '';
        return MaterialPageRoute(
          builder: (_) => BreedingDetailsScreen(mareId: mareId),
          settings: settings,
        );

      case '/pregnancy-details':
        final args = settings.arguments as Map<String, dynamic>? ?? {};
        return MaterialPageRoute(
          builder: (_) => PregnancyDetailsScreen(
            carrierType: args['carrierType'] as String? ?? 'mare',
            carrierId: args['carrierId'] as String? ?? '',
          ),
          settings: settings,
        );

      case '/advanced-pregnancy':
        final pregnancyRecordId = (settings.arguments as String?) ?? '';
        return MaterialPageRoute(
          builder: (_) => AdvancedPregnancyInfoScreen(pregnancyRecordId: pregnancyRecordId),
          settings: settings,
        );

      case '/recipient-mare-details':
        final breedingRecordId = (settings.arguments as String?) ?? '';
        return MaterialPageRoute(
          builder: (_) => RecipientMareDetailsScreen(breedingRecordId: breedingRecordId),
          settings: settings,
        );

      case '/mare-preventative-care':
        final mareId = (settings.arguments as String?) ?? '';
        return MaterialPageRoute(
          builder: (_) => MarePreventativeCareScreen(mareId: mareId),
          settings: settings,
        );

      case '/foal-details':
        final foal = settings.arguments as FoalRecord?;
        return MaterialPageRoute(
          builder: (_) => FoalDetailsScreen(foal: foal),
          settings: settings,
        );

      case '/foal-preventative-care':
        final args = settings.arguments as Map<String, dynamic>? ?? {};
        return MaterialPageRoute(
          builder: (_) => FoalPreventativeCareScreen(
            foalId: args['foalId'] as String? ?? '',
            damMareId: args['damMareId'] as String?,
          ),
          settings: settings,
        );

      case '/congratulations':
        final species = (settings.arguments as String?) ?? 'Equine';
        return MaterialPageRoute(
          builder: (_) => CongratulationsScreen(species: species),
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
      '/home': (context) => const MainNavigationScreen(),
      '/animal-detail': (context) => const AnimalDetailScreen(),
      '/settings': (context) => const SettingsScreen(),
      '/mare-details': (context) => const MareDetailsScreen(),
      '/foal-details': (context) => const FoalDetailsScreen(),
      '/congratulations': (context) => const CongratulationsScreen(),
    };
  }
}
