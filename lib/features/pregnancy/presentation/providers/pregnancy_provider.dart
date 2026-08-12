import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/pregnancy_repository.dart';
import '../../domain/pregnancy_record.dart';
import '../../../animals/domain/animal_type.dart';

final pregnancyRepositoryProvider = Provider<PregnancyRepository>((ref) {
  return PregnancyRepository();
});

class PregnancyListNotifier extends StateNotifier<AsyncValue<List<PregnancyRecord>>> {
  final PregnancyRepository _repository;

  PregnancyListNotifier(this._repository) : super(const AsyncValue.loading()) {
    loadPregnancies();
  }

  Future<void> loadPregnancies() async {
    state = const AsyncValue.loading();
    try {
      final list = await _repository.fetchPregnancies();
      state = AsyncValue.data(list);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<bool> addPregnancy(PregnancyRecord record) async {
    try {
      await _repository.addPregnancy(record);
      await loadPregnancies();
      return true;
    } catch (e) {
      return false;
    }
  }
}

final pregnancyListProvider =
    StateNotifierProvider<PregnancyListNotifier, AsyncValue<List<PregnancyRecord>>>((ref) {
  final repo = ref.watch(pregnancyRepositoryProvider);
  return PregnancyListNotifier(repo);
});

/// Gestation Calculator State
class GestationCalculation {
  final AnimalType animalType;
  final DateTime breedingDate;
  final DateTime expectedDueDate;
  final DateTime minDueDate;
  final DateTime maxDueDate;

  GestationCalculation({
    required this.animalType,
    required this.breedingDate,
  })  : expectedDueDate = animalType.calculateDueDate(breedingDate),
        minDueDate = breedingDate.add(Duration(days: animalType.minGestationDays)),
        maxDueDate = breedingDate.add(Duration(days: animalType.maxGestationDays));
}

class GestationCalculatorNotifier extends StateNotifier<GestationCalculation> {
  GestationCalculatorNotifier()
      : super(GestationCalculation(
          animalType: AnimalType.horse,
          breedingDate: DateTime.now(),
        ));

  void updateAnimalType(AnimalType type) {
    state = GestationCalculation(
      animalType: type,
      breedingDate: state.breedingDate,
    );
  }

  void updateBreedingDate(DateTime date) {
    state = GestationCalculation(
      animalType: state.animalType,
      breedingDate: date,
    );
  }
}

final gestationCalculatorProvider =
    StateNotifierProvider<GestationCalculatorNotifier, GestationCalculation>((ref) {
  return GestationCalculatorNotifier();
});
