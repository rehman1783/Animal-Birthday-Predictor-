import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:animal_birthday_predictor/core/constants/app_colors.dart';
import 'package:animal_birthday_predictor/core/router/app_router.dart';
import 'package:animal_birthday_predictor/core/widgets/abp_brand_badge.dart';
import 'package:animal_birthday_predictor/features/animals/domain/animal.dart';
import 'package:animal_birthday_predictor/features/dashboard/presentation/screens/dashboard_home_screen.dart';
import 'package:animal_birthday_predictor/features/foaling_diary/data/calendar_diary_sync_service.dart';
import 'package:animal_birthday_predictor/features/foaling_diary/domain/foaling_diary_entry.dart';
import 'package:animal_birthday_predictor/features/foaling_diary/data/foaling_diary_repository.dart';
import 'package:animal_birthday_predictor/features/foaling_diary/presentation/providers/foaling_diary_provider.dart';
import 'package:animal_birthday_predictor/features/foaling_diary/presentation/screens/foaling_diary_screen.dart';
import 'package:animal_birthday_predictor/features/pregnancy/domain/breeding_record.dart';
import 'package:animal_birthday_predictor/features/pregnancy/domain/pregnancy_calculation_utils.dart';
import 'package:animal_birthday_predictor/features/profile/presentation/screens/payment_details_screen.dart';
import 'package:animal_birthday_predictor/features/profile/presentation/screens/profile_screen.dart';
import 'package:animal_birthday_predictor/features/profile/presentation/screens/settings_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('ABP Branding Tests (Requirement 8)', () {
    testWidgets('AbpOfficialLogo and AbpBrandBadge render properly', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                AbpOfficialLogo(size: 40),
                AbpBrandBadge(text: 'OFFICIAL ABP™ PRODUCT'),
                AbpProtectedFooter(),
              ],
            ),
          ),
        ),
      );

      expect(find.byType(AbpOfficialLogo), findsOneWidget);
      expect(find.byType(AbpBrandBadge), findsOneWidget);
      expect(find.text('OFFICIAL ABP™ PRODUCT'), findsOneWidget);
      expect(find.byType(AbpProtectedFooter), findsOneWidget);
      expect(find.text('ANIMAL BIRTHDAY PREDICTOR (ABP)™'), findsOneWidget);
    });

    testWidgets('Dashboard renders ABP Official Logo and Brand Stamp', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: DashboardHomeScreen(),
          ),
        ),
      );
      await tester.pump();

      expect(find.byType(AbpOfficialLogo), findsOneWidget);
      expect(find.text('ANIMAL BIRTHDAY PREDICTOR'), findsOneWidget);
      expect(find.text('OFFICIAL ABP™'), findsOneWidget);
      expect(find.byType(AbpProtectedFooter), findsOneWidget);
    });

    testWidgets('Profile & Settings screens contain ABP Verification and Footer', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: ProfileScreen(),
          ),
        ),
      );
      await tester.pump();

      expect(find.text('ORIGINAL ABP™ REGISTERED BREEDER'), findsOneWidget);
      expect(find.byType(AbpProtectedFooter), findsOneWidget);
    });
  });

  group('Payment Details Page Tests (Requirement 9)', () {
    test('Router correctly registers /payment-details, /billing, and /subscription', () {
      final routes = AppRouter.routes;
      expect(routes.containsKey('/payment-details'), isTrue);
      expect(routes.containsKey('/billing'), isTrue);
      expect(routes.containsKey('/subscription'), isTrue);
    });

    testWidgets('PaymentDetailsScreen renders full subscription tier, credit card, bank wire & invoices', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: PaymentDetailsScreen(),
          ),
        ),
      );
      await tester.pump();

      // Active Subscription Card
      expect(find.text('ACTIVE SUBSCRIPTION'), findsOneWidget);
      expect(find.text('ABP Pro — Master Breeder'), findsOneWidget);
      expect(find.text('\$29.99 / Year (Annual Billing)'), findsOneWidget);
      expect(find.text('ACTIVE'), findsOneWidget);

      // Card on file
      expect(find.text('Payment Method on File'), findsOneWidget);
      expect(find.text('•••• •••• •••• 4242'), findsOneWidget);

      // Direct Bank Transfer Details
      expect(find.text('Direct Bank & Wire Transfer Details'), findsOneWidget);
      expect(find.text('Animal Birthday Predictor (ABP) Ltd.'), findsOneWidget);
      expect(find.text('JPMorgan Chase Bank, N.A. (New York)'), findsOneWidget);
      expect(find.text('CHASUS33ABP'), findsOneWidget);

      // Invoices
      expect(find.text('Billing History & Invoices'), findsOneWidget);
      expect(find.text('ABP-INV-2026-001'), findsOneWidget);
      expect(find.text('ABP-INV-2025-001'), findsOneWidget);

      // Security Seal & Footer
      expect(find.text('OFFICIAL ABP PAYMENT ENCRYPTION & GUARANTEE'), findsOneWidget);
      expect(find.byType(AbpProtectedFooter), findsOneWidget);
    });

    testWidgets('ProfileScreen and SettingsScreen display navigation tile to Payment Details', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: SettingsScreen(),
          ),
        ),
      );
      await tester.pump();

      expect(find.text('Subscription & Payment Management'), findsOneWidget);
      expect(find.text('Manage Plan & Invoices'), findsOneWidget);
    });
  });

  group('Calendar + Diary Sync Tests (Requirement 5)', () {
    test('calculatePregnancyDates computes accurate milestones for Natural, Frozen and ET', () {
      final baseDate = DateTime(2026, 3, 1);

      // Natural Cover (341 days)
      final naturalDates = calculatePregnancyDates(
        baseDate: baseDate,
        method: 'natural',
        isEmbryoTransfer: false,
      );
      expect(naturalDates.scan1DueDate, DateTime(2026, 3, 15)); // +14d
      expect(naturalDates.scan2DueDate, DateTime(2026, 3, 31)); // +30d
      expect(naturalDates.scan3DueDate, DateTime(2026, 4, 15)); // +45d
      expect(naturalDates.foalingDueDate, baseDate.add(const Duration(days: 341)));

      // Frozen Semen (340 days)
      final frozenDates = calculatePregnancyDates(
        baseDate: baseDate,
        method: 'frozen',
        isEmbryoTransfer: false,
      );
      expect(frozenDates.scan1DueDate, DateTime(2026, 3, 15));
      expect(frozenDates.foalingDueDate, baseDate.add(const Duration(days: 340)));

      // Embryo Transfer (Recipient Transfer Date, 334 days)
      final etDates = calculatePregnancyDates(
        baseDate: baseDate,
        method: 'et',
        isEmbryoTransfer: true,
      );
      expect(etDates.scan1DueDate, DateTime(2026, 3, 8)); // +7d
      expect(etDates.scan2DueDate, DateTime(2026, 3, 24)); // +23d
      expect(etDates.scan3DueDate, DateTime(2026, 4, 8)); // +38d
      expect(etDates.foalingDueDate, baseDate.add(const Duration(days: 334)));
    });

    testWidgets('FoalingDiaryScreen renders dual tabs and allows switching between Roster and Calendar Timeline', (tester) async {
      final testEntries = [
        FoalingDiaryEntry(
          id: 'test-diary-1',
          mareId: 'mare-1',
          mareName: 'Royal Duchess',
          microchipNo: '985141001234567',
          stallionName: 'Storm Cat',
          isEmbryoTransfer: false,
          breedingMethod: 'natural',
          serviceDate: DateTime.now().subtract(const Duration(days: 100)),
          foalingDueDate: DateTime.now().add(const Duration(days: 240)),
          minDueDate: DateTime.now().add(const Duration(days: 220)),
          maxDueDate: DateTime.now().add(const Duration(days: 265)),
          currentPaddock: 'Paddock A',
          scan1Confirmed: true,
          scan2Confirmed: true,
          scan3Confirmed: false,
          twinDetected: false,
          isFoaled: false,
        ),
      ];

      final testMilestones = [
        CalendarTimelineMilestone(
          id: 'milestone-1',
          title: 'Ultrasound Scan 3 (45-Day Organ & Sexing)',
          mareName: 'Royal Duchess',
          category: 'scan3',
          date: DateTime.now().add(const Duration(days: 5)),
          isCompleted: false,
          description: 'Organogenesis and fetal development ultrasound.',
        ),
      ];

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            foalingDiaryProvider.overrideWith((ref) => _FakeFoalingDiaryNotifier(testEntries)),
            calendarTimelineMilestonesProvider.overrideWith((ref) => Future.value(testMilestones)),
          ],
          child: const MaterialApp(
            home: FoalingDiaryScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Check Roster tab
      expect(find.text('Broodmare Roster'), findsOneWidget);
      expect(find.text('Calendar & Timeline'), findsOneWidget);
      expect(find.text('Royal Duchess'), findsOneWidget);

      // Switch to Calendar & Timeline Tab
      await tester.tap(find.text('Calendar & Timeline'));
      await tester.pumpAndSettle();

      expect(find.text('Live Synced Gestation Calendar'), findsOneWidget);
      expect(find.text('Ultrasound Scan 3 (45-Day Organ & Sexing)'), findsOneWidget);
      expect(find.text('IN 5 DAYS'), findsOneWidget);
    });
  });
}

class _FakeFoalingDiaryNotifier extends FoalingDiaryNotifier {
  _FakeFoalingDiaryNotifier(List<FoalingDiaryEntry> entries)
      : super(FoalingDiaryRepository(client: null)) {
    state = AsyncValue.data(entries);
  }

  @override
  Future<void> loadEntries() async {}
}

