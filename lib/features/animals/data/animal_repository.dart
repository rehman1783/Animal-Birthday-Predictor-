import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../domain/animal.dart';

class AnimalRepository {
  final SupabaseClient? _supabase;
  final List<Animal> _inMemoryAnimals = [];

  AnimalRepository({SupabaseClient? supabase})
      : _supabase = supabase ?? (kIsWeb || defaultTargetPlatform != TargetPlatform.windows ? null : Supabase.instance.client);

  SupabaseClient? get client {
    try {
      return _supabase ?? Supabase.instance.client;
    } catch (_) {
      return null;
    }
  }

  Future<List<Animal>> getAnimals({String? species}) async {
    final c = client;
    if (c == null) {
      if (species != null && species.isNotEmpty) {
        return _inMemoryAnimals.where((a) => a.species.toLowerCase() == species.toLowerCase()).toList();
      }
      return List.unmodifiable(_inMemoryAnimals);
    }
    try {
      var query = c.from('animals').select();
      if (species != null && species.isNotEmpty) {
        query = query.eq('species', species);
      }
      final data = await query.order('created_at', ascending: false);
      return (data as List).map((json) => Animal.fromJson(json)).toList();
    } catch (e) {
      debugPrint('Supabase getAnimals error: $e');
      if (species != null && species.isNotEmpty) {
        return _inMemoryAnimals.where((a) => a.species.toLowerCase() == species.toLowerCase()).toList();
      }
      return List.unmodifiable(_inMemoryAnimals);
    }
  }

  Future<Animal?> getAnimalById(String id) async {
    final c = client;
    if (c == null) {
      try {
        return _inMemoryAnimals.firstWhere((a) => a.id == id);
      } catch (_) {
        return null;
      }
    }
    try {
      final data = await c.from('animals').select().eq('id', id).maybeSingle();
      if (data == null) return null;
      return Animal.fromJson(data);
    } catch (e) {
      debugPrint('Supabase getAnimalById error: $e');
      return null;
    }
  }

  Future<Animal> saveAnimal(Animal animal) async {
    final c = client;
    final user = c?.auth.currentUser;
    final accountId = user?.id ?? (animal.accountId.isNotEmpty ? animal.accountId : '00000000-0000-0000-0000-000000000000');
    final toSave = animal.copyWith(accountId: accountId);

    if (c == null) {
      final index = _inMemoryAnimals.indexWhere((a) => a.id == toSave.id);
      if (index >= 0) {
        _inMemoryAnimals[index] = toSave;
      } else {
        _inMemoryAnimals.insert(0, toSave);
      }
      return toSave;
    }
    try {
      final data = await c.from('animals').upsert(toSave.toJson()).select().single();
      final saved = Animal.fromJson(data);
      final index = _inMemoryAnimals.indexWhere((a) => a.id == saved.id);
      if (index >= 0) {
        _inMemoryAnimals[index] = saved;
      } else {
        _inMemoryAnimals.insert(0, saved);
      }
      return saved;
    } catch (e) {
      debugPrint('Supabase saveAnimal error: $e');
      final index = _inMemoryAnimals.indexWhere((a) => a.id == toSave.id);
      if (index >= 0) {
        _inMemoryAnimals[index] = toSave;
      } else {
        _inMemoryAnimals.insert(0, toSave);
      }
      return toSave;
    }
  }

  Future<void> deleteAnimal(String id) async {
    final c = client;
    _inMemoryAnimals.removeWhere((a) => a.id == id);
    if (c != null) {
      try {
        await c.from('animals').delete().eq('id', id);
      } catch (e) {
        debugPrint('Supabase deleteAnimal error: $e');
      }
    }
  }
}
