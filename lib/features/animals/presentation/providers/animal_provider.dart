import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/animal_repository.dart';
import '../../domain/animal.dart';
import '../../domain/animal_type.dart';

final animalRepositoryProvider = Provider<AnimalRepository>((ref) {
  return AnimalRepository();
});

final selectedAnimalTypeFilterProvider = StateProvider<AnimalType?>((ref) => null);

class AnimalListNotifier extends StateNotifier<AsyncValue<List<Animal>>> {
  final AnimalRepository _repository;

  AnimalListNotifier(this._repository) : super(const AsyncValue.loading()) {
    loadAnimals();
  }

  Future<void> loadAnimals() async {
    state = const AsyncValue.loading();
    try {
      final animals = await _repository.fetchAnimals();
      state = AsyncValue.data(animals);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<bool> addAnimal(Animal animal) async {
    try {
      await _repository.addAnimal(animal);
      await loadAnimals();
      return true;
    } catch (e) {
      return false;
    }
  }
}

final animalListProvider =
    StateNotifierProvider<AnimalListNotifier, AsyncValue<List<Animal>>>((ref) {
  final repo = ref.watch(animalRepositoryProvider);
  return AnimalListNotifier(repo);
});

final selectedAnimalProvider = StateProvider<Animal?>((ref) => null);
