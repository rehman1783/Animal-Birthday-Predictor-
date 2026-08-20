import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/foal_repository.dart';
import '../../domain/foal_record.dart';

final foalRepositoryProvider = Provider<FoalRepository>((ref) {
  return FoalRepository();
});

final foalsListProvider = FutureProvider.autoDispose<List<FoalRecord>>((ref) async {
  ref.keepAlive();
  final repo = ref.watch(foalRepositoryProvider);
  return repo.getFoals();
});

final foalByIdProvider = FutureProvider.autoDispose.family<FoalRecord?, String>((ref, id) async {
  ref.keepAlive();
  final repo = ref.watch(foalRepositoryProvider);
  return repo.getFoalById(id);
});
