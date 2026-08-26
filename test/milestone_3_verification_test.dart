import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:animal_birthday_predictor/core/router/app_router.dart';
import 'package:animal_birthday_predictor/features/foal/domain/foal_record.dart';
import 'package:animal_birthday_predictor/features/foal/presentation/screens/foal_module_screen.dart';
import 'package:animal_birthday_predictor/features/foal/presentation/screens/foal_details_screen.dart';
import 'package:animal_birthday_predictor/features/foal/presentation/providers/foal_provider.dart';
import 'package:animal_birthday_predictor/features/animals/data/mare_repository.dart';
import 'package:animal_birthday_predictor/features/animals/domain/animal.dart';
import 'package:animal_birthday_predictor/features/foaling_diary/data/foaling_diary_repository.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Milestone 3 End-to-End Double Check Verification', () {
    test('1. FoalRecord Model & Buyer Persistence serialization', () {
      final foal = FoalRecord(
        id: 'foal-101',
        accountId: 'acc-101',
        mareAnimalId: 'mare-101',
        foalName: 'Starlight Dream',
        dateOfBirth: DateTime(2026, 4, 15),
        stallion: 'Galileo',
        breed: 'Thoroughbred',
        sex: 'colt',
        iggValue: 'Normal (>800)',
        foalMicrochipNo: '985141001234567',
        dna: 'DNA-999',
        gelded: true,
        geldedDate: DateTime(2026, 8, 1),
        studBookAssociation: 'Weatherbys',
        notes: 'Promising yearling colt',
        status: 'sold',
        buyerName: 'Sheikh Mohammed',
        createdAt: DateTime(2026, 4, 15),
        updatedAt: DateTime(2026, 8, 20),
      );

      final json = foal.toJson();
      expect(json['foal_name'], equals('Starlight Dream'));
      expect(json['sex'], equals('colt'));
      expect(json['status'], equals('sold'));
      expect(json['buyer_name'], equals('Sheikh Mohammed'));
      expect(json['gelded'], isTrue);

      final fromJson = FoalRecord.fromJson(json);
      expect(fromJson.foalName, equals('Starlight Dream'));
      expect(fromJson.sex, equals('colt'));
      expect(fromJson.status, equals('sold'));
      expect(fromJson.buyerName, equals('Sheikh Mohammed'));
    });

    test('2. FoalingDiaryRepository has zero dummy data and empty initial state', () async {
      final repo = FoalingDiaryRepository();
      final entries = await repo.getFoalingDiaryEntries();
      expect(entries, isEmpty, reason: 'Strict zero dummy data policy must be enforced');
    });

    test('3. AppRouter resolves /markings route without errors', () {
      final route = AppRouter.onGenerateRoute(
        const RouteSettings(
          name: '/markings',
          arguments: {'ownerType': 'foal', 'ownerId': 'foal-101'},
        ),
      );
      expect(route, isNotNull);
      expect(route, isA<MaterialPageRoute>());
    });

    testWidgets('4. FoalModuleScreen renders Summary KPI Strip, Chips, and List', (tester) async {
      tester.view.physicalSize = const Size(1080, 1920);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      final testFoals = [
        FoalRecord(
          id: 'f1',
          accountId: 'acc1',
          mareAnimalId: 'm1',
          foalName: 'Pegasus',
          sex: 'colt',
          status: 'keep',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
        FoalRecord(
          id: 'f2',
          accountId: 'acc1',
          mareAnimalId: 'm2',
          foalName: 'Bella',
          sex: 'filly',
          status: 'sold',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      ];

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            foalsListProvider.overrideWith((ref) => testFoals),
          ],
          child: const MaterialApp(
            home: Scaffold(
              body: FoalModuleScreen(),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify Summary KPI Strip
      expect(find.text('TOTAL'), findsOneWidget);
      expect(find.text('COLTS'), findsOneWidget);
      expect(find.text('FILLIES'), findsOneWidget);
      expect(find.text('SOLD'), findsWidgets);

      // Verify CTA Banner & List item
      expect(find.text('Register Newborn Foal'), findsOneWidget);
      expect(find.text('Pegasus'), findsOneWidget);
    });

    testWidgets('5. FoalDetailsScreen renders Status ChoiceChips and Lineage sections', (tester) async {
      tester.view.physicalSize = const Size(1080, 1920);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: FoalDetailsScreen(),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify Header & Sections
      expect(find.text('NEW FOAL REGISTRATION'), findsOneWidget);
      expect(find.text('FOAL IDENTITY'), findsOneWidget);
      expect(find.text('PARENTAGE & BREEDING LINEAGE'), findsOneWidget);
      expect(find.text('Foal Status'), findsOneWidget);
      expect(find.text('Healthy / Retained'), findsOneWidget);
      expect(find.text('Available'), findsOneWidget);
      expect(find.text('Reserved'), findsOneWidget);
    });
  });
}
