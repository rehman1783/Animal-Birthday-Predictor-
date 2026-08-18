import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:animal_birthday_predictor/core/services/permission_service.dart';

void main() {
  testWidgets('PermissionService returns true gracefully in non-mobile test environment', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) {
            return Scaffold(
              body: Column(
                children: [
                  ElevatedButton(
                    onPressed: () async {
                      final cameraGranted = await PermissionService.requestCameraPermission(context);
                      final photosGranted = await PermissionService.requestPhotosPermission(context);
                      expect(cameraGranted, isTrue);
                      expect(photosGranted, isTrue);
                    },
                    child: const Text('Check Permissions'),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );

    await tester.tap(find.text('Check Permissions'));
    await tester.pumpAndSettle();
  });
}
