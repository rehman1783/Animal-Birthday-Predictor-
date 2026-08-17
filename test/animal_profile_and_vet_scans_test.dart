import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:animal_birthday_predictor/features/animals/domain/animal.dart';
import 'package:animal_birthday_predictor/features/animals/presentation/screens/animal_profile_screen.dart';
import 'package:animal_birthday_predictor/features/animals/presentation/screens/saved_animals_screen.dart';
import 'package:animal_birthday_predictor/features/pregnancy/presentation/screens/veterinarian_pregnancy_scans_screen.dart';
import 'package:animal_birthday_predictor/features/animals/data/animal_repository.dart';
import 'package:animal_birthday_predictor/features/animals/presentation/providers/animal_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:animal_birthday_predictor/core/router/app_router.dart';

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
      expect(find.text('LOG BREEDING'), findsOneWidget);
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
  });
}
