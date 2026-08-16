import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../domain/breeding_record.dart';
import '../domain/pregnancy_record.dart';
import '../domain/advanced_pregnancy_info.dart';
import '../domain/pregnancy_calculation_utils.dart';

class PregnancyRepository {
  final SupabaseClient? _supabase;
  final List<BreedingRecord> _inMemoryBreeding = [];
  final List<PregnancyRecord> _inMemoryPregnancies = [];
  final List<AdvancedPregnancyInfo> _inMemoryAdvanced = [];

  PregnancyRepository({SupabaseClient? supabase})
      : _supabase = supabase ?? (kIsWeb || defaultTargetPlatform != TargetPlatform.windows ? null : Supabase.instance.client);

  SupabaseClient? get client {
    try {
      return _supabase ?? Supabase.instance.client;
    } catch (_) {
      return null;
    }
  }

  // --- BREEDING RECORDS ---
  Future<BreedingRecord> saveBreedingRecord(BreedingRecord record) async {
    final c = client;
    final user = c?.auth.currentUser;
    final accountId = user?.id ?? (record.accountId.isNotEmpty ? record.accountId : '00000000-0000-0000-0000-000000000000');
    final toSave = record.copyWith(accountId: accountId);

    if (c == null) {
      final index = _inMemoryBreeding.indexWhere((b) => b.id == toSave.id);
      if (index >= 0) {
        _inMemoryBreeding[index] = toSave;
      } else {
        _inMemoryBreeding.insert(0, toSave);
      }
      return toSave;
    }
    try {
      final data = await c.from('breeding_records').upsert(toSave.toJson()).select().single();
      return BreedingRecord.fromJson(data);
    } catch (e) {
      debugPrint('Supabase saveBreedingRecord error: $e');
      final index = _inMemoryBreeding.indexWhere((b) => b.id == toSave.id);
      if (index >= 0) {
        _inMemoryBreeding[index] = toSave;
      } else {
        _inMemoryBreeding.insert(0, toSave);
      }
      return toSave;
    }
  }

  Future<BreedingRecord?> getBreedingRecordById(String id) async {
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
      if (data == null) return null;
      return BreedingRecord.fromJson(data);
    } catch (e) {
      debugPrint('Supabase getBreedingRecordById error: $e');
      return null;
    }
  }

  // --- PREGNANCY RECORDS ---
  Future<PregnancyRecord?> getPregnancyRecordForCarrier(String carrierAnimalId) async {
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
      if (data == null) return null;
      return PregnancyRecord.fromJson(data);
    } catch (e) {
      debugPrint('Supabase getPregnancyRecordForCarrier error: $e');
      return null;
    }
  }

  Future<PregnancyRecord?> getPregnancyRecordById(String id) async {
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
      if (data == null) return null;
      return PregnancyRecord.fromJson(data);
    } catch (e) {
      debugPrint('Supabase getPregnancyRecordById error: $e');
      return null;
    }
  }

  Future<PregnancyRecord> savePregnancyRecord(PregnancyRecord record) async {
    final c = client;
    final user = c?.auth.currentUser;
    final accountId = user?.id ?? (record.accountId.isNotEmpty ? record.accountId : '00000000-0000-0000-0000-000000000000');
    final toSave = record.copyWith(accountId: accountId);

    if (c == null) {
      final index = _inMemoryPregnancies.indexWhere((p) => p.id == toSave.id);
      if (index >= 0) {
        _inMemoryPregnancies[index] = toSave;
      } else {
        _inMemoryPregnancies.insert(0, toSave);
      }
      return toSave;
    }
    try {
      final data = await c.from('pregnancy_records').upsert(toSave.toJson()).select().single();
      return PregnancyRecord.fromJson(data);
    } catch (e) {
      debugPrint('Supabase savePregnancyRecord error: $e');
      final index = _inMemoryPregnancies.indexWhere((p) => p.id == toSave.id);
      if (index >= 0) {
        _inMemoryPregnancies[index] = toSave;
      } else {
        _inMemoryPregnancies.insert(0, toSave);
      }
      return toSave;
    }
  }

  /// Create and store a calculated pregnancy record for a carrier
  Future<PregnancyRecord> createCalculatedPregnancyRecord({
    required String carrierAnimalId,
    required String breedingRecordId,
    required String method,
    required bool isEmbryoTransfer,
    required DateTime baseDate,
  }) async {
    final calculated = calculatePregnancyDates(
      isEmbryoTransfer: isEmbryoTransfer,
      method: method,
      baseDate: baseDate,
    );

    final record = PregnancyRecord(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      accountId: '',
      breedingRecordId: breedingRecordId,
      carrierAnimalId: carrierAnimalId,
      scan1DueDate: calculated.scan1DueDate,
      scan1Confirmed: false,
      scan2DueDate: calculated.scan2DueDate,
      scan2Confirmed: false,
      scan3DueDate: calculated.scan3DueDate,
      scan3Confirmed: false,
      foalingDueDate: calculated.foalingDueDate,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    return savePregnancyRecord(record);
  }

  // --- ADVANCED PREGNANCY INFO ---
  Future<AdvancedPregnancyInfo?> getAdvancedPregnancyInfo(String pregnancyRecordId) async {
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
      if (data == null) return null;
      return AdvancedPregnancyInfo.fromJson(data);
    } catch (e) {
      debugPrint('Supabase getAdvancedPregnancyInfo error: $e');
      return null;
    }
  }

  Future<AdvancedPregnancyInfo> saveAdvancedPregnancyInfo(AdvancedPregnancyInfo info) async {
    final c = client;
    if (c == null) {
      final index = _inMemoryAdvanced.indexWhere((a) => a.id == info.id || a.pregnancyRecordId == info.pregnancyRecordId);
      if (index >= 0) {
        _inMemoryAdvanced[index] = info;
      } else {
        _inMemoryAdvanced.add(info);
      }
      return info;
    }
    try {
      final data = await c.from('advanced_pregnancy_info').upsert(info.toJson()).select().single();
      return AdvancedPregnancyInfo.fromJson(data);
    } catch (e) {
      debugPrint('Supabase saveAdvancedPregnancyInfo error: $e');
      return info;
    }
  }
}
