import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/utils/app_uuid.dart';
import '../domain/dog_preventative_care.dart';
import '../domain/puppy.dart';
import '../domain/puppy_weight.dart';

class PuppyRepository {
  static const String _puppyStorageKey = 'abp_cached_puppies_records';
  static const String _weightsStorageKey = 'abp_cached_puppy_weights';
  static const String _careStorageKey = 'abp_cached_dog_care';

  final SupabaseClient? _supabase;
  final List<Puppy> _inMemoryPuppies = [];
  final List<PuppyWeight> _inMemoryWeights = [];
  final List<DogPreventativeCareItem> _inMemoryCare = [];
  bool _hasLoadedFromStorage = false;

  PuppyRepository({SupabaseClient? supabase})
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

      final puppyList = prefs.getStringList(_puppyStorageKey);
      if (puppyList != null && puppyList.isNotEmpty) {
        for (final item in puppyList) {
          try {
            final json = jsonDecode(item) as Map<String, dynamic>;
            final p = Puppy.fromJson(json);
            if (!_inMemoryPuppies.any((x) => x.id == p.id)) {
              _inMemoryPuppies.add(p);
            }
          } catch (e) {
            debugPrint('Error decoding puppy cache: $e');
          }
        }
      }

      final weightsList = prefs.getStringList(_weightsStorageKey);
      if (weightsList != null && weightsList.isNotEmpty) {
        for (final item in weightsList) {
          try {
            final json = jsonDecode(item) as Map<String, dynamic>;
            final w = PuppyWeight.fromJson(json);
            if (!_inMemoryWeights.any((x) => x.id == w.id)) {
              _inMemoryWeights.add(w);
            }
          } catch (e) {
            debugPrint('Error decoding puppy weight cache: $e');
          }
        }
      }

