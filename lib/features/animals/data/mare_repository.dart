import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/utils/app_uuid.dart';
import '../domain/animal.dart';
import '../domain/mare.dart';
import '../domain/markings.dart';

class MareRepository {
  final SupabaseClient? _supabase;
  final List<Mare> _inMemoryMares = [];
  final List<Markings> _inMemoryMarkings = [];
  String? _loadedUserId;

  MareRepository({SupabaseClient? supabase})
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

  String get _currentUserId {
    try {
      return client?.auth.currentUser?.id ?? 'guest';
    } catch (_) {
      return 'guest';
    }
  }

  String get _markingsStorageKey => 'abp_cached_markings_records_$_currentUserId';

  Future<void> _initLocalStorage() async {
    final uid = _currentUserId;
    if (_loadedUserId == uid) return;
    _loadedUserId = uid;
    _inMemoryMarkings.clear();

    try {
      final prefs = await SharedPreferences.getInstance();
      var list = prefs.getStringList(_markingsStorageKey);
      if (list == null || list.isEmpty) {
        list = prefs.getStringList('abp_cached_markings_records');
      }
      if (list != null && list.isNotEmpty) {
        final loaded = list.map((item) {
          final json = jsonDecode(item) as Map<String, dynamic>;
          return Markings.fromJson(json);
        }).toList();
        for (final m in loaded) {
          final idx = _inMemoryMarkings.indexWhere((x) => x.ownerType == m.ownerType && x.ownerId == m.ownerId);
          if (idx >= 0) {
            _inMemoryMarkings[idx] = m;
          } else {
            _inMemoryMarkings.add(m);
          }
        }
      }
    } catch (e) {
      debugPrint('MareRepository: error reading local cache: $e');
    }
  }

  Future<void> _persistMarkingsToLocalStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonList = _inMemoryMarkings.map((m) => jsonEncode(m.toJson())).toList();
      await prefs.setStringList(_markingsStorageKey, jsonList);
    } catch (e) {
      debugPrint('MareRepository: error persisting markings to local cache: $e');
    }
  }

  // --- ANIMALS / MARES (reads from unified animals table) ---
  Future<List<Animal>> getMares() async {
    final c = client;
    final user = c?.auth.currentUser;
    final accountId = user?.id;

    if (c != null) {
      try {
        var query = c.from('animals').select().eq('species', 'horse');
        if (accountId != null && accountId.isNotEmpty) {
          query = query.eq('account_id', accountId);
        }
        final data = await query.order('created_at', ascending: false);
        if (data is List) {
          return data.map((json) => Animal.fromJson(json as Map<String, dynamic>)).toList();
        }
      } catch (e) {
        debugPrint('Supabase getMares error: $e');
      }
    }

    return _inMemoryMares.where((m) {
      if (accountId != null && accountId.isNotEmpty) {
        if (m.accountId.isNotEmpty && m.accountId != accountId && m.accountId != '00000000-0000-0000-0000-000000000000') {
          return false;
        }
      }
      return true;
    }).map((m) => Animal(
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

  Future<Animal> saveMare(Animal animal) async {
    final c = client;
    final user = c?.auth.currentUser;
    final accountId = user?.id ?? (AppUuid.isValid(animal.accountId) ? animal.accountId : '00000000-0000-0000-0000-000000000000');
    final validId = AppUuid.isValid(animal.id) ? animal.id : AppUuid.generate();
    final toSave = animal.copyWith(id: validId, accountId: accountId, species: 'horse');

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

    if (c != null) {
      try {
        final data = await c.from('animals').upsert(toSave.toJson()).select();
        if (data is List && data.isNotEmpty) {
          return Animal.fromJson(data.first as Map<String, dynamic>);
        }
      } catch (e) {
        debugPrint('Supabase saveMare error: $e');
      }
    }
    return toSave;
  }

  // --- MARKINGS ---
  Future<Markings?> getMarkings(String ownerType, String ownerId) async {
    await _initLocalStorage();
    final c = client;
    if (c != null) {
      try {
        final data = await c
            .from('markings')
            .select()
            .eq('owner_type', ownerType)
            .eq('owner_id', ownerId)
            .limit(1);
        if (data is List && data.isNotEmpty) {
          final remoteMarkings = Markings.fromJson(data.first as Map<String, dynamic>);
          final idx = _inMemoryMarkings.indexWhere((m) => m.ownerType == ownerType && m.ownerId == ownerId);
          if (idx >= 0) {
            _inMemoryMarkings[idx] = remoteMarkings;
          } else {
            _inMemoryMarkings.add(remoteMarkings);
          }
          await _persistMarkingsToLocalStorage();
          return remoteMarkings;
        }
      } catch (e) {
        debugPrint('Supabase getMarkings error: $e');
      }
    }

    try {
      return _inMemoryMarkings.firstWhere(
        (m) => m.ownerType == ownerType && m.ownerId == ownerId,
      );
    } catch (_) {
      return null;
    }
  }

  Future<Markings> saveMarkings(Markings markings) async {
    await _initLocalStorage();
    final validId = AppUuid.isValid(markings.id) ? markings.id : AppUuid.generate();
    final toSave = markings.copyWith(id: validId);

    // Save in-memory and local cache
    final index = _inMemoryMarkings.indexWhere(
      (m) => m.ownerType == toSave.ownerType && m.ownerId == toSave.ownerId,
    );
    if (index >= 0) {
      _inMemoryMarkings[index] = toSave;
    } else {
      _inMemoryMarkings.add(toSave);
    }
    await _persistMarkingsToLocalStorage();

    final c = client;
    if (c != null) {
      try {
        final data = await c.from('markings').upsert(toSave.toJson()).select();
        if (data is List && data.isNotEmpty) {
          final synced = Markings.fromJson(data.first as Map<String, dynamic>);
          final idx = _inMemoryMarkings.indexWhere(
            (m) => m.ownerType == synced.ownerType && m.ownerId == synced.ownerId,
          );
          if (idx >= 0) {
            _inMemoryMarkings[idx] = synced;
            await _persistMarkingsToLocalStorage();
          }
          return synced;
        }
      } catch (e) {
        debugPrint('Supabase saveMarkings error: $e');
      }
    }
    return toSave;
  }
}
