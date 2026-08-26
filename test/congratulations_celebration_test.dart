import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:animal_birthday_predictor/features/foal/presentation/screens/congratulations_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Exciting & Celebratory Congratulations Screen Tests', () {
    testWidgets('Renders Equine celebration with glowing crest and 1-2-3 Foaling Rule', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: CongratulationsScreen(
            species: 'Equine',
            damMareId: 'mare_123',
            stallionName: 'Galileo Gold',
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      expect(find.text('BREEDING MILESTONE ACHIEVED'), findsOneWidget);
      expect(find.text('CONGRATULATIONS!'), findsOneWidget);
      expect(find.text('A NEW LIFE HAS ARRIVED SAFELY'), findsOneWidget);
      expect(find.text('THE 1-2-3 FOALING RULE (FIRST HOURS)'), findsOneWidget);
      expect(find.text('⏱️ Hour 1'), findsOneWidget);
      expect(find.text('🍼 Hour 2'), findsOneWidget);
      expect(find.text('🩺 Hour 3'), findsOneWidget);
      expect(find.text('📸 REGISTER NEW FOAL & BIRTH RECORD'), findsOneWidget);
      expect(find.text('CELEBRATE AGAIN 🎉'), findsOneWidget);
    });

    testWidgets('Renders Canine whelping celebration with puppy checklist', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: CongratulationsScreen(
            species: 'Canine',
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      expect(find.text('CONGRATULATIONS!'), findsOneWidget);
      expect(find.text('FIRST 24-HOUR CRITICAL WHELPING CHECKLIST'), findsOneWidget);
      expect(find.text('🌡️ Warmth'), findsOneWidget);
      expect(find.text('🍼 Colostrum'), findsOneWidget);
      expect(find.text('⚖️ Birth Weight'), findsOneWidget);
      expect(find.text('📸 REGISTER NEW PUPPY & BIRTH RECORD'), findsOneWidget);
    });

    testWidgets('Tapping CELEBRATE AGAIN triggers fresh confetti burst without crashing', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: CongratulationsScreen(
            species: 'Equine',
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));

      final celebrateBtn = find.text('CELEBRATE AGAIN 🎉');
      expect(celebrateBtn, findsOneWidget);

      await tester.ensureVisible(celebrateBtn);
      await tester.pumpAndSettle();

      await tester.tap(celebrateBtn);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('CONGRATULATIONS!'), findsOneWidget);
    });
  });
}
