import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:animal_birthday_predictor/features/auth/data/auth_repository.dart';
import 'package:animal_birthday_predictor/features/auth/domain/user_profile.dart';
import 'package:animal_birthday_predictor/features/auth/presentation/providers/auth_provider.dart';
import 'package:animal_birthday_predictor/features/auth/presentation/screens/email_verification_screen.dart';

class FakeAuthRepository extends AuthRepository {
  bool isVerifiedResponse = false;
  bool resendSuccessResponse = true;
  int checkVerifiedCalls = 0;
  int resendCalls = 0;

  @override
  Future<bool> isEmailVerified([String? email]) async {
    checkVerifiedCalls++;
    return isVerifiedResponse;
  }

  @override
  Future<void> resendVerificationEmail(String email) async {
    resendCalls++;
    if (!resendSuccessResponse) {
      throw const AuthExceptionCustom('Failed to resend verification email.');
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
  group('EmailVerificationScreen Flow Tests', () {
    late FakeAuthRepository fakeAuthRepository;

    setUp(() {
      fakeAuthRepository = FakeAuthRepository();
    });

    testWidgets('Displays target email address, Waiting for Verification indicator and Resend button', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authRepositoryProvider.overrideWithValue(fakeAuthRepository),
          ],
          child: const MaterialApp(
            home: EmailVerificationScreen(email: 'alex.sterling@example.com'),
          ),
        ),
      );

      expect(find.text('Verify Your Email'), findsOneWidget);
      expect(find.text('alex.sterling@example.com'), findsOneWidget);
      expect(find.text('Waiting for Verification...'), findsOneWidget);
      expect(find.text('Resend Verification Email'), findsOneWidget);
      // Verify manual check button is removed
      expect(find.text('Verify Link'), findsNothing);
      expect(find.text('I have verified'), findsNothing);
    });

    testWidgets('Automatically navigates to /home when email is detected as verified via polling', (tester) async {
      tester.view.physicalSize = const Size(800, 1200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      fakeAuthRepository.isVerifiedResponse = true;

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authRepositoryProvider.overrideWithValue(fakeAuthRepository),
          ],
          child: MaterialApp(
            routes: {
              '/': (context) => const EmailVerificationScreen(email: 'alex.sterling@example.com'),
              '/home': (context) => const Scaffold(body: Text('Home Screen Content')),
            },
            initialRoute: '/',
          ),
        ),
      );

      // Trigger the 3-second periodic timer
      await tester.pump(const Duration(seconds: 3));
      await tester.pump(const Duration(milliseconds: 500));

      expect(fakeAuthRepository.checkVerifiedCalls, greaterThanOrEqualTo(1));
      expect(find.text('Home Screen Content'), findsOneWidget);
      expect(find.text('Email Verified'), findsOneWidget);
    });

    testWidgets('Resend verification email triggers cooldown timer and single message', (tester) async {
      tester.view.physicalSize = const Size(800, 1200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      fakeAuthRepository.resendSuccessResponse = true;

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authRepositoryProvider.overrideWithValue(fakeAuthRepository),
          ],
          child: const MaterialApp(
            home: EmailVerificationScreen(email: 'alex.sterling@example.com'),
          ),
        ),
      );

      final resendBtn = find.text('Resend Verification Email');
      await tester.ensureVisible(resendBtn);
      await tester.tap(resendBtn);
      await tester.pump();

      expect(fakeAuthRepository.resendCalls, 1);
      expect(find.text('Verification Link Sent'), findsOneWidget);
      expect(find.textContaining('Resend in'), findsOneWidget);
    });
  });
}
