class PregnancyRecord {
  final String id;
  final String accountId;
  final String breedingRecordId;
  final String carrierAnimalId;
  final DateTime? scan1DueDate;
  final bool scan1Confirmed;
  final String? scan1ImageUrl;
  final DateTime? scan2DueDate;
  final bool scan2Confirmed;
  final String? scan2ImageUrl;
  final DateTime? scan3DueDate;
  final bool scan3Confirmed;
  final String? scan3ImageUrl;
  final DateTime? foalingDueDate;
  final String? vetName;
  final String? vetNumber;
  final DateTime createdAt;
  final DateTime updatedAt;

  const PregnancyRecord({
    required this.id,
    required this.accountId,
    required this.breedingRecordId,
    required this.carrierAnimalId,
    this.scan1DueDate,
    this.scan1Confirmed = false,
    this.scan1ImageUrl,
    this.scan2DueDate,
    this.scan2Confirmed = false,
    this.scan2ImageUrl,
    this.scan3DueDate,
    this.scan3Confirmed = false,
    this.scan3ImageUrl,
    this.foalingDueDate,
    this.vetName,
    this.vetNumber,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'account_id': accountId,
      'breeding_record_id': breedingRecordId,
      'carrier_animal_id': carrierAnimalId,
      'scan_1_due_date': scan1DueDate?.toIso8601String().split('T').first,
      'scan_1_confirmed': scan1Confirmed,
      'scan_1_image_url': scan1ImageUrl,
      'scan_2_due_date': scan2DueDate?.toIso8601String().split('T').first,
      'scan_2_confirmed': scan2Confirmed,
      'scan_2_image_url': scan2ImageUrl,
      'scan_3_due_date': scan3DueDate?.toIso8601String().split('T').first,
      'scan_3_confirmed': scan3Confirmed,
      'scan_3_image_url': scan3ImageUrl,
      'foaling_due_date': foalingDueDate?.toIso8601String().split('T').first,
      'vet_name': vetName,
      'vet_number': vetNumber,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  factory PregnancyRecord.fromJson(Map<String, dynamic> json) {
    return PregnancyRecord(
      id: json['id'] as String? ?? '',
      accountId: json['account_id'] as String? ?? '',
      breedingRecordId: json['breeding_record_id'] as String? ?? '',
      carrierAnimalId: json['carrier_animal_id'] as String? ?? json['carrier_id'] as String? ?? '',
      scan1DueDate: json['scan_1_due_date'] != null
          ? DateTime.tryParse(json['scan_1_due_date'] as String)
          : null,
      scan1Confirmed: json['scan_1_confirmed'] as bool? ?? false,
      scan1ImageUrl: json['scan_1_image_url'] as String?,
      scan2DueDate: json['scan_2_due_date'] != null
          ? DateTime.tryParse(json['scan_2_due_date'] as String)
          : null,
      scan2Confirmed: json['scan_2_confirmed'] as bool? ?? false,
      scan2ImageUrl: json['scan_2_image_url'] as String?,
      scan3DueDate: json['scan_3_due_date'] != null
          ? DateTime.tryParse(json['scan_3_due_date'] as String)
          : null,
      scan3Confirmed: json['scan_3_confirmed'] as bool? ?? false,
      scan3ImageUrl: json['scan_3_image_url'] as String?,
      foalingDueDate: json['foaling_due_date'] != null
          ? DateTime.tryParse(json['foaling_due_date'] as String)
          : null,
      vetName: json['vet_name'] as String?,
      vetNumber: json['vet_number'] as String? ?? json['vet_mobile'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'] as String) ?? DateTime.now()
          : DateTime.now(),
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'] as String) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  PregnancyRecord copyWith({
    String? id,
    String? accountId,
    String? breedingRecordId,
    String? carrierAnimalId,
    DateTime? scan1DueDate,
    bool? scan1Confirmed,
    String? scan1ImageUrl,
    DateTime? scan2DueDate,
    bool? scan2Confirmed,
    String? scan2ImageUrl,
    DateTime? scan3DueDate,
    bool? scan3Confirmed,
    String? scan3ImageUrl,
    DateTime? foalingDueDate,
    String? vetName,
    String? vetNumber,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return PregnancyRecord(
      id: id ?? this.id,
      accountId: accountId ?? this.accountId,
      breedingRecordId: breedingRecordId ?? this.breedingRecordId,
      carrierAnimalId: carrierAnimalId ?? this.carrierAnimalId,
      scan1DueDate: scan1DueDate ?? this.scan1DueDate,
      scan1Confirmed: scan1Confirmed ?? this.scan1Confirmed,
      scan1ImageUrl: scan1ImageUrl ?? this.scan1ImageUrl,
      scan2DueDate: scan2DueDate ?? this.scan2DueDate,
      scan2Confirmed: scan2Confirmed ?? this.scan2Confirmed,
      scan2ImageUrl: scan2ImageUrl ?? this.scan2ImageUrl,
      scan3DueDate: scan3DueDate ?? this.scan3DueDate,
      scan3Confirmed: scan3Confirmed ?? this.scan3Confirmed,
      scan3ImageUrl: scan3ImageUrl ?? this.scan3ImageUrl,
      foalingDueDate: foalingDueDate ?? this.foalingDueDate,
      vetName: vetName ?? this.vetName,
      vetNumber: vetNumber ?? this.vetNumber,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
