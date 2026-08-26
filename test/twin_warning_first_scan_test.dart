import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:animal_birthday_predictor/features/animals/domain/animal.dart';
import 'package:animal_birthday_predictor/features/pregnancy/domain/pregnancy_record.dart';
import 'package:animal_birthday_predictor/features/pregnancy/presentation/providers/pregnancy_provider.dart';
import 'package:animal_birthday_predictor/features/pregnancy/presentation/widgets/scan_due_block.dart';
import 'package:animal_birthday_predictor/features/pregnancy/presentation/widgets/mare_pregnancy_card.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final mockMare = Animal(
    id: 'mare_twin_test_01',
    accountId: 'acc_01',
    species: 'horse',
    name: 'Midnight Rose',
    breed: 'Thoroughbred',
    colour: 'Bay',
    sex: 'mare',
    createdAt: DateTime(2025, 1, 1),
    updatedAt: DateTime(2025, 1, 1),
  );

  group('Twin Warning & Re-Scan Protocol Tests', () {
    test('PregnancyRecord model serializes and deserializes twinsSuspected & twinRescanDate correctly', () {
      final now = DateTime(2026, 4, 1);
      final record = PregnancyRecord(
        id: 'preg_twin_01',
        accountId: 'acc_01',
        breedingRecordId: 'breed_01',
        carrierAnimalId: 'mare_twin_test_01',
        scan1DueDate: DateTime(2026, 4, 15),
        scan1Confirmed: true,
        twinsSuspected: true,
        twinRescanDate: DateTime(2026, 4, 17),
        createdAt: now,
        updatedAt: now,
      );

      final json = record.toJson();
      expect(json['twins_suspected'], true);
      expect(json['twin_rescan_date'], '2026-04-17');

      final deserialized = PregnancyRecord.fromJson(json);
      expect(deserialized.twinsSuspected, true);
      expect(deserialized.twinRescanDate, DateTime(2026, 4, 17));
    });

    testWidgets('ScanDueBlock displays Twin Warning Alert & Action Buttons when isTwinsSuspected is true', (tester) async {
      bool toggled = false;
      DateTime? rescanDate;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: ScanDueBlock(
                scanNumber: 1,
                dueDate: DateTime(2026, 4, 15),
                isConfirmed: true,
                imageUrl: null,
                helperGuidance: 'Day 14-16. Checks pregnancy & twin detection.',
                isTwinsSuspected: true,
                twinRescanDate: DateTime(2026, 4, 17),
                onToggleConfirmed: (_) {},
                onToggleTwins: (val) => toggled = val ?? false,
                onSelectTwinRescanDate: (dt) => rescanDate = dt,
                onImageSelected: (_) {},
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('TWIN ALERT'), findsOneWidget);
      expect(find.text('Twins Suspected / Detected at 1st Scan'), findsOneWidget);
      expect(find.text('CRITICAL EQUINE TWIN ALERT'), findsOneWidget);
      expect(find.text('URGENT RE-SCAN REQUIRED (Day 16-18)'), findsOneWidget);
      expect(find.textContaining('Re-scan Target Date: 17/04/2026'), findsOneWidget);
      expect(find.text('Set Re-Scan Date'), findsOneWidget);
    });

    testWidgets('MarePregnancyCard displays high-visibility TWIN ALERT banner when twinsSuspected is true', (tester) async {
      final twinPregnancy = PregnancyRecord(
        id: 'preg_twin_02',
        accountId: 'acc_01',
        breedingRecordId: 'breed_01',
        carrierAnimalId: mockMare.id,
        scan1DueDate: DateTime(2026, 4, 15),
        scan1Confirmed: true,
        twinsSuspected: true,
        twinRescanDate: DateTime(2026, 4, 17),
        createdAt: DateTime(2026, 4, 1),
        updatedAt: DateTime(2026, 4, 1),
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            pregnancyRecordForCarrierProvider(mockMare.id).overrideWith(
              (ref) => Future.value(twinPregnancy),
            ),
          ],
          child: MaterialApp(
            home: Scaffold(
              body: MarePregnancyCard(
                mare: mockMare,
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.textContaining('TWIN ALERT: Re-scan scheduled for 17/04/2026'), findsOneWidget);
    });
  });
}
