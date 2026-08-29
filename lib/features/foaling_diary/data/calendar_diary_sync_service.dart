import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/utils/app_uuid.dart';
import '../../animals/domain/animal.dart';
import '../../pregnancy/domain/breeding_record.dart';
import '../../pregnancy/domain/pregnancy_record.dart';
import '../../pregnancy/domain/pregnancy_calculation_utils.dart';
import '../domain/foaling_diary_entry.dart';

class CalendarTimelineMilestone {
  final String id;
  final String title;
  final String mareName;
  final String species;
  final String category; // 'scan1', 'scan2', 'scan3', 'close_paddock', 'foaling_barn', 'due_date', 'deworming', 'vaccination'
  final DateTime date;
  final bool isCompleted;
  final String description;
  final String? relatedRecordId;

  const CalendarTimelineMilestone({
    required this.id,
    required this.title,
    required this.mareName,
    this.species = 'horse',
    required this.category,
    required this.date,
    required this.isCompleted,
    required this.description,
    this.relatedRecordId,
  });
}

class CalendarDiarySyncService {
  final SupabaseClient? _supabase;

  CalendarDiarySyncService({SupabaseClient? client}) : _supabase = client;

  SupabaseClient? get client {
    if (_supabase != null) return _supabase;
    try {
      return Supabase.instance.client;
    } catch (_) {
      return null;
    }
  }

  /// Synchronize a newly saved or updated breeding record into Foaling Diary and Calendar
  Future<void> syncFromBreedingRecord({
    required BreedingRecord breeding,
    required Animal mare,
    Animal? recipient,
  }) async {
    final c = client;
    final user = c?.auth.currentUser;
    final coverDate = breeding.coverOrTransferDate ?? DateTime.now();

    final isET = breeding.isEmbryoTransfer;
    final carrierMare = (isET && recipient != null) ? recipient : mare;

    final calculations = calculatePregnancyDates(
      baseDate: coverDate,
      isEmbryoTransfer: isET,
      method: breeding.method,
    );

    final minDueDate = coverDate.add(const Duration(days: 320));
    final maxDueDate = coverDate.add(const Duration(days: 365));

    // 1. Create or Update Foaling Diary Entry
    final diaryEntry = FoalingDiaryEntry(
      id: breeding.id,
      mareId: carrierMare.id,
      mareName: carrierMare.name,
      microchipNo: carrierMare.microchipNo,
      stallionName: breeding.stallionName?.isNotEmpty == true ? breeding.stallionName! : 'Recorded Stallion',
      isEmbryoTransfer: isET,
      donorMareName: isET ? (breeding.damOfEmbryo ?? mare.name) : null,
      recipientMareName: isET ? (recipient?.name ?? carrierMare.name) : null,
      breedingMethod: breeding.method,
      serviceDate: coverDate,
      foalingDueDate: calculations.foalingDueDate,
      minDueDate: minDueDate,
      maxDueDate: maxDueDate,
      currentPaddock: 'Main Broodmare Pasture',
      scan1Confirmed: false,
      scan2Confirmed: false,
      scan3Confirmed: false,
      twinDetected: false,
      isFoaled: false,
      notes: 'Synced from Breeding Record (Method: ${breeding.method})',
    );

    if (c != null && user != null) {
      try {
        final payload = diaryEntry.toJson();
        payload['user_id'] = user.id;
        await c.from('foaling_diary_entries').upsert(payload);
      } catch (e) {
        debugPrint('CalendarDiarySyncService syncFromBreedingRecord foaling_diary error: $e');
      }

      // 2. Sync to calendar_reminders table
      final reminders = [
        {
          'id': AppUuid.generate(),
          'account_id': user.id,
          'related_table': 'foaling_diary_entries',
          'related_id': diaryEntry.id,
          'field_name': 'scan_1_due_date',
          'reminder_date': calculations.scan1DueDate.toIso8601String().split('T').first,
          'label': '${carrierMare.name} — Scan 1 (Pregnancy & Twin Check)',
          'synced_to_device_calendar': false,
        },
        {
          'id': AppUuid.generate(),
          'account_id': user.id,
          'related_table': 'foaling_diary_entries',
          'related_id': diaryEntry.id,
          'field_name': 'scan_2_due_date',
          'reminder_date': calculations.scan2DueDate.toIso8601String().split('T').first,
          'label': '${carrierMare.name} — Scan 2 (Heartbeat Check)',
          'synced_to_device_calendar': false,
        },
        {
          'id': AppUuid.generate(),
          'account_id': user.id,
          'related_table': 'foaling_diary_entries',
          'related_id': diaryEntry.id,
          'field_name': 'scan_3_due_date',
          'reminder_date': calculations.scan3DueDate.toIso8601String().split('T').first,
          'label': '${carrierMare.name} — Scan 3 (45-Day Organ & Sexing)',
          'synced_to_device_calendar': false,
        },
        {
          'id': AppUuid.generate(),
          'account_id': user.id,
          'related_table': 'foaling_diary_entries',
          'related_id': diaryEntry.id,
          'field_name': 'foaling_due_date',
          'reminder_date': calculations.foalingDueDate.toIso8601String().split('T').first,
          'label': '${carrierMare.name} — Expected Foaling Due Date (340d)',
          'synced_to_device_calendar': false,
        },
      ];

      for (final r in reminders) {
        try {
          await c.from('calendar_reminders').upsert(r);
        } catch (_) {}
      }
    }
  }

