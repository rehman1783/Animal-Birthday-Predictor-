import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../domain/foal_record.dart';

class FoalRepository {
  final SupabaseClient? _supabase;
  final List<FoalRecord> _inMemoryFoals = [];

  FoalRepository({SupabaseClient? supabase})
      : _supabase = supabase ?? (kIsWeb || defaultTargetPlatform != TargetPlatform.windows ? null : Supabase.instance.client);

  SupabaseClient? get client {
    try {
      return _supabase ?? Supabase.instance.client;
    } catch (_) {
      return null;
    }
  }

  Future<List<FoalRecord>> getFoals() async {
    final c = client;
    if (c == null) return List.unmodifiable(_inMemoryFoals);
    try {
      final data = await c.from('foals').select().order('created_at', ascending: false);
      return (data as List).map((json) => FoalRecord.fromJson(json)).toList();
    } catch (e) {
      debugPrint('Supabase getFoals error: $e');
      return List.unmodifiable(_inMemoryFoals);
    }
  }

  Future<FoalRecord?> getFoalById(String id) async {
    final c = client;
    if (c == null) {
      try {
        return _inMemoryFoals.firstWhere((f) => f.id == id);
      } catch (_) {
        return null;
      }
    }
    try {
      final data = await c.from('foals').select().eq('id', id).maybeSingle();
      if (data == null) return null;
      return FoalRecord.fromJson(data);
    } catch (e) {
      debugPrint('Supabase getFoalById error: $e');
      return null;
    }
  }

  Future<FoalRecord> saveFoal(FoalRecord foal) async {
    final c = client;
    final user = c?.auth.currentUser;
    final accountId = user?.id ?? (foal.accountId.isNotEmpty ? foal.accountId : '00000000-0000-0000-0000-000000000000');
    final toSave = foal.copyWith(accountId: accountId);

    if (c == null) {
      final index = _inMemoryFoals.indexWhere((f) => f.id == toSave.id);
      if (index >= 0) {
        _inMemoryFoals[index] = toSave;
      } else {
        _inMemoryFoals.insert(0, toSave);
      }
      return toSave;
    }
    try {
      final data = await c.from('foals').upsert(toSave.toJson()).select().single();
      final saved = FoalRecord.fromJson(data);
      final index = _inMemoryFoals.indexWhere((f) => f.id == saved.id);
      if (index >= 0) {
        _inMemoryFoals[index] = saved;
      } else {
        _inMemoryFoals.insert(0, saved);
      }
      return saved;
    } catch (e) {
      debugPrint('Supabase saveFoal error: $e');
      final index = _inMemoryFoals.indexWhere((f) => f.id == toSave.id);
      if (index >= 0) {
        _inMemoryFoals[index] = toSave;
      } else {
        _inMemoryFoals.insert(0, toSave);
      }
      return toSave;
    }
  }

  Future<void> deleteFoal(String id) async {
    final c = client;
    _inMemoryFoals.removeWhere((f) => f.id == id);
    if (c != null) {
      try {
        await c.from('foals').delete().eq('id', id);
      } catch (e) {
        debugPrint('Supabase deleteFoal error: $e');
      }
    }
  }
}
