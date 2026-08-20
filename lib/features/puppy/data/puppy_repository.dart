import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/utils/app_uuid.dart';
import '../domain/dog_preventative_care.dart';
import '../domain/puppy.dart';
import '../domain/puppy_weight.dart';

class PuppyRepository {
  final SupabaseClient? _supabase;
  final List<Puppy> _mockPuppies = [];
  final List<PuppyWeight> _mockWeights = [];
  final List<DogPreventativeCareItem> _mockCare = [];

  PuppyRepository({SupabaseClient? supabase}) : _supabase = supabase;

  SupabaseClient? get client {
    if (_supabase != null) return _supabase;
    try {
      return Supabase.instance.client;
    } catch (_) {
      return null;
    }
  }

  // --- PUPPY CRUD ---
  Future<List<Puppy>> getPuppies({String? damId}) async {
    final c = client;
    final user = c?.auth.currentUser;

    if (c != null && user != null) {
      try {
        var query = c.from('puppies').select().eq('account_id', user.id);
        if (damId != null && damId.isNotEmpty) {
          query = query.eq('dam_animal_id', damId);
        }
        final data = await query.order('created_at', ascending: false);
        if (data is List) {
          return data.map((json) => Puppy.fromJson(json as Map<String, dynamic>)).toList();
        }
      } catch (e) {
        debugPrint('Supabase getPuppies error: $e');
        rethrow;
      }
    }

    return _mockPuppies.where((p) {
      if (damId != null && damId.isNotEmpty) return p.damAnimalId == damId;
      return true;
    }).toList();
  }

  Future<Puppy?> getPuppyById(String id) async {
    final c = client;
    final user = c?.auth.currentUser;

    if (c != null && user != null) {
      try {
        final data = await c.from('puppies').select().eq('account_id', user.id).eq('id', id).limit(1);
        if (data is List && data.isNotEmpty) {
          return Puppy.fromJson(data.first as Map<String, dynamic>);
        }
        return null;
      } catch (e) {
        debugPrint('Supabase getPuppyById error: $e');
        rethrow;
      }
    }

    try {
      return _mockPuppies.firstWhere((p) => p.id == id);
    } catch (_) {
      return null;
    }
  }

  Future<Puppy> savePuppy(Puppy puppy) async {
    final c = client;
    final user = c?.auth.currentUser;
    final accountId = user?.id ?? (AppUuid.isValid(puppy.accountId) ? puppy.accountId : AppUuid.generate());
    final validId = AppUuid.isValid(puppy.id) ? puppy.id : AppUuid.generate();
    final toSave = puppy.copyWith(id: validId, accountId: accountId);

    if (c != null && user != null) {
      try {
        final data = await c.from('puppies').upsert(toSave.toJson()).select();
        if (data is List && data.isNotEmpty) {
          final saved = Puppy.fromJson(data.first as Map<String, dynamic>);
          final idx = _mockPuppies.indexWhere((p) => p.id == saved.id);
          if (idx >= 0) {
            _mockPuppies[idx] = saved;
          } else {
            _mockPuppies.insert(0, saved);
          }
          return saved;
        }
      } catch (e) {
        debugPrint('Supabase savePuppy error: $e');
        rethrow;
      }
    }

    final idx = _mockPuppies.indexWhere((p) => p.id == toSave.id);
    if (idx >= 0) {
      _mockPuppies[idx] = toSave;
    } else {
      _mockPuppies.insert(0, toSave);
    }
    return toSave;
  }

  Future<void> deletePuppy(String id) async {
    final c = client;
    final user = c?.auth.currentUser;

    if (c != null && user != null) {
      try {
        await c.from('puppies').delete().eq('account_id', user.id).eq('id', id);
      } catch (e) {
        debugPrint('Supabase deletePuppy error: $e');
        rethrow;
      }
    }
    _mockPuppies.removeWhere((p) => p.id == id);
    _mockWeights.removeWhere((w) => w.puppyId == id);
    _mockCare.removeWhere((care) => care.ownerId == id);
  }

