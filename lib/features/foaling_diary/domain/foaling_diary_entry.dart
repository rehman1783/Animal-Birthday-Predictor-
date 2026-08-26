enum MovementStage {
  overdue('Overdue', 'Past expected due date'),
  foalingBarn('Foaling Barn (<14 Days)', 'Move to foaling box & 24/7 watch'),
  closePaddock('Close Paddock (15-30 Days)', 'Move to close monitoring paddock'),
  upcoming('Mid Gestation (30+ Days)', 'Routine pasture & nutrition'),
  foaled('Foaled / Completed', 'Foaling completed');

  final String title;
  final String description;
  const MovementStage(this.title, this.description);
}

class FoalingDiaryEntry {
  final String id;
  final String mareId;
  final String mareName;
  final String? microchipNo;
  final String stallionName;
  final bool isEmbryoTransfer;
  final String? donorMareName;
  final String? recipientMareName;
  final String breedingMethod; // natural, chilled, frozen, et, icsi
  final DateTime serviceDate;
  final DateTime foalingDueDate;
  final DateTime minDueDate; // 320 days
  final DateTime maxDueDate; // 365 days
  final String currentPaddock; // e.g. "Paddock 4", "Foaling Barn Box 2"
  final bool scan1Confirmed;
  final bool scan2Confirmed;
  final bool scan3Confirmed;
  final bool twinDetected;
  final bool isFoaled;
  final String notes;

  const FoalingDiaryEntry({
    required this.id,
    required this.mareId,
    required this.mareName,
    this.microchipNo,
    required this.stallionName,
    this.isEmbryoTransfer = false,
    this.donorMareName,
    this.recipientMareName,
    this.breedingMethod = 'natural',
    required this.serviceDate,
    required this.foalingDueDate,
    required this.minDueDate,
    required this.maxDueDate,
    this.currentPaddock = 'Main Broodmare Pasture',
    this.scan1Confirmed = false,
    this.scan2Confirmed = false,
    this.scan3Confirmed = false,
    this.twinDetected = false,
    this.isFoaled = false,
    this.notes = '',
  });

  int get daysRemaining {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final target = DateTime(foalingDueDate.year, foalingDueDate.month, foalingDueDate.day);
    return target.difference(today).inDays;
  }

  MovementStage get movementStage {
    if (isFoaled) return MovementStage.foaled;
    final rem = daysRemaining;
    if (rem < 0) return MovementStage.overdue;
    if (rem <= 14) return MovementStage.foalingBarn;
    if (rem <= 30) return MovementStage.closePaddock;
    return MovementStage.upcoming;
  }

  FoalingDiaryEntry copyWith({
    String? id,
    String? mareId,
    String? mareName,
    String? microchipNo,
    String? stallionName,
    bool? isEmbryoTransfer,
    String? donorMareName,
    String? recipientMareName,
    String? breedingMethod,
    DateTime? serviceDate,
    DateTime? foalingDueDate,
    DateTime? minDueDate,
    DateTime? maxDueDate,
    String? currentPaddock,
    bool? scan1Confirmed,
    bool? scan2Confirmed,
    bool? scan3Confirmed,
    bool? twinDetected,
    bool? isFoaled,
    String? notes,
  }) {
    return FoalingDiaryEntry(
      id: id ?? this.id,
      mareId: mareId ?? this.mareId,
      mareName: mareName ?? this.mareName,
      microchipNo: microchipNo ?? this.microchipNo,
      stallionName: stallionName ?? this.stallionName,
      isEmbryoTransfer: isEmbryoTransfer ?? this.isEmbryoTransfer,
      donorMareName: donorMareName ?? this.donorMareName,
      recipientMareName: recipientMareName ?? this.recipientMareName,
      breedingMethod: breedingMethod ?? this.breedingMethod,
      serviceDate: serviceDate ?? this.serviceDate,
      foalingDueDate: foalingDueDate ?? this.foalingDueDate,
      minDueDate: minDueDate ?? this.minDueDate,
      maxDueDate: maxDueDate ?? this.maxDueDate,
      currentPaddock: currentPaddock ?? this.currentPaddock,
      scan1Confirmed: scan1Confirmed ?? this.scan1Confirmed,
      scan2Confirmed: scan2Confirmed ?? this.scan2Confirmed,
      scan3Confirmed: scan3Confirmed ?? this.scan3Confirmed,
      twinDetected: twinDetected ?? this.twinDetected,
      isFoaled: isFoaled ?? this.isFoaled,
      notes: notes ?? this.notes,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'mare_id': mareId,
      'mare_name': mareName,
      'microchip_no': microchipNo,
      'stallion_name': stallionName,
      'is_embryo_transfer': isEmbryoTransfer,
      'donor_mare_name': donorMareName,
      'recipient_mare_name': recipientMareName,
      'breeding_method': breedingMethod,
      'service_date': serviceDate.toIso8601String().split('T').first,
      'foaling_due_date': foalingDueDate.toIso8601String().split('T').first,
      'min_due_date': minDueDate.toIso8601String().split('T').first,
      'max_due_date': maxDueDate.toIso8601String().split('T').first,
      'current_paddock': currentPaddock,
      'scan1_confirmed': scan1Confirmed,
      'scan2_confirmed': scan2Confirmed,
      'scan3_confirmed': scan3Confirmed,
      'twin_detected': twinDetected,
      'is_foaled': isFoaled,
      'notes': notes,
    };
  }

  factory FoalingDiaryEntry.fromJson(Map<String, dynamic> json) {
    final service = DateTime.tryParse(json['service_date']?.toString() ?? '') ?? DateTime.now();
    final due = DateTime.tryParse(json['foaling_due_date']?.toString() ?? '') ?? service.add(const Duration(days: 340));
    final minDue = DateTime.tryParse(json['min_due_date']?.toString() ?? '') ?? service.add(const Duration(days: 320));
    final maxDue = DateTime.tryParse(json['max_due_date']?.toString() ?? '') ?? service.add(const Duration(days: 365));

    return FoalingDiaryEntry(
      id: json['id'] as String? ?? '',
      mareId: json['mare_id'] as String? ?? '',
      mareName: json['mare_name'] as String? ?? 'Unnamed Mare',
      microchipNo: json['microchip_no'] as String?,
      stallionName: json['stallion_name'] as String? ?? 'Recorded Stallion',
      isEmbryoTransfer: json['is_embryo_transfer'] as bool? ?? false,
      donorMareName: json['donor_mare_name'] as String?,
      recipientMareName: json['recipient_mare_name'] as String?,
      breedingMethod: json['breeding_method'] as String? ?? 'natural',
      serviceDate: service,
      foalingDueDate: due,
      minDueDate: minDue,
      maxDueDate: maxDue,
      currentPaddock: json['current_paddock'] as String? ?? 'Main Broodmare Pasture',
      scan1Confirmed: json['scan1_confirmed'] as bool? ?? false,
      scan2Confirmed: json['scan2_confirmed'] as bool? ?? false,
      scan3Confirmed: json['scan3_confirmed'] as bool? ?? false,
      twinDetected: json['twin_detected'] as bool? ?? false,
      isFoaled: json['is_foaled'] as bool? ?? false,
      notes: json['notes'] as String? ?? '',
    );
  }
}
