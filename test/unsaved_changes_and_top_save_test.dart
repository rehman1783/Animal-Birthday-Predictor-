import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:animal_birthday_predictor/core/widgets/app_unsaved_changes_dialog.dart';
import 'package:animal_birthday_predictor/features/animals/domain/animal.dart';
import 'package:animal_birthday_predictor/features/animals/presentation/screens/animal_details_screen.dart';
import 'package:animal_birthday_predictor/features/pregnancy/presentation/screens/veterinarian_pregnancy_scans_screen.dart';
import 'package:animal_birthday_predictor/features/pregnancy/presentation/widgets/scan_due_block.dart';
import 'package:animal_birthday_predictor/features/foal/presentation/screens/foal_details_screen.dart';
import 'package:animal_birthday_predictor/features/puppy/presentation/screens/puppy_details_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('AppUnsavedChangesDialog Tests', () {
    testWidgets('displays title, message, and all 3 action buttons', (tester) async {
      bool? result;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () async {
                  result = await showAppUnsavedChangesDialog(context);
                },
                child: const Text('Open Dialog'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open Dialog'));
      await tester.pumpAndSettle();

      expect(find.text('Unsaved Changes'), findsOneWidget);
      expect(find.text('You have unsaved changes. Do you want to save your changes before leaving?'), findsOneWidget);
      expect(find.text('CANCEL'), findsOneWidget);
      expect(find.text('DISCARD'), findsOneWidget);
      expect(find.text('SAVE & EXIT'), findsOneWidget);

      // Tap SAVE & EXIT
      await tester.tap(find.text('SAVE & EXIT'));
      await tester.pumpAndSettle();
      expect(result, isTrue);
    });

    testWidgets('discard returns false', (tester) async {
      bool? result;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () async {
                  result = await showAppUnsavedChangesDialog(context);
                },
                child: const Text('Open Dialog'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open Dialog'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('DISCARD'));
      await tester.pumpAndSettle();
      expect(result, isFalse);
    });

    testWidgets('cancel returns null', (tester) async {
      bool? result;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () async {
                  result = await showAppUnsavedChangesDialog(context);
                },
                child: const Text('Open Dialog'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open Dialog'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('CANCEL'));
      await tester.pumpAndSettle();
      expect(result, isNull);
    });
  });

  group('ScanDueBlock Dedicated Save Scan Button Tests', () {
    testWidgets('renders dedicated SAVE SCAN button and handles tap', (tester) async {
      bool scanSaved = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ScanDueBlock(
              scanNumber: 1,
              dueDate: DateTime(2026, 9, 1),
              isConfirmed: false,
              imageUrl: null,
              onToggleConfirmed: (_) {},
              onImageSelected: (_) {},
              helperGuidance: 'Test scan guidance',
              onSaveScan: () {
                scanSaved = true;
              },
            ),
          ),
        ),
      );

      expect(find.text('SAVE SCAN 1'), findsOneWidget);
      await tester.tap(find.text('SAVE SCAN 1'));
      await tester.pumpAndSettle();
      expect(scanSaved, isTrue);
    });
  });

  group('Edit Screens Top Bar Save Button Tests', () {
    testWidgets('AnimalDetailsScreen has Top Bar SAVE button', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: AnimalDetailsScreen(species: 'horse'),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('SAVE'), findsOneWidget);
    });

    testWidgets('FoalDetailsScreen has Top Bar SAVE button', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: FoalDetailsScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('SAVE'), findsOneWidget);
    });

    testWidgets('PuppyDetailsScreen has Top Bar SAVE button', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: PuppyDetailsScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('SAVE'), findsOneWidget);
    });

    testWidgets('VeterinarianPregnancyScansScreen has Top Bar SAVE button and individual scan buttons', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: VeterinarianPregnancyScansScreen(carrierAnimalId: 'test-id'),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('SAVE'), findsOneWidget);
      expect(find.text('SAVE SCAN 1'), findsOneWidget);
      expect(find.text('SAVE SCAN 2'), findsOneWidget);
      expect(find.text('SAVE SCAN 3'), findsOneWidget);
    });
  });

  group('Unsaved Changes Interception Flow Tests', () {
    testWidgets('modifying AnimalDetailsScreen triggers confirmation dialog on back press', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (ctx) => ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    ctx,
                    MaterialPageRoute(
                      builder: (_) => const ProviderScope(
                        child: AnimalDetailsScreen(species: 'horse'),
                      ),
                    ),
                  );
                },
                child: const Text('Open Animal Details'),
              ),
            ),
          ),
        ),
      );

      // Open screen
      await tester.tap(find.text('Open Animal Details'));
      await tester.pumpAndSettle();

      expect(find.text('ANIMAL DETAILS'), findsOneWidget);

      // Enter text to make form dirty
      await tester.enterText(find.byType(TextFormField).first, 'Thunderbolt');
      await tester.pumpAndSettle();

      // Tap back button
      await tester.tap(find.byIcon(Icons.arrow_back_ios_new_rounded));
      await tester.pumpAndSettle();

      // Verify unsaved changes dialog appears
      expect(find.text('Unsaved Changes'), findsOneWidget);
      expect(find.text('SAVE & EXIT'), findsOneWidget);
      expect(find.text('DISCARD'), findsOneWidget);

      // Tap DISCARD
      await tester.tap(find.text('DISCARD'));
      await tester.pumpAndSettle();

      // Verified popped back to root
      expect(find.text('Open Animal Details'), findsOneWidget);
    });

    testWidgets('unmodified screen pops immediately without showing unsaved changes dialog', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (ctx) => ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    ctx,
                    MaterialPageRoute(
                      builder: (_) => const ProviderScope(
                        child: AnimalDetailsScreen(species: 'horse'),
                      ),
                    ),
                  );
                },
                child: const Text('Open Clean Screen'),
              ),
            ),
          ),
        ),
      );

      // Open screen
      await tester.tap(find.text('Open Clean Screen'));
      await tester.pumpAndSettle();

      expect(find.text('ANIMAL DETAILS'), findsOneWidget);

      // Tap back button directly without changing any text/field
      await tester.tap(find.byIcon(Icons.arrow_back_ios_new_rounded));
      await tester.pumpAndSettle();

      // Verify NO dialog appeared and screen popped immediately
      expect(find.text('Unsaved Changes'), findsNothing);
      expect(find.text('Open Clean Screen'), findsOneWidget);
    });
  });
}
