import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:animal_birthday_predictor/features/auth/data/auth_repository.dart';
import 'package:animal_birthday_predictor/features/auth/domain/user_profile.dart';
import 'package:animal_birthday_predictor/features/auth/presentation/providers/auth_provider.dart';
import 'package:animal_birthday_predictor/features/auth/presentation/screens/password_reset_screen.dart';
import 'package:animal_birthday_predictor/features/auth/presentation/screens/update_password_screen.dart';

class FakePasswordResetAuthRepository extends AuthRepository {
  bool isResetVerifiedResponse = true;
  bool updatePasswordSuccess = true;
  int resetCalls = 0;
  int checkVerifiedCalls = 0;
  int updatePasswordCalls = 0;

  @override
  Future<void> resetPasswordForEmail(String email) async {
    resetCalls++;
  }

  @override
  Future<bool> checkIsPasswordResetVerified([String? email]) async {
    checkVerifiedCalls++;
    return isResetVerifiedResponse;
  }

  @override
  Future<void> updatePassword(String newPassword) async {
    updatePasswordCalls++;
    if (!updatePasswordSuccess) {
      throw const AuthExceptionCustom('Failed to update password.');
    }
  }

  @override
  Future<UserProfile?> getUserProfile(String userId) async {
    return UserProfile(
      id: userId,
      email: 'test@example.com',
      fullName: 'Test User',
      createdAt: DateTime.now(),
    );
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Password Reset & Update Password Flow Tests', () {
    late FakePasswordResetAuthRepository fakeRepo;

    setUp(() {
      fakeRepo = FakePasswordResetAuthRepository();
    });

    testWidgets('PasswordResetScreen: Shows error SnackBar and stays on screen when link is not verified yet', (tester) async {
      tester.view.physicalSize = const Size(800, 1200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      fakeRepo.isResetVerifiedResponse = false;

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authRepositoryProvider.overrideWithValue(fakeRepo),
          ],
          child: MaterialApp(
            routes: {
              '/': (context) => const PasswordResetScreen(),
              '/update-password': (context) => const Scaffold(body: Text('Update Password Screen Target')),
              '/signin': (context) => const Scaffold(body: Text('Sign In Screen Target')),
            },
            initialRoute: '/',
          ),
        ),
      );

      // Enter email
      await tester.enterText(find.byType(TextField), 'user@example.com');
      await tester.pump();

      // Tap Send Reset Link
      final sendBtn = find.text('Send Reset Link ➤');
      await tester.ensureVisible(sendBtn);
      await tester.tap(sendBtn);
      await tester.pumpAndSettle();

      expect(find.text('Check Your Email'), findsOneWidget);

      // Tap "Verify Link" when not verified
      final verifyBtn = find.text('Verify Link');
      await tester.ensureVisible(verifyBtn);
      await tester.tap(verifyBtn);
      await tester.pumpAndSettle();

      expect(fakeRepo.checkVerifiedCalls, 1);
      // Clean error SnackBar without any bypass button
      expect(
        find.textContaining('Your password reset link has not been verified yet'),
        findsOneWidget,
      );
      // Stays on confirmation screen
      expect(find.text('Check Your Email'), findsOneWidget);
      expect(find.text('Update Password Screen Target'), findsNothing);
    });

    testWidgets('PasswordResetScreen: Navigates to /update-password when link is verified', (tester) async {
      tester.view.physicalSize = const Size(800, 1200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      fakeRepo.isResetVerifiedResponse = true;

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authRepositoryProvider.overrideWithValue(fakeRepo),
          ],
          child: MaterialApp(
            routes: {
              '/': (context) => const PasswordResetScreen(),
              '/update-password': (context) => const Scaffold(body: Text('Update Password Screen Target')),
              '/signin': (context) => const Scaffold(body: Text('Sign In Screen Target')),
            },
            initialRoute: '/',
          ),
        ),
      );

      // Enter email
      await tester.enterText(find.byType(TextField), 'user@example.com');
      await tester.pump();

      // Tap Send Reset Link
      final sendBtn = find.text('Send Reset Link ➤');
      await tester.ensureVisible(sendBtn);
      await tester.tap(sendBtn);
      await tester.pumpAndSettle();

      expect(fakeRepo.resetCalls, 1);
      expect(find.text('Check Your Email'), findsOneWidget);

      // Tap "Verify Link" -> Navigates to /update-password
      final verifyBtn = find.text('Verify Link');
      await tester.ensureVisible(verifyBtn);
      await tester.tap(verifyBtn);
      await tester.pumpAndSettle();

      expect(fakeRepo.checkVerifiedCalls, 1);
      expect(find.text('Update Password Screen Target'), findsOneWidget);
    });

    testWidgets('UpdatePasswordScreen: Shows two fields, updates password and navigates to /home', (tester) async {
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
              '/': (context) => const UpdatePasswordScreen(),
              '/home': (context) => const Scaffold(body: Text('Home Dashboard Screen Target')),
              '/signin': (context) => const Scaffold(body: Text('Sign In Target')),
            },
            initialRoute: '/',
          ),
        ),
      );

      // Check fields
      expect(find.text('Reset Your Password'), findsOneWidget);
      expect(find.byType(TextField), findsNWidgets(2)); // New password & Confirm password

      // Enter matching passwords (min 8 chars)
      await tester.enterText(find.byType(TextField).at(0), 'NewSecretPassword123');
      await tester.enterText(find.byType(TextField).at(1), 'NewSecretPassword123');
      await tester.pump();

      // Tap Update Password
      final updateBtn = find.text('Update Password ✦');
      await tester.ensureVisible(updateBtn);
      await tester.tap(updateBtn);
      await tester.pumpAndSettle();

      expect(fakeRepo.updatePasswordCalls, 1);
      // Directly navigates to /home
      expect(find.text('Home Dashboard Screen Target'), findsOneWidget);
      expect(find.textContaining('Password updated successfully!'), findsOneWidget);
    });
  });
}
