import 'package:flutter/material.dart';

import '../../features/onboarding/presentation/screens/onboarding_screen.dart';
import '../../features/auth/presentation/screens/sign_up_screen.dart';
import '../../features/auth/presentation/screens/sign_in_screen.dart';
import '../../features/auth/presentation/screens/password_reset_screen.dart';
import '../../features/auth/presentation/screens/update_password_screen.dart';
import '../../features/auth/presentation/screens/email_verification_screen.dart';
import '../../features/main/presentation/screens/main_navigation_screen.dart';
import '../../features/animals/domain/animal.dart';
import '../../features/animals/presentation/screens/species_selection_screen.dart';
import '../../features/animals/presentation/screens/saved_animals_screen.dart';
import '../../features/animals/presentation/screens/animal_details_screen.dart';
import '../../features/animals/presentation/screens/animal_profile_screen.dart';
import '../../features/animals/presentation/screens/markings_screen.dart';
import '../../features/pregnancy/presentation/screens/breeding_details_screen.dart';
import '../../features/pregnancy/presentation/screens/pregnancy_details_screen.dart';
import '../../features/pregnancy/presentation/screens/veterinarian_pregnancy_scans_screen.dart';
import '../../features/pregnancy/presentation/screens/advanced_pregnancy_info_screen.dart';
import '../../features/pregnancy/presentation/screens/preventative_care_screen.dart';
import '../../features/foal/domain/foal_record.dart';
import '../../features/foal/presentation/screens/foal_details_screen.dart';
import '../../features/foal/presentation/screens/congratulations_screen.dart';
import '../../features/certificates/presentation/screens/certificate_screen.dart';
import '../../features/profile/presentation/screens/settings_screen.dart';
import '../../features/contacts/presentation/screens/contacts_directory_screen.dart';
import '../../features/puppy/domain/puppy.dart';
import '../../features/puppy/presentation/screens/puppy_details_screen.dart';
import '../../features/puppy/presentation/screens/puppy_list_screen.dart';
import '../../features/puppy/presentation/screens/puppy_weight_tracker_screen.dart';
import '../../features/puppy/presentation/screens/dog_preventative_care_screen.dart';

abstract class AppRouter {
  static Route<dynamic>? onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/email-verification':
        final email = (settings.arguments as String?) ?? '';
        return MaterialPageRoute(
          builder: (_) => EmailVerificationScreen(email: email),
          settings: settings,
        );

      case '/species-select':
        return MaterialPageRoute(
          builder: (_) => const SpeciesSelectionScreen(),
          settings: settings,
        );

      case '/saved-animals':
        return MaterialPageRoute(
          builder: (_) => const SavedAnimalsScreen(),
          settings: settings,
        );

      case '/animal-profile':
        final animal = settings.arguments as Animal;
        return MaterialPageRoute(
          builder: (_) => AnimalProfileScreen(animal: animal),
          settings: settings,
        );

      case '/animal-details':
      case '/mare-details':
        final args = settings.arguments;
        Animal? animal;
        String species = 'horse';
        if (args is Animal) {
          animal = args;
          species = args.species;
        } else if (args is Map<String, dynamic>) {
          animal = args['animal'] as Animal?;
          species = (args['species'] as String?) ?? 'horse';
        }
        return MaterialPageRoute(
          builder: (_) => AnimalDetailsScreen(animal: animal, species: species),
          settings: settings,
        );

      case '/markings':
        final args = settings.arguments as Map<String, dynamic>? ?? {};
        return MaterialPageRoute(
          builder: (_) => MarkingsScreen(
            ownerType: args['ownerType'] as String? ?? 'animal',
            ownerId: args['ownerId'] as String? ?? '',
          ),
          settings: settings,
        );

      case '/contacts':
        return MaterialPageRoute(
          builder: (_) => const ContactsDirectoryScreen(),
          settings: settings,
        );

      case '/puppies':
        final damId = settings.arguments as String?;
        return MaterialPageRoute(
          builder: (_) => PuppyListScreen(damId: damId),
          settings: settings,
        );

      case '/puppy-details':
        final puppy = settings.arguments as Puppy?;
        return MaterialPageRoute(
          builder: (_) => PuppyDetailsScreen(puppy: puppy),
          settings: settings,
        );

