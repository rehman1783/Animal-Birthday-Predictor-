import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/utils/app_uuid.dart';
import '../domain/animal.dart';

class AnimalRepository {
  final SupabaseClient? _supabase;
  final List<Animal> _mockAnimals = [];

  AnimalRepository({SupabaseClient? supabase}) : _supabase = supabase;

  SupabaseClient? get client {
    if (_supabase != null) return _supabase;
    try {
      return Supabase.instance.client;
    } catch (_) {
      return null;
    }
  }

  Future<List<Animal>> getAnimals({String? species}) async {
    final c = client;
    final user = c?.auth.currentUser;

    if (c != null && user != null) {
      try {
        var query = c.from('animals').select().eq('account_id', user.id);
        if (species != null && species.isNotEmpty && species != 'all') {
          query = query.eq('species', species);
        }
        final data = await query.order('created_at', ascending: false);
        if (data is List) {
          return data.map((json) => Animal.fromJson(json as Map<String, dynamic>)).toList();
        }
      } catch (e) {
        debugPrint('Supabase getAnimals error: $e');
        rethrow;
      }
    }

    // Standalone mock fallback for unit tests
    return _mockAnimals.where((a) {
      if (species != null && species.isNotEmpty && species != 'all') {
        return Animal.matchesSpeciesFilter(a.species, species);
      }
      return true;
    }).toList();
  }

  Future<Animal?> getAnimalById(String id) async {
    final c = client;
    final user = c?.auth.currentUser;

    if (c != null && user != null) {
      try {
        final data = await c.from('animals').select().eq('account_id', user.id).eq('id', id).limit(1);
        if (data is List && data.isNotEmpty) {
          return Animal.fromJson(data.first as Map<String, dynamic>);
        }
        return null;
      } catch (e) {
        debugPrint('Supabase getAnimalById error: $e');
        rethrow;
      }
    }

    try {
      return _mockAnimals.firstWhere((a) => a.id == id);
    } catch (_) {
      return null;
    }
  }

  Future<Animal> saveAnimal(Animal animal) async {
    final c = client;
    final user = c?.auth.currentUser;
    final accountId = user?.id ?? (AppUuid.isValid(animal.accountId) ? animal.accountId : AppUuid.generate());
    final validId = AppUuid.isValid(animal.id) ? animal.id : AppUuid.generate();
    final normalizedSpecies = Animal.normalizeSpecies(animal.species);

    final toSave = animal.copyWith(
      id: validId,
      accountId: accountId,
      species: normalizedSpecies,
    );

    if (c != null && user != null) {
      try {
        final data = await c.from('animals').upsert(toSave.toJson()).select();
        if (data is List && data.isNotEmpty) {
          final saved = Animal.fromJson(data.first as Map<String, dynamic>);
          final idx = _mockAnimals.indexWhere((a) => a.id == saved.id);
          if (idx >= 0) {
            _mockAnimals[idx] = saved;
          } else {
            _mockAnimals.insert(0, saved);
          }
          return saved;
        }
      } catch (e) {
        debugPrint('Supabase saveAnimal error: $e');
        rethrow;
      }
    }

    // Mock storage for unit testing without network
    final idx = _mockAnimals.indexWhere((a) => a.id == toSave.id);
    if (idx >= 0) {
      _mockAnimals[idx] = toSave;
    } else {
      _mockAnimals.insert(0, toSave);
    }
    return toSave;
  }

  Future<void> deleteAnimal(String id) async {
    final c = client;
    final user = c?.auth.currentUser;

    if (c != null && user != null) {
      try {
        await c.from('animals').delete().eq('account_id', user.id).eq('id', id);
      } catch (e) {
        debugPrint('Supabase deleteAnimal error: $e');
        rethrow;
      }
    }

    _mockAnimals.removeWhere((a) => a.id == id);
  }
}
