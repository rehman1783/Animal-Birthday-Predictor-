import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../domain/preventative_care_record.dart';

class PreventativeCareRepository {
  final SupabaseClient? _supabase;
  final List<PreventativeCareRecord> _inMemoryRecords = [];

  PreventativeCareRepository({SupabaseClient? supabase})
      : _supabase = supabase ?? (kIsWeb || defaultTargetPlatform != TargetPlatform.windows ? null : Supabase.instance.client);

  SupabaseClient? get client {
    try {
      return _supabase ?? Supabase.instance.client;
    } catch (_) {
      return null;
    }
  }

  Future<PreventativeCareRecord?> getPreventativeCare(String ownerType, String ownerId) async {
    final c = client;
    if (c == null) {
      try {
        return _inMemoryRecords.firstWhere(
          (r) => r.ownerType == ownerType && r.ownerId == ownerId,
        );
      } catch (_) {
        return null;
      }
    }
    try {
      final data = await c
          .from('preventative_care')
          .select()
          .eq('owner_type', ownerType)
          .eq('owner_id', ownerId)
          .maybeSingle();
      if (data == null) return null;
      return PreventativeCareRecord.fromJson(data);
    } catch (e) {
      debugPrint('Supabase getPreventativeCare error: $e');
      return null;
    }
  }

  Future<PreventativeCareRecord> savePreventativeCare(PreventativeCareRecord record) async {
    final c = client;
    if (c == null) {
      final index = _inMemoryRecords.indexWhere(
        (r) => r.ownerType == record.ownerType && r.ownerId == record.ownerId,
      );
      if (index >= 0) {
        _inMemoryRecords[index] = record;
      } else {
        _inMemoryRecords.add(record);
      }
      return record;
    }
    try {
      final data = await c.from('preventative_care').upsert(record.toJson()).select().single();
      return PreventativeCareRecord.fromJson(data);
    } catch (e) {
      debugPrint('Supabase savePreventativeCare error: $e');
      _inMemoryRecords.add(record);
      return record;
    }
  }
}
