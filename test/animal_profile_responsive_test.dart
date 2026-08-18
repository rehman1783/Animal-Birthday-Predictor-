import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:animal_birthday_predictor/features/animals/domain/animal.dart';
import 'package:animal_birthday_predictor/features/animals/data/animal_repository.dart';
import 'package:animal_birthday_predictor/features/animals/presentation/providers/animal_provider.dart';
import 'package:animal_birthday_predictor/features/animals/presentation/screens/animal_profile_screen.dart';

import 'package:animal_birthday_predictor/features/animals/domain/markings.dart';
import 'package:animal_birthday_predictor/features/animals/data/mare_repository.dart';
import 'package:animal_birthday_predictor/features/animals/presentation/providers/mare_provider.dart';

import 'package:animal_birthday_predictor/features/pregnancy/domain/pregnancy_record.dart';
import 'package:animal_birthday_predictor/features/pregnancy/domain/breeding_record.dart';
import 'package:animal_birthday_predictor/features/pregnancy/data/pregnancy_repository.dart';
import 'package:animal_birthday_predictor/features/pregnancy/presentation/providers/pregnancy_provider.dart';

class MockAnimalRepo extends AnimalRepository {
  @override
  Future<Animal?> getAnimalById(String id) async {
    return Animal(
      id: id,
      accountId: 'acc1',
      name: 'Starlight Majestic Champion Duchess of the Northern Realm',
      species: 'horse',
      sex: 'mare',
      breed: 'Arabian Warmblood Cross Thoroughbred',
      colour: 'Dappled Grey',
      dateOfBirth: DateTime(2018, 5, 12),
      microchipNo: '985141002345678',
      brand: 'Cross & Crescent Left Shoulder',
      dna: 'DNA-HORSE-94821',
      ownerClientName: 'Eleanor Vance Equestrian Farms',
      ownerClientPhone: '+1 555 019 2831',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }
}

class MockMareRepo extends MareRepository {
  @override
  Future<Markings?> getMarkings(String ownerType, String ownerId) async {
    return Markings(
      id: 'm1',
      ownerType: ownerType,
      ownerId: ownerId,
      leftSideImageUrl: 'https://example.com/left.jpg',
      rightSideImageUrl: 'https://example.com/right.jpg',
      headViewImageUrl: 'https://example.com/head.jpg',
      headViewNotes: 'White star on forehead, irregular blaze descending to left nostril.',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }
}

class MockPregnancyRepo extends PregnancyRepository {
  @override
  Future<PregnancyRecord?> getPregnancyRecordForCarrier(String carrierAnimalId) async {
    return PregnancyRecord(
      id: 'pr1',
      accountId: 'acc1',
      carrierAnimalId: carrierAnimalId,
      breedingRecordId: 'br1',
      scan1Confirmed: true,
      scan2Confirmed: true,
      scan3Confirmed: true,
      scan1DueDate: DateTime(2026, 8, 20),
      scan2DueDate: DateTime(2026, 9, 5),
      scan3DueDate: DateTime(2026, 9, 20),
      foalingDueDate: DateTime(2027, 7, 15),
      scan1ImageUrl: 'https://example.com/scan1.jpg',
      scan2ImageUrl: 'https://example.com/scan2.jpg',
      scan3ImageUrl: 'https://example.com/scan3.jpg',
      vetName: 'Dr. Emily Hayes DVM',
      vetNumber: '+1 555 019 3820',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  @override
  Future<BreedingRecord?> getBreedingRecordByMare(String mareAnimalId) async {
    return BreedingRecord(
      id: 'br1',
      accountId: 'acc1',
      mareAnimalId: mareAnimalId,
      stallionName: 'Valegro Majestic Stud of Olympus',
      method: 'chilled',
      coverOrTransferDate: DateTime(2026, 8, 1),
      photoUrl: 'https://example.com/straws.jpg',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }
}

void main() {
  final testAnimal = Animal(
    id: 'a1',
    accountId: 'acc1',
    name: 'Starlight Majestic Champion Duchess of the Northern Realm',
    species: 'horse',
    sex: 'mare',
    breed: 'Arabian Warmblood Cross Thoroughbred',
    colour: 'Dappled Grey',
    dateOfBirth: DateTime(2018, 5, 12),
    microchipNo: '985141002345678',
    brand: 'Cross & Crescent Left Shoulder',
    dna: 'DNA-HORSE-94821',
    ownerClientName: 'Eleanor Vance Equestrian Farms',
    ownerClientPhone: '+1 555 019 2831',
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
  );

  const resolutions = [
    Size(320, 568),
    Size(375, 812),
    Size(412, 915),
    Size(768, 1024),
    Size(1280, 800),
  ];

  for (final size in resolutions) {
    testWidgets('AnimalProfileScreen with full data renders without overflow on ${size.width}x${size.height}', (tester) async {
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            animalRepositoryProvider.overrideWithValue(MockAnimalRepo()),
            mareRepositoryProvider.overrideWithValue(MockMareRepo()),
            pregnancyRepositoryProvider.overrideWithValue(MockPregnancyRepo()),
          ],
          child: MaterialApp(home: AnimalProfileScreen(animal: testAnimal)),
        ),
      );
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.text('HORSE PROFILE'), findsOneWidget);
      expect(find.text('PHYSICAL MARKINGS'), findsOneWidget);
      expect(find.text('PREGNANCY & SCANS'), findsOneWidget);
      expect(find.text('3 / 3 SCANS CONFIRMED'), findsOneWidget);
      expect(find.text('BREEDING RECORD & PHOTO'), findsOneWidget);
    });
  }
}
