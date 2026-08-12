import '../domain/foal_record.dart';
import '../../animals/domain/animal_type.dart';

class FoalRepository {
  final List<FoalRecord> _mockFoals = [
    FoalRecord(
      id: 'f1',
      pregnancyId: 'p3',
      offspringName: 'Solar Flare',
      animalType: AnimalType.horse,
      damName: 'Celestial Queen',
      sireName: 'Northern Dancer',
      birthDate: DateTime.now().subtract(const Duration(days: 10)),
      birthWeightKg: 48.5,
      gender: 'colt',
      color: 'Chestnut',
      healthNotes: 'Strong vitals, nursing well within 2 hours. Normal colostrum intake.',
      createdAt: DateTime.now().subtract(const Duration(days: 10)),
    ),
    FoalRecord(
      id: 'f2',
      pregnancyId: 'p0',
      offspringName: 'Midnight Shadow',
      animalType: AnimalType.horse,
      damName: 'Starlight Eclipse',
      sireName: 'Thunderbolt Fury',
      birthDate: DateTime.now().subtract(const Duration(days: 365)),
      birthWeightKg: 52.0,
      gender: 'filly',
      color: 'Black / Bay',
      healthNotes: 'Healthy growth. Vaccinations updated.',
      createdAt: DateTime.now().subtract(const Duration(days: 365)),
    ),
  ];

  Future<List<FoalRecord>> fetchFoals() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return List.from(_mockFoals);
  }

  Future<void> addFoal(FoalRecord record) async {
    await Future.delayed(const Duration(milliseconds: 200));
    _mockFoals.insert(0, record);
  }
}
