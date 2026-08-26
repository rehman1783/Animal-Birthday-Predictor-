import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/utils/app_uuid.dart';
import '../domain/foaling_diary_entry.dart';

class FoalingDiaryRepository {
  final SupabaseClient? _supabase;
  final List<FoalingDiaryEntry> _mockEntries = [];

  FoalingDiaryRepository({SupabaseClient? client}) : _supabase = client;

  SupabaseClient? get client {
    if (_supabase != null) return _supabase;
    try {
      return Supabase.instance.client;
    } catch (_) {
      return null;
    }
  }

  Future<List<FoalingDiaryEntry>> getFoalingDiaryEntries() async {
    final c = client;
    final user = c?.auth.currentUser;

    if (c != null && user != null) {
      final List<FoalingDiaryEntry> results = [];
      final Set<String> processedIds = {};

      // 1. Fetch entries from foaling_diary_entries table
      try {
        final data = await c
            .from('foaling_diary_entries')
            .select()
            .eq('user_id', user.id)
            .order('foaling_due_date', ascending: true);

        if (data is List) {
          for (final json in data) {
            final entry = FoalingDiaryEntry.fromJson(json as Map<String, dynamic>);
            results.add(entry);
            processedIds.add(entry.id);
            if (entry.mareId.isNotEmpty) processedIds.add(entry.mareId);
          }
        }
      } catch (e) {
        debugPrint('Supabase getFoalingDiaryEntries table query error: $e');
      }

      // 2. Also retrieve any active equine pregnancy records recorded in the breeding suite
      try {
        final pregData = await c
            .from('pregnancy_records')
            .select('''
              id,
              breeding_record_id,
              carrier_animal_id,
              foaling_due_date,
              earliest_foaling_date,
              latest_foaling_date,
              is_embryo_transfer,
              donor_dam_name,
              recipient_mare_name,
              scan1_confirmed,
              scan2_confirmed,
              scan3_confirmed,
              twins_suspected,
              current_paddock,
              notes,
              is_foaled,
              animals!carrier_animal_id (
                id,
                name,
                microchip_no,
                species
              ),
              breeding_records (
                id,
                stallion_name,
                breeding_type,
                service_date
              )
            ''')
            .eq('account_id', user.id);

        if (pregData is List) {
          for (final row in pregData) {
            try {
              final rowMap = row as Map<String, dynamic>;
              final animal = rowMap['animals'] as Map<String, dynamic>?;
              final species = animal?['species']?.toString().toLowerCase();

              // Only include Equine (horse) pregnancies in Foaling Diary
              if (species != null && species != 'horse') continue;

              final pregId = rowMap['id']?.toString() ?? '';
              final carrierId = animal?['id']?.toString() ?? rowMap['carrier_animal_id']?.toString() ?? '';

              // Skip if already in diary from dedicated entries
              if (processedIds.contains(pregId) || (carrierId.isNotEmpty && processedIds.contains(carrierId))) {
                continue;
              }

              final mareName = animal?['name']?.toString() ?? 'Recorded Mare';
              final microchip = animal?['microchip_no']?.toString();
              final breeding = rowMap['breeding_records'] as Map<String, dynamic>?;
              final stallionName = breeding?['stallion_name']?.toString() ?? 'Recorded Stallion';
              final breedingType = breeding?['breeding_type']?.toString() ?? 'natural';

              final serviceDateStr = breeding?['service_date']?.toString();
              final serviceDate = serviceDateStr != null ? DateTime.tryParse(serviceDateStr) ?? DateTime.now() : DateTime.now();

              final dueDateStr = rowMap['foaling_due_date']?.toString();
              final foalingDueDate = dueDateStr != null ? DateTime.tryParse(dueDateStr) ?? serviceDate.add(const Duration(days: 340)) : serviceDate.add(const Duration(days: 340));

              final minDateStr = rowMap['earliest_foaling_date']?.toString();
              final minDueDate = minDateStr != null ? DateTime.tryParse(minDateStr) ?? serviceDate.add(const Duration(days: 320)) : serviceDate.add(const Duration(days: 320));

              final maxDateStr = rowMap['latest_foaling_date']?.toString();
              final maxDueDate = maxDateStr != null ? DateTime.tryParse(maxDateStr) ?? serviceDate.add(const Duration(days: 365)) : serviceDate.add(const Duration(days: 365));

              final entry = FoalingDiaryEntry(
                id: pregId,
                mareId: carrierId,
                mareName: mareName,
                microchipNo: microchip,
                stallionName: stallionName,
                isEmbryoTransfer: rowMap['is_embryo_transfer'] == true,
                donorMareName: rowMap['donor_dam_name']?.toString(),
                recipientMareName: rowMap['recipient_mare_name']?.toString(),
                breedingMethod: breedingType,
                serviceDate: serviceDate,
                foalingDueDate: foalingDueDate,
                minDueDate: minDueDate,
                maxDueDate: maxDueDate,
                currentPaddock: rowMap['current_paddock']?.toString() ?? 'Main Broodmare Pasture',
                scan1Confirmed: rowMap['scan1_confirmed'] == true,
                scan2Confirmed: rowMap['scan2_confirmed'] == true,
                scan3Confirmed: rowMap['scan3_confirmed'] == true,
                twinDetected: rowMap['twins_suspected'] == true,
                isFoaled: rowMap['is_foaled'] == true,
                notes: rowMap['notes']?.toString() ?? '',
              );

              results.add(entry);
              processedIds.add(pregId);
            } catch (innerErr) {
              debugPrint('Error mapping pregnancy row to foaling entry: $innerErr');
            }
          }
        }
      } catch (e) {
        debugPrint('Supabase auto-merge pregnancy records for diary error: $e');
      }

      results.sort((a, b) => a.foalingDueDate.compareTo(b.foalingDueDate));
      return results;
    }

    return List.unmodifiable(_mockEntries);
  }

