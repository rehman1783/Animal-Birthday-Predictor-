import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:animal_birthday_predictor/core/utils/app_phone_launcher.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  String? mockedClipboardText;

  setUp(() {
    mockedClipboardText = null;
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(SystemChannels.platform, (MethodCall methodCall) async {
      if (methodCall.method == 'Clipboard.setData') {
        mockedClipboardText = methodCall.arguments['text'] as String?;
        return null;
      }
      if (methodCall.method == 'Clipboard.getData') {
        return <String, dynamic>{'text': mockedClipboardText};
      }
      return null;
    });
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(SystemChannels.platform, null);
  });

  group('AppPhoneLauncher Tests', () {
    testWidgets('makePhoneCall shows error on empty number', (tester) async {
      late BuildContext buildContext;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) {
                buildContext = context;
                return const SizedBox();
              },
            ),
          ),
        ),
      );

      await AppPhoneLauncher.makePhoneCall(buildContext, '');
      await tester.pump();

      expect(find.text('Number Required', skipOffstage: false), findsOneWidget);
      ScaffoldMessenger.of(buildContext).clearSnackBars();
      await tester.pump(const Duration(seconds: 4));
    });

    testWidgets('makePhoneCall handles valid number and copies to clipboard in test environment', (tester) async {
      late BuildContext buildContext;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) {
                buildContext = context;
                return const SizedBox();
              },
            ),
          ),
        ),
      );

      await AppPhoneLauncher.makePhoneCall(buildContext, '+1 555 123 4567');
      await tester.pump();

      expect(mockedClipboardText, '+1 555 123 4567');
      expect(find.text('Phone Number Copied', skipOffstage: false), findsOneWidget);
      ScaffoldMessenger.of(buildContext).clearSnackBars();
      await tester.pump(const Duration(seconds: 4));
    });

    testWidgets('sendEmail handles valid email and copies to clipboard in test environment', (tester) async {
      late BuildContext buildContext;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) {
                buildContext = context;
                return const SizedBox();
              },
            ),
          ),
        ),
      );

      await AppPhoneLauncher.sendEmail(buildContext, 'dr.vet@example.com');
      await tester.pump();

      expect(mockedClipboardText, 'dr.vet@example.com');
      expect(find.text('Email Copied', skipOffstage: false), findsOneWidget);
      ScaffoldMessenger.of(buildContext).clearSnackBars();
      await tester.pump(const Duration(seconds: 4));
    });
  });
}
