import '../domain/pregnancy_record.dart';
import '../../animals/domain/animal_type.dart';

class PregnancyRepository {
  final List<PregnancyRecord> _mockPregnancies = [
    PregnancyRecord(
      id: 'p1',
      damName: 'Starlight Eclipse',
      sireName: 'Thunderbolt Fury',
      animalType: AnimalType.horse,
      breedingDate: DateTime.now().subtract(const Duration(days: 315)),
      expectedDueDate: DateTime.now().add(const Duration(days: 25)),
      confirmedPregnancy: true,
      status: PregnancyStatus.active,
      notes: 'Ultasound confirmed single healthy foal. Gestation on track.',
      createdAt: DateTime.now().subtract(const Duration(days: 315)),
    ),
    PregnancyRecord(
      id: 'p2',
      damName: 'Bella Sterling',
      sireName: 'Baron von Rex',
      animalType: AnimalType.dog,
      breedingDate: DateTime.now().subtract(const Duration(days: 52)),
      expectedDueDate: DateTime.now().add(const Duration(days: 11)),
      confirmedPregnancy: true,
      status: PregnancyStatus.dueSoon,
      notes: 'Nesting behavior observed. Expected litter of 5-7 puppies.',
      createdAt: DateTime.now().subtract(const Duration(days: 52)),
    ),
    PregnancyRecord(
      id: 'p3',
      damName: 'Celestial Queen',
      sireName: 'Northern Dancer',
      animalType: AnimalType.horse,
      breedingDate: DateTime.now().subtract(const Duration(days: 350)),
      expectedDueDate: DateTime.now().subtract(const Duration(days: 10)),
      confirmedPregnancy: true,
      status: PregnancyStatus.delivered,
      notes: 'Delivered healthy colt safely. Normal foaling.',
      createdAt: DateTime.now().subtract(const Duration(days: 350)),
    ),
  ];

  Future<List<PregnancyRecord>> fetchPregnancies() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return List.from(_mockPregnancies);
  }

  Future<void> addPregnancy(PregnancyRecord record) async {
    await Future.delayed(const Duration(milliseconds: 200));
    _mockPregnancies.insert(0, record);
  }
}
