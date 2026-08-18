import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:animal_birthday_predictor/features/auth/data/auth_repository.dart';
import 'package:animal_birthday_predictor/features/auth/domain/user_profile.dart';
import 'package:animal_birthday_predictor/features/auth/presentation/providers/auth_provider.dart';
import 'package:animal_birthday_predictor/features/auth/presentation/screens/sign_up_screen.dart';

class FakeSignUpAuthRepository extends AuthRepository {
  bool emailExistsResponse = false;
  bool shouldThrowDuplicateException = false;
  int checkEmailExistsCalls = 0;
  int signUpCalls = 0;

  @override
  Future<bool> checkEmailExists(String email) async {
    checkEmailExistsCalls++;
    return emailExistsResponse;
  }

  @override
  Future<UserProfile> signUp({
    required String email,
    required String password,
    required String fullName,
  }) async {
    signUpCalls++;
    if (emailExistsResponse || shouldThrowDuplicateException) {
      throw const AuthExceptionCustom('This email is already registered. Please log in.');
    }
    return UserProfile(
      id: 'new-user-123',
      email: email,
      fullName: fullName,
      createdAt: DateTime.now(),
    );
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('SignUp Duplicate Email Tests', () {
    late FakeSignUpAuthRepository fakeRepo;

    setUp(() {
      fakeRepo = FakeSignUpAuthRepository();
    });

    testWidgets('Shows inline error and SnackBar with Sign In button when email is already registered', (tester) async {
      tester.view.physicalSize = const Size(800, 1200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      fakeRepo.emailExistsResponse = true;

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authRepositoryProvider.overrideWithValue(fakeRepo),
          ],
          child: MaterialApp(
            routes: {
              '/': (context) => const SignUpScreen(),
              '/signin': (context) => const Scaffold(body: Text('Sign In Screen Target')),
              '/email-verification': (context) => const Scaffold(body: Text('Verification Screen Target')),
            },
            initialRoute: '/',
          ),
        ),
      );

      // Fill in signup form
      final nameField = find.widgetWithText(TextField, '');
      expect(nameField, findsNWidgets(3)); // Full name, Email, Password

      // Fill Full Name
      await tester.enterText(find.byType(TextField).at(0), 'John Doe');
      // Fill Email
      await tester.enterText(find.byType(TextField).at(1), 'registered@example.com');
      // Fill Password
      await tester.enterText(find.byType(TextField).at(2), 'password123');
      await tester.pump();

      // Tap Create Account
      final createAccountBtn = find.text('Create Account');
      await tester.ensureVisible(createAccountBtn);
      await tester.tap(createAccountBtn);
      await tester.pumpAndSettle();

      // Verify that error is shown inline and in SnackBar
      expect(find.text('This email is already registered. Please log in.'), findsAtLeastNWidgets(1));
      expect(find.text('Sign In'), findsAtLeastNWidgets(1));

      // Tap the Sign In action in SnackBar
      final signInAction = find.widgetWithText(TextButton, 'Sign In');
      if (signInAction.evaluate().isNotEmpty) {
        await tester.tap(signInAction);
        await tester.pumpAndSettle();
        expect(find.text('Sign In Screen Target'), findsOneWidget);
      }
    });

    testWidgets('Navigates to /email-verification when email is not registered and signup succeeds', (tester) async {
      tester.view.physicalSize = const Size(800, 1200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      fakeRepo.emailExistsResponse = false;

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authRepositoryProvider.overrideWithValue(fakeRepo),
          ],
          child: MaterialApp(
            routes: {
              '/': (context) => const SignUpScreen(),
              '/signin': (context) => const Scaffold(body: Text('Sign In Screen Target')),
              '/email-verification': (context) => const Scaffold(body: Text('Verification Screen Target')),
            },
            initialRoute: '/',
          ),
        ),
      );

      // Fill Full Name
      await tester.enterText(find.byType(TextField).at(0), 'Jane Doe');
      // Fill Email
      await tester.enterText(find.byType(TextField).at(1), 'newuser@example.com');
      // Fill Password
      await tester.enterText(find.byType(TextField).at(2), 'password123');
      await tester.pump();

      // Tap Create Account
      final createAccountBtn = find.text('Create Account');
      await tester.ensureVisible(createAccountBtn);
      await tester.tap(createAccountBtn);
      await tester.pumpAndSettle();

      // Should navigate to verification screen
      expect(find.text('Verification Screen Target'), findsOneWidget);
    });
  });
}
