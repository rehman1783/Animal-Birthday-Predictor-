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
import 'package:animal_birthday_predictor/features/onboarding/presentation/screens/onboarding_screen.dart';

import 'package:animal_birthday_predictor/features/dashboard/presentation/screens/dashboard_home_screen.dart';
import 'package:animal_birthday_predictor/features/main/presentation/screens/main_navigation_screen.dart';
import 'package:animal_birthday_predictor/features/animals/domain/animal.dart';
import 'package:animal_birthday_predictor/features/animals/data/animal_repository.dart';
import 'package:animal_birthday_predictor/features/animals/presentation/providers/animal_provider.dart';
import 'package:animal_birthday_predictor/features/animals/presentation/screens/saved_animals_screen.dart';
import 'package:animal_birthday_predictor/features/animals/presentation/screens/species_selection_screen.dart';
import 'package:animal_birthday_predictor/features/animals/presentation/screens/animal_details_screen.dart';
import 'package:animal_birthday_predictor/features/animals/presentation/screens/animal_profile_screen.dart';

import 'package:animal_birthday_predictor/features/pregnancy/presentation/screens/veterinarian_pregnancy_scans_screen.dart';
import 'package:animal_birthday_predictor/features/pregnancy/presentation/screens/advanced_pregnancy_info_screen.dart';
import 'package:animal_birthday_predictor/features/pregnancy/presentation/screens/pregnancy_module_screen.dart';
import 'package:animal_birthday_predictor/features/pregnancy/presentation/screens/pregnancy_details_screen.dart';
import 'package:animal_birthday_predictor/features/pregnancy/presentation/screens/breeding_details_screen.dart';
import 'package:animal_birthday_predictor/features/pregnancy/presentation/screens/preventative_care_screen.dart';
import 'package:animal_birthday_predictor/features/pregnancy/data/pregnancy_repository.dart';
import 'package:animal_birthday_predictor/features/pregnancy/data/preventative_care_repository.dart';
import 'package:animal_birthday_predictor/features/pregnancy/domain/pregnancy_record.dart';
import 'package:animal_birthday_predictor/features/pregnancy/domain/breeding_record.dart';
import 'package:animal_birthday_predictor/features/pregnancy/domain/preventative_care_record.dart';
import 'package:animal_birthday_predictor/features/pregnancy/presentation/providers/pregnancy_provider.dart';
import 'package:animal_birthday_predictor/features/pregnancy/presentation/providers/preventative_care_provider.dart';

import 'package:animal_birthday_predictor/features/foal/domain/foal_record.dart';
import 'package:animal_birthday_predictor/features/foal/data/foal_repository.dart';
import 'package:animal_birthday_predictor/features/foal/presentation/providers/foal_provider.dart';
import 'package:animal_birthday_predictor/features/foal/presentation/screens/foal_module_screen.dart';
import 'package:animal_birthday_predictor/features/foal/presentation/screens/foal_details_screen.dart';
import 'package:animal_birthday_predictor/features/foal/presentation/screens/congratulations_screen.dart';

import 'package:animal_birthday_predictor/features/puppy/domain/puppy.dart';
import 'package:animal_birthday_predictor/features/puppy/data/puppy_repository.dart';
import 'package:animal_birthday_predictor/features/puppy/presentation/providers/puppy_provider.dart';
import 'package:animal_birthday_predictor/features/puppy/presentation/screens/puppy_list_screen.dart';
import 'package:animal_birthday_predictor/features/puppy/presentation/screens/puppy_details_screen.dart';
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

