import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:animal_birthday_predictor/features/pregnancy/presentation/screens/breeding_details_screen.dart';
import 'package:animal_birthday_predictor/features/animals/presentation/screens/animal_profile_screen.dart';
import 'package:animal_birthday_predictor/features/animals/domain/animal.dart';
import 'package:animal_birthday_predictor/core/router/app_router.dart';

void main() {
  testWidgets('Renders BreedingDetailsScreen with initialMareId without crashing', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          onGenerateRoute: AppRouter.onGenerateRoute,
          home: BreedingDetailsScreen(initialMareId: 'some-id'),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('BREEDING DETAILS'), findsOneWidget);
    expect(find.text('HOW WAS YOUR MARE BRED?'), findsOneWidget);
    expect(find.text('SAVE & CALCULATE PREGNANCY'), findsOneWidget);
  });

  testWidgets('Renders BreedingDetailsScreen with null initialMareId without crashing', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          onGenerateRoute: AppRouter.onGenerateRoute,
          home: BreedingDetailsScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('BREEDING DETAILS'), findsOneWidget);
  });

  testWidgets('Navigating from AnimalProfileScreen to /breeding-details works cleanly', (tester) async {
    final testHorse = Animal(
      id: 'horse-123',
      accountId: 'account-123',
      species: 'horse',
      name: 'Bella Mare',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          onGenerateRoute: AppRouter.onGenerateRoute,
          home: AnimalProfileScreen(animal: testHorse),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final logBreedingBtn = find.text('LOG BREEDING');
    expect(logBreedingBtn, findsOneWidget);
    await tester.ensureVisible(logBreedingBtn);
    await tester.tap(logBreedingBtn);
    await tester.pumpAndSettle();

    expect(find.text('BREEDING DETAILS'), findsOneWidget);
  });
}
