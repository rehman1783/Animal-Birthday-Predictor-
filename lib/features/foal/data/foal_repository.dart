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

  Future<FoalRecord> saveFoal(FoalRecord foal) async {
    final c = client;
    if (c == null) {
      final index = _inMemoryFoals.indexWhere((f) => f.id == foal.id);
      if (index >= 0) {
        _inMemoryFoals[index] = foal;
      } else {
        _inMemoryFoals.add(foal);
      }
      return foal;
    }
    try {
      final data = await c.from('foals').upsert(foal.toJson()).select().single();
      return FoalRecord.fromJson(data);
    } catch (e) {
      debugPrint('Supabase saveFoal error: $e');
      _inMemoryFoals.add(foal);
      return foal;
    }
  }
}