class FakePregnancyRepo extends PregnancyRepository {
  @override
  Future<PregnancyRecord?> getPregnancyRecordByCarrier(String carrierAnimalId) async {
    return PregnancyRecord(
      id: 'preg1',
      accountId: 'acc1',
      breedingRecordId: 'b1',
      carrierAnimalId: carrierAnimalId,
      scan1DueDate: DateTime.now().add(const Duration(days: 14)),
      scan2DueDate: DateTime.now().add(const Duration(days: 30)),
      scan3DueDate: DateTime.now().add(const Duration(days: 45)),
      foalingDueDate: DateTime.now().add(const Duration(days: 341)),
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  @override
  Future<PregnancyRecord?> getPregnancyRecordById(String id) async {
    return PregnancyRecord(
      id: id,
      accountId: 'acc1',
      breedingRecordId: 'b1',
      carrierAnimalId: 'a1',
      scan1DueDate: DateTime.now().add(const Duration(days: 14)),
      scan2DueDate: DateTime.now().add(const Duration(days: 30)),
      scan3DueDate: DateTime.now().add(const Duration(days: 45)),
      foalingDueDate: DateTime.now().add(const Duration(days: 341)),
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  @override
  Future<BreedingRecord?> getBreedingRecordByMare(String mareAnimalId) async {
    return BreedingRecord(
      id: 'b1',
      accountId: 'acc1',
      mareAnimalId: mareAnimalId,
      stallionName: 'Thunderbolt Royal King Pegasus',
      method: 'et',
      coverOrTransferDate: DateTime.now(),
      isEmbryoTransfer: true,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }
}

class FakePreventativeCareRepo extends PreventativeCareRepository {
  @override
  Future<PreventativeCareRecord?> getPreventativeCare(String ownerType, String ownerId) async {
    return PreventativeCareRecord(
      id: 'pc1',
      ownerType: ownerType,
      ownerId: ownerId,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }
}

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
    late FakePreventativeCareRepo fakeCare;
    late FakeFoalRepo fakeFoal;
    late FakePuppyRepo fakePuppy;
    late FakeContactRepo fakeContact;

    setUp(() {
      fakeAuth = FakeResponsiveAuthRepository();
      fakeAnimal = FakeAnimalRepo();
      fakePreg = FakePregnancyRepo();
      fakeCare = FakePreventativeCareRepo();
      fakeFoal = FakeFoalRepo();
      fakePuppy = FakePuppyRepo();
      fakeContact = FakeContactRepo();
    });

    List<Override> getOverrides() => [
      authRepositoryProvider.overrideWithValue(fakeAuth),
      animalRepositoryProvider.overrideWithValue(fakeAnimal),
      pregnancyRepositoryProvider.overrideWithValue(fakePreg),
      preventativeCareRepositoryProvider.overrideWithValue(fakeCare),
      foalRepositoryProvider.overrideWithValue(fakeFoal),
      puppyRepositoryProvider.overrideWithValue(fakePuppy),
      contactRepositoryProvider.overrideWithValue(fakeContact),
    ];

    for (final size in screenSizes) {
      final sizeName = '${size.width.toInt()}x${size.height.toInt()}';

      // 1. OnboardingScreen
      testWidgets('OnboardingScreen renders without overflow on $sizeName', (tester) async {
        tester.view.physicalSize = size;
        tester.view.devicePixelRatio = 1.0;
        addTearDown(() => tester.view.resetPhysicalSize());

        await tester.pumpWidget(
          ProviderScope(
            overrides: getOverrides(),
            child: const MaterialApp(home: OnboardingScreen()),
          ),
        );
        await tester.pumpAndSettle();

        expect(tester.takeException(), isNull);
        expect(find.text('Get Started'), findsOneWidget);
      });

      // 2. DashboardHomeScreen
      testWidgets('DashboardHomeScreen renders without overflow on $sizeName', (tester) async {
        tester.view.physicalSize = size;
        tester.view.devicePixelRatio = 1.0;
        addTearDown(() => tester.view.resetPhysicalSize());

        await tester.pumpWidget(
          ProviderScope(
            overrides: getOverrides(),
            child: const MaterialApp(home: DashboardHomeScreen()),
          ),
        );
        await tester.pumpAndSettle();

        expect(tester.takeException(), isNull);
        expect(find.text('ANIMAL BIRTHDAY PREDICTOR'), findsOneWidget);
      });

      // 3. MainNavigationScreen
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
      });

      // 4. SavedAnimalsScreen
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
      });

      // 5. SpeciesSelectionScreen
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
        expect(find.text('What animal are you registering?'), findsOneWidget);
      });

