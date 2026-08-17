import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/utils/app_uuid.dart';
import '../domain/animal.dart';
import '../domain/markings.dart';

class MareRepository {
  final SupabaseClient? _supabase;
  final List<Animal> _mockMares = [];
  final List<Markings> _mockMarkings = [];

  MareRepository({SupabaseClient? supabase}) : _supabase = supabase;

  SupabaseClient? get client {
    if (_supabase != null) return _supabase;
    try {
      return Supabase.instance.client;
    } catch (_) {
      return null;
    }
  }

  // --- ANIMALS / MARES (reads from unified animals table) ---
  Future<List<Animal>> getMares() async {
    final c = client;
    final user = c?.auth.currentUser;

    if (c != null && user != null) {
      try {
        final data = await c
            .from('animals')
            .select()
            .eq('account_id', user.id)
            .eq('species', 'horse')
            .order('created_at', ascending: false);
        if (data is List) {
          return data.map((json) => Animal.fromJson(json as Map<String, dynamic>)).toList();
        }
      } catch (e) {
        debugPrint('Supabase getMares error: $e');
        rethrow;
      }
    }

    return List.unmodifiable(_mockMares);
  }

  Future<Animal> saveMare(Animal animal) async {
    final c = client;
    final user = c?.auth.currentUser;
    final accountId = user?.id ?? (AppUuid.isValid(animal.accountId) ? animal.accountId : AppUuid.generate());
    final validId = AppUuid.isValid(animal.id) ? animal.id : AppUuid.generate();
    final toSave = animal.copyWith(id: validId, accountId: accountId, species: 'horse');

    if (c != null && user != null) {
      try {
        final data = await c.from('animals').upsert(toSave.toJson()).select();
        if (data is List && data.isNotEmpty) {
          return Animal.fromJson(data.first as Map<String, dynamic>);
        }
      } catch (e) {
        debugPrint('Supabase saveMare error: $e');
        rethrow;
      }
    }

    final idx = _mockMares.indexWhere((m) => m.id == toSave.id);
    if (idx >= 0) {
      _mockMares[idx] = toSave;
    } else {
      _mockMares.insert(0, toSave);
    }
    return toSave;
  }

  // --- MARKINGS ---
  Future<Markings?> getMarkings(String ownerType, String ownerId) async {
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
          return Markings.fromJson(data.first as Map<String, dynamic>);
        }
        return null;
      } catch (e) {
        debugPrint('Supabase getMarkings error: $e');
        rethrow;
      }
    }

    try {
      return _mockMarkings.firstWhere(
        (m) => m.ownerType == ownerType && m.ownerId == ownerId,
      );
    } catch (_) {
      return null;
    }
  }

  Future<Markings> saveMarkings(Markings markings) async {
    final validId = AppUuid.isValid(markings.id) ? markings.id : AppUuid.generate();
    final toSave = markings.copyWith(id: validId);

    final c = client;
    if (c != null) {
      try {
        final data = await c.from('markings').upsert(toSave.toJson()).select();
        if (data is List && data.isNotEmpty) {
          return Markings.fromJson(data.first as Map<String, dynamic>);
        }
      } catch (e) {
        debugPrint('Supabase saveMarkings error: $e');
        rethrow;
      }
    }

    final idx = _mockMarkings.indexWhere((m) => m.ownerType == toSave.ownerType && m.ownerId == toSave.ownerId);
    if (idx >= 0) {
      _mockMarkings[idx] = toSave;
    } else {
      _mockMarkings.add(toSave);
    }
    return toSave;
  }
}
