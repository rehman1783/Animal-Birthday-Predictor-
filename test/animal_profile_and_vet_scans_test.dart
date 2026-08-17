import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:animal_birthday_predictor/features/animals/domain/animal.dart';
import 'package:animal_birthday_predictor/features/animals/presentation/screens/animal_profile_screen.dart';
import 'package:animal_birthday_predictor/features/animals/presentation/screens/saved_animals_screen.dart';
import 'package:animal_birthday_predictor/features/pregnancy/presentation/screens/veterinarian_pregnancy_scans_screen.dart';
import 'package:animal_birthday_predictor/features/pregnancy/data/pregnancy_repository.dart';
import 'package:animal_birthday_predictor/features/pregnancy/domain/pregnancy_record.dart';
import 'package:animal_birthday_predictor/features/pregnancy/presentation/providers/pregnancy_provider.dart';
import 'package:animal_birthday_predictor/features/animals/data/animal_repository.dart';
import 'package:animal_birthday_predictor/features/animals/presentation/providers/animal_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:animal_birthday_predictor/features/animals/domain/markings.dart';
import 'package:animal_birthday_predictor/features/animals/data/mare_repository.dart';
import 'package:animal_birthday_predictor/features/animals/presentation/providers/mare_provider.dart';
import 'package:animal_birthday_predictor/core/router/app_router.dart';
import 'package:animal_birthday_predictor/core/widgets/app_thumbnail_avatar.dart';
import 'package:animal_birthday_predictor/core/widgets/app_image_picker.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('Animal Profile & Veterinarian Scans Screen Tests', () {
    testWidgets('AnimalProfileScreen renders animal details, badges and action buttons', (tester) async {
      final testAnimal = Animal(
        id: '11111111-1111-4111-a111-111111111111',
        accountId: '22222222-2222-4222-a222-222222222222',
        species: 'horse',
        name: 'Thunderbolt Star',
        breed: 'Thoroughbred',
        colour: 'Chestnut',
        dateOfBirth: DateTime(2019, 4, 15),
        microchipNo: '985141009876543',
        brand: 'Star-T',
        dna: 'DNA-9901',
        ownerClientName: 'Jonathan Swift',
        ownerClientPhone: '+1 555 432 1098',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: AnimalProfileScreen(animal: testAnimal),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Verify Name & Species badge rendered
      expect(find.text('Thunderbolt Star'), findsOneWidget);
      expect(find.text('HORSE'), findsOneWidget);
      expect(find.text('Thoroughbred'), findsOneWidget);
      expect(find.text('Chestnut'), findsOneWidget);

      // Verify Registry Identifiers
      expect(find.text('985141009876543'), findsOneWidget);
      expect(find.text('Star-T'), findsOneWidget);
      expect(find.text('DNA-9901'), findsOneWidget);

      // Verify Owner Info
      expect(find.text('Jonathan Swift'), findsOneWidget);
      expect(find.text('+1 555 432 1098'), findsOneWidget);

      // Verify Quick Action Buttons
      expect(find.text('EDIT ANIMAL DETAILS'), findsOneWidget);
      expect(find.text('LOG BREEDING'), findsWidgets);
      expect(find.text('SCANS & VET'), findsOneWidget);
      expect(find.text('HEALTH & CARE'), findsOneWidget);
      expect(find.text('MARKINGS'), findsOneWidget);
    });

    testWidgets('VeterinarianPregnancyScansScreen renders Vet contact section and 3 Scans', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: VeterinarianPregnancyScansScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Verify screen title
      expect(find.text('VET CONTACT & SCANS OVERVIEW'), findsOneWidget);

      // Verify progress and Vet contact sections
      expect(find.text('PREGNANCY SCANS PROGRESS'), findsOneWidget);
      expect(find.text('VETERINARIAN CONTACT DETAILS'), findsOneWidget);
      expect(find.text('CALL VETERINARIAN NOW'), findsOneWidget);
      expect(find.text('SAVE VET INFO'), findsOneWidget);

      // Verify 3 Ultrasound scans
      expect(find.text('1st Pregnancy Scan'), findsOneWidget);
      expect(find.text('2nd Pregnancy Scan'), findsOneWidget);
      expect(find.text('3rd Pregnancy Scan'), findsOneWidget);

      // Verify Save All CTA
      expect(find.text('SAVE ALL SCAN & VET UPDATES'), findsOneWidget);
    });

    test('Animal.matchesSpeciesFilter correctly matches horses, dogs, cats, and other', () {
      expect(Animal.matchesSpeciesFilter('horse', 'horse'), isTrue);
      expect(Animal.matchesSpeciesFilter('Horse', 'horse'), isTrue);
      expect(Animal.matchesSpeciesFilter('Equine', 'horse'), isTrue);
      expect(Animal.matchesSpeciesFilter('mare', 'horse'), isTrue);
      expect(Animal.matchesSpeciesFilter('dog', 'horse'), isFalse);

      expect(Animal.matchesSpeciesFilter('dog', 'dog'), isTrue);
      expect(Animal.matchesSpeciesFilter('Dog', 'dog'), isTrue);
      expect(Animal.matchesSpeciesFilter('Canine', 'dog'), isTrue);
      expect(Animal.matchesSpeciesFilter('puppy', 'dog'), isTrue);
      expect(Animal.matchesSpeciesFilter('horse', 'dog'), isFalse);

      expect(Animal.matchesSpeciesFilter('cat', 'cat'), isTrue);
      expect(Animal.matchesSpeciesFilter('Feline', 'cat'), isTrue);
      expect(Animal.matchesSpeciesFilter('dog', 'cat'), isFalse);

      expect(Animal.matchesSpeciesFilter('sheep', 'other'), isTrue);
      expect(Animal.matchesSpeciesFilter('goat', 'other'), isTrue);
      expect(Animal.matchesSpeciesFilter('other', 'other'), isTrue);
      expect(Animal.matchesSpeciesFilter('horse', 'other'), isFalse);
      expect(Animal.matchesSpeciesFilter('dog', 'other'), isFalse);
    });

    testWidgets('Tapping EDIT ANIMAL DETAILS on AnimalProfileScreen opens AnimalDetailsScreen with pre-filled details', (tester) async {
      final testAnimal = Animal(
        id: '11111111-1111-4111-a111-111111111111',
        accountId: '22222222-2222-4222-a222-222222222222',
        species: 'horse',
        name: 'Thunderbolt Star',
        breed: 'Thoroughbred',
        colour: 'Chestnut',
        dateOfBirth: DateTime(2019, 4, 15),
        microchipNo: '985141009876543',
        brand: 'Star-T',
        dna: 'DNA-9901',
        ownerClientName: 'Jonathan Swift',
        ownerClientPhone: '+1 555 432 1098',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            onGenerateRoute: (settings) => AppRouter.onGenerateRoute(settings),
            home: AnimalProfileScreen(animal: testAnimal),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final editBtn = find.text('EDIT ANIMAL DETAILS');
      expect(editBtn, findsOneWidget);
      await tester.ensureVisible(editBtn);
      await tester.tap(editBtn);
      await tester.pumpAndSettle();

      // Verify that AnimalDetailsScreen opened in EDIT mode with the animal's name in title
      expect(find.text('EDIT THUNDERBOLT STAR'), findsOneWidget);
      // Verify existing values are populated in text fields
      expect(find.text('Thunderbolt Star'), findsWidgets);
      expect(find.text('Thoroughbred'), findsWidgets);
      expect(find.text('Chestnut'), findsWidgets);
      expect(find.text('985141009876543'), findsWidgets);
      expect(find.text('Star-T'), findsWidgets);
      expect(find.text('DNA-9901'), findsWidgets);
    });

    testWidgets('SavedAnimalsScreen displays species tabs and switches tabs correctly', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            onGenerateRoute: AppRouter.onGenerateRoute,
            home: SavedAnimalsScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('HORSES'), findsOneWidget);
      expect(find.text('DOGS'), findsOneWidget);
      expect(find.text('CATS'), findsOneWidget);
      expect(find.text('OTHER'), findsOneWidget);

      // Tap DOGS tab
      await tester.tap(find.text('DOGS'));
      await tester.pumpAndSettle();

      expect(find.text('No DOGs Registered'), findsOneWidget);
    });

    testWidgets('SavedAnimalsScreen strictly isolates horses and dogs into their respective tabs', (tester) async {
      final repo = AnimalRepository();
      await repo.saveAnimal(
        Animal(
          id: 'horse-1',
          accountId: 'acc-1',
          species: 'horse',
          name: 'Pegasus Pride',
          breed: 'Arabian',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      );

      await repo.saveAnimal(
        Animal(
          id: 'dog-1',
          accountId: 'acc-1',
          species: 'dog',
          name: 'Bella Golden',
          breed: 'Golden Retriever',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            animalRepositoryProvider.overrideWithValue(repo),
          ],
          child: const MaterialApp(
            onGenerateRoute: AppRouter.onGenerateRoute,
            home: SavedAnimalsScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // On Horses tab (default):
      expect(find.text('Pegasus Pride'), findsOneWidget);
      expect(find.text('Bella Golden'), findsNothing);

      // Switch to Dogs tab:
      await tester.tap(find.text('DOGS'));
      await tester.pumpAndSettle();

      expect(find.text('Bella Golden'), findsOneWidget);
      expect(find.text('Pegasus Pride'), findsNothing);

      // Switch to Cats tab:
      await tester.tap(find.text('CATS'));
      await tester.pumpAndSettle();

      expect(find.text('No CATs Registered'), findsOneWidget);
      expect(find.text('Pegasus Pride'), findsNothing);
      expect(find.text('Bella Golden'), findsNothing);
    });

    testWidgets('Pregnancy scans persist and display confirmed scans on AnimalProfileScreen and Vet Scans Screen', (tester) async {
      final pregRepo = PregnancyRepository();
      final animalRepo = AnimalRepository();

      final mare = Animal(
        id: 'mare-101',
        accountId: 'acc-1',
        species: 'horse',
        name: 'Duchess Royale',
        breed: 'Warmblood',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      await animalRepo.saveAnimal(mare);

      final pregRecord = PregnancyRecord(
        id: 'preg-101',
        accountId: 'acc-1',
        breedingRecordId: 'breed-101',
        carrierAnimalId: 'mare-101',
        scan1DueDate: DateTime(2026, 5, 1),
        scan1Confirmed: true,
        scan2DueDate: DateTime(2026, 5, 15),
        scan2Confirmed: true,
        scan3DueDate: DateTime(2026, 6, 1),
        scan3Confirmed: false,
        foalingDueDate: DateTime(2027, 4, 1),
        vetName: 'Dr. Jennifer Vance',
        vetNumber: '+1 555 999 1234',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      await pregRepo.savePregnancyRecord(pregRecord);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            pregnancyRepositoryProvider.overrideWithValue(pregRepo),
            animalRepositoryProvider.overrideWithValue(animalRepo),
          ],
          child: MaterialApp(
            onGenerateRoute: AppRouter.onGenerateRoute,
            home: AnimalProfileScreen(animal: mare),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Verify Live Pregnancy Card is visible on profile
      expect(find.text('PREGNANCY & SCANS'), findsOneWidget);
      expect(find.text('2 / 3 SCANS CONFIRMED'), findsOneWidget);
      expect(find.text('Estimated Foaling: 01/04/2027'), findsOneWidget);
      expect(find.text('Veterinarian: Dr. Jennifer Vance (+1 555 999 1234)'), findsOneWidget);

      // Tap VIEW & UPDATE SCANS
      final updateScansBtn = find.text('VIEW & UPDATE SCANS');
      expect(updateScansBtn, findsOneWidget);
      await tester.ensureVisible(updateScansBtn);
      await tester.tap(updateScansBtn);
      await tester.pumpAndSettle();

      // Verify VeterinarianPregnancyScansScreen opened with persisted scans
      expect(find.text('VET CONTACT & SCANS OVERVIEW'), findsOneWidget);
      expect(find.text('2 / 3 CONFIRMED'), findsOneWidget);
    });

    testWidgets('SavedAnimalsScreen horse tab has MARES and STALLIONS sub-filters and filters records accurately', (tester) async {
      final animalRepo = AnimalRepository();

      final mare = Animal(
        id: 'mare-1',
        accountId: 'acc-1',
        species: 'horse',
        name: 'Lady Guinevere',
        sex: 'mare',
        breed: 'Thoroughbred',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final stallion = Animal(
        id: 'stallion-1',
        accountId: 'acc-1',
        species: 'horse',
        name: 'King Arthur',
        sex: 'stallion',
        breed: 'Arabian',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await animalRepo.saveAnimal(mare);
      await animalRepo.saveAnimal(stallion);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            animalRepositoryProvider.overrideWithValue(animalRepo),
          ],
          child: const MaterialApp(
            onGenerateRoute: AppRouter.onGenerateRoute,
            home: SavedAnimalsScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // By default on HORSES tab, ALL (2) horses are visible
      expect(find.text('ALL (2)'), findsOneWidget);
      expect(find.text('MARES (1)'), findsOneWidget);
      expect(find.text('STALLIONS (1)'), findsOneWidget);
      expect(find.text('Lady Guinevere'), findsOneWidget);
      expect(find.text('King Arthur'), findsOneWidget);

      // Tap MARES sub-filter chip
      await tester.tap(find.text('MARES (1)'));
      await tester.pumpAndSettle();

      // Verify only Mare is shown
      expect(find.text('Lady Guinevere'), findsOneWidget);
      expect(find.text('King Arthur'), findsNothing);

      // Tap STALLIONS sub-filter chip
      await tester.tap(find.text('STALLIONS (1)'));
      await tester.pumpAndSettle();

      // Verify only Stallion is shown
      expect(find.text('Lady Guinevere'), findsNothing);
      expect(find.text('King Arthur'), findsOneWidget);

      // Tap ALL (2) sub-filter chip
      await tester.tap(find.text('ALL (2)'));
      await tester.pumpAndSettle();

      // Verify both are shown again
      expect(find.text('Lady Guinevere'), findsOneWidget);
      expect(find.text('King Arthur'), findsOneWidget);
    });

    testWidgets('AppThumbnailAvatar and AppImagePicker render Base64 data URI images without crashing', (tester) async {
      // 1x1 transparent PNG encoded in base64
      const transparentPngBase64 = 'data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNk+M9QDwADhgGAWjR9awAAAABJRU5ErkJggg==';

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                const AppThumbnailAvatar(
                  imagePath: transparentPngBase64,
                  size: 60,
                ),
                AppImagePicker(
                  label: 'Animal Photo',
                  currentImagePath: transparentPngBase64,
                  onImagePicked: (_) {},
                ),
              ],
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(AppThumbnailAvatar), findsOneWidget);
      expect(find.byType(AppImagePicker), findsOneWidget);
      expect(find.byType(Image), findsNWidgets(2));
    });

    testWidgets('Physical markings persist in repository and display on AnimalProfileScreen', (tester) async {
      final mareRepo = MareRepository();
      const transparentPngBase64 = 'data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNk+M9QDwADhgGAWjR9awAAAABJRU5ErkJggg==';

      final testHorse = Animal(
        id: 'horse-markings-1',
        accountId: 'acc-1',
        species: 'horse',
        name: 'Starlight Dream',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final markings = Markings(
        id: 'markings-1',
        ownerType: 'animal',
        ownerId: testHorse.id,
        leftSideImageUrl: transparentPngBase64,
        rightSideImageUrl: transparentPngBase64,
        headViewImageUrl: transparentPngBase64,
        headViewNotes: 'White star on forehead and white sock on left hind',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await mareRepo.saveMarkings(markings);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            mareRepositoryProvider.overrideWithValue(mareRepo),
          ],
          child: MaterialApp(
            onGenerateRoute: (settings) => AppRouter.onGenerateRoute(settings),
            home: AnimalProfileScreen(animal: testHorse),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Verify Physical Markings card is rendered with RECORDED status
      expect(find.text('PHYSICAL MARKINGS & IDENTIFICATION'), findsOneWidget);
      expect(find.text('RECORDED'), findsOneWidget);
      expect(find.text('LEFT SIDE'), findsOneWidget);
      expect(find.text('RIGHT SIDE'), findsOneWidget);
      expect(find.text('HEAD VIEW'), findsOneWidget);
      expect(find.text('White star on forehead and white sock on left hind'), findsOneWidget);
      expect(find.text('EDIT PHYSICAL MARKINGS'), findsOneWidget);
    });
  });
}
