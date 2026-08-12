import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/foal_repository.dart';
import '../../domain/foal_record.dart';

final foalRepositoryProvider = Provider<FoalRepository>((ref) {
  return FoalRepository();
});

class FoalListNotifier extends StateNotifier<AsyncValue<List<FoalRecord>>> {
  final FoalRepository _repository;

  FoalListNotifier(this._repository) : super(const AsyncValue.loading()) {
    loadFoals();
  }

  Future<void> loadFoals() async {
    state = const AsyncValue.loading();
    try {
      final list = await _repository.fetchFoals();
      state = AsyncValue.data(list);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<bool> addFoal(FoalRecord record) async {
    try {
      await _repository.addFoal(record);
      await loadFoals();
      return true;
    } catch (e) {
      return false;
    }
  }
}

final foalListProvider =
    StateNotifierProvider<FoalListNotifier, AsyncValue<List<FoalRecord>>>((ref) {
  final repo = ref.watch(foalRepositoryProvider);
  return FoalListNotifier(repo);
});
