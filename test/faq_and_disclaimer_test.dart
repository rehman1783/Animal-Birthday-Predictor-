import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:animal_birthday_predictor/features/faq/domain/faq_item.dart';
import 'package:animal_birthday_predictor/features/faq/data/faq_data.dart';
import 'package:animal_birthday_predictor/features/faq/presentation/screens/faq_screen.dart';
import 'package:animal_birthday_predictor/core/constants/app_disclaimer_content.dart';
import 'package:animal_birthday_predictor/features/disclaimer/presentation/screens/disclaimer_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('FAQ Data & Screen Tests', () {
    test('FaqData contains structured FAQs across multiple categories', () {
      expect(FaqData.defaultFaqs, isNotEmpty);
      final categories = FaqData.defaultFaqs.map((f) => f.category).toSet();
      expect(categories.contains(FaqCategory.equine), isTrue);
      expect(categories.contains(FaqCategory.canine), isTrue);
      expect(categories.contains(FaqCategory.scans), isTrue);
      expect(categories.contains(FaqCategory.certificates), isTrue);
    });

    testWidgets('FaqScreen renders title, search input, chips and accordion cards', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: FaqScreen(),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Frequently Asked Questions'), findsOneWidget);
      expect(find.byType(TextField), findsOneWidget);
      expect(find.byType(ChoiceChip), findsWidgets);
      expect(find.text('All Questions'), findsWidgets);
      expect(find.text('Equine & Foaling'), findsWidgets);
      expect(find.text('Canine & Puppies'), findsWidgets);

      // Verify accordion expansion works
      final firstQuestion = find.text(FaqData.defaultFaqs.first.question);
      expect(firstQuestion, findsOneWidget);

      await tester.tap(firstQuestion);
      await tester.pumpAndSettle();

      expect(find.text(FaqData.defaultFaqs.first.answer), findsOneWidget);
    });

    testWidgets('FaqScreen search filters articles correctly', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: FaqScreen(),
        ),
      );
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), '45-Day Scan');
      await tester.pumpAndSettle();

      expect(find.text('How do I generate a 45-Day Scan Certificate?'), findsOneWidget);
      expect(find.text('How long is the canine gestation period and when is whelping expected?'), findsNothing);
    });
  });

  group('Disclaimer Content & Screen Tests', () {
    test('AppDisclaimerContent contains legal sections and certificate notice', () {
      expect(AppDisclaimerContent.sections.length, 6);
      expect(AppDisclaimerContent.shortSummary, isNotEmpty);
      expect(AppDisclaimerContent.certificateDisclaimer, isNotEmpty);
    });

    testWidgets('DisclaimerScreen renders advisory notice and all sections', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: DisclaimerScreen(),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Disclaimer & Legal Notice'), findsOneWidget);
      expect(find.text('Important Notice for Breeders'), findsOneWidget);
      expect(find.textContaining('1. Informational & Decision-Support Purpose'), findsOneWidget);
      expect(find.textContaining('2. Licensed Veterinary Consultation Required'), findsOneWidget);
      expect(find.textContaining('3. Biological Gestation Variability'), findsOneWidget);
      expect(find.textContaining('4. Ultrasound Scans & Twin Warning Notice'), findsOneWidget);
      expect(find.textContaining('5. Limitation of Liability'), findsOneWidget);
      expect(find.textContaining('6. Breeder Responsibility & Due Diligence'), findsOneWidget);
      expect(find.text('Back to Settings'), findsOneWidget);
    });
  });
}
