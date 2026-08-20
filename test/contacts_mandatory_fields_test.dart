import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:animal_birthday_predictor/features/contacts/presentation/widgets/select_or_add_contact_modal.dart';
import 'package:animal_birthday_predictor/core/widgets/custom_text_field.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('SelectOrAddContactModal requires both Name and Contact Number', (tester) async {
    tester.view.physicalSize = const Size(1080, 1920);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: Scaffold(
            body: SelectOrAddContactModal(title: 'Add Contact'),
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    // Tap "+ ADD NEW CONTACT" button to switch to form
    final addNewButton = find.text('+ ADD NEW CONTACT');
    expect(addNewButton, findsOneWidget);
    await tester.tap(addNewButton);
    await tester.pumpAndSettle();

    // Verify fields exist
    expect(find.text('Full Name *'), findsOneWidget);
    expect(find.text('Contact Number *'), findsOneWidget);

    // Tap SAVE CONTACT with empty fields
    final saveButton = find.text('SAVE CONTACT');
    expect(saveButton, findsOneWidget);
    await tester.ensureVisible(saveButton);
    await tester.tap(saveButton);
    await tester.pumpAndSettle();

    // Verify both validation errors are displayed
    expect(find.text('Contact name is required'), findsOneWidget);
    expect(find.text('Contact number is required'), findsOneWidget);

    // Enter name only and tap save
    final nameField = find.widgetWithText(CustomTextField, 'Full Name *');
    await tester.enterText(find.descendant(of: nameField, matching: find.byType(TextField)), 'Dr. John Smith');
    await tester.pumpAndSettle();

    await tester.ensureVisible(saveButton);
    await tester.tap(saveButton);
    await tester.pumpAndSettle();

    // Name error should be gone, contact number error should remain
    expect(find.text('Contact name is required'), findsNothing);
    expect(find.text('Contact number is required'), findsOneWidget);

    // Enter valid phone number and verify both errors are cleared
    final phoneField = find.widgetWithText(CustomTextField, 'Contact Number *');
    await tester.enterText(find.descendant(of: phoneField, matching: find.byType(TextField)), '+1 555 123 4567');
    await tester.pumpAndSettle();

    await tester.ensureVisible(saveButton);
    await tester.tap(saveButton);
    await tester.pumpAndSettle();

    expect(find.text('Contact name is required'), findsNothing);
    expect(find.text('Contact number is required'), findsNothing);
  });
}
