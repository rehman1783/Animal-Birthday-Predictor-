import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:animal_birthday_predictor/features/foaling_diary/domain/foaling_diary_entry.dart';
import 'package:animal_birthday_predictor/features/foaling_diary/data/foaling_diary_repository.dart';
import 'package:animal_birthday_predictor/features/foaling_diary/presentation/providers/foaling_diary_provider.dart';
import 'package:animal_birthday_predictor/features/foaling_diary/presentation/screens/foaling_diary_screen.dart';
import 'package:animal_birthday_predictor/features/foaling_diary/presentation/screens/due_date_calculator_screen.dart';
import 'package:animal_birthday_predictor/features/certificates/data/pdf_certificate_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Foaling Diary Domain & Movement Stages', () {
    test('Calculates movement stages accurately based on days remaining', () {
      final now = DateTime.now();

      // Overdue (negative remaining)
      final overdue = FoalingDiaryEntry(
        id: '1',
        mareId: 'm1',
        mareName: 'Overdue Mare',
        stallionName: 'Stallion A',
        serviceDate: now.subtract(const Duration(days: 345)),
        foalingDueDate: now.subtract(const Duration(days: 5)),
        minDueDate: now.subtract(const Duration(days: 25)),
        maxDueDate: now.add(const Duration(days: 20)),
      );
      expect(overdue.movementStage, equals(MovementStage.overdue));

      // Foaling Barn (due in 8 days)
      final barn = FoalingDiaryEntry(
        id: '2',
        mareId: 'm2',
        mareName: 'Barn Mare',
        stallionName: 'Stallion B',
        serviceDate: now.subtract(const Duration(days: 332)),
        foalingDueDate: now.add(const Duration(days: 8)),
        minDueDate: now.subtract(const Duration(days: 12)),
        maxDueDate: now.add(const Duration(days: 33)),
      );
      expect(barn.movementStage, equals(MovementStage.foalingBarn));

      // Close Paddock (due in 25 days)
      final paddock = FoalingDiaryEntry(
        id: '3',
        mareId: 'm3',
        mareName: 'Paddock Mare',
        stallionName: 'Stallion C',
        serviceDate: now.subtract(const Duration(days: 315)),
        foalingDueDate: now.add(const Duration(days: 25)),
        minDueDate: now.add(const Duration(days: 5)),
        maxDueDate: now.add(const Duration(days: 50)),
      );
      expect(paddock.movementStage, equals(MovementStage.closePaddock));

      // Upcoming (due in 80 days)
      final upcoming = FoalingDiaryEntry(
        id: '4',
        mareId: 'm4',
        mareName: 'Upcoming Mare',
        stallionName: 'Stallion D',
        serviceDate: now.subtract(const Duration(days: 260)),
        foalingDueDate: now.add(const Duration(days: 80)),
        minDueDate: now.add(const Duration(days: 60)),
        maxDueDate: now.add(const Duration(days: 105)),
      );
      expect(upcoming.movementStage, equals(MovementStage.upcoming));

      // Foaled
      final foaled = upcoming.copyWith(isFoaled: true);
      expect(foaled.movementStage, equals(MovementStage.foaled));
    });
  });

  group('Foaling Diary Repository Tests (Strict User Data - No Dummy Data)', () {
    late FoalingDiaryRepository repo;

    setUp(() {
      repo = FoalingDiaryRepository();
    });

    test('getFoalingDiaryEntries starts strictly empty with 0 dummy records', () async {
      final entries = await repo.getFoalingDiaryEntries();
      expect(entries.isEmpty, isTrue);
      expect(entries.length, equals(0));
    });

    test('saveFoalingDiaryEntry and updatePaddockLocation modify user entries', () async {
      final entry = FoalingDiaryEntry(
        id: '00000000-0000-0000-0000-000000000999',
        mareId: '00000000-0000-0000-0000-000000000099',
        mareName: 'Test Princess',
        stallionName: 'Test King',
        serviceDate: DateTime(2025, 1, 1),
        foalingDueDate: DateTime(2025, 12, 7),
        minDueDate: DateTime(2025, 11, 17),
        maxDueDate: DateTime(2026, 1, 1),
        currentPaddock: 'Pasture 1',
      );

      final saved = await repo.saveFoalingDiaryEntry(entry);
      expect(saved.mareName, equals('Test Princess'));

      await repo.updatePaddockLocation(saved.id, 'Foaling Barn Box 5');
      final list = await repo.getFoalingDiaryEntries();
      final updated = list.firstWhere((e) => e.id == saved.id);
      expect(updated.currentPaddock, equals('Foaling Barn Box 5'));
    });
  });

  group('Foaling Diary PDF Generation Test', () {
    test('generateFoalingDiaryPdf returns valid non-empty byte document', () async {
      final entries = [
        FoalingDiaryEntry(
          id: '00000000-0000-0000-0000-000000000999',
          mareId: '00000000-0000-0000-0000-000000000099',
          mareName: 'User Champion Mare',
          stallionName: 'User Stud Sire',
          serviceDate: DateTime.now().subtract(const Duration(days: 300)),
          foalingDueDate: DateTime.now().add(const Duration(days: 40)),
          minDueDate: DateTime.now().add(const Duration(days: 20)),
          maxDueDate: DateTime.now().add(const Duration(days: 65)),
          currentPaddock: 'Paddock 1',
        ),
      ];

      final pdfBytes = await PdfCertificateService.generateFoalingDiaryPdf(
        entries: entries,
        studName: 'Sterling Stud',
        season: '2026/2027',
        filterTitle: 'All Active Mares',
      );

      expect(pdfBytes, isA<Uint8List>());
      expect(pdfBytes.length, greaterThan(1000));
    });
  });

  group('Foaling Diary Screen Widget Tests', () {
    testWidgets('FoalingDiaryScreen renders empty state when user has no saved mares', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: FoalingDiaryScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Foaling Diary & Stud Planner'), findsOneWidget);
      expect(find.text('Stud Gestation & Movement Manager'), findsOneWidget);
      expect(find.text('No Mares in Foaling Diary Yet'), findsOneWidget);
      expect(find.text('CALCULATE FOAL DUE DATE'), findsOneWidget);
    });

    testWidgets('FoalingDiaryScreen renders and filters user saved mares', (tester) async {
      final testRepo = FoalingDiaryRepository();
      await testRepo.saveFoalingDiaryEntry(
        FoalingDiaryEntry(
          id: '00000000-0000-0000-0000-000000000001',
          mareId: '00000000-0000-0000-0000-000000000011',
          mareName: 'Royal Empress',
          stallionName: 'Northern Dancer',
          serviceDate: DateTime.now().subtract(const Duration(days: 320)),
          foalingDueDate: DateTime.now().add(const Duration(days: 20)),
          minDueDate: DateTime.now(),
          maxDueDate: DateTime.now().add(const Duration(days: 45)),
          currentPaddock: 'Close Paddock A',
        ),
      );
      await testRepo.saveFoalingDiaryEntry(
        FoalingDiaryEntry(
          id: '00000000-0000-0000-0000-000000000002',
          mareId: '00000000-0000-0000-0000-000000000012',
          mareName: 'Silver Cascade',
          stallionName: 'Kingman Prince',
          serviceDate: DateTime.now().subtract(const Duration(days: 260)),
          foalingDueDate: DateTime.now().add(const Duration(days: 80)),
          minDueDate: DateTime.now().add(const Duration(days: 60)),
          maxDueDate: DateTime.now().add(const Duration(days: 105)),
          currentPaddock: 'North Pasture',
        ),
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            foalingDiaryRepositoryProvider.overrideWithValue(testRepo),
          ],
          child: const MaterialApp(
            home: FoalingDiaryScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Royal Empress'), findsOneWidget);
      expect(find.text('Silver Cascade'), findsOneWidget);

      // Filter with search
      await tester.enterText(find.byType(TextField), 'Royal Empress');
      await tester.pumpAndSettle();

      expect(find.text('Royal Empress'), findsWidgets);
      expect(find.text('Silver Cascade'), findsNothing);
    });
  });

  group('Due Date Calculator Screen Widget Tests', () {
    testWidgets('DueDateCalculatorScreen renders question banner, species chips, and date result', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: DueDateCalculatorScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('When Is My Foal Due?'), findsWidgets);
      expect(find.text('Horse (Mare)'), findsOneWidget);
      expect(find.text('Dog (Bitch)'), findsOneWidget);
      expect(find.text('Cat (Queen)'), findsOneWidget);
      expect(find.text('Natural Cover'), findsOneWidget);
      expect(find.text('EXPECTED FOALING DUE DATE'), findsOneWidget);
      expect(find.text('Save Record to Stud Foaling Diary'), findsOneWidget);
    });

    testWidgets('DueDateCalculatorScreen switching species updates timeline and gestation length', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: DueDateCalculatorScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Tap Dog (Bitch)
      await tester.tap(find.text('Dog (Bitch)'));
      await tester.pumpAndSettle();

      expect(find.text('Breeding Due Date Calculator'), findsOneWidget);
      expect(find.text('Ultrasound Pregnancy Confirmation'), findsOneWidget);
      expect(find.text('Nesting Area Preparation'), findsOneWidget);
    });
  });
}
