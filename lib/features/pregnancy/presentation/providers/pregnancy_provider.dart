import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/pregnancy_repository.dart';
import '../../domain/pregnancy_record.dart';
import '../../domain/advanced_pregnancy_info.dart';

final pregnancyRepositoryProvider = Provider<PregnancyRepository>((ref) {
  return PregnancyRepository();
});

final pregnancyRecordForCarrierProvider = FutureProvider.family<PregnancyRecord?, ({String carrierType, String carrierId})>((ref, arg) async {
  final repo = ref.watch(pregnancyRepositoryProvider);
  return repo.getPregnancyRecordForCarrier(arg.carrierType, arg.carrierId);
});

final advancedPregnancyInfoProvider = FutureProvider.family<AdvancedPregnancyInfo?, String>((ref, pregnancyRecordId) async {
  final repo = ref.watch(pregnancyRepositoryProvider);
  return repo.getAdvancedPregnancyInfo(pregnancyRecordId);
});
