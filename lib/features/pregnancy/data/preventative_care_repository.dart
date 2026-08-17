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
    final validId = AppUuid.isValid(record.id) ? record.id : AppUuid.generate();
    final toSave = record.copyWith(id: validId);

    final c = client;
    if (c != null) {
      try {
        final data = await c.from('preventative_care').upsert(toSave.toJson()).select();
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
