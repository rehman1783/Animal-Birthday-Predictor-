import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/utils/app_uuid.dart';
import '../domain/foal_record.dart';

class FoalRepository {
  final SupabaseClient? _supabase;
  final List<FoalRecord> _mockFoals = [];

  FoalRepository({SupabaseClient? supabase}) : _supabase = supabase;

  SupabaseClient? get client {
    if (_supabase != null) return _supabase;
    try {
      return Supabase.instance.client;
    } catch (_) {
      return null;
    }
  }

  Future<List<FoalRecord>> getFoals() async {
    final c = client;
    final user = c?.auth.currentUser;

    if (c != null && user != null) {
      try {
        final data = await c
            .from('foals')
            .select()
            .eq('account_id', user.id)
            .order('created_at', ascending: false);
        if (data is List) {
          return data.map((json) => FoalRecord.fromJson(json as Map<String, dynamic>)).toList();
        }
      } catch (e) {
        debugPrint('Supabase getFoals error: $e');
        rethrow;
      }
    }

    return List.unmodifiable(_mockFoals);
  }

  Future<FoalRecord?> getFoalById(String id) async {
    final c = client;
    final user = c?.auth.currentUser;

    if (c != null && user != null) {
      try {
        final data = await c.from('foals').select().eq('account_id', user.id).eq('id', id).limit(1);
        if (data is List && data.isNotEmpty) {
          return FoalRecord.fromJson(data.first as Map<String, dynamic>);
        }
        return null;
      } catch (e) {
        debugPrint('Supabase getFoalById error: $e');
        rethrow;
      }
    }

    try {
      return _mockFoals.firstWhere((f) => f.id == id);
    } catch (_) {
      return null;
    }
  }

  Future<FoalRecord> saveFoal(FoalRecord foal) async {
    final c = client;
    final user = c?.auth.currentUser;
    final accountId = user?.id ?? (AppUuid.isValid(foal.accountId) ? foal.accountId : AppUuid.generate());
    final validId = AppUuid.isValid(foal.id) ? foal.id : AppUuid.generate();
    final mareId = AppUuid.isValid(foal.mareAnimalId) ? foal.mareAnimalId : AppUuid.generate();
    final recipientId = (foal.recipientAnimalId != null && AppUuid.isValid(foal.recipientAnimalId!))
        ? foal.recipientAnimalId
        : null;

    final toSave = foal.copyWith(
      id: validId,
      accountId: accountId,
      mareAnimalId: mareId,
      recipientAnimalId: recipientId,
    );

    if (c != null && user != null) {
      final primaryPayload = <String, dynamic>{
        'id': validId,
        'account_id': accountId,
        'mare_animal_id': mareId,
        if (recipientId != null) 'recipient_animal_id': recipientId,
        if (toSave.foalName != null) 'foal_name': toSave.foalName,
        if (toSave.dateOfBirth != null) 'date_of_birth': toSave.dateOfBirth!.toIso8601String().split('T').first,
        if (toSave.stallion != null) 'stallion': toSave.stallion,
        if (toSave.breed != null) 'breed': toSave.breed,
        if (toSave.sex != null) 'sex': toSave.sex,
        if (toSave.iggValue != null) 'igg_value': toSave.iggValue,
        if (toSave.foalMicrochipNo != null) 'foal_microchip_no': toSave.foalMicrochipNo,
        if (toSave.dna != null) 'dna': toSave.dna,
        'gelded': toSave.gelded,
        if (toSave.geldedDate != null) 'gelded_date': toSave.geldedDate!.toIso8601String().split('T').first,
        if (toSave.studBookAssociation != null) 'stud_book_association': toSave.studBookAssociation,
        if (toSave.notes != null) 'notes': toSave.notes,
        if (toSave.status != null) 'status': toSave.status,
        if (toSave.photoUrl != null) 'photo_url': toSave.photoUrl,
        if (toSave.buyerName != null) 'buyer_name': toSave.buyerName,
        'created_at': toSave.createdAt.toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      };

      try {
        final data = await c.from('foals').upsert(primaryPayload).select();
        if (data is List && data.isNotEmpty) {
          return FoalRecord.fromJson(data.first as Map<String, dynamic>);
        }
      } catch (e) {
        debugPrint('Supabase saveFoal error: $e');
        rethrow;
      }
    }

    final idx = _mockFoals.indexWhere((f) => f.id == toSave.id);
    if (idx >= 0) {
      _mockFoals[idx] = toSave;
    } else {
      _mockFoals.insert(0, toSave);
    }
    return toSave;
  }

  Future<void> deleteFoal(String id) async {
    final c = client;
    final user = c?.auth.currentUser;

    if (c != null && user != null) {
      try {
        await c.from('foals').delete().eq('account_id', user.id).eq('id', id);
      } catch (e) {
        debugPrint('Supabase deleteFoal error: $e');
        rethrow;
      }
    }
    _mockFoals.removeWhere((f) => f.id == id);
  }
}