  /// Sync from Due Date Calculator
  Future<FoalingDiaryEntry> syncFromDueDateCalculator({
    required String mareName,
    required String stallionName,
    required DateTime serviceDate,
    required String species,
    required String method,
    String? recipientName,
    String? donorName,
  }) async {
    final c = client;
    final user = c?.auth.currentUser;
    final isET = method == 'et' || method == 'icsi';

    final int days = (species == 'dog') ? 63 : (species == 'cat') ? 65 : (isET ? 333 : 340);
    final dueDate = serviceDate.add(Duration(days: days));
    final minDueDate = serviceDate.add(Duration(days: days - 20));
    final maxDueDate = serviceDate.add(Duration(days: days + 25));

    final diaryId = AppUuid.generate();
    final dummyMareId = AppUuid.generate();

    final entry = FoalingDiaryEntry(
      id: diaryId,
      mareId: dummyMareId,
      mareName: mareName.trim().isEmpty ? 'Recorded Mare' : mareName.trim(),
      microchipNo: null,
      stallionName: stallionName.trim().isEmpty ? 'Recorded Stallion' : stallionName.trim(),
      isEmbryoTransfer: isET,
      donorMareName: isET ? (donorName ?? mareName) : null,
      recipientMareName: isET ? (recipientName ?? 'Recipient') : null,
      breedingMethod: method,
      serviceDate: serviceDate,
      foalingDueDate: dueDate,
      minDueDate: minDueDate,
      maxDueDate: maxDueDate,
      currentPaddock: 'Main Pasture',
      scan1Confirmed: false,
      scan2Confirmed: false,
      scan3Confirmed: false,
      twinDetected: false,
      isFoaled: false,
      notes: 'Calculated in Due Date Calculator (${species.toUpperCase()})',
    );

    if (c != null && user != null) {
      try {
        final payload = entry.toJson();
        payload['user_id'] = user.id;
        await c.from('foaling_diary_entries').upsert(payload);
      } catch (e) {
        debugPrint('syncFromDueDateCalculator upsert error: $e');
      }

      // Add Calendar Reminder
      try {
        await c.from('calendar_reminders').upsert({
          'id': AppUuid.generate(),
          'account_id': user.id,
          'related_table': 'foaling_diary_entries',
          'related_id': entry.id,
          'field_name': 'foaling_due_date',
          'reminder_date': dueDate.toIso8601String().split('T').first,
          'label': '${entry.mareName} — Expected Birth Due Date',
          'synced_to_device_calendar': false,
        });
      } catch (_) {}
    }

    return entry;
  }

  /// Sync scan confirmations from Vet Pregnancy Scans into Diary & Reminders
  Future<void> syncFromVetScanUpdate({
    required String pregnancyRecordId,
    required String carrierAnimalId,
    required int scanNumber,
    required bool isConfirmed,
    DateTime? scanDate,
    String? vetName,
    String? vetNumber,
  }) async {
    final c = client;
    final user = c?.auth.currentUser;

    final updateField = (scanNumber == 1)
        ? 'scan_1_confirmed'
        : (scanNumber == 2)
            ? 'scan_2_confirmed'
            : 'scan_3_confirmed';

    if (c != null && user != null) {
      try {
        await c.from('pregnancy_records').update({
          updateField: isConfirmed,
          if (vetName != null) 'vet_name': vetName,
          if (vetNumber != null) 'vet_number': vetNumber,
        }).eq('id', pregnancyRecordId).eq('account_id', user.id);
      } catch (e) {
        debugPrint('syncFromVetScanUpdate pregnancy_records error: $e');
      }

      try {
        await c.from('foaling_diary_entries').update({
          updateField: isConfirmed,
        }).eq('mare_id', carrierAnimalId).eq('user_id', user.id);
      } catch (e) {
        debugPrint('syncFromVetScanUpdate foaling_diary_entries error: $e');
      }
    }
  }

