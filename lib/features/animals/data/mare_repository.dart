import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/utils/app_uuid.dart';
import '../domain/animal.dart';
import '../domain/mare.dart';
import '../domain/markings.dart';

class MareRepository {
  final SupabaseClient? _supabase;
  final List<Mare> _inMemoryMares = [];
  final List<Markings> _inMemoryMarkings = [];

  MareRepository({SupabaseClient? supabase})
      : _supabase = supabase ?? (kIsWeb || defaultTargetPlatform != TargetPlatform.windows ? null : Supabase.instance.client);

  SupabaseClient? get client {
    try {
      return _supabase ?? Supabase.instance.client;
    } catch (_) {
      return null;
    }
  }

  // --- ANIMALS / MARES (reads from unified animals table) ---
  Future<List<Animal>> getMares() async {
    final c = client;
    if (c == null) {
      return _inMemoryMares.map((m) => Animal(
        id: m.id,
        accountId: m.accountId,
        species: 'horse',
        name: m.name,
        breed: m.breed,
        brand: m.brand,
        dna: m.dna,
        microchipNo: m.microchipNo,
        ownerClientName: m.ownerClientName,
        ownerClientPhone: m.ownerClientPhone,
        photoUrl: m.photoUrl,
        createdAt: m.createdAt,
        updatedAt: m.updatedAt,
      )).toList();
    }
    try {
      final data = await c.from('animals').select().eq('species', 'horse').order('created_at', ascending: false);
      return (data as List).map((json) => Animal.fromJson(json)).toList();
    } catch (e) {
      debugPrint('Supabase getMares error: $e');
      return [];
    }
  }

  Future<Animal> saveMare(Animal animal) async {
    final c = client;
    final user = c?.auth.currentUser;
    final accountId = user?.id ?? (AppUuid.isValid(animal.accountId) ? animal.accountId : '00000000-0000-0000-0000-000000000000');
    final validId = AppUuid.isValid(animal.id) ? animal.id : AppUuid.generate();
    final toSave = animal.copyWith(id: validId, accountId: accountId, species: 'horse');

    if (c == null) {
      final index = _inMemoryMares.indexWhere((m) => m.id == toSave.id);
      final mare = Mare(
        id: toSave.id,
        accountId: toSave.accountId,
        name: toSave.name,
        breed: toSave.breed,
        brand: toSave.brand,
        dna: toSave.dna,
        microchipNo: toSave.microchipNo,
        ownerClientName: toSave.ownerClientName,
        ownerClientPhone: toSave.ownerClientPhone,
        photoUrl: toSave.photoUrl,
        createdAt: toSave.createdAt,
        updatedAt: toSave.updatedAt,
      );
      if (index >= 0) {
        _inMemoryMares[index] = mare;
      } else {
        _inMemoryMares.insert(0, mare);
      }
      return toSave;
    }
    try {
      final data = await c.from('animals').upsert(toSave.toJson()).select().single();
      return Animal.fromJson(data);
    } catch (e) {
      debugPrint('Supabase saveMare error: $e');
      return toSave;
    }
  }

  // --- MARKINGS ---
  Future<Markings?> getMarkings(String ownerType, String ownerId) async {
    final c = client;
    if (c == null) {
      try {
        return _inMemoryMarkings.firstWhere(
          (m) => m.ownerType == ownerType && m.ownerId == ownerId,
        );
      } catch (_) {
        return null;
      }
    }
    try {
      final data = await c
          .from('markings')
          .select()
          .eq('owner_type', ownerType)
          .eq('owner_id', ownerId)
          .maybeSingle();
      if (data == null) return null;
      return Markings.fromJson(data);
    } catch (e) {
      debugPrint('Supabase getMarkings error: $e');
      return null;
    }
  }

  Future<Markings> saveMarkings(Markings markings) async {
    final c = client;
    final validId = AppUuid.isValid(markings.id) ? markings.id : AppUuid.generate();
    final toSave = markings.copyWith(id: validId);

    if (c == null) {
      final index = _inMemoryMarkings.indexWhere(
        (m) => m.ownerType == toSave.ownerType && m.ownerId == toSave.ownerId,
      );
      if (index >= 0) {
        _inMemoryMarkings[index] = toSave;
      } else {
        _inMemoryMarkings.add(toSave);
      }
      return toSave;
    }
    try {
      final data = await c.from('markings').upsert(toSave.toJson()).select().single();
      return Markings.fromJson(data);
    } catch (e) {
      debugPrint('Supabase saveMarkings error: $e');
      return toSave;
    }
  }
}
