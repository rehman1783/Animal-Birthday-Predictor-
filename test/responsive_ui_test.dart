import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:animal_birthday_predictor/features/auth/data/auth_repository.dart';
import 'package:animal_birthday_predictor/features/auth/domain/user_profile.dart';
import 'package:animal_birthday_predictor/features/auth/presentation/providers/auth_provider.dart';
import 'package:animal_birthday_predictor/features/auth/presentation/screens/sign_in_screen.dart';
import 'package:animal_birthday_predictor/features/auth/presentation/screens/sign_up_screen.dart';
import 'package:animal_birthday_predictor/features/auth/presentation/screens/password_reset_screen.dart';
import 'package:animal_birthday_predictor/features/auth/presentation/screens/update_password_screen.dart';
import 'package:animal_birthday_predictor/features/auth/presentation/screens/email_verification_screen.dart';
import 'package:animal_birthday_predictor/features/profile/presentation/screens/change_password_screen.dart';

import 'package:animal_birthday_predictor/features/dashboard/presentation/screens/dashboard_home_screen.dart';
import 'package:animal_birthday_predictor/features/main/presentation/screens/main_navigation_screen.dart';
import 'package:animal_birthday_predictor/features/animals/domain/animal.dart';
import 'package:animal_birthday_predictor/features/animals/data/animal_repository.dart';
import 'package:animal_birthday_predictor/features/animals/presentation/providers/animal_provider.dart';
import 'package:animal_birthday_predictor/features/animals/presentation/screens/saved_animals_screen.dart';
import 'package:animal_birthday_predictor/features/animals/presentation/screens/species_selection_screen.dart';
import 'package:animal_birthday_predictor/features/animals/presentation/screens/animal_details_screen.dart';

import 'package:animal_birthday_predictor/features/pregnancy/presentation/screens/veterinarian_pregnancy_scans_screen.dart';
import 'package:animal_birthday_predictor/features/pregnancy/presentation/screens/advanced_pregnancy_info_screen.dart';
import 'package:animal_birthday_predictor/features/pregnancy/presentation/screens/pregnancy_module_screen.dart';
import 'package:animal_birthday_predictor/features/pregnancy/data/pregnancy_repository.dart';
import 'package:animal_birthday_predictor/features/pregnancy/presentation/providers/pregnancy_provider.dart';

import 'package:animal_birthday_predictor/features/foal/domain/foal_record.dart';
import 'package:animal_birthday_predictor/features/foal/data/foal_repository.dart';
import 'package:animal_birthday_predictor/features/foal/presentation/providers/foal_provider.dart';
import 'package:animal_birthday_predictor/features/foal/presentation/screens/foal_module_screen.dart';
import 'package:animal_birthday_predictor/features/foal/presentation/screens/congratulations_screen.dart';

import 'package:animal_birthday_predictor/features/puppy/domain/puppy.dart';
import 'package:animal_birthday_predictor/features/puppy/data/puppy_repository.dart';
import 'package:animal_birthday_predictor/features/puppy/presentation/providers/puppy_provider.dart';
import 'package:animal_birthday_predictor/features/puppy/presentation/screens/puppy_list_screen.dart';
import 'package:animal_birthday_predictor/features/puppy/presentation/screens/puppy_weight_tracker_screen.dart';
import 'package:animal_birthday_predictor/features/puppy/presentation/screens/dog_preventative_care_screen.dart';

import 'package:animal_birthday_predictor/features/contacts/data/contact_repository.dart';
import 'package:animal_birthday_predictor/features/contacts/presentation/providers/contact_provider.dart';
import 'package:animal_birthday_predictor/features/contacts/presentation/screens/contacts_directory_screen.dart';

import 'package:animal_birthday_predictor/features/certificates/presentation/screens/certificate_screen.dart';
import 'package:animal_birthday_predictor/features/profile/presentation/screens/profile_screen.dart';
import 'package:animal_birthday_predictor/features/profile/presentation/screens/settings_screen.dart';
import 'package:animal_birthday_predictor/features/profile/presentation/screens/delete_account_screen.dart';

