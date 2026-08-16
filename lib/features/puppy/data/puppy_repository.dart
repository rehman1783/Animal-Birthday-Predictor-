import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/utils/app_uuid.dart';
import '../domain/dog_preventative_care.dart';
import '../domain/puppy.dart';
import '../domain/puppy_weight.dart';

class PuppyRepository {
  final SupabaseClient? _supabase;
  final List<Puppy> _inMemoryPuppies = [];
  final List<PuppyWeight> _inMemoryWeights = [];
  final List<DogPreventativeCareItem> _inMemoryCare = [];

  PuppyRepository({SupabaseClient? supabase})
      : _supabase = supabase ?? (kIsWeb || defaultTargetPlatform != TargetPlatform.windows ? null : Supabase.instance.client);

  SupabaseClient? get client {
    try {
      return _supabase ?? Supabase.instance.client;
    } catch (_) {
      return null;
    }
  }

  // -------------------------------------------------------------
  // PUPPY CRUD
  // -------------------------------------------------------------
  Future<List<Puppy>> getPuppies({String? damId}) async {
    final c = client;
    if (c == null) {
      if (damId != null && damId.isNotEmpty) {
        return _inMemoryPuppies.where((p) => p.damAnimalId == damId).toList();
      }
      return List.unmodifiable(_inMemoryPuppies);
    }
    try {
      var query = c.from('puppies').select();
      if (damId != null && damId.isNotEmpty) {
        query = query.eq('dam_animal_id', damId);
      }
      final data = await query.order('created_at', ascending: false);
      return (data as List).map((json) => Puppy.fromJson(json)).toList();
    } catch (e) {
      debugPrint('Supabase getPuppies error: $e');
      if (damId != null && damId.isNotEmpty) {
        return _inMemoryPuppies.where((p) => p.damAnimalId == damId).toList();
      }
      return List.unmodifiable(_inMemoryPuppies);
    }
  }

  Future<Puppy?> getPuppyById(String id) async {
    final c = client;
    if (c == null) {
      try {
        return _inMemoryPuppies.firstWhere((p) => p.id == id);
      } catch (_) {
        return null;
      }
    }
    try {
      final data = await c.from('puppies').select().eq('id', id).maybeSingle();
      if (data == null) return null;
      return Puppy.fromJson(data);
    } catch (e) {
      debugPrint('Supabase getPuppyById error: $e');
      return null;
    }
  }

  Future<Puppy> savePuppy(Puppy puppy) async {
    final c = client;
    final user = c?.auth.currentUser;
    final accountId = user?.id ?? (AppUuid.isValid(puppy.accountId) ? puppy.accountId : '00000000-0000-0000-0000-000000000000');
    final validId = AppUuid.isValid(puppy.id) ? puppy.id : AppUuid.generate();
    final toSave = puppy.copyWith(id: validId, accountId: accountId);

    if (c == null) {
      final index = _inMemoryPuppies.indexWhere((p) => p.id == toSave.id);
      if (index >= 0) {
        _inMemoryPuppies[index] = toSave;
      } else {
        _inMemoryPuppies.insert(0, toSave);
      }
      return toSave;
    }
    try {
      final data = await c.from('puppies').upsert(toSave.toJson()).select().single();
      final saved = Puppy.fromJson(data);
      final index = _inMemoryPuppies.indexWhere((p) => p.id == saved.id);
      if (index >= 0) {
        _inMemoryPuppies[index] = saved;
      } else {
        _inMemoryPuppies.insert(0, saved);
      }
      return saved;
    } catch (e) {
      debugPrint('Supabase savePuppy error: $e');
      final index = _inMemoryPuppies.indexWhere((p) => p.id == toSave.id);
      if (index >= 0) {
        _inMemoryPuppies[index] = toSave;
      } else {
        _inMemoryPuppies.insert(0, toSave);
      }
      return toSave;
    }
  }

