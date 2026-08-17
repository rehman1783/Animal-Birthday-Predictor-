import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:animal_birthday_predictor/features/profile/presentation/screens/profile_screen.dart';
import 'package:animal_birthday_predictor/features/profile/presentation/screens/settings_screen.dart';
import 'package:animal_birthday_predictor/core/widgets/app_logout_dialog.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('Logout Confirmation Dialog & Flows', () {
    testWidgets('AppLogoutDialog shows title, warning message, CANCEL and YES, LOG OUT buttons', (tester) async {
      bool? userChoice;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () async {
                  userChoice = await AppLogoutDialog.show(context);
                },
                child: const Text('Open Dialog'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open Dialog'));
      await tester.pumpAndSettle();

      expect(find.text('LOG OUT'), findsOneWidget);
      expect(find.textContaining('Are you sure you want to log out?'), findsOneWidget);
      expect(find.text('CANCEL'), findsOneWidget);
      expect(find.text('YES, LOG OUT'), findsOneWidget);

      // Tap CANCEL
      await tester.tap(find.text('CANCEL'));
      await tester.pumpAndSettle();

      expect(userChoice, false);
      expect(find.text('LOG OUT'), findsNothing);
    });

    testWidgets('AppLogoutDialog returns true when YES, LOG OUT is pressed', (tester) async {
      bool? userChoice;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () async {
                  userChoice = await AppLogoutDialog.show(context);
                },
                child: const Text('Open Dialog'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open Dialog'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('YES, LOG OUT'));
      await tester.pumpAndSettle();

      expect(userChoice, true);
    });

    testWidgets('ProfileScreen Sign Out CTA triggers AppLogoutDialog and does not sign out if cancelled', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: const ProfileScreen(),
            routes: {
              '/signin': (context) => const Scaffold(body: Text('SignIn Screen')),
            },
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Scroll to Sign Out CTA
      final signOutFinder = find.text('Sign Out & Terminate Session');
      await tester.scrollUntilVisible(signOutFinder, 100);
      await tester.tap(signOutFinder);
      await tester.pumpAndSettle();

      // Verify dialog is visible
      expect(find.text('LOG OUT'), findsOneWidget);
      expect(find.text('CANCEL'), findsOneWidget);
      expect(find.text('YES, LOG OUT'), findsOneWidget);

      // Cancel dialog
      await tester.tap(find.text('CANCEL'));
      await tester.pumpAndSettle();

      // Still on Profile screen
      expect(find.text('Sign Out & Terminate Session'), findsOneWidget);
      expect(find.text('SignIn Screen'), findsNothing);
    });

    testWidgets('SettingsScreen Log Out triggers AppLogoutDialog', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: const SettingsScreen(),
            routes: {
              '/signin': (context) => const Scaffold(body: Text('SignIn Screen')),
            },
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Scroll to Log Out option
      final logOutFinder = find.text('Log Out of ABP Account');
      await tester.scrollUntilVisible(logOutFinder, 100);
      await tester.tap(logOutFinder);
      await tester.pumpAndSettle();

      // Verify dialog is visible
      expect(find.text('LOG OUT'), findsOneWidget);
      expect(find.text('CANCEL'), findsOneWidget);
      expect(find.text('YES, LOG OUT'), findsOneWidget);

      // Cancel dialog
      await tester.tap(find.text('CANCEL'));
      await tester.pumpAndSettle();

      // Still on Settings screen
      expect(find.text('Log Out of ABP Account'), findsOneWidget);
    });
  });
}
