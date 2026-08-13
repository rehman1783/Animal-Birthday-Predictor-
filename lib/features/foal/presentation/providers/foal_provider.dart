import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/foal_repository.dart';
import '../../domain/foal_record.dart';

final foalRepositoryProvider = Provider<FoalRepository>((ref) {
  return FoalRepository();
});

final foalsListProvider = FutureProvider<List<FoalRecord>>((ref) async {
  final repo = ref.watch(foalRepositoryProvider);
  return repo.getFoals();
});