class FakeResponsiveAuthRepository extends AuthRepository {
  @override
  Future<UserProfile?> getUserProfile(String userId) async {
    return UserProfile(
      id: userId,
      email: 'alexander.sterling.verylongemailaddress@breederfarmdomain.com',
      fullName: 'Alexander Sterling Senior Master Breeder of Champions',
      createdAt: DateTime.now(),
    );
  }
}

class FakeAnimalRepo extends AnimalRepository {
  final List<Animal> _animals = [
    Animal(
      id: 'a1',
      accountId: 'acc1',
      name: 'Starlight Majestic Champion Duchess of the Northern Realm',
      species: 'horse',
      sex: 'mare',
      breed: 'Arabian Warmblood Cross Thoroughbred',
      microchipNo: '98514100293847291',
      dna: 'DNA-99281-ST-09281',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ),
    Animal(
      id: 'a2',
      accountId: 'acc1',
      name: 'Thunderbolt Royal King Pegasus',
      species: 'horse',
      sex: 'stallion',
      breed: 'Friesian Purebred Stallion',
      microchipNo: '98514100293847292',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ),
    Animal(
      id: 'a3',
      accountId: 'acc1',
      name: 'Bella Princess Golden Bella Star',
      species: 'dog',
      sex: 'female',
      breed: 'Golden Retriever Champion',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ),
  ];

  @override
  Future<List<Animal>> getAnimals({String? species}) async {
    if (species != null) {
      return _animals.where((a) => Animal.matchesSpeciesFilter(a.species, species)).toList();
    }
    return _animals;
  }

  @override
  Future<Animal?> getAnimalById(String id) async {
    return _animals.firstWhere((a) => a.id == id, orElse: () => _animals.first);
  }
}

class FakePregnancyRepo extends PregnancyRepository {}
class FakeFoalRepo extends FoalRepository {}
class FakePuppyRepo extends PuppyRepository {}
class FakeContactRepo extends ContactRepository {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final screenSizes = [
    const Size(320, 568),  // Small Mobile (iPhone SE)
    const Size(375, 812),  // Standard Mobile (iPhone X/11/12/13/14)
    const Size(412, 915),  // Large Mobile (Pixel 7 Pro)
    const Size(768, 1024), // Tablet Portrait (iPad)
    const Size(1280, 800), // Tablet Landscape / Desktop
  ];

  final sampleAnimal = Animal(
    id: 'a1',
    accountId: 'acc1',
    name: 'Starlight Majestic Champion Duchess',
    species: 'horse',
    sex: 'mare',
    breed: 'Arabian Warmblood Cross Thoroughbred',
    microchipNo: '98514100293847291',
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
  );

  final samplePuppy = Puppy(
    id: 'p1',
    accountId: 'acc1',
    puppyName: 'Maximus Aurelius Golden Star',
    collarTagColour: 'Royal Blue',
    birthOrder: 1,
    birthWeight: '450g',
    status: 'available',
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
  );

  final sampleFoal = FoalRecord(
    id: 'f1',
    accountId: 'acc1',
    mareAnimalId: 'a1',
    foalName: 'Starlight Eclipse Royal Colt',
    stallion: 'Thunderbolt Royal King Pegasus',
    breed: 'Arabian Warmblood',
    sex: 'colt',
    dateOfBirth: DateTime.now(),
    foalMicrochipNo: '98514100293847299',
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
  );

