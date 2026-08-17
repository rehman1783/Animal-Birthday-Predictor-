import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:animal_birthday_predictor/features/pregnancy/presentation/screens/breeding_details_screen.dart';
import 'package:animal_birthday_predictor/features/animals/presentation/screens/animal_profile_screen.dart';
import 'package:animal_birthday_predictor/features/animals/domain/animal.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:animal_birthday_predictor/core/router/app_router.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

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

  testWidgets('Selecting stallion on BreedingDetailsScreen shows ADD NEW STALLION and pre-selects STALLION in AnimalDetailsScreen', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          onGenerateRoute: AppRouter.onGenerateRoute,
          home: BreedingDetailsScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Tap Pick Saved on Stallion section
    final pickStallionBtn = find.text('Pick Saved');
    expect(pickStallionBtn, findsOneWidget);
    await tester.ensureVisible(pickStallionBtn);
    await tester.tap(pickStallionBtn);
    await tester.pumpAndSettle();

    // Modal opens with title and ADD NEW STALLION button
    expect(find.text('Select Stallion (Father)'), findsOneWidget);
    expect(find.text('ADD NEW STALLION'), findsOneWidget);

    // Tap ADD NEW STALLION
    await tester.tap(find.text('ADD NEW STALLION'));
    await tester.pumpAndSettle();

    // AnimalDetailsScreen opens with STALLION selected
    expect(find.text('ANIMAL DETAILS'), findsOneWidget);
    expect(find.text('STALLION'), findsOneWidget);
  });
}
