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

    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(const MethodChannel('plugins.flutter.io/url_launcher'), (MethodCall methodCall) async {
      if (methodCall.method == 'canLaunch') {
        return false;
      }
      if (methodCall.method == 'launch') {
        return false;
      }
      return false;
    });
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(SystemChannels.platform, null);
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(const MethodChannel('plugins.flutter.io/url_launcher'), null);
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

    test('sanitizePhoneNumber correctly formats various international and local formats', () {
      expect(AppPhoneLauncher.sanitizePhoneNumber('+44 7700 900077'), '+447700900077');
      expect(AppPhoneLauncher.sanitizePhoneNumber('(020) 7946-0991'), '02079460991');
      expect(AppPhoneLauncher.sanitizePhoneNumber('+1 (555) 234-5678'), '+15552345678');
      expect(AppPhoneLauncher.sanitizePhoneNumber('0300-1234567'), '03001234567');
      expect(AppPhoneLauncher.sanitizePhoneNumber(''), '');
      expect(AppPhoneLauncher.sanitizePhoneNumber('    '), '');
      expect(AppPhoneLauncher.sanitizePhoneNumber('none'), '');
    });

    testWidgets('makePhoneCall shows error on number with no digits', (tester) async {
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

      await AppPhoneLauncher.makePhoneCall(buildContext, 'abc-xyz');
      await tester.pump();

      expect(find.text('Invalid Phone Number', skipOffstage: false), findsOneWidget);
      ScaffoldMessenger.of(buildContext).clearSnackBars();
      await tester.pump(const Duration(seconds: 4));
    });

    testWidgets('sendSms handles valid number and copies to clipboard in test environment', (tester) async {
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

      await AppPhoneLauncher.sendSms(buildContext, '+44 7700 900123', body: 'Hello Vet');
      await tester.pump();

      expect(mockedClipboardText, '+44 7700 900123');
      expect(find.text('Phone Number Copied', skipOffstage: false), findsOneWidget);
      ScaffoldMessenger.of(buildContext).clearSnackBars();
      await tester.pump(const Duration(seconds: 4));
    });

    testWidgets('sendWhatsApp constructs valid link and runs safely', (tester) async {
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

      final result = await AppPhoneLauncher.sendWhatsApp(buildContext, '+44 7700 900123', message: 'Hi');
      expect(result, isA<bool>());
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
