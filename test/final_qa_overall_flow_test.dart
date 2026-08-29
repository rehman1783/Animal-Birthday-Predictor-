import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:animal_birthday_predictor/core/router/app_router.dart';
import 'package:animal_birthday_predictor/core/widgets/abp_brand_badge.dart';

import 'package:animal_birthday_predictor/features/animals/domain/animal.dart';
import 'package:animal_birthday_predictor/features/animals/data/animal_repository.dart';
import 'package:animal_birthday_predictor/features/animals/presentation/providers/animal_provider.dart';

import 'package:animal_birthday_predictor/features/pregnancy/domain/breeding_record.dart';
import 'package:animal_birthday_predictor/features/pregnancy/domain/pregnancy_record.dart';
import 'package:animal_birthday_predictor/features/pregnancy/domain/pregnancy_calculation_utils.dart';
import 'package:animal_birthday_predictor/features/pregnancy/data/pregnancy_repository.dart';
import 'package:animal_birthday_predictor/features/pregnancy/presentation/providers/pregnancy_provider.dart';
import 'package:animal_birthday_predictor/features/pregnancy/presentation/screens/equine_breeding_wizard_screen.dart';
import 'package:animal_birthday_predictor/features/pregnancy/presentation/screens/veterinarian_pregnancy_scans_screen.dart';

import 'package:animal_birthday_predictor/features/foaling_diary/data/calendar_diary_sync_service.dart';
import 'package:animal_birthday_predictor/features/foaling_diary/data/foaling_diary_repository.dart';
import 'package:animal_birthday_predictor/features/foaling_diary/domain/foaling_diary_entry.dart';
import 'package:animal_birthday_predictor/features/foaling_diary/presentation/providers/foaling_diary_provider.dart';
import 'package:animal_birthday_predictor/features/foaling_diary/presentation/screens/foaling_diary_screen.dart';
import 'package:animal_birthday_predictor/features/foaling_diary/presentation/screens/due_date_calculator_screen.dart';

import 'package:animal_birthday_predictor/features/foal/presentation/screens/congratulations_screen.dart';
import 'package:animal_birthday_predictor/features/certificates/presentation/screens/certificate_screen.dart';
import 'package:animal_birthday_predictor/features/contacts/domain/contact.dart';
import 'package:animal_birthday_predictor/features/contacts/data/contact_repository.dart';
import 'package:animal_birthday_predictor/features/contacts/presentation/providers/contact_provider.dart';
import 'package:animal_birthday_predictor/features/contacts/presentation/screens/contacts_directory_screen.dart';
import 'package:animal_birthday_predictor/features/profile/presentation/screens/payment_details_screen.dart';

// Fakes for QA Test Suite
class _QAFakeAnimalRepo extends AnimalRepository {
  final List<Animal> animals = [
    Animal(
      id: 'mare_qa_1',
      accountId: 'acc1',
      name: 'Duchess of Cambridge',
      species: 'horse',
      sex: 'mare',
      breed: 'Thoroughbred',
      microchipNo: '98514100293847291',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ),
    Animal(
      id: 'stallion_qa_1',
      accountId: 'acc1',
      name: 'Galileo Champion',
      species: 'horse',
      sex: 'stallion',
      breed: 'Thoroughbred',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ),
  ];

  @override
  Future<List<Animal>> getAnimals({String? species}) async {
    if (species != null) {
      return animals.where((a) => a.species == species).toList();
    }
    return animals;
  }

  @override
  Future<Animal?> getAnimalById(String id) async {
    return animals.firstWhere((a) => a.id == id, orElse: () => animals.first);
  }
}

