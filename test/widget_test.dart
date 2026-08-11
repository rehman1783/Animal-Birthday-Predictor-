import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:animal_birthday_predictor/main.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    // Build our app wrapped in ProviderScope
    await tester.pumpWidget(
      const ProviderScope(
        child: AnimalBirthdayPredictorApp(initialRoute: '/onboarding'),
      ),
    );

    // Verify that onboarding screen loads with "WHY ABP?" section label
    expect(find.textContaining('WHY ABP?'), findsOneWidget);
  });
}
