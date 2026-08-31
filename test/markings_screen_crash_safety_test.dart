import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:animal_birthday_predictor/features/animals/domain/animal.dart';
import 'package:animal_birthday_predictor/features/animals/domain/markings.dart';
import 'package:animal_birthday_predictor/features/animals/data/mare_repository.dart';
import 'package:animal_birthday_predictor/features/animals/presentation/providers/mare_provider.dart';
import 'package:animal_birthday_predictor/features/animals/presentation/screens/markings_screen.dart';
import 'package:animal_birthday_predictor/features/animals/presentation/screens/animal_profile_screen.dart';
import 'package:animal_birthday_predictor/core/router/app_router.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('MarkingsScreen Zero-Crash & Safety Tests', () {
    late MareRepository mareRepo;

    setUp(() {
      mareRepo = MareRepository();
    });

    testWidgets('MarkingsScreen opens with empty state without crashing', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            mareRepositoryProvider.overrideWithValue(mareRepo),
          ],
          child: const MaterialApp(
            home: MarkingsScreen(
              ownerType: 'animal',
              ownerId: 'horse-empty-id',
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('PHYSICAL MARKINGS'), findsOneWidget);
      expect(find.text('LEFT SIDE VIEW'), findsOneWidget);
      expect(find.text('RIGHT SIDE VIEW'), findsOneWidget);
      expect(find.text('HEAD VIEW & FACIAL MARKINGS'), findsOneWidget);
      expect(find.text('SAVE MARKINGS'), findsOneWidget);
    });

    testWidgets('MarkingsScreen opens with pre-existing markings without crashing', (tester) async {
      const animalId = 'horse-saved-id';
      final existingMarkings = Markings(
        id: 'markings-99',
        ownerType: 'animal',
        ownerId: animalId,
        leftSideImageUrl: 'data:image/jpeg;base64,sampleLeft',
        rightSideImageUrl: 'data:image/jpeg;base64,sampleRight',
        headViewImageUrl: 'data:image/jpeg;base64,sampleHead',
        headViewNotes: 'White blaze, star between eyes',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      await mareRepo.saveMarkings(existingMarkings);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            mareRepositoryProvider.overrideWithValue(mareRepo),
          ],
          child: const MaterialApp(
            home: MarkingsScreen(
              ownerType: 'animal',
              ownerId: animalId,
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('PHYSICAL MARKINGS'), findsOneWidget);
      expect(find.text('White blaze, star between eyes'), findsOneWidget);
    });

    testWidgets('Navigating from AnimalProfileScreen to /markings via AppRouter works without crash', (tester) async {
      final testAnimal = Animal(
        id: 'animal-nav-test-1',
        accountId: 'account-1',
        name: 'Royal Duchess',
        species: 'horse',
        sex: 'mare',
        breed: 'Thoroughbred',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            mareRepositoryProvider.overrideWithValue(mareRepo),
          ],
          child: MaterialApp(
            onGenerateRoute: AppRouter.onGenerateRoute,
            home: AnimalProfileScreen(animal: testAnimal),
          ),
        ),
      );

      await tester.pumpAndSettle();

      final addMarkingsBtn = find.text('ADD PHYSICAL MARKINGS');
      expect(addMarkingsBtn, findsOneWidget);

      await tester.ensureVisible(addMarkingsBtn);
      await tester.pumpAndSettle();

      await tester.tap(addMarkingsBtn);
      await tester.pumpAndSettle();

      expect(find.text('PHYSICAL MARKINGS'), findsOneWidget);
      expect(find.text('HEAD VIEW & FACIAL MARKINGS'), findsOneWidget);
    });
  });
}
