import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:animal_birthday_predictor/core/utils/error_handler.dart';
import 'package:animal_birthday_predictor/core/widgets/app_error_view.dart';
import 'package:animal_birthday_predictor/core/widgets/app_loading_view.dart';
import 'package:animal_birthday_predictor/core/widgets/app_feedback_snackbar.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('ErrorHandler Utility Tests', () {
    test('detects SocketException as network error', () {
      const error = SocketException('Failed host lookup: db.supabase.co');
      expect(ErrorHandler.isNetworkError(error), isTrue);
      expect(ErrorHandler.getUserFriendlyTitle(error), 'No Internet Connection');
      expect(ErrorHandler.getUserFriendlyMessage(error), contains('Wi-Fi or mobile data'));
    });

    test('detects TimeoutException as timeout error', () {
      final error = TimeoutException('Connection timed out');
      expect(ErrorHandler.isNetworkError(error), isTrue);
      expect(ErrorHandler.getUserFriendlyTitle(error), 'Connection Timed Out');
      expect(ErrorHandler.getUserFriendlyMessage(error), contains('too long to complete'));
    });

    test('detects network string errors', () {
      expect(ErrorHandler.isNetworkError('ClientException: XMLHttpRequest error'), isTrue);
      expect(ErrorHandler.isNetworkError('Network is unreachable'), isTrue);
      expect(ErrorHandler.isNetworkError('Failed to connect to host'), isTrue);
      expect(ErrorHandler.isNetworkError('Connection refused'), isTrue);
    });

    test('handles general database / application errors', () {
      const error = 'PostgrestException: relation does not exist';
      expect(ErrorHandler.isNetworkError(error), isFalse);
      expect(ErrorHandler.getUserFriendlyTitle(error), 'Something Went Wrong');
      expect(ErrorHandler.getUserFriendlyMessage(error), contains('Unable to load data'));
    });
  });

  group('AppErrorView Widget Tests', () {
    testWidgets('renders Network Error UI with Try Again button', (tester) async {
      bool retried = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AppErrorView(
              error: const SocketException('No Internet'),
              onRetry: () => retried = true,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('No Internet Connection'), findsOneWidget);
      expect(find.byIcon(Icons.wifi_off_rounded), findsOneWidget);
      expect(find.text('TRY AGAIN'), findsOneWidget);

      await tester.tap(find.text('TRY AGAIN'));
      await tester.pump();
      expect(retried, isTrue);
    });

    testWidgets('renders General Error UI with retry', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AppErrorView(
              error: 'Something went wrong',
              onRetry: () {},
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Something Went Wrong'), findsOneWidget);
      expect(find.byIcon(Icons.error_outline_rounded), findsOneWidget);
      expect(find.text('TRY AGAIN'), findsOneWidget);
    });

    testWidgets('renders Compact Mode properly', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AppErrorView(
              error: const SocketException('No Internet'),
              isCompact: true,
              onRetry: () {},
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('No Internet Connection'), findsOneWidget);
      expect(find.byIcon(Icons.refresh_rounded), findsOneWidget);
    });
  });

  group('AppLoadingView Widget Tests', () {
    testWidgets('renders full page loading indicator and custom message', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AppLoadingView(message: 'Loading your animals...'),
          ),
        ),
      );
      await tester.pump();

      expect(find.text('Loading your animals...'), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('renders compact loading view', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AppLoadingView(
              message: 'Fetching...',
              isCompact: true,
            ),
          ),
        ),
      );
      await tester.pump();

      expect(find.text('Fetching...'), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });
  });

  group('AppFeedbackSnackbar Network Error Tests', () {
    testWidgets('displays WiFi off and RETRY button on network error snackbar', (tester) async {
      bool retryPressed = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (ctx) => ElevatedButton(
                onPressed: () {
                  AppFeedbackSnackbar.showError(
                    ctx,
                    error: const SocketException('No connection'),
                    onRetry: () => retryPressed = true,
                  );
                },
                child: const Text('Show Error'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Show Error'));
      await tester.pumpAndSettle();

      expect(find.text('No Internet Connection'), findsOneWidget);
      expect(find.byIcon(Icons.wifi_off_rounded), findsOneWidget);
      expect(find.text('RETRY'), findsOneWidget);

      await tester.tap(find.text('RETRY'));
      await tester.pumpAndSettle();
      expect(retryPressed, isTrue);
    });
  });

  group('Pregnancy Module Screens Error and Loading Handling Tests', () {
    testWidgets('AppErrorView in Pregnancy context shows TRY AGAIN button and triggers retry callback', (tester) async {
      bool pregnancyRetried = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AppErrorView(
              error: const SocketException('No Internet Connection'),
              onRetry: () => pregnancyRetried = true,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('No Internet Connection'), findsOneWidget);
      expect(find.byIcon(Icons.wifi_off_rounded), findsOneWidget);
      expect(find.text('TRY AGAIN'), findsOneWidget);

      await tester.tap(find.text('TRY AGAIN'));
      await tester.pump();
      expect(pregnancyRetried, isTrue);
    });
  });
}
