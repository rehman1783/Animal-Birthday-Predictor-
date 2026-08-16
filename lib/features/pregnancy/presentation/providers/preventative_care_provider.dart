import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/preventative_care_repository.dart';
import '../../domain/preventative_care_record.dart';

final preventativeCareRepositoryProvider = Provider<PreventativeCareRepository>((ref) {
  return PreventativeCareRepository();
});

final preventativeCareForOwnerProvider = FutureProvider.family<PreventativeCareRecord?, ({String ownerType, String ownerId})>((ref, arg) async {
  final repo = ref.watch(preventativeCareRepositoryProvider);
  return repo.getPreventativeCare(arg.ownerType, arg.ownerId);
});
