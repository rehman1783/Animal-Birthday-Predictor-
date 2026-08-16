import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/animal_repository.dart';
import '../../domain/animal.dart';

final animalRepositoryProvider = Provider<AnimalRepository>((ref) {
  return AnimalRepository();
});

final selectedSpeciesFilterProvider = StateProvider<String>((ref) => 'horse');

final animalsListProvider = FutureProvider.family<List<Animal>, String?>((ref, species) async {
  final repo = ref.watch(animalRepositoryProvider);
  return repo.getAnimals(species: species);
});

final animalByIdProvider = FutureProvider.family<Animal?, String>((ref, id) async {
  final repo = ref.watch(animalRepositoryProvider);
  return repo.getAnimalById(id);
});

final selectedAnimalProvider = StateProvider<Animal?>((ref) => null);