class _QAFakePregnancyRepo extends PregnancyRepository {
  @override
  Future<BreedingRecord?> getBreedingRecordByMare(String mareId) async {
    return BreedingRecord(
      id: 'breed_rec_qa_1',
      accountId: 'acc1',
      mareAnimalId: mareId,
      stallionName: 'Galileo Champion',
      method: 'natural',
      coverOrTransferDate: DateTime.now().subtract(const Duration(days: 45)),
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  @override
  Future<PregnancyRecord?> getPregnancyRecordForCarrier(String carrierAnimalId) async {
    return PregnancyRecord(
      id: 'preg_rec_qa_1',
      accountId: 'acc1',
      breedingRecordId: 'breed_rec_qa_1',
      carrierAnimalId: carrierAnimalId,
      scan1DueDate: DateTime.now().subtract(const Duration(days: 31)),
      scan1Confirmed: true,
      scan2DueDate: DateTime.now().subtract(const Duration(days: 15)),
      scan2Confirmed: true,
      scan3DueDate: DateTime.now().add(const Duration(days: 5)),
      scan3Confirmed: false,
      foalingDueDate: DateTime.now().add(const Duration(days: 295)),
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }
}

class _QAFakeFoalingDiaryNotifier extends FoalingDiaryNotifier {
  _QAFakeFoalingDiaryNotifier(List<FoalingDiaryEntry> entries)
      : super(FoalingDiaryRepository(client: null)) {
    state = AsyncValue.data(entries);
  }

  @override
  Future<void> loadEntries() async {}
}

class _QAFakeContactRepo extends ContactRepository {
  @override
  Future<List<Contact>> getContacts({String? role}) async {
    return [
      Contact(
        id: 'c1',
        accountId: 'acc1',
        name: 'Dr. Sarah Jenkins DVM',
        role: 'vet',
        phone: '+1 (555) 382-9912',
        email: 'sarah.jenkins@equinerepro.com',
        clinicOrBusiness: 'Lexington Equine Medical Center',
        notes: 'Primary reproduction vet & embryo transfer specialist',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
    ];
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Final QA Complete End-to-End Flow Validation (Requirement 12)', () {
    // -------------------------------------------------------------------------
    // STEP 1: Equine / Mare Gestation Calculation & Breeding Scenarios
    // -------------------------------------------------------------------------
    test('Flow Step 1: Gestation engine computes precise dates for Natural, AI & Embryo Transfer', () {
      final baseDate = DateTime(2026, 3, 15);

      // Natural Cover / Fresh AI
      final naturalResult = calculatePregnancyDates(
        baseDate: baseDate,
        isEmbryoTransfer: false,
        method: 'natural',
      );
      expect(naturalResult.foalingDueDate.difference(baseDate).inDays, 341);
      expect(naturalResult.scan1DueDate.difference(baseDate).inDays, 14);
      expect(naturalResult.scan2DueDate.difference(baseDate).inDays, 30);
      expect(naturalResult.scan3DueDate.difference(baseDate).inDays, 45);

      // Embryo Transfer (ET offset: donor 7-8d embryo transferred into recipient)
      final etResult = calculatePregnancyDates(
        baseDate: baseDate,
        isEmbryoTransfer: true,
        method: 'et',
      );
      expect(etResult.foalingDueDate.difference(baseDate).inDays, 334);
      expect(etResult.scan1DueDate.difference(baseDate).inDays, 7);
      expect(etResult.scan2DueDate.difference(baseDate).inDays, 23);
      expect(etResult.scan3DueDate.difference(baseDate).inDays, 38);
    });

    // -------------------------------------------------------------------------
    // STEP 2: 6-Step Equine Breeding Wizard UI Flow
    // -------------------------------------------------------------------------
    testWidgets('Flow Step 2: Equine Breeding Wizard renders 6-step flow with ABP badges', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            animalRepositoryProvider.overrideWithValue(_QAFakeAnimalRepo()),
            animalsListProvider('horse').overrideWith((ref) => Future.value(_QAFakeAnimalRepo().animals)),
          ],
          child: const MaterialApp(
            home: EquineBreedingWizardScreen(initialMareId: 'mare_qa_1'),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('EQUINE BREEDING WIZARD'), findsOneWidget);
      expect(find.text('STEP 1 OF 6: MARE'), findsOneWidget);
      expect(find.text('SAVE & CONTINUE ➔'), findsOneWidget);
    });

    // -------------------------------------------------------------------------
    // STEP 3: Veterinarian Pregnancy Scans & Ultrasound Milestones
    // -------------------------------------------------------------------------
    testWidgets('Flow Step 3: Veterinarian Scans screen displays ultrasound milestones & vet contact', (tester) async {
      final sampleMare = _QAFakeAnimalRepo().animals.first;

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            animalRepositoryProvider.overrideWithValue(_QAFakeAnimalRepo()),
            animalByIdProvider(sampleMare.id).overrideWith((ref) async => sampleMare),
            pregnancyRepositoryProvider.overrideWithValue(_QAFakePregnancyRepo()),
            pregnancyRecordForCarrierProvider(sampleMare.id).overrideWith((ref) async => _QAFakePregnancyRepo().getPregnancyRecordForCarrier(sampleMare.id)),
            breedingRecordByMareProvider(sampleMare.id).overrideWith((ref) async => _QAFakePregnancyRepo().getBreedingRecordByMare(sampleMare.id)),
          ],
          child: MaterialApp(
            home: VeterinarianPregnancyScansScreen(carrierAnimalId: sampleMare.id),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('VET CONTACT & SCANS OVERVIEW'), findsOneWidget);
      expect(find.text('VETERINARIAN CONTACT DETAILS'), findsOneWidget);
      expect(find.text('ULTRASOUND SCANS OVERVIEW & PROTOCOLS'), findsOneWidget);
    });

    // -------------------------------------------------------------------------
    // STEP 4: Live Synced Foaling Diary & Calendar Timeline
    // -------------------------------------------------------------------------
    testWidgets('Flow Step 4: Foaling Diary renders live synced Broodmare Roster & Calendar Timeline', (tester) async {
      final diaryEntries = <FoalingDiaryEntry>[
        FoalingDiaryEntry(
          id: 'entry_qa_1',
          mareId: 'mare_qa_1',
          mareName: 'Duchess of Cambridge',
          stallionName: 'Galileo Champion',
          isEmbryoTransfer: false,
          breedingMethod: 'natural',
          serviceDate: DateTime.now().subtract(const Duration(days: 100)),
          foalingDueDate: DateTime.now().add(const Duration(days: 240)),
          minDueDate: DateTime.now().add(const Duration(days: 220)),
          maxDueDate: DateTime.now().add(const Duration(days: 265)),
          currentPaddock: 'Foaling Barn 1',
          scan1Confirmed: true,
          scan2Confirmed: true,
          scan3Confirmed: false,
          twinDetected: false,
          isFoaled: false,
        ),
      ];

      final milestones = <CalendarTimelineMilestone>[
        CalendarTimelineMilestone(
          id: 'ms_qa_1',
          title: '45-Day Organogenesis Ultrasound',
          mareName: 'Duchess of Cambridge',
          category: 'scan3',
          date: DateTime.now().add(const Duration(days: 2)),
          isCompleted: false,
          description: 'Critical heartbeat, organ development and gender determination.',
        ),
      ];

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            foalingDiaryProvider.overrideWith((ref) => _QAFakeFoalingDiaryNotifier(diaryEntries)),
            calendarTimelineMilestonesProvider.overrideWith((ref) => Future.value(milestones)),
          ],
          child: const MaterialApp(
            home: FoalingDiaryScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Check Roster View
      expect(find.text('Broodmare Roster'), findsOneWidget);
      expect(find.text('Duchess of Cambridge'), findsOneWidget);
      expect(find.text('Sire: Galileo Champion'), findsOneWidget);

      // Switch to Timeline View
      await tester.tap(find.text('Calendar & Timeline'));
      await tester.pumpAndSettle();

      expect(find.text('Live Synced Gestation Calendar'), findsOneWidget);
      expect(find.text('45-Day Organogenesis Ultrasound'), findsOneWidget);
    });

    // -------------------------------------------------------------------------
    // STEP 5: Due Date Calculator Screen
    // -------------------------------------------------------------------------
    testWidgets('Flow Step 5: Due Date Calculator computes and offers Save to Foaling Diary', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            animalsListProvider('horse').overrideWith((ref) => Future.value(_QAFakeAnimalRepo().animals)),
          ],
          child: const MaterialApp(
            home: DueDateCalculatorScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('When Is My Foal Due?'), findsWidgets);
      expect(find.text('Save Record to Stud Foaling Diary'), findsOneWidget);
    });

