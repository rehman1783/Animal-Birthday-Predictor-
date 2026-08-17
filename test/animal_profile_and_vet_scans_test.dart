import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:animal_birthday_predictor/features/animals/domain/animal.dart';
import 'package:animal_birthday_predictor/features/animals/presentation/screens/animal_profile_screen.dart';
import 'package:animal_birthday_predictor/features/pregnancy/presentation/screens/veterinarian_pregnancy_scans_screen.dart';

void main() {
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
  });
}
