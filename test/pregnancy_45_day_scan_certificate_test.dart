import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:animal_birthday_predictor/features/animals/domain/animal.dart';
import 'package:animal_birthday_predictor/features/certificates/data/pdf_certificate_service.dart';
import 'package:animal_birthday_predictor/features/certificates/presentation/screens/certificate_screen.dart';
import 'package:animal_birthday_predictor/features/pregnancy/domain/breeding_record.dart';
import 'package:animal_birthday_predictor/features/pregnancy/domain/pregnancy_record.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final mockAiMare = Animal(
    id: 'mare_ai_101',
    accountId: 'acc_test_01',
    species: 'horse',
    name: 'Bella Star',
    breed: 'Thoroughbred',
    colour: 'Bay',
    microchipNo: '985141001234567',
    sex: 'mare',
    createdAt: DateTime(2025, 1, 1),
    updatedAt: DateTime(2025, 1, 1),
  );

  final mockRecipientMare = Animal(
    id: 'recip_mare_202',
    accountId: 'acc_test_01',
    species: 'horse',
    name: 'Recip #42 (Clover)',
    breed: 'Standardbred / Cross',
    colour: 'Chestnut',
    microchipNo: '985141009998887',
    sex: 'mare',
    createdAt: DateTime(2025, 1, 1),
    updatedAt: DateTime(2025, 1, 1),
  );

  final mockDonorMare = Animal(
    id: 'donor_mare_303',
    accountId: 'acc_test_01',
    species: 'horse',
    name: 'Royal Duchess (Elite Donor)',
    breed: 'Warmblood (KWPN)',
    colour: 'Black',
    microchipNo: '985141007776655',
    sex: 'mare',
    createdAt: DateTime(2025, 1, 1),
    updatedAt: DateTime(2025, 1, 1),
  );

  final mockPregnancyRecord = PregnancyRecord(
    id: 'preg_rec_45d_01',
    accountId: 'acc_test_01',
    breedingRecordId: 'breed_rec_01',
    carrierAnimalId: 'mare_ai_101',
    scan1DueDate: DateTime(2026, 3, 1),
    scan1Confirmed: true,
    scan2DueDate: DateTime(2026, 3, 17),
    scan2Confirmed: true,
    scan3DueDate: DateTime(2026, 4, 1),
    scan3Confirmed: true,
    foalingDueDate: DateTime(2027, 1, 23),
    vetName: 'Dr. Sarah Jenkins MRCVS',
    vetNumber: '+44 7700 900077',
    createdAt: DateTime(2026, 2, 15),
    updatedAt: DateTime(2026, 4, 1),
  );

  group('45-Day Equine Pregnancy Scan Certificate Tests', () {
    test('generate45DayScanCertificate creates valid PDF bytes for AI Mare (Direct Gestation)', () async {
      final breedingAi = BreedingRecord(
        id: 'breed_rec_01',
        accountId: 'acc_test_01',
        mareAnimalId: mockAiMare.id,
        stallionName: 'Galileo Gold',
        method: 'chilled',
        coverOrTransferDate: DateTime(2026, 2, 15),
        isEmbryoTransfer: false,
        createdAt: DateTime(2026, 2, 15),
        updatedAt: DateTime(2026, 2, 15),
      );

      final pdfBytes = await PdfCertificateService.generate45DayScanCertificate(
        pregnancy: mockPregnancyRecord,
        carrierMare: mockAiMare,
        donorMare: null,
        breedingRecord: breedingAi,
        vetName: 'Dr. Sarah Jenkins MRCVS',
        vetNumber: '+44 7700 900077',
        breederName: 'Newmarket Equine Stud',
        breederEmail: 'studmaster@newmarket.co.uk',
      );

      expect(pdfBytes, isNotEmpty);
      expect(pdfBytes.length, greaterThan(1000));
    });

    test('generate45DayScanCertificate creates valid PDF bytes for Recipient Mare (Embryo Transfer)', () async {
      final breedingEt = BreedingRecord(
        id: 'breed_rec_et_02',
        accountId: 'acc_test_01',
        mareAnimalId: mockDonorMare.id,
        recipientAnimalId: mockRecipientMare.id,
        stallionName: 'Chacco-Blue',
        method: 'et',
        coverOrTransferDate: DateTime(2026, 2, 22),
        isEmbryoTransfer: true,
        damOfEmbryo: 'Royal Duchess (Elite Donor)',
        stallionOfEmbryo: 'Chacco-Blue',
        createdAt: DateTime(2026, 2, 22),
        updatedAt: DateTime(2026, 2, 22),
      );

      final recipPregnancy = mockPregnancyRecord.copyWith(
        carrierAnimalId: mockRecipientMare.id,
        breedingRecordId: breedingEt.id,
      );

      final pdfBytes = await PdfCertificateService.generate45DayScanCertificate(
        pregnancy: recipPregnancy,
        carrierMare: mockRecipientMare,
        donorMare: mockDonorMare,
        breedingRecord: breedingEt,
        vetName: 'Dr. Alistair Ross MRCVS',
        vetNumber: '+44 7700 900999',
        breederName: 'Sport Horse International',
        breederEmail: 'breeding@sporthorse.com',
      );

      expect(pdfBytes, isNotEmpty);
      expect(pdfBytes.length, greaterThan(1000));
    });

    testWidgets('CertificateScreen displays 45-Day Equine Pregnancy Scan Certificate preview correctly', (tester) async {
      final breedingAi = BreedingRecord(
        id: 'breed_rec_01',
        accountId: 'acc_test_01',
        mareAnimalId: mockAiMare.id,
        stallionName: 'Galileo Gold',
        method: 'chilled',
        coverOrTransferDate: DateTime(2026, 2, 15),
        isEmbryoTransfer: false,
        createdAt: DateTime(2026, 2, 15),
        updatedAt: DateTime(2026, 2, 15),
      );

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: CertificateScreen(
              pregnancy: mockPregnancyRecord,
              carrierMare: mockAiMare,
              breedingRecord: breedingAi,
              is45DayScan: true,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('45-DAY SCAN CERTIFICATE'), findsWidgets);
      expect(find.text('45-DAY POSITIVE SCAN CONFIRMED'), findsOneWidget);
      expect(find.text('DIRECT / AI MARE GESTATION'), findsOneWidget);
      expect(find.text('Bella Star'), findsOneWidget);
      expect(find.text('Galileo Gold'), findsOneWidget);
      expect(find.text('EXPORT / PRINT PDF CERTIFICATE'), findsOneWidget);
    });

    testWidgets('CertificateScreen displays Recipient Mare ET indicators properly', (tester) async {
      final breedingEt = BreedingRecord(
        id: 'breed_rec_et_02',
        accountId: 'acc_test_01',
        mareAnimalId: mockDonorMare.id,
        recipientAnimalId: mockRecipientMare.id,
        stallionName: 'Chacco-Blue',
        method: 'et',
        coverOrTransferDate: DateTime(2026, 2, 22),
        isEmbryoTransfer: true,
        damOfEmbryo: 'Royal Duchess (Elite Donor)',
        stallionOfEmbryo: 'Chacco-Blue',
        createdAt: DateTime(2026, 2, 22),
        updatedAt: DateTime(2026, 2, 22),
      );

      final recipPregnancy = mockPregnancyRecord.copyWith(
        carrierAnimalId: mockRecipientMare.id,
        breedingRecordId: breedingEt.id,
      );

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: CertificateScreen(
              pregnancy: recipPregnancy,
              carrierMare: mockRecipientMare,
              donorMare: mockDonorMare,
              breedingRecord: breedingEt,
              is45DayScan: true,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('45-DAY SCAN CERTIFICATE'), findsWidgets);
      expect(find.text('RECIPIENT MARE GESTATION'), findsOneWidget);
      expect(find.text('Recip #42 (Clover)'), findsOneWidget);
      expect(find.text('Royal Duchess (Elite Donor)'), findsOneWidget);
      expect(find.text('Chacco-Blue'), findsOneWidget);
    });
  });
}