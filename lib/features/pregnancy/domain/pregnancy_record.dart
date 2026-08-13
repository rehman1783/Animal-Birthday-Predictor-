class PregnancyRecord {
  final String id;
  final String carrierType; // 'mare', 'recipient_mare'
  final String carrierId;
  final String? breedingRecordId;
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
  final String? vetMobile;
  final DateTime createdAt;

  const PregnancyRecord({
    required this.id,
    required this.carrierType,
    required this.carrierId,
    this.breedingRecordId,
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
    this.vetMobile,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'carrier_type': carrierType,
      'carrier_id': carrierId,
      'breeding_record_id': breedingRecordId,
      'scan_1_due_date': scan1DueDate?.toIso8601String(),
      'scan_1_confirmed': scan1Confirmed,
      'scan_1_image_url': scan1ImageUrl,
      'scan_2_due_date': scan2DueDate?.toIso8601String(),
      'scan_2_confirmed': scan2Confirmed,
      'scan_2_image_url': scan2ImageUrl,
      'scan_3_due_date': scan3DueDate?.toIso8601String(),
      'scan_3_confirmed': scan3Confirmed,
      'scan_3_image_url': scan3ImageUrl,
      'foaling_due_date': foalingDueDate?.toIso8601String(),
      'vet_name': vetName,
      'vet_mobile': vetMobile,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory PregnancyRecord.fromJson(Map<String, dynamic> json) {
    return PregnancyRecord(
      id: json['id'] as String,
      carrierType: json['carrier_type'] as String? ?? 'mare',
      carrierId: json['carrier_id'] as String? ?? '',
      breedingRecordId: json['breeding_record_id'] as String?,
      scan1DueDate: json['scan_1_due_date'] != null
          ? DateTime.parse(json['scan_1_due_date'] as String)
          : null,
      scan1Confirmed: json['scan_1_confirmed'] as bool? ?? false,
      scan1ImageUrl: json['scan_1_image_url'] as String?,
      scan2DueDate: json['scan_2_due_date'] != null
          ? DateTime.parse(json['scan_2_due_date'] as String)
          : null,
      scan2Confirmed: json['scan_2_confirmed'] as bool? ?? false,
      scan2ImageUrl: json['scan_2_image_url'] as String?,
      scan3DueDate: json['scan_3_due_date'] != null
          ? DateTime.parse(json['scan_3_due_date'] as String)
          : null,
      scan3Confirmed: json['scan_3_confirmed'] as bool? ?? false,
      scan3ImageUrl: json['scan_3_image_url'] as String?,
      foalingDueDate: json['foaling_due_date'] != null
          ? DateTime.parse(json['foaling_due_date'] as String)
          : null,
      vetName: json['vet_name'] as String?,
      vetMobile: json['vet_mobile'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
    );
  }
}
