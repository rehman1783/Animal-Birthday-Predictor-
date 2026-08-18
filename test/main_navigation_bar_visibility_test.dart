import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:animal_birthday_predictor/core/router/app_router.dart';
import 'package:animal_birthday_predictor/features/main/presentation/screens/main_navigation_screen.dart';
import 'package:animal_birthday_predictor/features/main/presentation/providers/main_navigation_provider.dart';

void main() {
  Widget createTestApp({String initialRoute = '/home', RouteSettings? initialSettings}) {
    return ProviderScope(
      child: MaterialApp(
        onGenerateRoute: AppRouter.onGenerateRoute,
        initialRoute: initialRoute,
      ),
    );
  }

  group('Main Navigation Bar Visibility and Tab Switching Tests', () {
    testWidgets('Dashboard renders with BottomNavigationBar visible', (tester) async {
      await tester.pumpWidget(createTestApp());
      await tester.pumpAndSettle();

      expect(find.byType(BottomNavigationBar), findsOneWidget);
      expect(find.text('Dashboard'), findsWidgets);
      expect(find.text('Animals'), findsWidgets);
      expect(find.text('Birth Log'), findsWidgets);
    });

    testWidgets('Tapping Saved Horses on Dashboard switches to Animals tab while keeping BottomNavigationBar', (tester) async {
      await tester.pumpWidget(createTestApp());
      await tester.pumpAndSettle();

      // Tap on Saved Horses StatCard
      final savedHorsesCard = find.text('Saved Horses');
      expect(savedHorsesCard, findsOneWidget);
      await tester.tap(savedHorsesCard);
      await tester.pumpAndSettle();

      // Verify BottomNavigationBar is still present
      expect(find.byType(BottomNavigationBar), findsOneWidget);
      expect(find.text('SAVED ANIMALS REGISTRY'), findsOneWidget);
    });

    testWidgets('Tapping Puppy Registry on Dashboard switches to Birth Log Puppies tab while keeping BottomNavigationBar', (tester) async {
      await tester.pumpWidget(createTestApp());
      await tester.pumpAndSettle();

      // Tap on Puppy Registry StatCard
      final puppyRegistryCard = find.text('Puppy Registry');
      expect(puppyRegistryCard, findsOneWidget);
      await tester.tap(puppyRegistryCard);
      await tester.pumpAndSettle();

      // Verify BottomNavigationBar is still present and Birth Log screen is active
      expect(find.byType(BottomNavigationBar), findsOneWidget);
      expect(find.text('BIRTH LOG & REGISTRY'), findsOneWidget);
      // Verify that Puppies section is active
      expect(find.text('Register Newborn Puppy'), findsOneWidget);
      expect(find.text('+ REGISTER NEW PUPPY'), findsOneWidget);
    });

    testWidgets('Navigating to /saved-animals route opens MainNavigationScreen with BottomNavigationBar', (tester) async {
      await tester.pumpWidget(createTestApp(initialRoute: '/saved-animals'));
      await tester.pumpAndSettle();

      expect(find.byType(BottomNavigationBar), findsOneWidget);
      expect(find.text('SAVED ANIMALS REGISTRY'), findsOneWidget);
    });

    testWidgets('Navigating to /puppies route opens MainNavigationScreen with BottomNavigationBar', (tester) async {
      await tester.pumpWidget(createTestApp(initialRoute: '/puppies'));
      await tester.pumpAndSettle();

      expect(find.byType(BottomNavigationBar), findsOneWidget);
      expect(find.text('BIRTH LOG & REGISTRY'), findsOneWidget);
    });

    testWidgets('Tapping Dog / Canine Module on Dashboard switches to Animals tab on Dogs filter while keeping BottomNavigationBar', (tester) async {
      await tester.pumpWidget(createTestApp());
      await tester.pumpAndSettle();

      final dogModuleCard = find.text('Dog / Canine Module');
      expect(dogModuleCard, findsOneWidget);
      await tester.ensureVisible(dogModuleCard);
      await tester.pumpAndSettle();

      await tester.tap(dogModuleCard);
      await tester.pumpAndSettle();

      expect(find.byType(BottomNavigationBar), findsOneWidget);
      expect(find.text('SAVED ANIMALS REGISTRY'), findsOneWidget);
      expect(find.text('DOGS'), findsOneWidget);
    });

    testWidgets('Navigating to /pregnancy route opens MainNavigationScreen with BottomNavigationBar', (tester) async {
      await tester.pumpWidget(createTestApp(initialRoute: '/pregnancy'));
      await tester.pumpAndSettle();

      expect(find.byType(BottomNavigationBar), findsOneWidget);
      expect(find.text('PREGNANCY & BREEDING TRACKER'), findsOneWidget);
    });
  });
}
