import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:animal_birthday_predictor/features/auth/data/auth_repository.dart';
import 'package:animal_birthday_predictor/features/auth/domain/user_profile.dart';
import 'package:animal_birthday_predictor/features/auth/presentation/providers/auth_provider.dart';
import 'package:animal_birthday_predictor/features/profile/presentation/screens/profile_screen.dart';
import 'package:animal_birthday_predictor/features/profile/presentation/screens/delete_account_screen.dart';

class FakeDeleteAccountAuthRepository extends AuthRepository {
  bool shouldThrowWrongPassword = false;
  int deleteAccountCalls = 0;

  @override
  Future<void> deleteAccount({required String password}) async {
    deleteAccountCalls++;
    if (shouldThrowWrongPassword || password != 'ValidPassword123') {
      throw const AuthExceptionCustom('Incorrect password. Please enter your valid password.');
    }
  }

  @override
  Future<UserProfile?> getUserProfile(String userId) async {
    return UserProfile(
      id: userId,
      email: 'breeder@example.com',
      fullName: 'Breeder User',
      createdAt: DateTime.now(),
    );
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Delete Account Flow Tests', () {
    late FakeDeleteAccountAuthRepository fakeRepo;

    setUp(() {
      fakeRepo = FakeDeleteAccountAuthRepository();
    });

    testWidgets('ProfileScreen contains Danger Zone and Delete Account tile', (tester) async {
      tester.view.physicalSize = const Size(800, 1200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authRepositoryProvider.overrideWithValue(fakeRepo),
          ],
          child: MaterialApp(
            routes: {
              '/': (context) => const ProfileScreen(),
              '/delete-account': (context) => const Scaffold(body: Text('Delete Account Screen Target')),
            },
            initialRoute: '/',
          ),
        ),
      );

      // Verify Danger Zone is rendered
      expect(find.text('Danger Zone'), findsOneWidget);
      expect(find.text('Delete Account'), findsOneWidget);

      // Tap Delete Account
      final deleteTile = find.text('Delete Account');
      await tester.ensureVisible(deleteTile);
      await tester.tap(deleteTile);
      await tester.pumpAndSettle();

      // Should navigate to Delete Account screen
      expect(find.text('Delete Account Screen Target'), findsOneWidget);
    });

    testWidgets('DeleteAccountScreen: Shows error when wrong password entered', (tester) async {
      tester.view.physicalSize = const Size(800, 1200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      fakeRepo.shouldThrowWrongPassword = true;

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authRepositoryProvider.overrideWithValue(fakeRepo),
          ],
          child: const MaterialApp(
            home: DeleteAccountScreen(),
          ),
        ),
      );

      // Verify Warning and Consequences items
      expect(find.text('Permanent Account Deletion'), findsOneWidget);
      expect(find.text('All Animals & Profiles'), findsOneWidget);
      expect(find.text('Breeding & Pregnancy Logs'), findsOneWidget);

      // Enter wrong password
      await tester.enterText(find.byType(TextField), 'WrongPassword999');
      await tester.pump();

      // Tap Delete CTA
      final deleteBtn = find.text('Permanently Delete Account');
      await tester.ensureVisible(deleteBtn);
      await tester.tap(deleteBtn);
      await tester.pumpAndSettle();

      // Confirm in dialog
      final confirmBtn = find.text('Yes, Delete');
      expect(confirmBtn, findsOneWidget);
      await tester.tap(confirmBtn);
      await tester.pumpAndSettle();

      expect(fakeRepo.deleteAccountCalls, 1);
      // Verify error message is shown
      expect(find.text('Incorrect password. Please enter your valid password.'), findsAtLeastNWidgets(1));
    });

    testWidgets('DeleteAccountScreen: Deletes account on valid password and navigates to /signin', (tester) async {
      tester.view.physicalSize = const Size(800, 1200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      fakeRepo.shouldThrowWrongPassword = false;

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authRepositoryProvider.overrideWithValue(fakeRepo),
          ],
          child: MaterialApp(
            routes: {
              '/': (context) => const DeleteAccountScreen(),
              '/signin': (context) => const Scaffold(body: Text('Sign In Target Screen')),
            },
            initialRoute: '/',
          ),
        ),
      );

      // Enter correct password
      await tester.enterText(find.byType(TextField), 'ValidPassword123');
      await tester.pump();

      // Tap Delete CTA
      final deleteBtn = find.text('Permanently Delete Account');
      await tester.ensureVisible(deleteBtn);
      await tester.tap(deleteBtn);
      await tester.pumpAndSettle();

      // Confirm in dialog
      final confirmBtn = find.text('Yes, Delete');
      await tester.tap(confirmBtn);
      await tester.pumpAndSettle();

      expect(fakeRepo.deleteAccountCalls, 1);
      // Navigates to Sign In
      expect(find.text('Sign In Target Screen'), findsOneWidget);
      expect(find.textContaining('Your account and all associated data have been permanently deleted.'), findsOneWidget);
    });
  });
}
