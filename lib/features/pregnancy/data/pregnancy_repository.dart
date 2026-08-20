import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/utils/app_uuid.dart';
import '../domain/breeding_record.dart';
import '../domain/pregnancy_record.dart';
import '../domain/advanced_pregnancy_info.dart';
import '../domain/pregnancy_calculation_utils.dart';

class PregnancyRepository {
  final SupabaseClient? _supabase;
  final List<BreedingRecord> _mockBreeding = [];
  final List<PregnancyRecord> _mockPregnancies = [];
  final List<AdvancedPregnancyInfo> _mockAdvanced = [];

  PregnancyRepository({SupabaseClient? supabase}) : _supabase = supabase;

  SupabaseClient? get client {
    if (_supabase != null) return _supabase;
    try {
      return Supabase.instance.client;
    } catch (_) {
      return null;
    }
  }

  // --- BREEDING RECORDS ---
  Future<BreedingRecord> saveBreedingRecord(BreedingRecord record) async {
    final c = client;
    final user = c?.auth.currentUser;
    final accountId = user?.id ?? (AppUuid.isValid(record.accountId) ? record.accountId : AppUuid.generate());
    final validId = AppUuid.isValid(record.id) ? record.id : AppUuid.generate();
    final toSave = record.copyWith(id: validId, accountId: accountId);

    if (c != null && user != null) {
      try {
        final data = await c.from('breeding_records').upsert(toSave.toJson()).select();
        if (data is List && data.isNotEmpty) {
          return BreedingRecord.fromJson(data.first as Map<String, dynamic>);
        }
      } catch (e) {
        debugPrint('Supabase saveBreedingRecord error: $e');
        rethrow;
      }
    }

    final idx = _mockBreeding.indexWhere((b) => b.id == toSave.id);
    if (idx >= 0) {
      _mockBreeding[idx] = toSave;
    } else {
      _mockBreeding.insert(0, toSave);
    }
    return toSave;
  }

  Future<BreedingRecord?> getBreedingRecordById(String id) async {
    final c = client;
    final user = c?.auth.currentUser;

    if (c != null && user != null) {
      try {
        final data = await c.from('breeding_records').select().eq('account_id', user.id).eq('id', id).limit(1);
        if (data is List && data.isNotEmpty) {
          return BreedingRecord.fromJson(data.first as Map<String, dynamic>);
        }
        return null;
      } catch (e) {
        debugPrint('Supabase getBreedingRecordById error: $e');
        rethrow;
      }
    }

    try {
      return _mockBreeding.firstWhere((b) => b.id == id);
    } catch (_) {
      return null;
    }
  }

  Future<BreedingRecord?> getBreedingRecordByMare(String mareAnimalId) async {
    final c = client;
    final user = c?.auth.currentUser;

    if (c != null && user != null) {
      try {
        final data = await c
            .from('breeding_records')
            .select()
            .eq('account_id', user.id)
            .or('mare_animal_id.eq.$mareAnimalId,recipient_animal_id.eq.$mareAnimalId')
            .order('created_at', ascending: false)
            .limit(1);
        if (data is List && data.isNotEmpty) {
          return BreedingRecord.fromJson(data.first as Map<String, dynamic>);
        }
        return null;
      } catch (e) {
        debugPrint('Supabase getBreedingRecordByMare error: $e');
        rethrow;
      }
    }

    try {
      return _mockBreeding.firstWhere(
        (b) => b.mareAnimalId == mareAnimalId || b.recipientAnimalId == mareAnimalId,
      );
    } catch (_) {
      return null;
    }
  }

  // --- PREGNANCY RECORDS ---
  Future<PregnancyRecord?> getPregnancyRecordForCarrier(String carrierAnimalId) async {
    final c = client;
    final user = c?.auth.currentUser;

    if (c != null && user != null) {
      try {
        // 1. Check direct carrier match
        final data = await c
            .from('pregnancy_records')
            .select()
            .eq('account_id', user.id)
            .eq('carrier_animal_id', carrierAnimalId)
            .order('created_at', ascending: false)
            .limit(1);
        if (data is List && data.isNotEmpty) {
          return PregnancyRecord.fromJson(data.first as Map<String, dynamic>);
        }

        // 2. Check if this mare has a breeding record linked to an active pregnancy
        final breeding = await getBreedingRecordByMare(carrierAnimalId);
        if (breeding != null && AppUuid.isValid(breeding.id)) {
          final pregByBreeding = await c
              .from('pregnancy_records')
              .select()
              .eq('account_id', user.id)
              .eq('breeding_record_id', breeding.id)
              .order('created_at', ascending: false)
              .limit(1);
          if (pregByBreeding is List && pregByBreeding.isNotEmpty) {
            return PregnancyRecord.fromJson(pregByBreeding.first as Map<String, dynamic>);
          }
        }

        return null;
      } catch (e) {
        debugPrint('Supabase getPregnancyRecordForCarrier error: $e');
        rethrow;
      }
    }

    try {
      return _mockPregnancies.firstWhere((p) => p.carrierAnimalId == carrierAnimalId);
    } catch (_) {
      try {
        final b = _mockBreeding.firstWhere((b) => b.mareAnimalId == carrierAnimalId || b.recipientAnimalId == carrierAnimalId);
        return _mockPregnancies.firstWhere((p) => p.breedingRecordId == b.id);
      } catch (_) {
        return null;
      }
    }
  }