      final careList = prefs.getStringList(_careStorageKey);
      if (careList != null && careList.isNotEmpty) {
        for (final item in careList) {
          try {
            final json = jsonDecode(item) as Map<String, dynamic>;
            final c = DogPreventativeCareItem.fromJson(json);
            if (!_inMemoryCare.any((x) => x.id == c.id)) {
              _inMemoryCare.add(c);
            }
          } catch (e) {
            debugPrint('Error decoding dog care cache: $e');
          }
        }
      }
    } catch (e) {
      debugPrint('PuppyRepository: error reading local cache: $e');
    }
  }

  Future<void> _persistPuppiesToLocalStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final list = _inMemoryPuppies.map((p) => jsonEncode(p.toJson())).toList();
      await prefs.setStringList(_puppyStorageKey, list);
    } catch (e) {
      debugPrint('PuppyRepository: error persisting puppies: $e');
    }
  }

  Future<void> _persistWeightsToLocalStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final list = _inMemoryWeights.map((w) => jsonEncode(w.toJson())).toList();
      await prefs.setStringList(_weightsStorageKey, list);
    } catch (e) {
      debugPrint('PuppyRepository: error persisting weights: $e');
    }
  }

  Future<void> _persistCareToLocalStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final list = _inMemoryCare.map((c) => jsonEncode(c.toJson())).toList();
      await prefs.setStringList(_careStorageKey, list);
    } catch (e) {
      debugPrint('PuppyRepository: error persisting care: $e');
    }
  }

  // -------------------------------------------------------------
  // PUPPY CRUD
  // -------------------------------------------------------------
  Future<List<Puppy>> getPuppies({String? damId}) async {
    await _initLocalStorage();
    final c = client;
    if (c != null) {
      try {
        var query = c.from('puppies').select();
        if (damId != null && damId.isNotEmpty) {
          query = query.eq('dam_animal_id', damId);
        }
        final data = await query.order('created_at', ascending: false);
        if (data is List) {
          final list = data.map((json) => Puppy.fromJson(json as Map<String, dynamic>)).toList();
          for (final p in list) {
            final idx = _inMemoryPuppies.indexWhere((x) => x.id == p.id);
            if (idx >= 0) {
              _inMemoryPuppies[idx] = p;
            } else {
              _inMemoryPuppies.add(p);
            }
          }
          await _persistPuppiesToLocalStorage();
          return list;
        }
      } catch (e) {
        debugPrint('Supabase getPuppies error: $e');
      }
    }

    if (damId != null && damId.isNotEmpty) {
      return _inMemoryPuppies.where((p) => p.damAnimalId == damId).toList();
    }
    return List.unmodifiable(_inMemoryPuppies);
  }

  Future<Puppy?> getPuppyById(String id) async {
    await _initLocalStorage();
    final c = client;
    if (c != null) {
      try {
        final data = await c.from('puppies').select().eq('id', id).limit(1);
        if (data is List && data.isNotEmpty) {
          final saved = Puppy.fromJson(data.first as Map<String, dynamic>);
          final idx = _inMemoryPuppies.indexWhere((p) => p.id == saved.id);
          if (idx >= 0) {
            _inMemoryPuppies[idx] = saved;
          } else {
            _inMemoryPuppies.add(saved);
          }
          await _persistPuppiesToLocalStorage();
          return saved;
        }
      } catch (e) {
        debugPrint('Supabase getPuppyById error: $e');
      }
    }

    try {
      return _inMemoryPuppies.firstWhere((p) => p.id == id);
    } catch (_) {
      return null;
    }
  }

  Future<Puppy> savePuppy(Puppy puppy) async {
    await _initLocalStorage();
    final c = client;
    final user = c?.auth.currentUser;
    final accountId = user?.id ?? (AppUuid.isValid(puppy.accountId) ? puppy.accountId : '00000000-0000-0000-0000-000000000000');
    final validId = AppUuid.isValid(puppy.id) ? puppy.id : AppUuid.generate();
    final toSave = puppy.copyWith(id: validId, accountId: accountId);

    final index = _inMemoryPuppies.indexWhere((p) => p.id == toSave.id);
    if (index >= 0) {
      _inMemoryPuppies[index] = toSave;
    } else {
      _inMemoryPuppies.insert(0, toSave);
    }
    await _persistPuppiesToLocalStorage();

    if (c != null) {
      try {
        final data = await c.from('puppies').upsert(toSave.toJson()).select();
        if (data is List && data.isNotEmpty) {
          final saved = Puppy.fromJson(data.first as Map<String, dynamic>);
          final idx = _inMemoryPuppies.indexWhere((p) => p.id == saved.id);
          if (idx >= 0) {
            _inMemoryPuppies[idx] = saved;
          } else {
            _inMemoryPuppies.insert(0, saved);
          }
          await _persistPuppiesToLocalStorage();
          return saved;
        }
      } catch (e) {
        debugPrint('Supabase savePuppy error: $e');
      }
    }

    return toSave;
  }

  Future<void> deletePuppy(String id) async {
    await _initLocalStorage();
    final c = client;
    _inMemoryPuppies.removeWhere((p) => p.id == id);
    _inMemoryWeights.removeWhere((w) => w.puppyId == id);
    _inMemoryCare.removeWhere((care) => care.ownerId == id);
    await _persistPuppiesToLocalStorage();
    await _persistWeightsToLocalStorage();
    await _persistCareToLocalStorage();

    if (c != null) {
      try {
        await c.from('puppies').delete().eq('id', id);
      } catch (e) {
        debugPrint('Supabase deletePuppy error: $e');
      }
    }
  }

  // -------------------------------------------------------------
  // PUPPY WEIGHT TRACKER
  // -------------------------------------------------------------
  Future<List<PuppyWeight>> getPuppyWeights(String puppyId) async {
    await _initLocalStorage();
    final c = client;
    if (c != null) {
      try {
        final data = await c.from('puppy_weights').select().eq('puppy_id', puppyId).order('weight_date', ascending: true);
        if (data is List) {
          final list = data.map((json) => PuppyWeight.fromJson(json as Map<String, dynamic>)).toList();
          for (final w in list) {
            final idx = _inMemoryWeights.indexWhere((x) => x.id == w.id);
            if (idx >= 0) {
              _inMemoryWeights[idx] = w;
            } else {
              _inMemoryWeights.add(w);
            }
          }
          await _persistWeightsToLocalStorage();
          return list;
        }
      } catch (e) {
        debugPrint('Supabase getPuppyWeights error: $e');
      }
    }

    return _inMemoryWeights.where((w) => w.puppyId == puppyId).toList();
  }

  Future<PuppyWeight> savePuppyWeight(PuppyWeight weight) async {
    await _initLocalStorage();
    final c = client;
    final user = c?.auth.currentUser;
    final accountId = user?.id ?? (AppUuid.isValid(weight.accountId) ? weight.accountId : '00000000-0000-0000-0000-000000000000');
    final validId = AppUuid.isValid(weight.id) ? weight.id : AppUuid.generate();
    final toSave = PuppyWeight(
      id: validId,
      puppyId: weight.puppyId,
      accountId: accountId,
      weightDate: weight.weightDate,
      ageInDays: weight.ageInDays,
      weight: weight.weight,
      notes: weight.notes,
      createdAt: weight.createdAt,
    );

    final index = _inMemoryWeights.indexWhere((w) => w.id == toSave.id);
    if (index >= 0) {
      _inMemoryWeights[index] = toSave;
    } else {
      _inMemoryWeights.add(toSave);
    }
    await _persistWeightsToLocalStorage();

    if (c != null) {
      try {
        final data = await c.from('puppy_weights').upsert(toSave.toJson()).select();
        if (data is List && data.isNotEmpty) {
          final saved = PuppyWeight.fromJson(data.first as Map<String, dynamic>);
          final idx = _inMemoryWeights.indexWhere((w) => w.id == saved.id);
          if (idx >= 0) {
            _inMemoryWeights[idx] = saved;
          } else {
            _inMemoryWeights.add(saved);
          }
          await _persistWeightsToLocalStorage();
          return saved;
        }
      } catch (e) {
        debugPrint('Supabase savePuppyWeight error: $e');
      }
    }

    return toSave;
  }

  Future<void> deletePuppyWeight(String id) async {
    await _initLocalStorage();
    final c = client;
    _inMemoryWeights.removeWhere((w) => w.id == id);
    await _persistWeightsToLocalStorage();

    if (c != null) {
      try {
        await c.from('puppy_weights').delete().eq('id', id);
      } catch (e) {
        debugPrint('Supabase deletePuppyWeight error: $e');
      }
    }
  }

  // -------------------------------------------------------------
  // DOG / PUPPY PREVENTATIVE CARE (GIVEN + DUE PAIRS)
  // -------------------------------------------------------------
  Future<List<DogPreventativeCareItem>> getDogPreventativeCare(String ownerType, String ownerId) async {
    await _initLocalStorage();
    final c = client;
    if (c != null) {
      try {
        final data = await c.from('dog_preventative_care')
            .select()
            .eq('owner_type', ownerType)
            .eq('owner_id', ownerId)
            .order('created_at', ascending: true);
        if (data is List) {
          final list = data.map((json) => DogPreventativeCareItem.fromJson(json as Map<String, dynamic>)).toList();
          for (final item in list) {
            final idx = _inMemoryCare.indexWhere((x) => x.id == item.id);
            if (idx >= 0) {
              _inMemoryCare[idx] = item;
            } else {
              _inMemoryCare.add(item);
            }
          }
          await _persistCareToLocalStorage();
          return list;
        }
      } catch (e) {
        debugPrint('Supabase getDogPreventativeCare error: $e');
      }
    }

    return _inMemoryCare.where((item) => item.ownerType == ownerType && item.ownerId == ownerId).toList();
  }

  Future<DogPreventativeCareItem> saveDogPreventativeCareItem(DogPreventativeCareItem item) async {
    await _initLocalStorage();
    final c = client;
    final user = c?.auth.currentUser;
    final accountId = user?.id ?? (AppUuid.isValid(item.accountId) ? item.accountId : '00000000-0000-0000-0000-000000000000');
    final validId = AppUuid.isValid(item.id) ? item.id : AppUuid.generate();
    final toSave = item.copyWith(id: validId, accountId: accountId);

    final index = _inMemoryCare.indexWhere((c) => c.id == toSave.id);
    if (index >= 0) {
      _inMemoryCare[index] = toSave;
    } else {
      _inMemoryCare.add(toSave);
    }
    await _persistCareToLocalStorage();

    if (c != null) {
      try {
        final data = await c.from('dog_preventative_care').upsert(toSave.toJson()).select();
        if (data is List && data.isNotEmpty) {
          final saved = DogPreventativeCareItem.fromJson(data.first as Map<String, dynamic>);
          final idx = _inMemoryCare.indexWhere((c) => c.id == saved.id);
          if (idx >= 0) {
            _inMemoryCare[idx] = saved;
          } else {
            _inMemoryCare.add(saved);
          }
          await _persistCareToLocalStorage();
          return saved;
        }
      } catch (e) {
        debugPrint('Supabase saveDogPreventativeCareItem error: $e');
      }
    }

    return toSave;
  }

  Future<void> deleteDogPreventativeCareItem(String id) async {
    await _initLocalStorage();
    final c = client;
    _inMemoryCare.removeWhere((item) => item.id == id);
    await _persistCareToLocalStorage();

    if (c != null) {
      try {
        await c.from('dog_preventative_care').delete().eq('id', id);
      } catch (e) {
        debugPrint('Supabase deleteDogPreventativeCareItem error: $e');
      }
    }
  }

  /// Initializes default schedule if none exists yet for this puppy/dog
  Future<List<DogPreventativeCareItem>> initializeDefaultDogSchedule({
    required String ownerType,
    required String ownerId,
    DateTime? dateOfBirth,
  }) async {
    final existing = await getDogPreventativeCare(ownerType, ownerId);
    if (existing.isNotEmpty) return existing;

    final dob = dateOfBirth ?? DateTime.now();
    final List<({String type, String title, int dueDays})> defaults = [
      (type: 'worming', title: 'Worming (2 Weeks)', dueDays: 14),
      (type: 'worming', title: 'Worming (4 Weeks)', dueDays: 28),
      (type: 'worming', title: 'Worming (6 Weeks)', dueDays: 42),
      (type: 'worming', title: 'Worming (8 Weeks)', dueDays: 56),
      (type: 'worming', title: 'Worming (12 Weeks)', dueDays: 84),
      (type: 'vaccination', title: '1st Vaccination (C3/C5 - 6-8 Weeks)', dueDays: 42),
      (type: 'vaccination', title: '2nd Vaccination (C5 Booster - 10-12 Weeks)', dueDays: 77),
      (type: 'vaccination', title: '3rd Vaccination / Annual Booster', dueDays: 365),
      (type: 'vet_check', title: '6-Week Vet & Health Examination', dueDays: 42),
      (type: 'vet_check', title: '8-Week Pre-Departure Vet Check', dueDays: 56),
      (type: 'microchip', title: 'Microchipping & Registry Implantation', dueDays: 56),
    ];

    final List<DogPreventativeCareItem> created = [];
    for (final def in defaults) {
      final item = DogPreventativeCareItem(
        id: AppUuid.generate(),
        accountId: '',
        ownerType: ownerType,
        ownerId: ownerId,
        treatmentType: def.type,
        title: def.title,
        dateGiven: null,
        dateDue: dob.add(Duration(days: def.dueDays)),
        isCompleted: false,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      final saved = await saveDogPreventativeCareItem(item);
      created.add(saved);
    }
    return created;
  }
}
