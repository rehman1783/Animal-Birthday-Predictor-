import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/pregnancy_repository.dart';
import '../../domain/advanced_pregnancy_info.dart';
import '../../domain/breeding_record.dart';
import '../../domain/pregnancy_record.dart';

final pregnancyRepositoryProvider = Provider<PregnancyRepository>((ref) {
  return PregnancyRepository();
});

final pregnancyRecordForCarrierProvider = FutureProvider.autoDispose.family<PregnancyRecord?, String>((ref, carrierAnimalId) async {
  final repo = ref.watch(pregnancyRepositoryProvider);
  return repo.getPregnancyRecordForCarrier(carrierAnimalId);
});

final breedingRecordByIdProvider = FutureProvider.autoDispose.family<BreedingRecord?, String>((ref, id) async {
  final repo = ref.watch(pregnancyRepositoryProvider);
  return repo.getBreedingRecordById(id);
});

final breedingRecordByMareProvider = FutureProvider.autoDispose.family<BreedingRecord?, String>((ref, mareId) async {
  final repo = ref.watch(pregnancyRepositoryProvider);
  return repo.getBreedingRecordByMare(mareId);
});

final pregnancyRecordByIdProvider = FutureProvider.autoDispose.family<PregnancyRecord?, String>((ref, id) async {
  final repo = ref.watch(pregnancyRepositoryProvider);
  return repo.getPregnancyRecordById(id);
});

final advancedPregnancyInfoProvider = FutureProvider.autoDispose.family<AdvancedPregnancyInfo?, String>((ref, pregnancyRecordId) async {
  final repo = ref.watch(pregnancyRepositoryProvider);
  return repo.getAdvancedPregnancyInfo(pregnancyRecordId);
});
