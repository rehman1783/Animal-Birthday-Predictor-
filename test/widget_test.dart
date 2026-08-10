import 'package:flutter_test/flutter_test.dart';
import 'package:animal_birthday_predictor/main.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const AnimalBirthdayPredictorApp());

    // Verify that onboarding screen loads with "WHY ABP?" section label
    expect(find.textContaining('WHY ABP?'), findsOneWidget);
  });
}
