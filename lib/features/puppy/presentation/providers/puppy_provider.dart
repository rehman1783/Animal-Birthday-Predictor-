import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/puppy_repository.dart';
import '../../domain/dog_preventative_care.dart';
import '../../domain/puppy.dart';
import '../../domain/puppy_weight.dart';

final puppyRepositoryProvider = Provider<PuppyRepository>((ref) {
  return PuppyRepository();
});

final puppiesListProvider = FutureProvider.autoDispose.family<List<Puppy>, String?>((ref, damId) async {
  final repo = ref.watch(puppyRepositoryProvider);
  return repo.getPuppies(damId: damId);
});

final puppyByIdProvider = FutureProvider.autoDispose.family<Puppy?, String>((ref, id) async {
  final repo = ref.watch(puppyRepositoryProvider);
  return repo.getPuppyById(id);
});

final puppyWeightsProvider = FutureProvider.autoDispose.family<List<PuppyWeight>, String>((ref, puppyId) async {
  final repo = ref.watch(puppyRepositoryProvider);
  return repo.getPuppyWeights(puppyId);
});

final dogPreventativeCareProvider = FutureProvider.autoDispose.family<List<DogPreventativeCareItem>, ({String ownerType, String ownerId, DateTime? dob})>((ref, arg) async {
  final repo = ref.watch(puppyRepositoryProvider);
  return repo.initializeDefaultDogSchedule(
    ownerType: arg.ownerType,
    ownerId: arg.ownerId,
    dateOfBirth: arg.dob,
  );
});
