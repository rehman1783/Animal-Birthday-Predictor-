import 'package:flutter_test/flutter_test.dart';
import 'package:animal_birthday_predictor/features/puppy/data/puppy_repository.dart';
import 'package:animal_birthday_predictor/features/puppy/domain/dog_preventative_care.dart';
import 'package:animal_birthday_predictor/features/puppy/domain/puppy.dart';
import 'package:animal_birthday_predictor/core/utils/app_uuid.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Supabase UUID & Dog Preventative Care Safety Tests', () {
    late PuppyRepository repo;

    setUp(() {
      repo = PuppyRepository();
    });

    test('getDogPreventativeCare handles empty string ownerId safely without throwing UUID syntax errors', () async {
      final results = await repo.getDogPreventativeCare('general_canine', '');
      expect(results, isA<List<DogPreventativeCareItem>>());
    });

    test('initializeDefaultDogSchedule creates full 11-step schedule with valid UUIDs', () async {
      final schedule = await repo.initializeDefaultDogSchedule(
        ownerType: 'general_canine',
        ownerId: '',
        dateOfBirth: DateTime(2025, 1, 1),
      );

      expect(schedule.length, 11);
      for (final item in schedule) {
        expect(AppUuid.isValid(item.id), isTrue);
        expect(item.ownerId, isNotEmpty);
      }
    });

    test('saveDogPreventativeCareItem sanitizes non-UUID ownerId and generates valid IDs', () async {
      final item = DogPreventativeCareItem(
        id: '',
        accountId: '',
        ownerType: 'puppy',
        ownerId: '',
        treatmentType: 'worming',
        title: '2-Week Worming',
        dateGiven: null,
        dateDue: DateTime.now(),
        isCompleted: false,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final saved = await repo.saveDogPreventativeCareItem(item);
      expect(AppUuid.isValid(saved.id), isTrue);
      expect(saved.ownerId, isNotEmpty);
      expect(AppUuid.isValid(saved.ownerId), isTrue);
    });

    test('saveDogPreventativeCareItem normalizes invalid owner_type to animal to satisfy postgres check constraint', () async {
      final item = DogPreventativeCareItem(
        id: '',
        accountId: '',
        ownerType: 'general_canine', // Non-standard owner type
        ownerId: '',
        treatmentType: 'worming',
        title: '2-Week Worming',
        dateGiven: null,
        dateDue: DateTime.now(),
        isCompleted: false,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final saved = await repo.saveDogPreventativeCareItem(item);
      expect(saved.ownerType, equals('animal'));
      expect(AppUuid.isValid(saved.id), isTrue);
      expect(AppUuid.isValid(saved.ownerId), isTrue);
    });

    test('Puppy CRUD handles invalid UUID lookups gracefully without crashing', () async {
      final notFound = await repo.getPuppyById('');
      expect(notFound, isNull);

      final invalidIdNotFound = await repo.getPuppyById('invalid-not-uuid');
      expect(invalidIdNotFound, isNull);

      final listWithEmptyDam = await repo.getPuppies(damId: '');
      expect(listWithEmptyDam, isA<List<Puppy>>());
    });
  });
}
