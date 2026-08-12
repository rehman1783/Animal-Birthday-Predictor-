import '../domain/animal.dart';
import '../domain/animal_type.dart';

class AnimalRepository {
  // In-memory initial data for demonstration & fast UI testing
  final List<Animal> _mockAnimals = [
    Animal(
      id: 'a1',
      name: 'Starlight Eclipse',
      type: AnimalType.horse,
      breed: 'Thoroughbred',
      gender: 'female',
      dateOfBirth: DateTime(2019, 4, 12),
      registrationNumber: 'TB-89421',
      damName: 'Celestial Queen',
      sireName: 'Northern Dancer',
      notes: 'Prime breeding mare. Exceptionally calm temperament.',
      createdAt: DateTime.now().subtract(const Duration(days: 300)),
    ),
    Animal(
      id: 'a2',
      name: 'Thunderbolt Fury',
      type: AnimalType.horse,
      breed: 'Quarter Horse',
      gender: 'male',
      dateOfBirth: DateTime(2018, 5, 20),
      registrationNumber: 'QH-55910',
      damName: 'Golden Sunburst',
      sireName: 'Storm Chaser',
      notes: 'Proven stud stallion. High fertility score.',
      createdAt: DateTime.now().subtract(const Duration(days: 280)),
    ),
    Animal(
      id: 'a3',
      name: 'Bella Sterling',
      type: AnimalType.dog,
      breed: 'German Shepherd',
      gender: 'female',
      dateOfBirth: DateTime(2021, 8, 15),
      registrationNumber: 'AKC-GS9942',
      damName: 'Lady Freya',
      sireName: 'Baron von Rex',
      notes: 'Champion bloodline. Excellent whelping history.',
      createdAt: DateTime.now().subtract(const Duration(days: 120)),
    ),
  ];

  Future<List<Animal>> fetchAnimals() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return List.from(_mockAnimals);
  }

  Future<void> addAnimal(Animal animal) async {
    await Future.delayed(const Duration(milliseconds: 200));
    _mockAnimals.insert(0, animal);
  }
}