  Future<PregnancyRecord?> getPregnancyRecordById(String id) async {
    final c = client;
    final user = c?.auth.currentUser;

    if (c != null && user != null) {
      try {
        final data = await c.from('pregnancy_records').select().eq('account_id', user.id).eq('id', id).limit(1);
        if (data is List && data.isNotEmpty) {
          return PregnancyRecord.fromJson(data.first as Map<String, dynamic>);
        }
        return null;
      } catch (e) {
        debugPrint('Supabase getPregnancyRecordById error: $e');
        rethrow;
      }
    }

    try {
      return _mockPregnancies.firstWhere((p) => p.id == id);
    } catch (_) {
      return null;
    }
  }

  Future<PregnancyRecord> savePregnancyRecord(PregnancyRecord record) async {
    final c = client;
    final user = c?.auth.currentUser;
    final accountId = user?.id ?? (AppUuid.isValid(record.accountId) ? record.accountId : AppUuid.generate());
    final validId = AppUuid.isValid(record.id) ? record.id : AppUuid.generate();
    
    // Ensure breedingRecordId is a valid UUID pointing to a real breeding record
    String validBreedingId = record.breedingRecordId;
    if (!AppUuid.isValid(validBreedingId)) {
      final existingBreeding = await getBreedingRecordByMare(record.carrierAnimalId);
      if (existingBreeding != null && AppUuid.isValid(existingBreeding.id)) {
        validBreedingId = existingBreeding.id;
      } else {
        final autoBreeding = BreedingRecord(
          id: AppUuid.generate(),
          accountId: accountId,
          mareAnimalId: record.carrierAnimalId,
          method: 'natural',
          isEmbryoTransfer: false,
          coverOrTransferDate: DateTime.now().subtract(const Duration(days: 15)),
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
        final created = await saveBreedingRecord(autoBreeding);
        validBreedingId = created.id;
      }
    }

    final toSave = record.copyWith(
      id: validId,
      accountId: accountId,
      breedingRecordId: validBreedingId,
    );

    if (c != null && user != null) {
      try {
        final data = await c.from('pregnancy_records').upsert(toSave.toJson()).select();
        if (data is List && data.isNotEmpty) {
          return PregnancyRecord.fromJson(data.first as Map<String, dynamic>);
        }
      } catch (e) {
        debugPrint('Supabase savePregnancyRecord error: $e');
        rethrow;
      }
    }

    final idx = _mockPregnancies.indexWhere((p) => p.id == toSave.id || (p.carrierAnimalId.isNotEmpty && p.carrierAnimalId == toSave.carrierAnimalId));
    if (idx >= 0) {
      _mockPregnancies[idx] = toSave;
    } else {
      _mockPregnancies.insert(0, toSave);
    }
    return toSave;
  }

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
    final c = client;
    final user = c?.auth.currentUser;

    if (c != null && user != null) {
      try {
        await c.from('pregnancy_records').delete().eq('account_id', user.id).eq('id', id);
      } catch (e) {
        debugPrint('Supabase deletePregnancyRecord error: $e');
        rethrow;
      }
    }
    _mockPregnancies.removeWhere((p) => p.id == id);
    _mockAdvanced.removeWhere((a) => a.pregnancyRecordId == id);
  }

  Future<void> deleteBreedingRecord(String id) async {
    final c = client;
    final user = c?.auth.currentUser;

    if (c != null && user != null) {
      try {
        await c.from('breeding_records').delete().eq('account_id', user.id).eq('id', id);
      } catch (e) {
        debugPrint('Supabase deleteBreedingRecord error: $e');
        rethrow;
      }
    }
    _mockBreeding.removeWhere((b) => b.id == id);
  }

  // --- ADVANCED PREGNANCY INFO ---
  Future<AdvancedPregnancyInfo?> getAdvancedPregnancyInfo(String pregnancyRecordId) async {
    final c = client;

    if (c != null) {
      try {
        final data = await c
            .from('advanced_pregnancy_info')
            .select()
            .eq('pregnancy_record_id', pregnancyRecordId)
            .limit(1);
        if (data is List && data.isNotEmpty) {
          return AdvancedPregnancyInfo.fromJson(data.first as Map<String, dynamic>);
        }
        return null;
      } catch (e) {
        debugPrint('Supabase getAdvancedPregnancyInfo error: $e');
        rethrow;
      }
    }

    try {
      return _mockAdvanced.firstWhere((a) => a.pregnancyRecordId == pregnancyRecordId);
    } catch (_) {
      return null;
    }
  }

  Future<AdvancedPregnancyInfo> saveAdvancedPregnancyInfo(AdvancedPregnancyInfo info) async {
    final c = client;
    String validId = info.id;

    if (!AppUuid.isValid(validId)) {
      final existing = await getAdvancedPregnancyInfo(info.pregnancyRecordId);
      if (existing != null && AppUuid.isValid(existing.id)) {
        validId = existing.id;
      } else {
        validId = AppUuid.generate();
      }
    }

    final toSave = info.copyWith(id: validId);

    if (c != null) {
      try {
        final data = await c
            .from('advanced_pregnancy_info')
            .upsert(toSave.toJson(), onConflict: 'pregnancy_record_id')
            .select();
        if (data is List && data.isNotEmpty) {
          return AdvancedPregnancyInfo.fromJson(data.first as Map<String, dynamic>);
        }
      } catch (e) {
        debugPrint('Supabase saveAdvancedPregnancyInfo error: $e');
        rethrow;
      }
    }

    final idx = _mockAdvanced.indexWhere((a) => a.id == toSave.id || a.pregnancyRecordId == toSave.pregnancyRecordId);
    if (idx >= 0) {
      _mockAdvanced[idx] = toSave;
    } else {
      _mockAdvanced.insert(0, toSave);
    }
    return toSave;
  }
}
