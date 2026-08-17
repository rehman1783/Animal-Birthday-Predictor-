import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/utils/app_uuid.dart';
import '../domain/foal_record.dart';

class FoalRepository {
  static const String _storageKey = 'abp_cached_foal_records';
  final SupabaseClient? _supabase;
  final List<FoalRecord> _inMemoryFoals = [];
  bool _hasLoadedFromStorage = false;

  FoalRepository({SupabaseClient? supabase})
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
      final list = prefs.getStringList(_storageKey);
      if (list != null && list.isNotEmpty) {
        for (final str in list) {
          try {
            final map = jsonDecode(str) as Map<String, dynamic>;
            final foal = FoalRecord.fromJson(map);
            if (!_inMemoryFoals.any((f) => f.id == foal.id)) {
              _inMemoryFoals.add(foal);
            }
          } catch (e) {
            debugPrint('Error decoding cached foal: $e');
          }
        }
      }
    } catch (e) {
      debugPrint('Error loading cached foals from SharedPreferences: $e');
    }
  }

  Future<void> _persistToLocalStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonList = _inMemoryFoals.map((f) => jsonEncode(f.toJson())).toList();
      await prefs.setStringList(_storageKey, jsonList);
    } catch (e) {
      debugPrint('Error saving cached foals to SharedPreferences: $e');
    }
  }

  Future<List<FoalRecord>> getFoals() async {
    await _ensureLoaded();
    final c = client;
    if (c == null) return List.unmodifiable(_inMemoryFoals);

    try {
      final data = await c.from('foals').select().order('created_at', ascending: false);
      if (data is List) {
        final List<FoalRecord> remoteFoals = [];
        for (final item in data) {
          try {
            if (item is Map<String, dynamic>) {
              remoteFoals.add(FoalRecord.fromJson(item));
            } else if (item is Map) {
              remoteFoals.add(FoalRecord.fromJson(Map<String, dynamic>.from(item)));
            }
          } catch (e) {
            debugPrint('Error parsing remote foal item: $e');
          }
        }

        // Merge remote items into in-memory list
        for (final remote in remoteFoals) {
          final idx = _inMemoryFoals.indexWhere((f) => f.id == remote.id);
          if (idx >= 0) {
            _inMemoryFoals[idx] = remote;
          } else {
            _inMemoryFoals.add(remote);
          }
        }

        await _persistToLocalStorage();
        return List.unmodifiable(_inMemoryFoals);
      }
      return List.unmodifiable(_inMemoryFoals);
    } catch (e) {
      debugPrint('Supabase getFoals error: $e');
      return List.unmodifiable(_inMemoryFoals);
    }
  }

  Future<FoalRecord?> getFoalById(String id) async {
    await _ensureLoaded();
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
      if (data == null) {
        try {
          return _inMemoryFoals.firstWhere((f) => f.id == id);
        } catch (_) {
          return null;
        }
      }
      final foal = FoalRecord.fromJson(data);
      _updateLocalFoals(foal);
      return foal;
    } catch (e) {
      debugPrint('Supabase getFoalById error: $e');
      try {
        return _inMemoryFoals.firstWhere((f) => f.id == id);
      } catch (_) {
        return null;
      }
    }
  }

  void _updateLocalFoals(FoalRecord foal) {
    final idx = _inMemoryFoals.indexWhere((f) => f.id == foal.id);
    if (idx >= 0) {
      _inMemoryFoals[idx] = foal;
    } else {
      _inMemoryFoals.insert(0, foal);
    }
  }

  Future<FoalRecord> saveFoal(FoalRecord foal) async {
    await _ensureLoaded();
    final c = client;
    final user = c?.auth.currentUser;
    final accountId = user != null
        ? user.id
        : (AppUuid.isValid(foal.accountId) ? foal.accountId : '00000000-0000-0000-0000-000000000000');
    final validId = AppUuid.isValid(foal.id) ? foal.id : AppUuid.generate();
    final mareId = AppUuid.isValid(foal.mareAnimalId) ? foal.mareAnimalId : AppUuid.generate();
    final recipientId = (foal.recipientAnimalId != null && AppUuid.isValid(foal.recipientAnimalId!))
        ? foal.recipientAnimalId
        : null;

    final toSave = foal.copyWith(
      id: validId,
      accountId: accountId,
      mareAnimalId: mareId,
      recipientAnimalId: recipientId,
    );

    // Save locally first immediately
    _updateLocalFoals(toSave);
    await _persistToLocalStorage();

    if (c != null) {
      // Build primary modern payload
      final primaryPayload = <String, dynamic>{
        'id': validId,
        'account_id': accountId,
        'mare_animal_id': mareId,
        if (recipientId != null) 'recipient_animal_id': recipientId,
        if (toSave.foalName != null) 'foal_name': toSave.foalName,
        if (toSave.dateOfBirth != null) 'date_of_birth': toSave.dateOfBirth!.toIso8601String().split('T').first,
        if (toSave.stallion != null) 'stallion': toSave.stallion,
        if (toSave.breed != null) 'breed': toSave.breed,
        if (toSave.sex != null) 'sex': toSave.sex,
        if (toSave.iggValue != null) 'igg_value': toSave.iggValue,
        if (toSave.foalMicrochipNo != null) 'foal_microchip_no': toSave.foalMicrochipNo,
        if (toSave.dna != null) 'dna': toSave.dna,
        'gelded': toSave.gelded,
        if (toSave.geldedDate != null) 'gelded_date': toSave.geldedDate!.toIso8601String().split('T').first,
        if (toSave.studBookAssociation != null) 'stud_book_association': toSave.studBookAssociation,
        if (toSave.notes != null) 'notes': toSave.notes,
        if (toSave.status != null) 'status': toSave.status,
        if (toSave.photoUrl != null) 'photo_url': toSave.photoUrl,
        if (toSave.buyerName != null) 'buyer_name': toSave.buyerName,
        'created_at': toSave.createdAt.toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      };

      try {
        final data = await c.from('foals').upsert(primaryPayload).select().maybeSingle();
        if (data != null) {
          final saved = FoalRecord.fromJson(data);
          _updateLocalFoals(saved);
          await _persistToLocalStorage();
          return saved;
        }
      } catch (e1) {
        debugPrint('Supabase primary saveFoal error: $e1. Trying legacy fallback...');

        // Fallback 1: Column name compatibility for mare_id / recipient_mare_id
        try {
          final legacyPayload = Map<String, dynamic>.from(primaryPayload)
            ..remove('mare_animal_id')
            ..remove('recipient_animal_id')
            ..['mare_id'] = mareId;
          if (recipientId != null) legacyPayload['recipient_mare_id'] = recipientId;

          final data = await c.from('foals').upsert(legacyPayload).select().maybeSingle();
          if (data != null) {
            final saved = FoalRecord.fromJson(data);
            _updateLocalFoals(saved);
            await _persistToLocalStorage();
            return saved;
          }
        } catch (e2) {
          debugPrint('Supabase legacy column fallback error: $e2. Trying minimal fallback...');

          // Fallback 2: Minimal columns without buyer_name if column not in schema
          try {
            final minPayload = Map<String, dynamic>.from(primaryPayload)..remove('buyer_name');
            final data = await c.from('foals').upsert(minPayload).select().maybeSingle();
            if (data != null) {
              final saved = FoalRecord.fromJson(data).copyWith(buyerName: toSave.buyerName);
              _updateLocalFoals(saved);
              await _persistToLocalStorage();
              return saved;
            }
          } catch (e3) {
            debugPrint('Supabase minimal fallback error: $e3. Retaining local copy.');
          }
        }
      }
    }

    return toSave;
  }

  Future<void> deleteFoal(String id) async {
    await _ensureLoaded();
    _inMemoryFoals.removeWhere((f) => f.id == id);
    await _persistToLocalStorage();

    final c = client;
    if (c != null) {
      try {
        await c.from('foals').delete().eq('id', id);
      } catch (e) {
        debugPrint('Supabase deleteFoal error: $e');
      }
    }
  }
}
