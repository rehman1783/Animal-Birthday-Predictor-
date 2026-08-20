import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:animal_birthday_predictor/features/animals/domain/animal.dart';
import 'package:animal_birthday_predictor/features/animals/domain/mare.dart';
import 'package:animal_birthday_predictor/features/animals/domain/markings.dart';
import 'package:animal_birthday_predictor/features/animals/data/animal_repository.dart';
import 'package:animal_birthday_predictor/features/animals/data/mare_repository.dart';
import 'package:animal_birthday_predictor/features/pregnancy/domain/breeding_record.dart';
import 'package:animal_birthday_predictor/features/pregnancy/domain/pregnancy_record.dart';
import 'package:animal_birthday_predictor/features/pregnancy/domain/advanced_pregnancy_info.dart';
import 'package:animal_birthday_predictor/features/pregnancy/data/pregnancy_repository.dart';
import 'package:animal_birthday_predictor/features/foal/domain/foal_record.dart';
import 'package:animal_birthday_predictor/features/foal/data/foal_repository.dart';
import 'package:animal_birthday_predictor/features/puppy/domain/puppy.dart';
import 'package:animal_birthday_predictor/features/puppy/data/puppy_repository.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('Complete Image Database Persistence & Fetch Tests', () {
    const sampleBase64 = 'data:image/jpeg;base64,/9j/4AAQSkZJRgABAQEASABIAAD/2wBDAP//////////////////////////////////////////////////////////////////////////////////////wgALCAABAAEBAREA/8QAFBABAAAAAAAAAAAAAAAAAAAAAP/aAAgBAQABPxA=';
    const sampleRemoteUrl = 'https://supabase.co/storage/v1/object/public/abp-images/test-scan.jpg';

    test('1. Animal / Mare Avatar Photo: save & fetch roundtrip', () async {
      final repo = AnimalRepository();
      final animal = Animal(
        id: 'animal-img-001',
        accountId: 'acc-img-001',
        species: 'horse',
        name: 'Starlight Dream',
        photoUrl: sampleBase64,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // JSON mapping verification
      final json = animal.toJson();
      expect(json['photo_url'], sampleBase64);
      final fromJson = Animal.fromJson(json);
      expect(fromJson.photoUrl, sampleBase64);

      // Repository save and get
      final saved = await repo.saveAnimal(animal);
      expect(saved.photoUrl, sampleBase64);

      final fetched = await repo.getAnimalById(saved.id);
      expect(fetched, isNotNull);
      expect(fetched!.photoUrl, sampleBase64);
    });

    test('2. Physical Markings (Left, Right, Head View): save & fetch roundtrip', () async {
      final repo = MareRepository();
      final markings = Markings(
        id: 'markings-img-001',
        ownerType: 'animal',
        ownerId: 'animal-img-001',
        leftSideImageUrl: 'data:image/jpeg;base64,LEFT_SIDE_PHOTO',
        rightSideImageUrl: 'data:image/jpeg;base64,RIGHT_SIDE_PHOTO',
        headViewImageUrl: 'data:image/jpeg;base64,HEAD_VIEW_PHOTO',
        headViewNotes: 'White blaze and star',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // JSON mapping verification
      final json = markings.toJson();
      expect(json['left_side_image_url'], 'data:image/jpeg;base64,LEFT_SIDE_PHOTO');
      expect(json['right_side_image_url'], 'data:image/jpeg;base64,RIGHT_SIDE_PHOTO');
      expect(json['head_view_image_url'], 'data:image/jpeg;base64,HEAD_VIEW_PHOTO');

      final fromJson = Markings.fromJson(json);
      expect(fromJson.leftSideImageUrl, 'data:image/jpeg;base64,LEFT_SIDE_PHOTO');
      expect(fromJson.rightSideImageUrl, 'data:image/jpeg;base64,RIGHT_SIDE_PHOTO');
      expect(fromJson.headViewImageUrl, 'data:image/jpeg;base64,HEAD_VIEW_PHOTO');

      // Repository save and get
      final saved = await repo.saveMarkings(markings);
      expect(saved.leftSideImageUrl, 'data:image/jpeg;base64,LEFT_SIDE_PHOTO');
      expect(saved.rightSideImageUrl, 'data:image/jpeg;base64,RIGHT_SIDE_PHOTO');
      expect(saved.headViewImageUrl, 'data:image/jpeg;base64,HEAD_VIEW_PHOTO');

      final fetched = await repo.getMarkings('animal', 'animal-img-001');
      expect(fetched, isNotNull);
      expect(fetched!.leftSideImageUrl, 'data:image/jpeg;base64,LEFT_SIDE_PHOTO');
      expect(fetched.rightSideImageUrl, 'data:image/jpeg;base64,RIGHT_SIDE_PHOTO');
      expect(fetched.headViewImageUrl, 'data:image/jpeg;base64,HEAD_VIEW_PHOTO');
    });

    test('3. Breeding Event / Insemination Straws Photo: save & fetch roundtrip', () async {
      final repo = PregnancyRepository();
      final breeding = BreedingRecord(
        id: 'breeding-img-001',
        accountId: 'acc-img-001',
        mareAnimalId: 'animal-img-001',
        stallionName: 'Galileo Champion',
        method: 'frozen',
        photoUrl: 'data:image/jpeg;base64,STRAWS_PHOTO_DATA',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // JSON mapping verification
      final json = breeding.toJson();
      expect(json['photo_url'], 'data:image/jpeg;base64,STRAWS_PHOTO_DATA');

      final fromJson = BreedingRecord.fromJson(json);
      expect(fromJson.photoUrl, 'data:image/jpeg;base64,STRAWS_PHOTO_DATA');

      // Repository save and get
      final saved = await repo.saveBreedingRecord(breeding);
      expect(saved.photoUrl, 'data:image/jpeg;base64,STRAWS_PHOTO_DATA');

      final fetched = await repo.getBreedingRecordById(saved.id);
      expect(fetched, isNotNull);
      expect(fetched!.photoUrl, 'data:image/jpeg;base64,STRAWS_PHOTO_DATA');
    });

    test('4. Three Ultrasound Pregnancy Scans (Scan 1, Scan 2, Scan 3): save & fetch roundtrip', () async {
      final repo = PregnancyRepository();
      final preg = PregnancyRecord(
        id: 'preg-img-001',
        accountId: 'acc-img-001',
        breedingRecordId: 'breeding-img-001',
        carrierAnimalId: 'animal-img-001',
        scan1Confirmed: true,
        scan1ImageUrl: 'data:image/jpeg;base64,SCAN_1_ULTRASOUND',
        scan2Confirmed: true,
        scan2ImageUrl: 'data:image/jpeg;base64,SCAN_2_ULTRASOUND',
        scan3Confirmed: true,
        scan3ImageUrl: sampleRemoteUrl,
        foalingDueDate: DateTime(2027, 2, 1),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // JSON mapping verification
      final json = preg.toJson();
      expect(json['scan_1_image_url'], 'data:image/jpeg;base64,SCAN_1_ULTRASOUND');
      expect(json['scan_2_image_url'], 'data:image/jpeg;base64,SCAN_2_ULTRASOUND');
      expect(json['scan_3_image_url'], sampleRemoteUrl);

      final fromJson = PregnancyRecord.fromJson(json);
      expect(fromJson.scan1ImageUrl, 'data:image/jpeg;base64,SCAN_1_ULTRASOUND');
      expect(fromJson.scan2ImageUrl, 'data:image/jpeg;base64,SCAN_2_ULTRASOUND');
      expect(fromJson.scan3ImageUrl, sampleRemoteUrl);

      // Repository save and get
      final saved = await repo.savePregnancyRecord(preg);
      expect(saved.scan1ImageUrl, 'data:image/jpeg;base64,SCAN_1_ULTRASOUND');
      expect(saved.scan2ImageUrl, 'data:image/jpeg;base64,SCAN_2_ULTRASOUND');
      expect(saved.scan3ImageUrl, sampleRemoteUrl);

      final fetched = await repo.getPregnancyRecordById(saved.id);
      expect(fetched, isNotNull);
      expect(fetched!.scan1ImageUrl, 'data:image/jpeg;base64,SCAN_1_ULTRASOUND');
      expect(fetched.scan2ImageUrl, 'data:image/jpeg;base64,SCAN_2_ULTRASOUND');
      expect(fetched.scan3ImageUrl, sampleRemoteUrl);
    });

    test('5. Advanced Pregnancy / Fetal Sex Ultrasound Photo: save & fetch roundtrip', () async {
      final repo = PregnancyRepository();
      final advInfo = AdvancedPregnancyInfo(
        id: 'adv-img-001',
        pregnancyRecordId: 'preg-img-001',
        fetalSexScanDone: true,
        fetalSexScanDate: DateTime(2026, 5, 20),
        ffsResult: 'filly',
        ffsResultDate: DateTime(2026, 5, 20),
        ultrasoundImageUrl: 'data:image/jpeg;base64,FETAL_SEX_ULTRASOUND_IMAGE_DATA',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // JSON mapping verification
      final json = advInfo.toJson();
      expect(json['pregnancy_record_id'], 'preg-img-001');
      expect(json['ffs_result'], 'filly');
      expect(json['ultrasound_image_url'], 'data:image/jpeg;base64,FETAL_SEX_ULTRASOUND_IMAGE_DATA');

      final fromJson = AdvancedPregnancyInfo.fromJson(json);
      expect(fromJson.pregnancyRecordId, 'preg-img-001');
      expect(fromJson.ffsResult, 'filly');
      expect(fromJson.ultrasoundImageUrl, 'data:image/jpeg;base64,FETAL_SEX_ULTRASOUND_IMAGE_DATA');

      // Repository save and get
      final saved = await repo.saveAdvancedPregnancyInfo(advInfo);
      expect(saved.ultrasoundImageUrl, 'data:image/jpeg;base64,FETAL_SEX_ULTRASOUND_IMAGE_DATA');

      final fetched = await repo.getAdvancedPregnancyInfo('preg-img-001');
      expect(fetched, isNotNull);
      expect(fetched!.ultrasoundImageUrl, 'data:image/jpeg;base64,FETAL_SEX_ULTRASOUND_IMAGE_DATA');
      expect(fetched.ffsResult, 'filly');
    });

    test('6. Foal Photo: save & fetch roundtrip', () async {
      final repo = FoalRepository();
      final foal = FoalRecord(
        id: 'foal-img-001',
        accountId: 'acc-img-001',
        mareAnimalId: 'animal-img-001',
        foalName: 'Eclipse Star',
        sex: 'filly',
        photoUrl: 'data:image/jpeg;base64,FOAL_NEWBORN_PHOTO',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // JSON mapping verification
      final json = foal.toJson();
      expect(json['photo_url'], 'data:image/jpeg;base64,FOAL_NEWBORN_PHOTO');

      final fromJson = FoalRecord.fromJson(json);
      expect(fromJson.photoUrl, 'data:image/jpeg;base64,FOAL_NEWBORN_PHOTO');

      // Repository save and get
      final saved = await repo.saveFoal(foal);
      expect(saved.photoUrl, 'data:image/jpeg;base64,FOAL_NEWBORN_PHOTO');

      final fetched = await repo.getFoalById(saved.id);
      expect(fetched, isNotNull);
      expect(fetched!.photoUrl, 'data:image/jpeg;base64,FOAL_NEWBORN_PHOTO');
    });

    test('7. Puppy Photo: save & fetch roundtrip', () async {
      final repo = PuppyRepository();
      final puppy = Puppy(
        id: 'puppy-img-001',
        accountId: 'acc-img-001',
        puppyName: 'Apollo',
        collarTagColour: 'Blue',
        photoUrl: 'data:image/jpeg;base64,PUPPY_PHOTO_DATA',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // JSON mapping verification
      final json = puppy.toJson();
      expect(json['photo_url'], 'data:image/jpeg;base64,PUPPY_PHOTO_DATA');

      final fromJson = Puppy.fromJson(json);
      expect(fromJson.photoUrl, 'data:image/jpeg;base64,PUPPY_PHOTO_DATA');

      // Repository save and get
      final saved = await repo.savePuppy(puppy);
      expect(saved.photoUrl, 'data:image/jpeg;base64,PUPPY_PHOTO_DATA');

      final fetched = await repo.getPuppyById(saved.id);
      expect(fetched, isNotNull);
      expect(fetched!.photoUrl, 'data:image/jpeg;base64,PUPPY_PHOTO_DATA');
    });
  });
}