  // --- PUPPY WEIGHT TRACKER ---
  Future<List<PuppyWeight>> getPuppyWeights(String puppyId) async {
    final c = client;

    if (c != null) {
      try {
        final data = await c.from('puppy_weights').select().eq('puppy_id', puppyId).order('weight_date', ascending: true);
        if (data is List) {
          return data.map((json) => PuppyWeight.fromJson(json as Map<String, dynamic>)).toList();
        }
      } catch (e) {
        debugPrint('Supabase getPuppyWeights error: $e');
        rethrow;
      }
    }

    final list = _mockWeights.where((w) => w.puppyId == puppyId).toList();
    list.sort((a, b) => a.weightDate.compareTo(b.weightDate));
    return list;
  }

  Future<PuppyWeight> savePuppyWeight(PuppyWeight weight) async {
    final c = client;
    final user = c?.auth.currentUser;
    final accountId = user?.id ?? (AppUuid.isValid(weight.accountId) ? weight.accountId : AppUuid.generate());
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

    if (c != null && user != null) {
      try {
        final data = await c.from('puppy_weights').upsert(toSave.toJson()).select();
        if (data is List && data.isNotEmpty) {
          return PuppyWeight.fromJson(data.first as Map<String, dynamic>);
        }
      } catch (e) {
        debugPrint('Supabase savePuppyWeight error: $e');
        rethrow;
      }
    }

    final idx = _mockWeights.indexWhere((w) => w.id == toSave.id);
    if (idx >= 0) {
      _mockWeights[idx] = toSave;
    } else {
      _mockWeights.insert(0, toSave);
    }
    return toSave;
  }

  Future<void> deletePuppyWeight(String id) async {
    final c = client;
    if (c != null) {
      try {
        await c.from('puppy_weights').delete().eq('id', id);
      } catch (e) {
        debugPrint('Supabase deletePuppyWeight error: $e');
        rethrow;
      }
    }
    _mockWeights.removeWhere((w) => w.id == id);
  }

  // --- DOG PREVENTATIVE CARE ---
  Future<List<DogPreventativeCareItem>> getDogPreventativeCare(String ownerType, String ownerId) async {
    final c = client;

    if (c != null) {
      try {
        final data = await c.from('dog_preventative_care')
            .select()
            .eq('owner_type', ownerType)
            .eq('owner_id', ownerId)
            .order('created_at', ascending: true);
        if (data is List) {
          return data.map((json) => DogPreventativeCareItem.fromJson(json as Map<String, dynamic>)).toList();
        }
      } catch (e) {
        debugPrint('Supabase getDogPreventativeCare error: $e');
        rethrow;
      }
    }

    return _mockCare.where((item) => item.ownerType == ownerType && item.ownerId == ownerId).toList();
  }

  Future<DogPreventativeCareItem> saveDogPreventativeCareItem(DogPreventativeCareItem item) async {
    final c = client;
    final user = c?.auth.currentUser;
    final accountId = user?.id ?? (AppUuid.isValid(item.accountId) ? item.accountId : AppUuid.generate());
    final validId = AppUuid.isValid(item.id) ? item.id : AppUuid.generate();
    final toSave = item.copyWith(id: validId, accountId: accountId);

    if (c != null && user != null) {
      try {
        final data = await c.from('dog_preventative_care').upsert(toSave.toJson()).select();
        if (data is List && data.isNotEmpty) {
          return DogPreventativeCareItem.fromJson(data.first as Map<String, dynamic>);
        }
      } catch (e) {
        debugPrint('Supabase saveDogPreventativeCareItem error: $e');
        rethrow;
      }
    }

    final idx = _mockCare.indexWhere((care) => care.id == toSave.id);
    if (idx >= 0) {
      _mockCare[idx] = toSave;
    } else {
      _mockCare.insert(0, toSave);
    }
    return toSave;
  }

  Future<void> deleteDogPreventativeCareItem(String id) async {
    final c = client;
    if (c != null) {
      try {
        await c.from('dog_preventative_care').delete().eq('id', id);
      } catch (e) {
        debugPrint('Supabase deleteDogPreventativeCareItem error: $e');
        rethrow;
      }
    }
    _mockCare.removeWhere((item) => item.id == id);
  }

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