    // -------------------------------------------------------------------------
    // STEP 6: Official PDF Certificates & Health Records
    // -------------------------------------------------------------------------
    testWidgets('Flow Step 6: Certificate screen displays official ABP crest & 45-Day scan cert', (tester) async {
      final sampleMare = _QAFakeAnimalRepo().animals.first;
      final samplePregnancy = PregnancyRecord(
        id: 'preg_rec_qa_1',
        accountId: 'acc1',
        breedingRecordId: 'breed_rec_qa_1',
        carrierAnimalId: sampleMare.id,
        scan1DueDate: DateTime.now().subtract(const Duration(days: 31)),
        scan1Confirmed: true,
        scan2DueDate: DateTime.now().subtract(const Duration(days: 15)),
        scan2Confirmed: true,
        scan3DueDate: DateTime.now().add(const Duration(days: 5)),
        scan3Confirmed: true,
        foalingDueDate: DateTime.now().add(const Duration(days: 295)),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            animalRepositoryProvider.overrideWithValue(_QAFakeAnimalRepo()),
            pregnancyRepositoryProvider.overrideWithValue(_QAFakePregnancyRepo()),
            pregnancyRecordForCarrierProvider(sampleMare.id).overrideWith((ref) async => samplePregnancy),
            breedingRecordByMareProvider(sampleMare.id).overrideWith((ref) async => _QAFakePregnancyRepo().getBreedingRecordByMare(sampleMare.id)),
          ],
          child: MaterialApp(
            home: CertificateScreen(
              pregnancy: samplePregnancy,
              carrierMare: sampleMare,
              is45DayScan: true,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(AbpOfficialLogo), findsWidgets);
      expect(find.text('ANIMAL BIRTHDAY PREDICTOR'), findsOneWidget);
      expect(find.text('45-DAY SCAN CERTIFICATE'), findsWidgets);
      expect(find.text('EXPORT / PRINT PDF CERTIFICATE'), findsOneWidget);
    });

    // -------------------------------------------------------------------------
    // STEP 7: Foal Birth Arrival & Congratulations Celebration Screen
    // -------------------------------------------------------------------------
    testWidgets('Flow Step 7: Congratulations screen renders celebration, 1-2-3 rule & newborn log link', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: CongratulationsScreen(
            species: 'Equine',
            damMareId: 'mare_qa_1',
            stallionName: 'Galileo Champion',
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      expect(find.text('CONGRATULATIONS!'), findsOneWidget);
      expect(find.text('BREEDING MILESTONE ACHIEVED'), findsOneWidget);
      expect(find.text('THE 1-2-3 FOALING RULE (FIRST HOURS)'), findsOneWidget);
      expect(find.text('⏱️ Hour 1'), findsOneWidget);
      expect(find.text('🍼 Hour 2'), findsOneWidget);
      expect(find.text('🩺 Hour 3'), findsOneWidget);
      expect(find.text('📸 REGISTER NEW FOAL & BIRTH RECORD'), findsOneWidget);
    });

    // -------------------------------------------------------------------------
    // STEP 8: Contacts Directory, Click-to-Call & Phone Actions
    // -------------------------------------------------------------------------
    testWidgets('Flow Step 8: Contacts Directory displays reproduction vet and phone actions', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            contactRepositoryProvider.overrideWithValue(_QAFakeContactRepo()),
            contactsListProvider(null).overrideWith((ref) async => _QAFakeContactRepo().getContacts()),
            contactsListProvider('all').overrideWith((ref) async => _QAFakeContactRepo().getContacts()),
          ],
          child: const MaterialApp(
            home: ContactsDirectoryScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('CONTACTS DIRECTORY'), findsOneWidget);
      expect(find.text('Dr. Sarah Jenkins DVM'), findsOneWidget);
      expect(find.text('+1 (555) 382-9912'), findsOneWidget);
      expect(find.byIcon(Icons.phone), findsWidgets);
    });

    // -------------------------------------------------------------------------
    // STEP 9: Payment Details & Subscription Management
    // -------------------------------------------------------------------------
    testWidgets('Flow Step 9: Payment details screen renders billing tier, bank wire & 1-tap copy', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: PaymentDetailsScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Payment & Billing Details'), findsOneWidget);
      expect(find.text('ABP Pro — Master Breeder'), findsOneWidget);
      expect(find.text('Direct Bank & Wire Transfer Details'), findsOneWidget);
      expect(find.text('JPMorgan Chase Bank, N.A. (New York)'), findsOneWidget);
      expect(find.text('CHASUS33ABP'), findsOneWidget);
    });

    // -------------------------------------------------------------------------
    // STEP 10: AppRouter Route Completeness & Zero Broken Routes
    // -------------------------------------------------------------------------
    test('Flow Step 10: AppRouter generates all required routes without missing definitions', () {
      final routeNames = [
        '/home',
        '/onboarding',
        '/signin',
        '/signup',
        '/species-select',
        '/saved-animals',
        '/pregnancy-module',
        '/foaling-diary',
        '/due-date-calculator',
        '/settings',
        '/payment-details',
        '/billing',
        '/subscription',
        '/contacts',
        '/faq',
        '/disclaimer',
      ];

      for (final name in routeNames) {
        final route = AppRouter.onGenerateRoute(RouteSettings(name: name));
        expect(route, isNotNull, reason: 'Route $name should be registered in AppRouter');
      }
    });
  });
}
