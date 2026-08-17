import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/utils/app_uuid.dart';
import '../domain/preventative_care_record.dart';

class PreventativeCareRepository {
  static const String _storageKey = 'abp_cached_preventative_care_records';
  final SupabaseClient? _supabase;
  final List<PreventativeCareRecord> _inMemoryRecords = [];
  bool _hasLoadedFromStorage = false;

  PreventativeCareRepository({SupabaseClient? supabase})
      : _supabase = supabase ?? (kIsWeb || defaultTargetPlatform != TargetPlatform.windows ? null : Supabase.instance.client) {
    _initLocalStorage();
  }

  SupabaseClient? get client {
    try {
      return _supabase ?? Supabase.instance.client;
    } catch (_) {
      return null;
    }
  }

  Future<void> _initLocalStorage() async {
    if (_hasLoadedFromStorage) return;
    _hasLoadedFromStorage = true;
    try {
      final prefs = await SharedPreferences.getInstance();
      final list = prefs.getStringList(_storageKey);
      if (list != null && list.isNotEmpty) {
        for (final item in list) {
          try {
            final json = jsonDecode(item) as Map<String, dynamic>;
            final rec = PreventativeCareRecord.fromJson(json);
            if (!_inMemoryRecords.any((r) => r.id == rec.id)) {
              _inMemoryRecords.add(rec);
            }
          } catch (e) {
            debugPrint('Error decoding preventative care cache: $e');
          }
        }
      }
    } catch (e) {
      debugPrint('PreventativeCareRepository: error loading local cache: $e');
    }
  }

  Future<void> _persistToLocalStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final list = _inMemoryRecords.map((r) => jsonEncode(r.toJson())).toList();
      await prefs.setStringList(_storageKey, list);
    } catch (e) {
      debugPrint('PreventativeCareRepository: error persisting to local cache: $e');
    }
  }

  Future<PreventativeCareRecord?> getPreventativeCare(String ownerType, String ownerId) async {
    await _initLocalStorage();
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
          final remote = PreventativeCareRecord.fromJson(data.first as Map<String, dynamic>);
          final idx = _inMemoryRecords.indexWhere((r) => r.ownerType == ownerType && r.ownerId == ownerId);
          if (idx >= 0) {
            _inMemoryRecords[idx] = remote;
          } else {
            _inMemoryRecords.add(remote);
          }
          await _persistToLocalStorage();
          return remote;
        }
      } catch (e) {
        debugPrint('Supabase getPreventativeCare error: $e');
      }
    }

    try {
      return _inMemoryRecords.firstWhere(
        (r) => r.ownerType == ownerType && r.ownerId == ownerId,
      );
    } catch (_) {
      return null;
    }
  }

  Future<PreventativeCareRecord> savePreventativeCare(PreventativeCareRecord record) async {
    await _initLocalStorage();
    final validId = AppUuid.isValid(record.id) ? record.id : AppUuid.generate();
    final toSave = record.copyWith(id: validId);

    final index = _inMemoryRecords.indexWhere(
      (r) => r.ownerType == toSave.ownerType && r.ownerId == toSave.ownerId,
    );
    if (index >= 0) {
      _inMemoryRecords[index] = toSave;
    } else {
      _inMemoryRecords.add(toSave);
    }
    await _persistToLocalStorage();

    final c = client;
    if (c != null) {
      try {
        final data = await c.from('preventative_care').upsert(toSave.toJson()).select();
        if (data is List && data.isNotEmpty) {
          final remote = PreventativeCareRecord.fromJson(data.first as Map<String, dynamic>);
          final idx = _inMemoryRecords.indexWhere((r) => r.ownerType == toSave.ownerType && r.ownerId == toSave.ownerId);
          if (idx >= 0) {
            _inMemoryRecords[idx] = remote;
          } else {
            _inMemoryRecords.add(remote);
          }
          await _persistToLocalStorage();
          return remote;
        }
      } catch (e) {
        debugPrint('Supabase savePreventativeCare error: $e');
      }
    }

    return toSave;
  }
}
