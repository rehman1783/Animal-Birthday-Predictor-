import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/foaling_diary_entry.dart';
import '../../data/foaling_diary_repository.dart';
import '../../data/calendar_diary_sync_service.dart';

final foalingDiaryRepositoryProvider = Provider<FoalingDiaryRepository>((ref) {
  SupabaseClient? client;
  try {
    client = Supabase.instance.client;
  } catch (_) {}
  return FoalingDiaryRepository(client: client);
});

class FoalingDiaryNotifier extends StateNotifier<AsyncValue<List<FoalingDiaryEntry>>> {
  final FoalingDiaryRepository _repo;

  FoalingDiaryNotifier(this._repo) : super(const AsyncValue.loading()) {
    loadEntries();
  }

  Future<void> loadEntries() async {
    state = const AsyncValue.loading();
    try {
      final entries = await _repo.getFoalingDiaryEntries();
      state = AsyncValue.data(entries);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> addOrUpdateEntry(FoalingDiaryEntry entry) async {
    try {
      await _repo.saveFoalingDiaryEntry(entry);
      await loadEntries();
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> updatePaddock(String id, String paddock) async {
    try {
      await _repo.updatePaddockLocation(id, paddock);
      await loadEntries();
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> markFoaled(String id) async {
    try {
      await _repo.markAsFoaled(id);
      await loadEntries();
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> deleteEntry(String id) async {
    try {
      await _repo.deleteEntry(id);
      await loadEntries();
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

final foalingDiaryProvider = StateNotifierProvider<FoalingDiaryNotifier, AsyncValue<List<FoalingDiaryEntry>>>((ref) {
  final repo = ref.watch(foalingDiaryRepositoryProvider);
  return FoalingDiaryNotifier(repo);
});

final calendarDiarySyncServiceProvider = Provider<CalendarDiarySyncService>((ref) {
  SupabaseClient? client;
  try {
    client = Supabase.instance.client;
  } catch (_) {}
  return CalendarDiarySyncService(client: client);
});

final calendarTimelineMilestonesProvider = FutureProvider.autoDispose<List<CalendarTimelineMilestone>>((ref) async {
  final diaryAsync = ref.watch(foalingDiaryProvider);
  final syncService = ref.watch(calendarDiarySyncServiceProvider);
  final entries = diaryAsync.value ?? [];
  return syncService.getUnifiedCalendarMilestones(entries);
});