      // 6. AnimalDetailsScreen
      testWidgets('AnimalDetailsScreen renders without overflow on $sizeName', (tester) async {
        tester.view.physicalSize = size;
        tester.view.devicePixelRatio = 1.0;
        addTearDown(() => tester.view.resetPhysicalSize());

        await tester.pumpWidget(
          ProviderScope(
            overrides: getOverrides(),
            child: const MaterialApp(home: AnimalDetailsScreen(species: 'horse')),
          ),
        );
        await tester.pumpAndSettle();

        expect(tester.takeException(), isNull);
      });

      // 7. AnimalProfileScreen
      testWidgets('AnimalProfileScreen renders without overflow on $sizeName', (tester) async {
        tester.view.physicalSize = size;
        tester.view.devicePixelRatio = 1.0;
        addTearDown(() => tester.view.resetPhysicalSize());

        await tester.pumpWidget(
          ProviderScope(
            overrides: getOverrides(),
            child: MaterialApp(home: AnimalProfileScreen(animal: sampleAnimal)),
          ),
        );
        await tester.pumpAndSettle();

        expect(tester.takeException(), isNull);
      });

      // 8. PregnancyModuleScreen
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
      });

      // 9. BreedingDetailsScreen
      testWidgets('BreedingDetailsScreen renders without overflow on $sizeName', (tester) async {
        tester.view.physicalSize = size;
        tester.view.devicePixelRatio = 1.0;
        addTearDown(() => tester.view.resetPhysicalSize());

        await tester.pumpWidget(
          ProviderScope(
            overrides: getOverrides(),
            child: const MaterialApp(home: BreedingDetailsScreen(initialMareId: 'a1')),
          ),
        );
        await tester.pumpAndSettle();

        expect(tester.takeException(), isNull);
        expect(find.text('HOW WAS YOUR MARE BRED?'), findsOneWidget);
      });

      // 10. PregnancyDetailsScreen
      testWidgets('PregnancyDetailsScreen renders without overflow on $sizeName', (tester) async {
        tester.view.physicalSize = size;
        tester.view.devicePixelRatio = 1.0;
        addTearDown(() => tester.view.resetPhysicalSize());

        await tester.pumpWidget(
          ProviderScope(
            overrides: getOverrides(),
            child: const MaterialApp(
              home: PregnancyDetailsScreen(carrierAnimalId: 'a1', pregnancyRecordId: 'preg1'),
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(tester.takeException(), isNull);
      });

      // 11. VeterinarianPregnancyScansScreen
      testWidgets('VeterinarianPregnancyScansScreen renders without overflow on $sizeName', (tester) async {
        tester.view.physicalSize = size;
        tester.view.devicePixelRatio = 1.0;
        addTearDown(() => tester.view.resetPhysicalSize());

        await tester.pumpWidget(
          ProviderScope(
            overrides: getOverrides(),
            child: const MaterialApp(home: VeterinarianPregnancyScansScreen()),
          ),
        );
        await tester.pumpAndSettle();

        expect(tester.takeException(), isNull);
      });

      // 12. AdvancedPregnancyInfoScreen
      testWidgets('AdvancedPregnancyInfoScreen renders without overflow on $sizeName', (tester) async {
        tester.view.physicalSize = size;
        tester.view.devicePixelRatio = 1.0;
        addTearDown(() => tester.view.resetPhysicalSize());

        await tester.pumpWidget(
          ProviderScope(
            overrides: getOverrides(),
            child: const MaterialApp(
              home: AdvancedPregnancyInfoScreen(pregnancyRecordId: 'preg1'),
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(tester.takeException(), isNull);
      });

      // 13. PreventativeCareScreen
      testWidgets('PreventativeCareScreen renders without overflow on $sizeName', (tester) async {
        tester.view.physicalSize = size;
        tester.view.devicePixelRatio = 1.0;
        addTearDown(() => tester.view.resetPhysicalSize());

        await tester.pumpWidget(
          ProviderScope(
            overrides: getOverrides(),
            child: const MaterialApp(
              home: PreventativeCareScreen(ownerType: 'animal', ownerId: 'a1'),
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(tester.takeException(), isNull);
      });

      // 14. FoalModuleScreen
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
      });

      // 15. FoalDetailsScreen
      testWidgets('FoalDetailsScreen renders without overflow on $sizeName', (tester) async {
        tester.view.physicalSize = size;
        tester.view.devicePixelRatio = 1.0;
        addTearDown(() => tester.view.resetPhysicalSize());

        await tester.pumpWidget(
          ProviderScope(
            overrides: getOverrides(),
            child: MaterialApp(home: FoalDetailsScreen(foal: sampleFoal)),
          ),
        );
        await tester.pumpAndSettle();

        expect(tester.takeException(), isNull);
      });

      // 16. PuppyListScreen
      testWidgets('PuppyListScreen renders without overflow on $sizeName', (tester) async {
        tester.view.physicalSize = size;
        tester.view.devicePixelRatio = 1.0;
        addTearDown(() => tester.view.resetPhysicalSize());

        await tester.pumpWidget(
          ProviderScope(
            overrides: getOverrides(),
            child: const MaterialApp(
              home: PuppyListScreen(damId: 'a3'),
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(tester.takeException(), isNull);
      });

      // 17. PuppyDetailsScreen
      testWidgets('PuppyDetailsScreen renders without overflow on $sizeName', (tester) async {
        tester.view.physicalSize = size;
        tester.view.devicePixelRatio = 1.0;
        addTearDown(() => tester.view.resetPhysicalSize());

        await tester.pumpWidget(
          ProviderScope(
            overrides: getOverrides(),
            child: MaterialApp(
              home: PuppyDetailsScreen(puppy: samplePuppy),
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(tester.takeException(), isNull);
      });

      // 18. PuppyWeightTrackerScreen
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

      // 19. DogPreventativeCareScreen
      testWidgets('DogPreventativeCareScreen renders without overflow on $sizeName', (tester) async {
        tester.view.physicalSize = size;
        tester.view.devicePixelRatio = 1.0;
        addTearDown(() => tester.view.resetPhysicalSize());

        await tester.pumpWidget(
          ProviderScope(
            overrides: getOverrides(),
            child: const MaterialApp(
              home: DogPreventativeCareScreen(
                ownerType: 'animal',
                ownerId: 'a3',
                title: 'Bella - Preventative Care',
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(tester.takeException(), isNull);
      });

      // 20. ContactsDirectoryScreen
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
      });

      // 21. CongratulationsScreen
      testWidgets('CongratulationsScreen renders without overflow on $sizeName', (tester) async {
        tester.view.physicalSize = size;
        tester.view.devicePixelRatio = 1.0;
        addTearDown(() => tester.view.resetPhysicalSize());

        await tester.pumpWidget(
          ProviderScope(
            overrides: getOverrides(),
            child: const MaterialApp(home: CongratulationsScreen(species: 'Equine')),
          ),
        );
        await tester.pumpAndSettle();

        expect(tester.takeException(), isNull);
      });

      // 22. CertificateScreen
      testWidgets('CertificateScreen renders without overflow on $sizeName', (tester) async {
        tester.view.physicalSize = size;
        tester.view.devicePixelRatio = 1.0;
        addTearDown(() => tester.view.resetPhysicalSize());

        await tester.pumpWidget(
          ProviderScope(
            overrides: getOverrides(),
            child: MaterialApp(home: CertificateScreen(dam: sampleAnimal)),
          ),
        );
        await tester.pumpAndSettle();

        expect(tester.takeException(), isNull);
      });

      // 23. ProfileScreen
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
      });

      // 24. SettingsScreen
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

      // 25. DeleteAccountScreen
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

      // 26. SignInScreen
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

      // 27. SignUpScreen
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

      // 28. PasswordResetScreen
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

      // 29. UpdatePasswordScreen
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

      // 30. EmailVerificationScreen
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

      // 31. ChangePasswordScreen
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
