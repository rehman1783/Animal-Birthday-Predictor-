import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:animal_birthday_predictor/features/auth/data/auth_repository.dart';
import 'package:animal_birthday_predictor/features/auth/domain/user_profile.dart';
import 'package:animal_birthday_predictor/features/auth/presentation/providers/auth_provider.dart';
import 'package:animal_birthday_predictor/features/profile/presentation/screens/change_password_screen.dart';

class FakeChangePasswordAuthRepository extends AuthRepository {
  bool changePasswordSuccess = true;
  String? lastCurrentPassword;
  String? lastNewPassword;
  int changePasswordCalls = 0;

  @override
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    changePasswordCalls++;
    lastCurrentPassword = currentPassword;
    lastNewPassword = newPassword;

    if (!changePasswordSuccess) {
      throw const AuthExceptionCustom('Incorrect current password. Please try again.');
    }
  }

  @override
  Future<UserProfile?> getUserProfile(String userId) async {
    return UserProfile(
      id: userId,
      email: 'user@example.com',
      fullName: 'Test User',
      createdAt: DateTime.now(),
    );
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Change Password Flow Tests (In-App Profile)', () {
    late FakeChangePasswordAuthRepository fakeRepo;

    setUp(() {
      fakeRepo = FakeChangePasswordAuthRepository();
    });

    testWidgets('ChangePasswordScreen: Validates all required fields & mismatches', (tester) async {
      tester.view.physicalSize = const Size(800, 1200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authRepositoryProvider.overrideWithValue(fakeRepo),
          ],
          child: const MaterialApp(
            home: ChangePasswordScreen(),
          ),
        ),
      );

      // Verify header and 3 text fields
      expect(find.text('Change Password'), findsWidgets);
      expect(find.byType(TextField), findsNWidgets(3)); // Current, New, Confirm

      // Tap submit with empty fields
      final submitBtn = find.text('Change Password ✦');
      await tester.ensureVisible(submitBtn);
      await tester.tap(submitBtn);
      await tester.pumpAndSettle();

      expect(find.text('Current password is required'), findsOneWidget);
      expect(fakeRepo.changePasswordCalls, 0);

      // Enter current password but short new password
      await tester.enterText(find.byType(TextField).at(0), 'OldPass123');
      await tester.enterText(find.byType(TextField).at(1), 'short');
      await tester.enterText(find.byType(TextField).at(2), 'short');
      await tester.pump();

      await tester.tap(submitBtn);
      await tester.pumpAndSettle();

      expect(find.text('Password must be at least 8 characters'), findsOneWidget);
      expect(fakeRepo.changePasswordCalls, 0);

      // Enter same new password as current password
      await tester.enterText(find.byType(TextField).at(1), 'OldPass123');
      await tester.enterText(find.byType(TextField).at(2), 'OldPass123');
      await tester.pump();

      await tester.tap(submitBtn);
      await tester.pumpAndSettle();

      expect(find.text('New password must be different from current password'), findsOneWidget);
      expect(fakeRepo.changePasswordCalls, 0);

      // Enter non-matching confirm password
      await tester.enterText(find.byType(TextField).at(1), 'BrandNewPass123');
      await tester.enterText(find.byType(TextField).at(2), 'DifferentPass123');
      await tester.pump();

      await tester.tap(submitBtn);
      await tester.pumpAndSettle();

      expect(find.text('Passwords do not match'), findsOneWidget);
      expect(fakeRepo.changePasswordCalls, 0);
    });

    testWidgets('ChangePasswordScreen: Shows error when wrong current password is provided', (tester) async {
      tester.view.physicalSize = const Size(800, 1200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      fakeRepo.changePasswordSuccess = false;

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authRepositoryProvider.overrideWithValue(fakeRepo),
          ],
          child: const MaterialApp(
            home: ChangePasswordScreen(),
          ),
        ),
      );

      // Enter wrong current password
      await tester.enterText(find.byType(TextField).at(0), 'WrongOldPassword123');
      await tester.enterText(find.byType(TextField).at(1), 'BrandNewSecret123');
      await tester.enterText(find.byType(TextField).at(2), 'BrandNewSecret123');
      await tester.pump();

      final submitBtn = find.text('Change Password ✦');
      await tester.ensureVisible(submitBtn);
      await tester.tap(submitBtn);
      await tester.pumpAndSettle();

      expect(fakeRepo.changePasswordCalls, 1);
      expect(fakeRepo.lastCurrentPassword, 'WrongOldPassword123');
      expect(find.textContaining('Incorrect current password'), findsWidgets);
    });

    testWidgets('ChangePasswordScreen: Successfully updates password on correct current password', (tester) async {
      tester.view.physicalSize = const Size(800, 1200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      fakeRepo.changePasswordSuccess = true;

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authRepositoryProvider.overrideWithValue(fakeRepo),
          ],
          child: MaterialApp(
            home: Builder(
              builder: (context) => Scaffold(
                body: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const ChangePasswordScreen()),
                    );
                  },
                  child: const Text('Open Change Password'),
                ),
              ),
            ),
          ),
        ),
      );

      // Open screen
      await tester.tap(find.text('Open Change Password'));
      await tester.pumpAndSettle();

      expect(find.text('Change Password'), findsWidgets);

      // Enter valid fields
      await tester.enterText(find.byType(TextField).at(0), 'CorrectOldPassword123');
      await tester.enterText(find.byType(TextField).at(1), 'BrandNewSecret123');
      await tester.enterText(find.byType(TextField).at(2), 'BrandNewSecret123');
      await tester.pump();

      final submitBtn = find.text('Change Password ✦');
      await tester.ensureVisible(submitBtn);
      await tester.tap(submitBtn);
      await tester.pumpAndSettle();

      expect(fakeRepo.changePasswordCalls, 1);
      expect(fakeRepo.lastCurrentPassword, 'CorrectOldPassword123');
      expect(fakeRepo.lastNewPassword, 'BrandNewSecret123');

      // Returns to previous screen and shows success feedback
      expect(find.text('Open Change Password'), findsOneWidget);
      expect(find.text('Password Changed'), findsOneWidget);
    });
  });
}
