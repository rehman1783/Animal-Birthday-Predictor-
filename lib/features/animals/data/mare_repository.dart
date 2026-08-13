import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../domain/mare.dart';
import '../domain/markings.dart';

class MareRepository {
  final SupabaseClient? _supabase;
  final List<Mare> _inMemoryMares = [];
  final List<RecipientMare> _inMemoryRecipientMares = [];
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

  // --- MARES ---
  Future<List<Mare>> getMares() async {
    final c = client;
    if (c == null) return List.unmodifiable(_inMemoryMares);
    try {
      final data = await c.from('mares').select().order('created_at', ascending: false);
      return (data as List).map((json) => Mare.fromJson(json)).toList();
    } catch (e) {
      debugPrint('Supabase getMares error: $e');
      return List.unmodifiable(_inMemoryMares);
    }
  }

  Future<Mare> saveMare(Mare mare) async {
    final c = client;
    if (c == null) {
      final index = _inMemoryMares.indexWhere((m) => m.id == mare.id);
      if (index >= 0) {
        _inMemoryMares[index] = mare;
      } else {
        _inMemoryMares.add(mare);
      }
      return mare;
    }
    try {
      final data = await c.from('mares').upsert(mare.toJson()).select().single();
      return Mare.fromJson(data);
    } catch (e) {
      debugPrint('Supabase saveMare error: $e');
      _inMemoryMares.add(mare);
      return mare;
    }
  }

  // --- RECIPIENT MARES ---
  Future<List<RecipientMare>> getRecipientMares() async {
    final c = client;
    if (c == null) return List.unmodifiable(_inMemoryRecipientMares);
    try {
      final data = await c.from('recipient_mares').select().order('created_at', ascending: false);
      return (data as List).map((json) => RecipientMare.fromJson(json)).toList();
    } catch (e) {
      debugPrint('Supabase getRecipientMares error: $e');
      return List.unmodifiable(_inMemoryRecipientMares);
    }
  }

  Future<RecipientMare> saveRecipientMare(RecipientMare recip) async {
    final c = client;
    if (c == null) {
      final index = _inMemoryRecipientMares.indexWhere((r) => r.id == recip.id);
      if (index >= 0) {
        _inMemoryRecipientMares[index] = recip;
      } else {
        _inMemoryRecipientMares.add(recip);
      }
      return recip;
    }
    try {
      final data = await c.from('recipient_mares').upsert(recip.toJson()).select().single();
      return RecipientMare.fromJson(data);
    } catch (e) {
      debugPrint('Supabase saveRecipientMare error: $e');
      _inMemoryRecipientMares.add(recip);
      return recip;
    }
  }

  // --- MARKINGS ---
  Future<Markings?> getMarkings(String ownerType, String ownerId) async {
    final c = client;
    if (c == null) {
      return _inMemoryMarkings.firstWhere(
        (m) => m.ownerType == ownerType && m.ownerId == ownerId,
        orElse: () => Markings(
          id: '',
          ownerType: ownerType,
          ownerId: ownerId,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      );
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
    if (c == null) {
      final index = _inMemoryMarkings.indexWhere(
        (m) => m.ownerType == markings.ownerType && m.ownerId == markings.ownerId,
      );
      if (index >= 0) {
        _inMemoryMarkings[index] = markings;
      } else {
        _inMemoryMarkings.add(markings);
      }
      return markings;
    }
    try {
      final data = await c.from('markings').upsert(markings.toJson()).select().single();
      return Markings.fromJson(data);
    } catch (e) {
      debugPrint('Supabase saveMarkings error: $e');
      _inMemoryMarkings.add(markings);
      return markings;
    }
  }
}