  Future<void> deletePuppy(String id) async {
    final c = client;
    _inMemoryPuppies.removeWhere((p) => p.id == id);
    _inMemoryWeights.removeWhere((w) => w.puppyId == id);
    _inMemoryCare.removeWhere((care) => care.ownerId == id);

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
    final c = client;
    if (c == null) {
      return _inMemoryWeights.where((w) => w.puppyId == puppyId).toList();
    }
    try {
      final data = await c.from('puppy_weights').select().eq('puppy_id', puppyId).order('weight_date', ascending: true);
      return (data as List).map((json) => PuppyWeight.fromJson(json)).toList();
    } catch (e) {
      debugPrint('Supabase getPuppyWeights error: $e');
      return _inMemoryWeights.where((w) => w.puppyId == puppyId).toList();
    }
  }

  Future<PuppyWeight> savePuppyWeight(PuppyWeight weight) async {
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

    if (c == null) {
      final index = _inMemoryWeights.indexWhere((w) => w.id == toSave.id);
      if (index >= 0) {
        _inMemoryWeights[index] = toSave;
      } else {
        _inMemoryWeights.add(toSave);
      }
      return toSave;
    }
    try {
      final data = await c.from('puppy_weights').upsert(toSave.toJson()).select().single();
      final saved = PuppyWeight.fromJson(data);
      final index = _inMemoryWeights.indexWhere((w) => w.id == saved.id);
      if (index >= 0) {
        _inMemoryWeights[index] = saved;
      } else {
        _inMemoryWeights.add(saved);
      }
      return saved;
    } catch (e) {
      debugPrint('Supabase savePuppyWeight error: $e');
      final index = _inMemoryWeights.indexWhere((w) => w.id == toSave.id);
      if (index >= 0) {
        _inMemoryWeights[index] = toSave;
      } else {
        _inMemoryWeights.add(toSave);
      }
      return toSave;
    }
  }

  Future<void> deletePuppyWeight(String id) async {
    final c = client;
    _inMemoryWeights.removeWhere((w) => w.id == id);
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
    final c = client;
    if (c == null) {
      return _inMemoryCare.where((item) => item.ownerType == ownerType && item.ownerId == ownerId).toList();
    }
    try {
      final data = await c.from('dog_preventative_care')
          .select()
          .eq('owner_type', ownerType)
          .eq('owner_id', ownerId)
          .order('created_at', ascending: true);
      return (data as List).map((json) => DogPreventativeCareItem.fromJson(json)).toList();
    } catch (e) {
      debugPrint('Supabase getDogPreventativeCare error: $e');
      return _inMemoryCare.where((item) => item.ownerType == ownerType && item.ownerId == ownerId).toList();
    }
  }

  Future<DogPreventativeCareItem> saveDogPreventativeCareItem(DogPreventativeCareItem item) async {
    final c = client;
    final user = c?.auth.currentUser;
    final accountId = user?.id ?? (AppUuid.isValid(item.accountId) ? item.accountId : '00000000-0000-0000-0000-000000000000');
    final validId = AppUuid.isValid(item.id) ? item.id : AppUuid.generate();
    final toSave = item.copyWith(id: validId, accountId: accountId);

    if (c == null) {
      final index = _inMemoryCare.indexWhere((c) => c.id == toSave.id);
      if (index >= 0) {
        _inMemoryCare[index] = toSave;
      } else {
        _inMemoryCare.add(toSave);
      }
      return toSave;
    }
    try {
      final data = await c.from('dog_preventative_care').upsert(toSave.toJson()).select().single();
      final saved = DogPreventativeCareItem.fromJson(data);
      final index = _inMemoryCare.indexWhere((c) => c.id == saved.id);
      if (index >= 0) {
        _inMemoryCare[index] = saved;
      } else {
        _inMemoryCare.add(saved);
      }
      return saved;
    } catch (e) {
      debugPrint('Supabase saveDogPreventativeCareItem error: $e');
      final index = _inMemoryCare.indexWhere((c) => c.id == toSave.id);
      if (index >= 0) {
        _inMemoryCare[index] = toSave;
      } else {
        _inMemoryCare.add(toSave);
      }
      return toSave;
    }
  }

  Future<void> deleteDogPreventativeCareItem(String id) async {
    final c = client;
    _inMemoryCare.removeWhere((item) => item.id == id);
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
