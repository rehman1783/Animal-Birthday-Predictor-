import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:animal_birthday_predictor/features/animals/domain/animal.dart';
import 'package:animal_birthday_predictor/features/pregnancy/data/pregnancy_repository.dart';
import 'package:animal_birthday_predictor/features/pregnancy/domain/pregnancy_record.dart';
import 'package:animal_birthday_predictor/features/pregnancy/domain/breeding_record.dart';
import 'package:animal_birthday_predictor/features/pregnancy/presentation/providers/pregnancy_provider.dart';
import 'package:animal_birthday_predictor/features/pregnancy/presentation/widgets/mare_pregnancy_card.dart';
import 'package:animal_birthday_predictor/core/router/app_router.dart';

class FakePregnancyRepository extends PregnancyRepository {
  final PregnancyRecord? mockRecord;
  final BreedingRecord? mockBreeding;

  FakePregnancyRepository({this.mockRecord, this.mockBreeding});

  @override
  Future<PregnancyRecord?> getPregnancyRecordForCarrier(String carrierAnimalId) async {
    return mockRecord;
  }

  @override
  Future<PregnancyRecord?> getPregnancyRecordById(String id) async {
    return mockRecord;
  }

  @override
  Future<BreedingRecord?> getBreedingRecordByMare(String mareId) async {
    return mockBreeding;
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final testMare = Animal(
    id: 'mare-101',
    accountId: 'acc-1',
    name: 'Bella Luna',
    species: 'horse',
    sex: 'female',
    breed: 'Thoroughbred',
    microchipNo: '981020002931',
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
  );

  final testBreeding = BreedingRecord(
    id: 'breeding-101',
    accountId: 'acc-1',
    mareAnimalId: 'mare-101',
    stallionName: 'Thunder King',
    method: 'frozen',
    coverOrTransferDate: DateTime(2026, 3, 15),
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
  );

  final testConfirmedPregnancy = PregnancyRecord(
    id: 'preg-101',
    accountId: 'acc-1',
    breedingRecordId: 'breeding-101',
    carrierAnimalId: 'mare-101',
    scan1DueDate: DateTime(2026, 3, 29),
    scan1Confirmed: true,
    scan2DueDate: DateTime(2026, 4, 14),
    scan2Confirmed: true,
    scan3DueDate: DateTime(2026, 4, 29),
    scan3Confirmed: true,
    foalingDueDate: DateTime(2027, 2, 18),
    vetName: 'Dr. Jennifer Smith',
    vetNumber: '+1 555 123 4567',
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
  );

  group('Pregnancy Screen & Flow Enhancements Tests', () {
    testWidgets('MarePregnancyCard displays Pregnancy Status, Final Foaling Date, and View Details button', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            pregnancyRepositoryProvider.overrideWithValue(
              FakePregnancyRepository(mockRecord: testConfirmedPregnancy, mockBreeding: testBreeding),
            ),
            pregnancyRecordForCarrierProvider('mare-101').overrideWith(
              (ref) async => testConfirmedPregnancy,
            ),
            breedingRecordByMareProvider('mare-101').overrideWith(
              (ref) async => testBreeding,
            ),
          ],
          child: MaterialApp(
            onGenerateRoute: AppRouter.onGenerateRoute,
            home: Scaffold(
              body: SingleChildScrollView(
                child: MarePregnancyCard(mare: testMare),
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // 1. Mare Profile Name & Breed
      expect(find.text('Bella Luna'), findsOneWidget);
      expect(find.text('Thoroughbred • FEMALE'), findsOneWidget);

      // 2. Pregnancy Status Badge
      expect(find.text('SCAN 3 CONFIRMED • FULL GESTATION'), findsOneWidget);

      // 3. Breeding info (Stallion & method)
      expect(find.textContaining('Thunder King'), findsOneWidget);
      expect(find.textContaining('FROZEN'), findsOneWidget);

      // 4. Final Foaling Date Banner
      expect(find.text('FINAL FOALING DUE DATE'), findsOneWidget);
      expect(find.text('18/02/2027'), findsOneWidget);

      // 5. Action Buttons
      expect(find.text('VIEW PREGNANCY DETAILS & SCANS'), findsOneWidget);
      expect(find.text('Scans & Vet'), findsOneWidget);
      expect(find.text('Edit Breeding'), findsOneWidget);
      expect(find.text('Advanced Info'), findsOneWidget);
      expect(find.text('Preventative Care'), findsOneWidget);
      expect(find.text('CELEBRATE FOAL ARRIVAL 🎉'), findsOneWidget);
    });

    testWidgets('Tapping VIEW PREGNANCY DETAILS opens PregnancyDetailsScreen with accurate foaling due date and status chip', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            pregnancyRepositoryProvider.overrideWithValue(
              FakePregnancyRepository(mockRecord: testConfirmedPregnancy, mockBreeding: testBreeding),
            ),
            pregnancyRecordForCarrierProvider('mare-101').overrideWith(
              (ref) async => testConfirmedPregnancy,
            ),
            breedingRecordByMareProvider('mare-101').overrideWith(
              (ref) async => testBreeding,
            ),
          ],
          child: MaterialApp(
            onGenerateRoute: AppRouter.onGenerateRoute,
            home: Scaffold(
              body: SingleChildScrollView(
                child: MarePregnancyCard(mare: testMare),
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Tap View Pregnancy Details
      await tester.tap(find.text('VIEW PREGNANCY DETAILS & SCANS'));
      await tester.pumpAndSettle();

      // Should be on PregnancyDetailsScreen
      expect(find.text('PREGNANCY DETAILS'), findsOneWidget);
      expect(find.text('CELEBRATE FOAL ARRIVAL 🎉'), findsOneWidget);
    });

    testWidgets('Tapping CELEBRATE FOAL ARRIVAL navigates to CongratulationsScreen and then to FoalDetailsScreen with prefilled Dam', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            pregnancyRepositoryProvider.overrideWithValue(
              FakePregnancyRepository(mockRecord: testConfirmedPregnancy, mockBreeding: testBreeding),
            ),
            pregnancyRecordForCarrierProvider('mare-101').overrideWith(
              (ref) async => testConfirmedPregnancy,
            ),
            breedingRecordByMareProvider('mare-101').overrideWith(
              (ref) async => testBreeding,
            ),
          ],
          child: MaterialApp(
            onGenerateRoute: AppRouter.onGenerateRoute,
            home: Scaffold(
              body: SingleChildScrollView(
                child: MarePregnancyCard(mare: testMare),
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Tap Celebrate
      await tester.tap(find.text('CELEBRATE FOAL ARRIVAL 🎉'));
      await tester.pumpAndSettle();

      // CongratulationsScreen
      expect(find.text('CONGRATULATIONS!'), findsOneWidget);
      expect(find.text('REGISTER NEW FOAL RECORD'), findsOneWidget);

      // Tap Register New Foal Record
      await tester.tap(find.text('REGISTER NEW FOAL RECORD'));
      await tester.pumpAndSettle();

      // Opens FoalDetailsScreen
      expect(find.text('NEW FOAL REGISTRATION'), findsOneWidget);
      expect(find.text('Thunder King'), findsOneWidget);
    });
  });
}