  Future<FoalingDiaryEntry> saveFoalingDiaryEntry(FoalingDiaryEntry entry) async {
    final validId = AppUuid.isValid(entry.id) ? entry.id : AppUuid.generate();
    final toSave = entry.copyWith(id: validId);

    final c = client;
    final user = c?.auth.currentUser;

    if (c != null && user != null && AppUuid.isValid(toSave.id)) {
      try {
        final payload = toSave.toJson();
        payload['user_id'] = user.id;

        final data = await c.from('foaling_diary_entries').upsert(payload).select();
        if (data is List && data.isNotEmpty) {
          return FoalingDiaryEntry.fromJson(data.first as Map<String, dynamic>);
        }
      } catch (e) {
        debugPrint('Supabase saveFoalingDiaryEntry error: $e');
      }
    }

    final idx = _mockEntries.indexWhere((e) => e.id == toSave.id);
    if (idx >= 0) {
      _mockEntries[idx] = toSave;
    } else {
      _mockEntries.add(toSave);
      _mockEntries.sort((a, b) => a.foalingDueDate.compareTo(b.foalingDueDate));
    }
    return toSave;
  }

  Future<void> updatePaddockLocation(String id, String newPaddock) async {
    final c = client;
    final user = c?.auth.currentUser;

    if (c != null && user != null && AppUuid.isValid(id)) {
      try {
        await c.from('foaling_diary_entries').update({'current_paddock': newPaddock}).eq('id', id).eq('user_id', user.id);
      } catch (e) {
        debugPrint('Supabase updatePaddockLocation in foaling_diary_entries error: $e');
      }
      try {
        await c.from('pregnancy_records').update({'current_paddock': newPaddock}).eq('id', id).eq('account_id', user.id);
      } catch (_) {}
    }

    final idx = _mockEntries.indexWhere((e) => e.id == id);
    if (idx >= 0) {
      final updated = _mockEntries[idx].copyWith(currentPaddock: newPaddock);
      _mockEntries[idx] = updated;
    }
  }

  Future<void> markAsFoaled(String id) async {
    final c = client;
    final user = c?.auth.currentUser;

    if (c != null && user != null && AppUuid.isValid(id)) {
      try {
        await c.from('foaling_diary_entries').update({'is_foaled': true}).eq('id', id).eq('user_id', user.id);
      } catch (e) {
        debugPrint('Supabase markAsFoaled in foaling_diary_entries error: $e');
      }
      try {
        await c.from('pregnancy_records').update({'is_foaled': true}).eq('id', id).eq('account_id', user.id);
      } catch (_) {}
    }

    final idx = _mockEntries.indexWhere((e) => e.id == id);
    if (idx >= 0) {
      final updated = _mockEntries[idx].copyWith(isFoaled: true);
      _mockEntries[idx] = updated;
    }
  }
}
