import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/utils/app_uuid.dart';
import '../domain/preventative_care_record.dart';

class PreventativeCareRepository {
  final SupabaseClient? _supabase;
  final List<PreventativeCareRecord> _mockRecords = [];

  PreventativeCareRepository({SupabaseClient? supabase}) : _supabase = supabase;

  SupabaseClient? get client {
    if (_supabase != null) return _supabase;
    try {
      return Supabase.instance.client;
    } catch (_) {
      return null;
    }
  }

  Future<PreventativeCareRecord?> getPreventativeCare(String ownerType, String ownerId) async {
    final c = client;

    if (c != null) {
      try {
        final data = await c
            .from('preventative_care')
            .select()
            .eq('owner_type', ownerType)
            .eq('owner_id', ownerId)
            .limit(1);
        if (data is List && data.isNotEmpty) {
          return PreventativeCareRecord.fromJson(data.first as Map<String, dynamic>);
        }
        return null;
      } catch (e) {
        debugPrint('Supabase getPreventativeCare error: $e');
        rethrow;
      }
    }

    try {
      return _mockRecords.firstWhere(
        (r) => r.ownerType == ownerType && r.ownerId == ownerId,
      );
    } catch (_) {
      return null;
    }
  }

  Future<PreventativeCareRecord> savePreventativeCare(PreventativeCareRecord record) async {
    final c = client;
    String validId = record.id;

    if (!AppUuid.isValid(validId)) {
      final existing = await getPreventativeCare(record.ownerType, record.ownerId);
      if (existing != null && AppUuid.isValid(existing.id)) {
        validId = existing.id;
      } else {
        validId = AppUuid.generate();
      }
    }

    final toSave = record.copyWith(id: validId);

    if (c != null) {
      try {
        final data = await c
            .from('preventative_care')
            .upsert(toSave.toJson(), onConflict: 'owner_type,owner_id')
            .select();
        if (data is List && data.isNotEmpty) {
          return PreventativeCareRecord.fromJson(data.first as Map<String, dynamic>);
        }
      } catch (e) {
        debugPrint('Supabase savePreventativeCare error: $e');
        rethrow;
      }
    }

    final idx = _mockRecords.indexWhere((r) => r.ownerType == toSave.ownerType && r.ownerId == toSave.ownerId);
    if (idx >= 0) {
      _mockRecords[idx] = toSave;
    } else {
      _mockRecords.insert(0, toSave);
    }
    return toSave;
  }
}
