import 'package:flutter_test/flutter_test.dart';
import 'package:animal_birthday_predictor/features/pregnancy/data/pregnancy_repository.dart';
import 'package:animal_birthday_predictor/features/pregnancy/data/preventative_care_repository.dart';
import 'package:animal_birthday_predictor/features/animals/data/mare_repository.dart';
import 'package:animal_birthday_predictor/features/pregnancy/domain/advanced_pregnancy_info.dart';
import 'package:animal_birthday_predictor/features/pregnancy/domain/preventative_care_record.dart';
import 'package:animal_birthday_predictor/features/animals/domain/markings.dart';
import 'package:animal_birthday_predictor/core/utils/app_uuid.dart';

void main() {
  group('Unique Constraint Upsert and Conflict Deduplication Tests', () {
    test('saveAdvancedPregnancyInfo reuses existing ID and updates without duplication', () async {
      final repo = PregnancyRepository();
      final recordId = AppUuid.generate();

      // First save with generated ID
      final initialInfo = AdvancedPregnancyInfo(
        id: '',
        pregnancyRecordId: recordId,
        caslickDone: false,
        fetalSexScanDone: false,
        ffsResult: 'filly',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      final saved1 = await repo.saveAdvancedPregnancyInfo(initialInfo);
      expect(AppUuid.isValid(saved1.id), isTrue);
      expect(saved1.ffsResult, 'filly');

      // Second save with non-UUID or different ID for the same pregnancyRecordId
      final updatedInfo = AdvancedPregnancyInfo(
        id: 'timestamp-12345',
        pregnancyRecordId: recordId,
        caslickDone: true,
        fetalSexScanDone: true,
        ffsResult: 'colt',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      final saved2 = await repo.saveAdvancedPregnancyInfo(updatedInfo);

      // Should preserve the original valid UUID
      expect(saved2.id, saved1.id);
      expect(saved2.caslickDone, isTrue);
      expect(saved2.ffsResult, 'colt');

      // Querying by pregnancyRecordId should return the updated single record
      final fetched = await repo.getAdvancedPregnancyInfo(recordId);
      expect(fetched, isNotNull);
      expect(fetched!.id, saved1.id);
      expect(fetched.ffsResult, 'colt');
    });

    test('savePreventativeCare reuses existing ID and updates without duplication', () async {
      final repo = PreventativeCareRepository();
      final animalId = AppUuid.generate();

      // First save
      final initialCare = PreventativeCareRecord(
        id: '',
        ownerType: 'animal',
        ownerId: animalId,
        wormerDone: false,
        tetanusDone: false,
        dentistNumber: '12345',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      final saved1 = await repo.savePreventativeCare(initialCare);
      expect(AppUuid.isValid(saved1.id), isTrue);

      // Second save with empty or non-UUID id
      final updatedCare = PreventativeCareRecord(
        id: 'timestamp-999',
        ownerType: 'animal',
        ownerId: animalId,
        wormerDone: true,
        tetanusDone: true,
        dentistNumber: '99999',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      final saved2 = await repo.savePreventativeCare(updatedCare);

      expect(saved2.id, saved1.id);
      expect(saved2.wormerDone, isTrue);
      expect(saved2.dentistNumber, '99999');

      final fetched = await repo.getPreventativeCare('animal', animalId);
      expect(fetched, isNotNull);
      expect(fetched!.id, saved1.id);
      expect(fetched.wormerDone, isTrue);
    });

    test('saveMarkings reuses existing ID and updates without duplication', () async {
      final repo = MareRepository();
      final animalId = AppUuid.generate();

      // First save
      final initialMarkings = Markings(
        id: '',
        ownerType: 'animal',
        ownerId: animalId,
        headViewNotes: 'White star on forehead',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      final saved1 = await repo.saveMarkings(initialMarkings);
      expect(AppUuid.isValid(saved1.id), isTrue);

      // Second save with new notes and invalid/empty ID
      final updatedMarkings = Markings(
        id: '',
        ownerType: 'animal',
        ownerId: animalId,
        headViewNotes: 'White star and snip',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      final saved2 = await repo.saveMarkings(updatedMarkings);

      expect(saved2.id, saved1.id);
      expect(saved2.headViewNotes, 'White star and snip');

      final fetched = await repo.getMarkings('animal', animalId);
      expect(fetched, isNotNull);
      expect(fetched!.id, saved1.id);
      expect(fetched.headViewNotes, 'White star and snip');
    });
  });
}
