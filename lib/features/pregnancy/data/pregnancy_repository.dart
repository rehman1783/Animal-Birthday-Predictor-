import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/utils/app_uuid.dart';
import '../domain/breeding_record.dart';
import '../domain/pregnancy_record.dart';
import '../domain/advanced_pregnancy_info.dart';
import '../domain/pregnancy_calculation_utils.dart';

class PregnancyRepository {
  static const String _pregnancyStorageKey = 'abp_cached_pregnancy_records';
  static const String _breedingStorageKey = 'abp_cached_breeding_records';
  static const String _advancedStorageKey = 'abp_cached_advanced_pregnancy';

  final SupabaseClient? _supabase;
  final List<BreedingRecord> _inMemoryBreeding = [];
  final List<PregnancyRecord> _inMemoryPregnancies = [];
  final List<AdvancedPregnancyInfo> _inMemoryAdvanced = [];
  bool _hasLoadedFromStorage = false;

  PregnancyRepository({SupabaseClient? supabase})
      : _supabase = supabase ?? (kIsWeb || defaultTargetPlatform != TargetPlatform.windows ? null : Supabase.instance.client);

  SupabaseClient? get client {
    try {
      return _supabase ?? Supabase.instance.client;
    } catch (_) {
      return null;
    }
  }

  Future<void> _ensureLoaded() async {
    if (_hasLoadedFromStorage) return;
    _hasLoadedFromStorage = true;
    try {
      final prefs = await SharedPreferences.getInstance();

      // Load Pregnancy records
      final pregList = prefs.getStringList(_pregnancyStorageKey);
      if (pregList != null && pregList.isNotEmpty) {
        for (final str in pregList) {
          try {
            final map = jsonDecode(str) as Map<String, dynamic>;
            final rec = PregnancyRecord.fromJson(map);
            if (!_inMemoryPregnancies.any((p) => p.id == rec.id)) {
              _inMemoryPregnancies.add(rec);
            }
          } catch (e) {
            debugPrint('Error decoding cached pregnancy: $e');
          }
        }
      }

      // Load Breeding records
      final breedList = prefs.getStringList(_breedingStorageKey);
      if (breedList != null && breedList.isNotEmpty) {
        for (final str in breedList) {
          try {
            final map = jsonDecode(str) as Map<String, dynamic>;
            final rec = BreedingRecord.fromJson(map);
            if (!_inMemoryBreeding.any((b) => b.id == rec.id)) {
              _inMemoryBreeding.add(rec);
            }
          } catch (e) {
            debugPrint('Error decoding cached breeding: $e');
          }
        }
      }

      // Load Advanced info
      final advList = prefs.getStringList(_advancedStorageKey);
      if (advList != null && advList.isNotEmpty) {
        for (final str in advList) {
          try {
            final map = jsonDecode(str) as Map<String, dynamic>;
            final rec = AdvancedPregnancyInfo.fromJson(map);
            if (!_inMemoryAdvanced.any((a) => a.id == rec.id)) {
              _inMemoryAdvanced.add(rec);
            }
          } catch (e) {
            debugPrint('Error decoding cached advanced pregnancy: $e');
          }
        }
      }
    } catch (e) {
      debugPrint('Error loading cached pregnancy data from SharedPreferences: $e');
    }
  }

  Future<void> _persistPregnanciesToLocalStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final list = _inMemoryPregnancies.map((p) => jsonEncode(p.toJson())).toList();
      await prefs.setStringList(_pregnancyStorageKey, list);
    } catch (e) {
      debugPrint('Error saving cached pregnancies to SharedPreferences: $e');
    }
  }

  Future<void> _persistBreedingToLocalStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final list = _inMemoryBreeding.map((b) => jsonEncode(b.toJson())).toList();
      await prefs.setStringList(_breedingStorageKey, list);
    } catch (e) {
      debugPrint('Error saving cached breeding to SharedPreferences: $e');
    }
  }

  Future<void> _persistAdvancedToLocalStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final list = _inMemoryAdvanced.map((a) => jsonEncode(a.toJson())).toList();
      await prefs.setStringList(_advancedStorageKey, list);
    } catch (e) {
      debugPrint('Error saving cached advanced info to SharedPreferences: $e');
    }
  }

  void _updateLocalPregnancy(PregnancyRecord record) {
    final idx = _inMemoryPregnancies.indexWhere((p) => p.id == record.id || (p.carrierAnimalId.isNotEmpty && p.carrierAnimalId == record.carrierAnimalId));
    if (idx >= 0) {
      _inMemoryPregnancies[idx] = record;
    } else {
      _inMemoryPregnancies.insert(0, record);
    }
  }

  void _updateLocalBreeding(BreedingRecord record) {
    final idx = _inMemoryBreeding.indexWhere((b) => b.id == record.id);
    if (idx >= 0) {
      _inMemoryBreeding[idx] = record;
    } else {
      _inMemoryBreeding.insert(0, record);
    }
  }

  // --- BREEDING RECORDS ---
  Future<BreedingRecord> saveBreedingRecord(BreedingRecord record) async {
    await _ensureLoaded();
    final c = client;
    final user = c?.auth.currentUser;
    final accountId = user?.id ?? (AppUuid.isValid(record.accountId) ? record.accountId : '00000000-0000-0000-0000-000000000000');
    final validId = AppUuid.isValid(record.id) ? record.id : AppUuid.generate();
    final toSave = record.copyWith(id: validId, accountId: accountId);

    // Save locally first
    _updateLocalBreeding(toSave);
    await _persistBreedingToLocalStorage();

    if (c != null) {
      try {
        final data = await c.from('breeding_records').upsert(toSave.toJson()).select().maybeSingle();
        if (data != null) {
          final saved = BreedingRecord.fromJson(data);
          _updateLocalBreeding(saved);
          await _persistBreedingToLocalStorage();
          return saved;
        }
      } catch (e) {
        debugPrint('Supabase saveBreedingRecord error: $e. Local copy retained.');
      }
    }
    return toSave;
  }

  Future<BreedingRecord?> getBreedingRecordById(String id) async {
    await _ensureLoaded();
    final c = client;
    if (c == null) {
      try {
        return _inMemoryBreeding.firstWhere((b) => b.id == id);
      } catch (_) {
        return null;
      }
    }
    try {
      final data = await c.from('breeding_records').select().eq('id', id).maybeSingle();
      if (data != null) {
        final saved = BreedingRecord.fromJson(data);
        _updateLocalBreeding(saved);
        await _persistBreedingToLocalStorage();
        return saved;
      }
      return _inMemoryBreeding.firstWhere((b) => b.id == id);
    } catch (e) {
      debugPrint('Supabase getBreedingRecordById error: $e');
      try {
        return _inMemoryBreeding.firstWhere((b) => b.id == id);
      } catch (_) {
        return null;
      }
    }
  }

  // --- PREGNANCY RECORDS ---
  Future<PregnancyRecord?> getPregnancyRecordForCarrier(String carrierAnimalId) async {
    await _ensureLoaded();
    final c = client;
    if (c == null) {
      try {
        return _inMemoryPregnancies.firstWhere((p) => p.carrierAnimalId == carrierAnimalId);
      } catch (_) {
        return null;
      }
    }
    try {
      final data = await c
          .from('pregnancy_records')
          .select()
          .eq('carrier_animal_id', carrierAnimalId)
          .maybeSingle();
      if (data != null) {
        final saved = PregnancyRecord.fromJson(data);
        _updateLocalPregnancy(saved);
        await _persistPregnanciesToLocalStorage();
        return saved;
      }
      try {
        return _inMemoryPregnancies.firstWhere((p) => p.carrierAnimalId == carrierAnimalId);
      } catch (_) {
        return null;
      }
    } catch (e) {
      debugPrint('Supabase getPregnancyRecordForCarrier error: $e');
      try {
        return _inMemoryPregnancies.firstWhere((p) => p.carrierAnimalId == carrierAnimalId);
      } catch (_) {
        return null;
      }
    }
  }

  Future<PregnancyRecord?> getPregnancyRecordById(String id) async {
    await _ensureLoaded();
    final c = client;
    if (c == null) {
      try {
        return _inMemoryPregnancies.firstWhere((p) => p.id == id);
      } catch (_) {
        return null;
      }
    }
    try {
      final data = await c.from('pregnancy_records').select().eq('id', id).maybeSingle();
      if (data != null) {
        final saved = PregnancyRecord.fromJson(data);
        _updateLocalPregnancy(saved);
        await _persistPregnanciesToLocalStorage();
        return saved;
      }
      try {
        return _inMemoryPregnancies.firstWhere((p) => p.id == id);
      } catch (_) {
        return null;
      }
    } catch (e) {
      debugPrint('Supabase getPregnancyRecordById error: $e');
      try {
        return _inMemoryPregnancies.firstWhere((p) => p.id == id);
      } catch (_) {
        return null;
      }
    }
  }

  Future<PregnancyRecord> savePregnancyRecord(PregnancyRecord record) async {
    await _ensureLoaded();
    final c = client;
    final user = c?.auth.currentUser;
    final accountId = user?.id ?? (AppUuid.isValid(record.accountId) ? record.accountId : '00000000-0000-0000-0000-000000000000');
    final validId = AppUuid.isValid(record.id) ? record.id : AppUuid.generate();
    final toSave = record.copyWith(id: validId, accountId: accountId);

    // Save locally immediately
    _updateLocalPregnancy(toSave);
    await _persistPregnanciesToLocalStorage();

    if (c != null) {
      try {
        final data = await c.from('pregnancy_records').upsert(toSave.toJson()).select().maybeSingle();
        if (data != null) {
          final saved = PregnancyRecord.fromJson(data);
          _updateLocalPregnancy(saved);
          await _persistPregnanciesToLocalStorage();
          return saved;
        }
      } catch (e) {
        debugPrint('Supabase savePregnancyRecord error: $e. Local copy preserved.');
      }
    }

    return toSave;
  }

  /// Create and store a calculated pregnancy record for a carrier
  Future<PregnancyRecord> createCalculatedPregnancyRecord({
    required String carrierAnimalId,
    required String breedingRecordId,
    required String method,
    required bool isEmbryoTransfer,
    required DateTime baseDate,
  }) async {
    await _ensureLoaded();
    final calculated = calculatePregnancyDates(
      isEmbryoTransfer: isEmbryoTransfer,
      method: method,
      baseDate: baseDate,
    );

    // Check if an existing pregnancy record exists for this carrier and update its due dates
    final existing = await getPregnancyRecordForCarrier(carrierAnimalId);

    final record = PregnancyRecord(
      id: existing != null && AppUuid.isValid(existing.id) ? existing.id : AppUuid.generate(),
      accountId: existing?.accountId ?? '',
      breedingRecordId: breedingRecordId,
      carrierAnimalId: carrierAnimalId,
      scan1DueDate: calculated.scan1DueDate,
      scan1Confirmed: existing?.scan1Confirmed ?? false,
      scan1ImageUrl: existing?.scan1ImageUrl,
      scan2DueDate: calculated.scan2DueDate,
      scan2Confirmed: existing?.scan2Confirmed ?? false,
      scan2ImageUrl: existing?.scan2ImageUrl,
      scan3DueDate: calculated.scan3DueDate,
      scan3Confirmed: existing?.scan3Confirmed ?? false,
      scan3ImageUrl: existing?.scan3ImageUrl,
      foalingDueDate: calculated.foalingDueDate,
      vetName: existing?.vetName,
      vetNumber: existing?.vetNumber,
      createdAt: existing?.createdAt ?? DateTime.now(),
      updatedAt: DateTime.now(),
    );

    return savePregnancyRecord(record);
  }

  Future<void> deletePregnancyRecord(String id) async {
    await _ensureLoaded();
    _inMemoryPregnancies.removeWhere((p) => p.id == id);
    _inMemoryAdvanced.removeWhere((a) => a.pregnancyRecordId == id);
    await _persistPregnanciesToLocalStorage();
    await _persistAdvancedToLocalStorage();

    final c = client;
    if (c != null) {
      try {
        await c.from('pregnancy_records').delete().eq('id', id);
      } catch (e) {
        debugPrint('Supabase deletePregnancyRecord error: $e');
      }
    }
  }

  Future<void> deleteBreedingRecord(String id) async {
    await _ensureLoaded();
    _inMemoryBreeding.removeWhere((b) => b.id == id);
    await _persistBreedingToLocalStorage();

    final c = client;
    if (c != null) {
      try {
        await c.from('breeding_records').delete().eq('id', id);
      } catch (e) {
        debugPrint('Supabase deleteBreedingRecord error: $e');
      }
    }
  }

  // --- ADVANCED PREGNANCY INFO ---
  Future<AdvancedPregnancyInfo?> getAdvancedPregnancyInfo(String pregnancyRecordId) async {
    await _ensureLoaded();
    final c = client;
    if (c == null) {
      try {
        return _inMemoryAdvanced.firstWhere(
          (a) => a.pregnancyRecordId == pregnancyRecordId,
        );
      } catch (_) {
        return null;
      }
    }
    try {
      final data = await c
          .from('advanced_pregnancy_info')
          .select()
          .eq('pregnancy_record_id', pregnancyRecordId)
          .maybeSingle();
      if (data != null) {
        final saved = AdvancedPregnancyInfo.fromJson(data);
        final idx = _inMemoryAdvanced.indexWhere((a) => a.id == saved.id);
        if (idx >= 0) {
          _inMemoryAdvanced[idx] = saved;
        } else {
          _inMemoryAdvanced.add(saved);
        }
        await _persistAdvancedToLocalStorage();
        return saved;
      }
      try {
        return _inMemoryAdvanced.firstWhere((a) => a.pregnancyRecordId == pregnancyRecordId);
      } catch (_) {
        return null;
      }
    } catch (e) {
      debugPrint('Supabase getAdvancedPregnancyInfo error: $e');
      try {
        return _inMemoryAdvanced.firstWhere(
          (a) => a.pregnancyRecordId == pregnancyRecordId,
        );
      } catch (_) {
        return null;
      }
    }
  }

  Future<AdvancedPregnancyInfo> saveAdvancedPregnancyInfo(AdvancedPregnancyInfo info) async {
    await _ensureLoaded();
    final c = client;
    final validId = AppUuid.isValid(info.id) ? info.id : AppUuid.generate();
    final toSave = info.copyWith(id: validId);

    final index = _inMemoryAdvanced.indexWhere((a) => a.id == toSave.id || a.pregnancyRecordId == toSave.pregnancyRecordId);
    if (index >= 0) {
      _inMemoryAdvanced[index] = toSave;
    } else {
      _inMemoryAdvanced.add(toSave);
    }
    await _persistAdvancedToLocalStorage();

    if (c != null) {
      try {
        final data = await c.from('advanced_pregnancy_info').upsert(toSave.toJson()).select().maybeSingle();
        if (data != null) {
          final saved = AdvancedPregnancyInfo.fromJson(data);
          final idx = _inMemoryAdvanced.indexWhere((a) => a.id == saved.id);
          if (idx >= 0) {
            _inMemoryAdvanced[idx] = saved;
          } else {
            _inMemoryAdvanced.add(saved);
          }
          await _persistAdvancedToLocalStorage();
          return saved;
        }
      } catch (e) {
        debugPrint('Supabase saveAdvancedPregnancyInfo error: $e');
      }
    }

    return toSave;
  }
}