      case '/puppy-weight-tracker':
        final puppy = settings.arguments as Puppy;
        return MaterialPageRoute(
          builder: (_) => PuppyWeightTrackerScreen(puppy: puppy),
          settings: settings,
        );

      case '/dog-preventative-care':
        final args = settings.arguments as Map<String, dynamic>? ?? {};
        return MaterialPageRoute(
          builder: (_) => DogPreventativeCareScreen(
            ownerType: (args['ownerType'] as String?) ?? 'puppy',
            ownerId: (args['ownerId'] as String?) ?? '',
            title: (args['title'] as String?) ?? 'Canine',
            dateOfBirth: args['dateOfBirth'] as DateTime?,
          ),
          settings: settings,
        );

      case '/breeding-details':
        final mareId = settings.arguments is String ? (settings.arguments as String) : null;
        return MaterialPageRoute(
          builder: (_) => BreedingDetailsScreen(initialMareId: mareId),
          settings: settings,
        );

      case '/pregnancy-details':
        final args = settings.arguments as Map<String, dynamic>? ?? {};
        return MaterialPageRoute(
          builder: (_) => PregnancyDetailsScreen(
            carrierAnimalId: (args['carrierAnimalId'] as String?) ?? (args['carrierId'] as String?) ?? '',
            breedingRecordId: args['breedingRecordId'] as String?,
            pregnancyRecordId: args['pregnancyRecordId'] as String?,
          ),
          settings: settings,
        );

      case '/vet-pregnancy-scans':
      case '/pregnancy-scans':
        final args = settings.arguments as Map<String, dynamic>? ?? {};
        return MaterialPageRoute(
          builder: (_) => VeterinarianPregnancyScansScreen(
            carrierAnimalId: (args['carrierAnimalId'] as String?) ?? (args['carrierId'] as String?),
            pregnancyRecordId: args['pregnancyRecordId'] as String?,
          ),
          settings: settings,
        );

      case '/advanced-pregnancy':
        final pregnancyRecordId = (settings.arguments as String?) ?? '';
        return MaterialPageRoute(
          builder: (_) => AdvancedPregnancyInfoScreen(pregnancyRecordId: pregnancyRecordId),
          settings: settings,
        );

      case '/preventative-care':
      case '/mare-preventative-care':
        final args = settings.arguments;
        String ownerType = 'animal';
        String ownerId = '';
        String? title;
        String? damMareId;

        if (args is String) {
          ownerId = args;
        } else if (args is Map<String, dynamic>) {
          ownerType = args['ownerType'] as String? ?? 'animal';
          ownerId = args['ownerId'] as String? ?? '';
          title = args['title'] as String?;
          damMareId = args['damMareId'] as String?;
        }

        return MaterialPageRoute(
          builder: (_) => PreventativeCareScreen(
            ownerType: ownerType,
            ownerId: ownerId,
            title: title,
            damMareId: damMareId,
          ),
          settings: settings,
        );

      case '/foal-details':
        final foal = settings.arguments as FoalRecord?;
        return MaterialPageRoute(
          builder: (_) => FoalDetailsScreen(foal: foal),
          settings: settings,
        );

      case '/congratulations':
        final species = (settings.arguments as String?) ?? 'Equine';
        return MaterialPageRoute(
          builder: (_) => CongratulationsScreen(species: species),
          settings: settings,
        );

      case '/certificate':
        final args = settings.arguments as Map<String, dynamic>? ?? {};
        final foal = args['foal'] as FoalRecord?;
        final puppy = args['puppy'] as Puppy?;
        final dam = args['dam'] as Animal?;
        return MaterialPageRoute(
          builder: (_) => CertificateScreen(foal: foal, puppy: puppy, dam: dam),
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
      '/species-select': (context) => const SpeciesSelectionScreen(),
      '/saved-animals': (context) => const SavedAnimalsScreen(),
      '/animal-details': (context) => const AnimalDetailsScreen(),
      '/settings': (context) => const SettingsScreen(),
      '/contacts': (context) => const ContactsDirectoryScreen(),
      '/puppies': (context) => const PuppyListScreen(),
    };
  }
}