  /// Aggregate all upcoming calendar milestones from Diary & Pregnancies
  Future<List<CalendarTimelineMilestone>> getUnifiedCalendarMilestones(List<FoalingDiaryEntry> entries) async {
    final List<CalendarTimelineMilestone> milestones = [];

    for (final entry in entries) {
      final isET = entry.isEmbryoTransfer;
      final service = entry.serviceDate;

      // Scan 1
      final scan1Date = service.add(Duration(days: isET ? 7 : 14));
      milestones.add(
        CalendarTimelineMilestone(
          id: '${entry.id}_scan1',
          title: 'Ultrasound Scan 1 (Twin Check)',
          mareName: entry.mareName,
          category: 'scan1',
          date: scan1Date,
          isCompleted: entry.scan1Confirmed,
          description: 'Day 14-16 post cover: Initial pregnancy confirmation & vesicle check.',
          relatedRecordId: entry.id,
        ),
      );

      // Scan 2
      final scan2Date = service.add(Duration(days: isET ? 23 : 28));
      milestones.add(
        CalendarTimelineMilestone(
          id: '${entry.id}_scan2',
          title: 'Ultrasound Scan 2 (Heartbeat Check)',
          mareName: entry.mareName,
          category: 'scan2',
          date: scan2Date,
          isCompleted: entry.scan2Confirmed,
          description: 'Day 28-30 post cover: Detect fetal heartbeat & viable development.',
          relatedRecordId: entry.id,
        ),
      );

      // Scan 3
      final scan3Date = service.add(Duration(days: isET ? 38 : 45));
      milestones.add(
        CalendarTimelineMilestone(
          id: '${entry.id}_scan3',
          title: 'Ultrasound Scan 3 (45-Day Organ & Sexing)',
          mareName: entry.mareName,
          category: 'scan3',
          date: scan3Date,
          isCompleted: entry.scan3Confirmed,
          description: 'Day 45-60 post cover: Fetal development, Caslick evaluation & fetal sexing.',
          relatedRecordId: entry.id,
        ),
      );

      // Close Paddock (30 days before foaling)
      final closePaddockDate = entry.foalingDueDate.subtract(const Duration(days: 30));
      milestones.add(
        CalendarTimelineMilestone(
          id: '${entry.id}_close_paddock',
          title: 'Move to Close / Observation Paddock',
          mareName: entry.mareName,
          category: 'close_paddock',
          date: closePaddockDate,
          isCompleted: DateTime.now().isAfter(closePaddockDate) || entry.isFoaled,
          description: '30 days prior to due date: Daily udder checks, move closer to barn.',
          relatedRecordId: entry.id,
        ),
      );

      // Foaling Barn Box (10 days before foaling)
      final barnBoxDate = entry.foalingDueDate.subtract(const Duration(days: 10));
      milestones.add(
        CalendarTimelineMilestone(
          id: '${entry.id}_barn_box',
          title: 'Move to Foaling Barn Box / Straw Bedding',
          mareName: entry.mareName,
          category: 'foaling_barn',
          date: barnBoxDate,
          isCompleted: DateTime.now().isAfter(barnBoxDate) || entry.isFoaled,
          description: '10 days prior to due date: Night camera monitor on, milk strip testing.',
          relatedRecordId: entry.id,
        ),
      );

      // Foaling Due Date
      milestones.add(
        CalendarTimelineMilestone(
          id: '${entry.id}_due_date',
          title: 'Expected Foaling Due Date (340 Days)',
          mareName: entry.mareName,
          category: 'due_date',
          date: entry.foalingDueDate,
          isCompleted: entry.isFoaled,
          description: 'Average 340-day equine gestation. Foaling kit & veterinarian on standby.',
          relatedRecordId: entry.id,
        ),
      );
    }

    milestones.sort((a, b) => a.date.compareTo(b.date));
    return milestones;
  }
}
