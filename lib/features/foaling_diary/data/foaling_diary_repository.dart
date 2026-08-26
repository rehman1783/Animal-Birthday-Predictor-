import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/utils/app_uuid.dart';
import '../domain/foaling_diary_entry.dart';

class FoalingDiaryRepository {
  final SupabaseClient? client;

  FoalingDiaryRepository({this.client});

  static final List<FoalingDiaryEntry> _mockEntries = [
    // 1. Immediate Foaling Barn (Due in 5 days)
    FoalingDiaryEntry(
      id: '00000000-0000-0000-0000-000000000101',
      mareId: '00000000-0000-0000-0000-000000000011',
      mareName: 'Royal Empress',
      microchipNo: '985141001298451',
      stallionName: 'Northern Dancer Legacy',
      isEmbryoTransfer: false,
      breedingMethod: 'chilled',
      serviceDate: DateTime.now().subtract(const Duration(days: 335)),
      foalingDueDate: DateTime.now().add(const Duration(days: 5)),
      minDueDate: DateTime.now().subtract(const Duration(days: 15)),
      maxDueDate: DateTime.now().add(const Duration(days: 30)),
      currentPaddock: 'Foaling Barn - Box 1',
      scan1Confirmed: true,
      scan2Confirmed: true,
      scan3Confirmed: true,
      twinDetected: false,
      isFoaled: false,
      notes: 'Waxing observed on udder tips. Milk calcium 240ppm. Move to 24hr camera monitoring.',
    ),

    // 2. Immediate Foaling Barn (Due in 9 days - Embryo Transfer Recipient)
    FoalingDiaryEntry(
      id: '00000000-0000-0000-0000-000000000102',
      mareId: '00000000-0000-0000-0000-000000000012',
      mareName: 'Bella Recipient 44',
      microchipNo: '985141004581290',
      stallionName: 'Chacco-Blue Champion',
      isEmbryoTransfer: true,
      donorMareName: 'Starlight Diva (Grand Prix)',
      recipientMareName: 'Bella Recipient 44',
      breedingMethod: 'et',
      serviceDate: DateTime.now().subtract(const Duration(days: 325)),
      foalingDueDate: DateTime.now().add(const Duration(days: 9)),
      minDueDate: DateTime.now().subtract(const Duration(days: 11)),
      maxDueDate: DateTime.now().add(const Duration(days: 34)),
      currentPaddock: 'Foaling Barn - Box 3',
      scan1Confirmed: true,
      scan2Confirmed: true,
      scan3Confirmed: true,
      twinDetected: false,
      isFoaled: false,
      notes: 'Embryo Transfer pregnancy. Recipient mare relaxed. Foaling alarm belt fitted.',
    ),

    // 3. Close Paddock (Due in 21 days)
    FoalingDiaryEntry(
      id: '00000000-0000-0000-0000-000000000103',
      mareId: '00000000-0000-0000-0000-000000000013',
      mareName: 'Golden Sovereign',
      microchipNo: '985141007812349',
      stallionName: 'Galileo Supreme',
      isEmbryoTransfer: false,
      breedingMethod: 'natural',
      serviceDate: DateTime.now().subtract(const Duration(days: 319)),
      foalingDueDate: DateTime.now().add(const Duration(days: 21)),
      minDueDate: DateTime.now().add(const Duration(days: 1)),
      maxDueDate: DateTime.now().add(const Duration(days: 46)),
      currentPaddock: 'Close Monitoring Paddock A',
      scan1Confirmed: true,
      scan2Confirmed: true,
      scan3Confirmed: true,
      twinDetected: false,
      isFoaled: false,
      notes: 'Moved from Hill pasture to Close Paddock A. Daily evening udder inspections active.',
    ),

    // 4. Close Paddock (Due in 28 days)
    FoalingDiaryEntry(
      id: '00000000-0000-0000-0000-000000000104',
      mareId: '00000000-0000-0000-0000-000000000014',
      mareName: 'Velvet Midnight',
      microchipNo: '985141009941203',
      stallionName: 'Dubawi Gold',
      isEmbryoTransfer: false,
      breedingMethod: 'frozen',
      serviceDate: DateTime.now().subtract(const Duration(days: 312)),
      foalingDueDate: DateTime.now().add(const Duration(days: 28)),
      minDueDate: DateTime.now().add(const Duration(days: 8)),
      maxDueDate: DateTime.now().add(const Duration(days: 53)),
      currentPaddock: 'Close Monitoring Paddock B',
      scan1Confirmed: true,
      scan2Confirmed: true,
      scan3Confirmed: true,
      twinDetected: false,
      isFoaled: false,
      notes: 'Pre-foaling 5-in-1 vaccine administered on Day 300. Body condition score 6.5.',
    ),

    // 5. Overdue Mare (Due -3 days)
    FoalingDiaryEntry(
      id: '00000000-0000-0000-0000-000000000105',
      mareId: '00000000-0000-0000-0000-000000000015',
      mareName: 'Sapphire Mirage',
      microchipNo: '985141003319082',
      stallionName: 'Frankel Express',
      isEmbryoTransfer: false,
      breedingMethod: 'natural',
      serviceDate: DateTime.now().subtract(const Duration(days: 343)),
      foalingDueDate: DateTime.now().subtract(const Duration(days: 3)),
      minDueDate: DateTime.now().subtract(const Duration(days: 23)),
      maxDueDate: DateTime.now().add(const Duration(days: 22)),
      currentPaddock: 'Foaling Barn - Box 2',
      scan1Confirmed: true,
      scan2Confirmed: true,
      scan3Confirmed: true,
      twinDetected: false,
      isFoaled: false,
      notes: 'Day 343 gestation. Vet examined placenta thickness; normal. Milk drop imminent.',
    ),

    // 6. Mid-Gestation (Due in 75 days)
    FoalingDiaryEntry(
      id: '00000000-0000-0000-0000-000000000106',
      mareId: '00000000-0000-0000-0000-000000000016',
      mareName: 'Silver Cascade',
      microchipNo: '985141005523190',
      stallionName: 'Kingman Prince',
      isEmbryoTransfer: false,
      breedingMethod: 'chilled',
      serviceDate: DateTime.now().subtract(const Duration(days: 265)),
      foalingDueDate: DateTime.now().add(const Duration(days: 75)),
      minDueDate: DateTime.now().add(const Duration(days: 55)),
      maxDueDate: DateTime.now().add(const Duration(days: 100)),
      currentPaddock: 'Main North Broodmare Pasture',
      scan1Confirmed: true,
      scan2Confirmed: true,
      scan3Confirmed: true,
      twinDetected: false,
      isFoaled: false,
      notes: '45-day certificate issued. Scheduled for move to Close Paddock next month.',
    ),
  ];

