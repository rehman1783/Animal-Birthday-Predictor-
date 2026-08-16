import 'package:flutter_test/flutter_test.dart';
import 'package:animal_birthday_predictor/core/utils/app_uuid.dart';
import 'package:animal_birthday_predictor/features/animals/domain/animal.dart';
import 'package:animal_birthday_predictor/features/animals/data/animal_repository.dart';

void main() {
  group('Animal Database & Repository Flow Tests', () {
    late AnimalRepository repository;

    setUp(() {
      repository = AnimalRepository();
    });

    test('Validates and generates RFC 4122 v4 UUIDs', () {
      final uuid = AppUuid.generate();
      expect(AppUuid.isValid(uuid), isTrue);
      expect(AppUuid.isValid('not-a-uuid'), isFalse);
      expect(AppUuid.isValid('1723829182391'), isFalse);
      expect(AppUuid.isValid(''), isFalse);
      expect(AppUuid.isValid(null), isFalse);
    });

    test('Saves animal, auto-normalizes ID to UUID, and persists all fields', () async {
      final newAnimal = Animal(
        id: '', // Will be normalized by repository
        accountId: '',
        species: 'horse',
        name: 'Starlight Royal',
        breed: 'Thoroughbred',
        colour: 'Bay',
        dateOfBirth: DateTime(2018, 5, 20),
        microchipNo: '985141001234567',
        dna: 'DNA-88421',
        brand: 'Star & Bar',
        ownerClientName: 'Eleanor Vance',
        ownerClientPhone: '+1 555 019 2831',
        photoUrl: 'https://example.com/starlight.jpg',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final saved = await repository.saveAnimal(newAnimal);

      // Verify ID is now a valid UUID
      expect(AppUuid.isValid(saved.id), isTrue);
      expect(saved.name, 'Starlight Royal');
      expect(saved.species, 'horse');
      expect(saved.breed, 'Thoroughbred');
      expect(saved.microchipNo, '985141001234567');
      expect(saved.ownerClientName, 'Eleanor Vance');

      // Fetch by ID and verify exact match
      final fetched = await repository.getAnimalById(saved.id);
      expect(fetched, isNotNull);
      expect(fetched!.id, saved.id);
      expect(fetched.name, 'Starlight Royal');
      expect(fetched.colour, 'Bay');
      expect(fetched.dateOfBirth, DateTime(2018, 5, 20));
      expect(fetched.brand, 'Star & Bar');
    });

    test('Fetches animals filtered by species (horse vs dog vs cat)', () async {
      final horse1 = Animal(
        id: AppUuid.generate(),
        accountId: AppUuid.generate(),
        species: 'horse',
        name: 'Horse One',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      final horse2 = Animal(
        id: AppUuid.generate(),
        accountId: AppUuid.generate(),
        species: 'horse',
        name: 'Horse Two',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      final dog1 = Animal(
        id: AppUuid.generate(),
        accountId: AppUuid.generate(),
        species: 'dog',
        name: 'Dog One',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await repository.saveAnimal(horse1);
      await repository.saveAnimal(horse2);
      await repository.saveAnimal(dog1);

      final horses = await repository.getAnimals(species: 'horse');
      expect(horses.length, 2);
      expect(horses.every((a) => a.species == 'horse'), isTrue);

      final dogs = await repository.getAnimals(species: 'dog');
      expect(dogs.length, 1);
      expect(dogs.first.name, 'Dog One');

      final cats = await repository.getAnimals(species: 'cat');
      expect(cats.isEmpty, isTrue);

      final all = await repository.getAnimals();
      expect(all.length, 3);
    });

    test('Updates an existing animal without duplicating records', () async {
      final initial = Animal(
        id: AppUuid.generate(),
        accountId: AppUuid.generate(),
        species: 'horse',
        name: 'Golden Arrow',
        breed: 'Arabian',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final saved = await repository.saveAnimal(initial);
      expect(saved.breed, 'Arabian');

      // Update the animal's breed and add microchip
      final updated = saved.copyWith(
        breed: 'Purebred Arabian',
        microchipNo: '900012345678901',
      );

      final savedUpdate = await repository.saveAnimal(updated);
      expect(savedUpdate.id, saved.id);
      expect(savedUpdate.breed, 'Purebred Arabian');
      expect(savedUpdate.microchipNo, '900012345678901');

      final list = await repository.getAnimals(species: 'horse');
      expect(list.length, 1);
      expect(list.first.breed, 'Purebred Arabian');
    });

    test('Deletes an animal cleanly', () async {
      final animal = Animal(
        id: AppUuid.generate(),
        accountId: AppUuid.generate(),
        species: 'horse',
        name: 'To Delete',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final saved = await repository.saveAnimal(animal);
      expect(await repository.getAnimalById(saved.id), isNotNull);

      await repository.deleteAnimal(saved.id);
      expect(await repository.getAnimalById(saved.id), isNull);
      final list = await repository.getAnimals();
      expect(list.isEmpty, isTrue);
    });
  });
}
