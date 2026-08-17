import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/utils/app_uuid.dart';
import '../domain/animal.dart';

class AnimalRepository {
  static const String _storageKey = 'abp_cached_animal_records';
  final SupabaseClient? _supabase;
  final List<Animal> _inMemoryAnimals = [];
  bool _hasLoadedFromStorage = false;

  AnimalRepository({SupabaseClient? supabase})
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
            final animal = Animal.fromJson(map);
            if (!_inMemoryAnimals.any((a) => a.id == animal.id)) {
              _inMemoryAnimals.add(animal);
            }
          } catch (e) {
            debugPrint('Error decoding cached animal: $e');
          }
        }
      }
    } catch (e) {
      debugPrint('Error loading cached animals from SharedPreferences: $e');
    }
  }

  Future<void> _persistToLocalStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonList = _inMemoryAnimals.map((a) => jsonEncode(a.toJson())).toList();
      await prefs.setStringList(_storageKey, jsonList);
    } catch (e) {
      debugPrint('Error saving cached animals to SharedPreferences: $e');
    }
  }

  void _updateLocalAnimals(Animal animal) {
    final idx = _inMemoryAnimals.indexWhere((a) => a.id == animal.id);
    if (idx >= 0) {
      _inMemoryAnimals[idx] = animal;
    } else {
      _inMemoryAnimals.insert(0, animal);
    }
  }

  Future<List<Animal>> getAnimals({String? species}) async {
    await _ensureLoaded();
    final c = client;

    if (c == null) {
      if (species != null && species.isNotEmpty) {
        return _inMemoryAnimals.where((a) => Animal.matchesSpeciesFilter(a.species, species)).toList();
      }
      return List.unmodifiable(_inMemoryAnimals);
    }

    try {
      final data = await c.from('animals').select().order('created_at', ascending: false);
      if (data is List) {
        final List<Animal> remoteList = [];
        for (final item in data) {
          try {
            if (item is Map<String, dynamic>) {
              remoteList.add(Animal.fromJson(item));
            } else if (item is Map) {
              remoteList.add(Animal.fromJson(Map<String, dynamic>.from(item)));
            }
          } catch (e) {
            debugPrint('Error parsing remote animal item: $e');
          }
        }

        // Merge remote items with local
        for (final remote in remoteList) {
          final idx = _inMemoryAnimals.indexWhere((a) => a.id == remote.id);
          if (idx >= 0) {
            _inMemoryAnimals[idx] = remote;
          } else {
            _inMemoryAnimals.add(remote);
          }
        }

        await _persistToLocalStorage();
      }

      if (species != null && species.isNotEmpty) {
        return _inMemoryAnimals.where((a) => Animal.matchesSpeciesFilter(a.species, species)).toList();
      }
      return List.unmodifiable(_inMemoryAnimals);
    } catch (e) {
      debugPrint('Supabase getAnimals error: $e');
      if (species != null && species.isNotEmpty) {
        return _inMemoryAnimals.where((a) => Animal.matchesSpeciesFilter(a.species, species)).toList();
      }
      return List.unmodifiable(_inMemoryAnimals);
    }
  }

  Future<Animal?> getAnimalById(String id) async {
    await _ensureLoaded();
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
      if (data == null) {
        try {
          return _inMemoryAnimals.firstWhere((a) => a.id == id);
        } catch (_) {
          return null;
        }
      }
      final animal = Animal.fromJson(data);
      _updateLocalAnimals(animal);
      return animal;
    } catch (e) {
      debugPrint('Supabase getAnimalById error: $e');
      try {
        return _inMemoryAnimals.firstWhere((a) => a.id == id);
      } catch (_) {
        return null;
      }
    }
  }

  Future<Animal> saveAnimal(Animal animal) async {
    await _ensureLoaded();
    final c = client;
    final user = c?.auth.currentUser;
    final accountId = user != null
        ? user.id
        : (AppUuid.isValid(animal.accountId) ? animal.accountId : '00000000-0000-0000-0000-000000000000');
    final validId = AppUuid.isValid(animal.id) ? animal.id : AppUuid.generate();
    final normalizedSpecies = Animal.normalizeSpecies(animal.species);

    final toSave = animal.copyWith(
      id: validId,
      accountId: accountId,
      species: normalizedSpecies,
    );

    // Save locally immediately
    _updateLocalAnimals(toSave);
    await _persistToLocalStorage();

    if (c != null) {
      try {
        final data = await c.from('animals').upsert(toSave.toJson()).select().maybeSingle();
        if (data != null) {
          final saved = Animal.fromJson(data);
          _updateLocalAnimals(saved);
          await _persistToLocalStorage();
          return saved;
        }
      } catch (e) {
        debugPrint('Supabase saveAnimal error: $e. Retaining local persistent copy.');
      }
    }

    return toSave;
  }

  Future<void> deleteAnimal(String id) async {
    await _ensureLoaded();
    _inMemoryAnimals.removeWhere((a) => a.id == id);
    await _persistToLocalStorage();

    final c = client;
    if (c != null) {
      try {
        await c.from('animals').delete().eq('id', id);
      } catch (e) {
        debugPrint('Supabase deleteAnimal error: $e');
      }
    }
  }
}