  Future<List<FoalingDiaryEntry>> getFoalingDiaryEntries() async {
    final c = client;
    if (c != null) {
      try {
        final data = await c.from('foaling_diary_entries').select().order('foaling_due_date', ascending: true);
        if (data is List && data.isNotEmpty) {
          return data.map((json) => FoalingDiaryEntry.fromJson(json as Map<String, dynamic>)).toList();
        }
      } catch (e) {
        debugPrint('Supabase getFoalingDiaryEntries error: $e');
      }
    }
    return List.unmodifiable(_mockEntries);
  }

  Future<FoalingDiaryEntry> saveFoalingDiaryEntry(FoalingDiaryEntry entry) async {
    final validId = AppUuid.isValid(entry.id) ? entry.id : AppUuid.generate();
    final toSave = entry.copyWith(id: validId);

    final c = client;
    if (c != null && AppUuid.isValid(toSave.id)) {
      try {
        final data = await c.from('foaling_diary_entries').upsert(toSave.toJson()).select();
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
    final idx = _mockEntries.indexWhere((e) => e.id == id);
    if (idx >= 0) {
      final updated = _mockEntries[idx].copyWith(currentPaddock: newPaddock);
      await saveFoalingDiaryEntry(updated);
    }
  }

  Future<void> markAsFoaled(String id) async {
    final idx = _mockEntries.indexWhere((e) => e.id == id);
    if (idx >= 0) {
      final updated = _mockEntries[idx].copyWith(isFoaled: true);
      await saveFoalingDiaryEntry(updated);
    }
  }
}