  group('Comprehensive All-Screens Responsiveness & Zero-Overflow Tests', () {
    late FakeResponsiveAuthRepository fakeAuth;
    late FakeAnimalRepo fakeAnimal;
    late FakePregnancyRepo fakePreg;
    late FakeFoalRepo fakeFoal;
    late FakePuppyRepo fakePuppy;
    late FakeContactRepo fakeContact;

    setUp(() {
      fakeAuth = FakeResponsiveAuthRepository();
      fakeAnimal = FakeAnimalRepo();
      fakePreg = FakePregnancyRepo();
      fakeFoal = FakeFoalRepo();
      fakePuppy = FakePuppyRepo();
      fakeContact = FakeContactRepo();
    });

    List<Override> getOverrides() => [
      authRepositoryProvider.overrideWithValue(fakeAuth),
      animalRepositoryProvider.overrideWithValue(fakeAnimal),
      pregnancyRepositoryProvider.overrideWithValue(fakePreg),
      foalRepositoryProvider.overrideWithValue(fakeFoal),
      puppyRepositoryProvider.overrideWithValue(fakePuppy),
      contactRepositoryProvider.overrideWithValue(fakeContact),
    ];

    for (final size in screenSizes) {
      final sizeName = '${size.width.toInt()}x${size.height.toInt()}';

      // 1. DashboardHomeScreen
      testWidgets('DashboardHomeScreen renders without overflow on $sizeName', (tester) async {
        tester.view.physicalSize = size;
        tester.view.devicePixelRatio = 1.0;
        addTearDown(() => tester.view.resetPhysicalSize());

        await tester.pumpWidget(
          ProviderScope(
            overrides: getOverrides(),
            child: const MaterialApp(home: Scaffold(body: DashboardHomeScreen())),
          ),
        );
        await tester.pumpAndSettle();

        expect(tester.takeException(), isNull);
        expect(find.text('WELCOME TO ABP'), findsOneWidget);
      });

      // 2. MainNavigationScreen
      testWidgets('MainNavigationScreen renders without overflow on $sizeName', (tester) async {
        tester.view.physicalSize = size;
        tester.view.devicePixelRatio = 1.0;
        addTearDown(() => tester.view.resetPhysicalSize());

        await tester.pumpWidget(
          ProviderScope(
            overrides: getOverrides(),
            child: const MaterialApp(home: MainNavigationScreen()),
          ),
        );
        await tester.pumpAndSettle();

        expect(tester.takeException(), isNull);
        expect(find.text('Dashboard'), findsOneWidget);
        expect(find.text('Animals'), findsOneWidget);
      });

      // 3. SavedAnimalsScreen
      testWidgets('SavedAnimalsScreen renders without overflow on $sizeName', (tester) async {
        tester.view.physicalSize = size;
        tester.view.devicePixelRatio = 1.0;
        addTearDown(() => tester.view.resetPhysicalSize());

        await tester.pumpWidget(
          ProviderScope(
            overrides: getOverrides(),
            child: const MaterialApp(home: SavedAnimalsScreen()),
          ),
        );
        await tester.pumpAndSettle();

        expect(tester.takeException(), isNull);
        expect(find.text('SAVED ANIMALS REGISTRY'), findsOneWidget);
      });

      // 4. SpeciesSelectionScreen
      testWidgets('SpeciesSelectionScreen renders without overflow on $sizeName', (tester) async {
        tester.view.physicalSize = size;
        tester.view.devicePixelRatio = 1.0;
        addTearDown(() => tester.view.resetPhysicalSize());

        await tester.pumpWidget(
          ProviderScope(
            overrides: getOverrides(),
            child: const MaterialApp(home: SpeciesSelectionScreen()),
          ),
        );
        await tester.pumpAndSettle();

        expect(tester.takeException(), isNull);
        expect(find.text('SELECT SPECIES'), findsOneWidget);
      });

      // 5. AnimalDetailsScreen
      testWidgets('AnimalDetailsScreen renders without overflow on $sizeName', (tester) async {
        tester.view.physicalSize = size;
        tester.view.devicePixelRatio = 1.0;
        addTearDown(() => tester.view.resetPhysicalSize());

        await tester.pumpWidget(
          ProviderScope(
            overrides: getOverrides(),
            child: MaterialApp(home: AnimalDetailsScreen(animal: sampleAnimal)),
          ),
        );
        await tester.pumpAndSettle();

        expect(tester.takeException(), isNull);
        expect(find.byType(AnimalDetailsScreen), findsOneWidget);
      });

      // 6. PregnancyModuleScreen
      testWidgets('PregnancyModuleScreen renders without overflow on $sizeName', (tester) async {
        tester.view.physicalSize = size;
        tester.view.devicePixelRatio = 1.0;
        addTearDown(() => tester.view.resetPhysicalSize());

        await tester.pumpWidget(
          ProviderScope(
            overrides: getOverrides(),
            child: const MaterialApp(home: PregnancyModuleScreen()),
          ),
        );
        await tester.pumpAndSettle();

        expect(tester.takeException(), isNull);
        expect(find.text('PREGNANCY & BREEDING TRACKER'), findsOneWidget);
      });

      // 7. VeterinarianPregnancyScansScreen
      testWidgets('VeterinarianPregnancyScansScreen renders without overflow on $sizeName', (tester) async {
        tester.view.physicalSize = size;
        tester.view.devicePixelRatio = 1.0;
        addTearDown(() => tester.view.resetPhysicalSize());

        await tester.pumpWidget(
          ProviderScope(
            overrides: getOverrides(),
            child: const MaterialApp(home: VeterinarianPregnancyScansScreen(carrierAnimalId: 'a1')),
          ),
        );
        await tester.pumpAndSettle();

        expect(tester.takeException(), isNull);
        expect(find.text('VET CONTACT & SCANS OVERVIEW'), findsOneWidget);
      });

      // 8. AdvancedPregnancyInfoScreen
      testWidgets('AdvancedPregnancyInfoScreen renders without overflow on $sizeName', (tester) async {
        tester.view.physicalSize = size;
        tester.view.devicePixelRatio = 1.0;
        addTearDown(() => tester.view.resetPhysicalSize());

        await tester.pumpWidget(
          ProviderScope(
            overrides: getOverrides(),
            child: const MaterialApp(home: AdvancedPregnancyInfoScreen(pregnancyRecordId: 'pr1')),
          ),
        );
        await tester.pumpAndSettle();

        expect(tester.takeException(), isNull);
        expect(find.text('ADVANCED PREGNANCY INFO'), findsOneWidget);
      });

      // 9. FoalModuleScreen
      testWidgets('FoalModuleScreen renders without overflow on $sizeName', (tester) async {
        tester.view.physicalSize = size;
        tester.view.devicePixelRatio = 1.0;
        addTearDown(() => tester.view.resetPhysicalSize());

        await tester.pumpWidget(
          ProviderScope(
            overrides: getOverrides(),
            child: const MaterialApp(home: FoalModuleScreen()),
          ),
        );
        await tester.pumpAndSettle();

        expect(tester.takeException(), isNull);
        expect(find.text('BIRTH LOG & REGISTRY'), findsOneWidget);
      });

      // 10. PuppyListScreen
      testWidgets('PuppyListScreen renders without overflow on $sizeName', (tester) async {
        tester.view.physicalSize = size;
        tester.view.devicePixelRatio = 1.0;
        addTearDown(() => tester.view.resetPhysicalSize());

        await tester.pumpWidget(
          ProviderScope(
            overrides: getOverrides(),
            child: const MaterialApp(home: PuppyListScreen(damId: 'a1')),
          ),
        );
        await tester.pumpAndSettle();

        expect(tester.takeException(), isNull);
        expect(find.text('PUPPY REGISTRY & LITTERS'), findsOneWidget);
      });

      // 11. PuppyWeightTrackerScreen
      testWidgets('PuppyWeightTrackerScreen renders without overflow on $sizeName', (tester) async {
        tester.view.physicalSize = size;
        tester.view.devicePixelRatio = 1.0;
        addTearDown(() => tester.view.resetPhysicalSize());

        await tester.pumpWidget(
          ProviderScope(
            overrides: getOverrides(),
            child: MaterialApp(home: PuppyWeightTrackerScreen(puppy: samplePuppy)),
          ),
        );
        await tester.pumpAndSettle();

        expect(tester.takeException(), isNull);
      });

      // 12. DogPreventativeCareScreen
      testWidgets('DogPreventativeCareScreen renders without overflow on $sizeName', (tester) async {
        tester.view.physicalSize = size;
        tester.view.devicePixelRatio = 1.0;
        addTearDown(() => tester.view.resetPhysicalSize());

        await tester.pumpWidget(
          ProviderScope(
            overrides: getOverrides(),
            child: MaterialApp(home: DogPreventativeCareScreen(ownerType: 'puppy', ownerId: samplePuppy.id, title: 'Puppy Care')),
          ),
        );
        await tester.pumpAndSettle();

        expect(tester.takeException(), isNull);
      });

      // 13. ContactsDirectoryScreen
      testWidgets('ContactsDirectoryScreen renders without overflow on $sizeName', (tester) async {
        tester.view.physicalSize = size;
        tester.view.devicePixelRatio = 1.0;
        addTearDown(() => tester.view.resetPhysicalSize());

        await tester.pumpWidget(
          ProviderScope(
            overrides: getOverrides(),
            child: const MaterialApp(home: ContactsDirectoryScreen()),
          ),
        );
        await tester.pumpAndSettle();

        expect(tester.takeException(), isNull);
        expect(find.text('CONTACTS DIRECTORY'), findsOneWidget);
      });

      // 14. CongratulationsScreen
      testWidgets('CongratulationsScreen renders without overflow on $sizeName', (tester) async {
        tester.view.physicalSize = size;
        tester.view.devicePixelRatio = 1.0;
        addTearDown(() => tester.view.resetPhysicalSize());

        await tester.pumpWidget(
          const MaterialApp(home: CongratulationsScreen(species: 'Equine')),
        );
        await tester.pumpAndSettle();

        expect(tester.takeException(), isNull);
        expect(find.text('CONGRATULATIONS!'), findsOneWidget);
      });

      // 15. CertificateScreen
      testWidgets('CertificateScreen renders without overflow on $sizeName', (tester) async {
        tester.view.physicalSize = size;
        tester.view.devicePixelRatio = 1.0;
        addTearDown(() => tester.view.resetPhysicalSize());

        await tester.pumpWidget(
          ProviderScope(
            overrides: getOverrides(),
            child: MaterialApp(home: CertificateScreen(foal: sampleFoal, dam: sampleAnimal)),
          ),
        );
        await tester.pumpAndSettle();

        expect(tester.takeException(), isNull);
        expect(find.text('FOAL CERTIFICATE'), findsOneWidget);
      });

      // 16. ProfileScreen
      testWidgets('ProfileScreen renders without overflow on $sizeName', (tester) async {
        tester.view.physicalSize = size;
        tester.view.devicePixelRatio = 1.0;
        addTearDown(() => tester.view.resetPhysicalSize());

        await tester.pumpWidget(
          ProviderScope(
            overrides: getOverrides(),
            child: const MaterialApp(home: ProfileScreen()),
          ),
        );
        await tester.pumpAndSettle();

        expect(tester.takeException(), isNull);
        expect(find.text('User Profile'), findsOneWidget);
        expect(find.text('Danger Zone'), findsOneWidget);
      });

      // 17. SettingsScreen
      testWidgets('SettingsScreen renders without overflow on $sizeName', (tester) async {
        tester.view.physicalSize = size;
        tester.view.devicePixelRatio = 1.0;
        addTearDown(() => tester.view.resetPhysicalSize());

        await tester.pumpWidget(
          ProviderScope(
            overrides: getOverrides(),
            child: const MaterialApp(home: SettingsScreen()),
          ),
        );
        await tester.pumpAndSettle();

        expect(tester.takeException(), isNull);
        expect(find.text('App Settings'), findsOneWidget);
      });

      // 18. DeleteAccountScreen
      testWidgets('DeleteAccountScreen renders without overflow on $sizeName', (tester) async {
        tester.view.physicalSize = size;
        tester.view.devicePixelRatio = 1.0;
        addTearDown(() => tester.view.resetPhysicalSize());

        await tester.pumpWidget(
          ProviderScope(
            overrides: getOverrides(),
            child: const MaterialApp(home: DeleteAccountScreen()),
          ),
        );
        await tester.pumpAndSettle();

        expect(tester.takeException(), isNull);
        expect(find.text('Permanent Account Deletion'), findsOneWidget);
      });

      // 19. SignInScreen
      testWidgets('SignInScreen renders without overflow on $sizeName', (tester) async {
        tester.view.physicalSize = size;
        tester.view.devicePixelRatio = 1.0;
        addTearDown(() => tester.view.resetPhysicalSize());

        await tester.pumpWidget(
          ProviderScope(
            overrides: getOverrides(),
            child: const MaterialApp(home: SignInScreen()),
          ),
        );
        await tester.pumpAndSettle();

        expect(tester.takeException(), isNull);
      });

      // 20. SignUpScreen
      testWidgets('SignUpScreen renders without overflow on $sizeName', (tester) async {
        tester.view.physicalSize = size;
        tester.view.devicePixelRatio = 1.0;
        addTearDown(() => tester.view.resetPhysicalSize());

        await tester.pumpWidget(
          ProviderScope(
            overrides: getOverrides(),
            child: const MaterialApp(home: SignUpScreen()),
          ),
        );
        await tester.pumpAndSettle();

        expect(tester.takeException(), isNull);
      });

      // 21. PasswordResetScreen
      testWidgets('PasswordResetScreen renders without overflow on $sizeName', (tester) async {
        tester.view.physicalSize = size;
        tester.view.devicePixelRatio = 1.0;
        addTearDown(() => tester.view.resetPhysicalSize());

        await tester.pumpWidget(
          ProviderScope(
            overrides: getOverrides(),
            child: const MaterialApp(home: PasswordResetScreen()),
          ),
        );
        await tester.pumpAndSettle();

        expect(tester.takeException(), isNull);
      });

      // 22. UpdatePasswordScreen
      testWidgets('UpdatePasswordScreen renders without overflow on $sizeName', (tester) async {
        tester.view.physicalSize = size;
        tester.view.devicePixelRatio = 1.0;
        addTearDown(() => tester.view.resetPhysicalSize());

        await tester.pumpWidget(
          ProviderScope(
            overrides: getOverrides(),
            child: const MaterialApp(home: UpdatePasswordScreen()),
          ),
        );
        await tester.pumpAndSettle();

        expect(tester.takeException(), isNull);
      });

      // 23. EmailVerificationScreen
      testWidgets('EmailVerificationScreen renders without overflow on $sizeName', (tester) async {
        tester.view.physicalSize = size;
        tester.view.devicePixelRatio = 1.0;
        addTearDown(() => tester.view.resetPhysicalSize());

        await tester.pumpWidget(
          ProviderScope(
            overrides: getOverrides(),
            child: const MaterialApp(
              home: EmailVerificationScreen(
                email: 'alexander.sterling.verylongemailaddress@breederfarmdomain.com',
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(tester.takeException(), isNull);
      });

      // 24. ChangePasswordScreen
      testWidgets('ChangePasswordScreen renders without overflow on $sizeName', (tester) async {
        tester.view.physicalSize = size;
        tester.view.devicePixelRatio = 1.0;
        addTearDown(() => tester.view.resetPhysicalSize());

        await tester.pumpWidget(
          ProviderScope(
            overrides: getOverrides(),
            child: const MaterialApp(home: ChangePasswordScreen()),
          ),
        );
        await tester.pumpAndSettle();

        expect(tester.takeException(), isNull);
        expect(find.text('Change Password'), findsWidgets);
      });
    }
  });
}
