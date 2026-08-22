import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:animal_birthday_predictor/core/router/app_router.dart';
import 'package:animal_birthday_predictor/features/dashboard/presentation/screens/dashboard_home_screen.dart';
import 'package:animal_birthday_predictor/features/foal/data/foal_repository.dart';
import 'package:animal_birthday_predictor/features/foal/domain/foal_record.dart';
import 'package:animal_birthday_predictor/features/foal/presentation/providers/foal_provider.dart';
import 'package:animal_birthday_predictor/features/main/presentation/screens/main_navigation_screen.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('Dashboard Foal Records and Navigation Tests', () {
    testWidgets('Displays Foal Records count in stat card on Dashboard', (tester) async {
      final repo = FoalRepository();
      await repo.saveFoal(
        FoalRecord(
          id: 'foal-1',
          accountId: 'acc-1',
          mareAnimalId: 'mare-1',
          foalName: 'Starlight Dreamer',
          breed: 'Thoroughbred',
          sex: 'colt',
          status: 'sold',
          dateOfBirth: DateTime(2026, 4, 15),
          foalMicrochipNo: '985141002938475',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            foalRepositoryProvider.overrideWithValue(repo),
          ],
          child: const MaterialApp(
            home: DashboardHomeScreen(),
            onGenerateRoute: AppRouter.onGenerateRoute,
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Check stat card
      expect(find.text('Foal Records'), findsOneWidget);
      expect(find.text('1'), findsOneWidget);
    });

    testWidgets('Tapping Foal Records stat card invokes onNavigateTab with index 3 (Birth Log)', (tester) async {
      int? tappedIndex;

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: DashboardHomeScreen(
              onNavigateTab: (index) => tappedIndex = index,
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      final foalCardFinder = find.ancestor(
        of: find.text('Foal Records'),
        matching: find.byType(GestureDetector),
      );

      await tester.tap(foalCardFinder.first);
      await tester.pumpAndSettle();

      expect(tappedIndex, 3);
    });

    testWidgets('MainNavigationScreen displays FoalModuleScreen on Tab 3 (Birth Log) with category tabs', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: MainNavigationScreen(),
            onGenerateRoute: AppRouter.onGenerateRoute,
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Tap on Birth Log in BottomNavigationBar
      await tester.tap(find.text('Birth Log'));
      await tester.pumpAndSettle();

      expect(find.text('BIRTH LOG & REGISTRY'), findsOneWidget);
      expect(find.text('SAVED MARES FOAL RECORDS'), findsOneWidget);
      expect(find.text('DAM/BITCH PUPPY RECORDS'), findsOneWidget);
      expect(find.text('+ REGISTER NEW FOAL'), findsOneWidget);

      // Switch to PUPPIES tab
      await tester.tap(find.text('DAM/BITCH PUPPY RECORDS'));
      await tester.pumpAndSettle();

      expect(find.text('+ REGISTER NEW PUPPY'), findsOneWidget);
    });

    testWidgets('Navigating to /foals route loads FoalModuleScreen', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            initialRoute: '/home',
            onGenerateRoute: AppRouter.onGenerateRoute,
          ),
        ),
      );

      await tester.pumpAndSettle();

      Navigator.pushNamed(tester.element(find.byType(MainNavigationScreen)), '/foals');
      await tester.pumpAndSettle();

      expect(find.text('BIRTH LOG & REGISTRY'), findsOneWidget);
      expect(find.text('SAVED MARES FOAL RECORDS'), findsOneWidget);
    });

    testWidgets('Pressing system back on non-dashboard tab in MainNavigationScreen navigates to Dashboard', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: MainNavigationScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Initially on Dashboard
      expect(find.text('ANIMAL BIRTHDAY PREDICTOR'), findsOneWidget);

      // Switch to Animals tab (index 1)
      await tester.tap(find.text('Animals'));
      await tester.pumpAndSettle();
      expect(find.text('SAVED ANIMALS REGISTRY'), findsOneWidget);

      // Trigger system back pop on the Navigator
      final dynamic widgetsAppState = tester.state(find.byType(WidgetsApp));
      await widgetsAppState.didPopRoute();
      await tester.pumpAndSettle();

      // Verify it navigated back to Dashboard instead of popping the app
      expect(find.text('ANIMAL BIRTHDAY PREDICTOR'), findsOneWidget);
    });
  });
}
