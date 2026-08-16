class AdvancedPregnancyInfo {
  final String id;
  final String pregnancyRecordId;
  final DateTime? caslickDate;
  final bool caslickDone;
  final DateTime? fetalSexScanDate;
  final bool fetalSexScanDone;
  final DateTime? ffsResultDate;
  final String? ffsResult; // 'filly', 'colt'
  final String? ultrasoundImageUrl;
  final DateTime createdAt;
  final DateTime updatedAt;

  const AdvancedPregnancyInfo({
    required this.id,
    required this.pregnancyRecordId,
    this.caslickDate,
    this.caslickDone = false,
    this.fetalSexScanDate,
    this.fetalSexScanDone = false,
    this.ffsResultDate,
    this.ffsResult,
    this.ultrasoundImageUrl,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'pregnancy_record_id': pregnancyRecordId,
      'caslick_date': caslickDate?.toIso8601String().split('T').first,
      'caslick_done': caslickDone,
      'fetal_sex_scan_date': fetalSexScanDate?.toIso8601String().split('T').first,
      'fetal_sex_scan_done': fetalSexScanDone,
      'ffs_result_date': ffsResultDate?.toIso8601String().split('T').first,
      'ffs_result': ffsResult,
      'ultrasound_image_url': ultrasoundImageUrl,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  factory AdvancedPregnancyInfo.fromJson(Map<String, dynamic> json) {
    return AdvancedPregnancyInfo(
      id: json['id'] as String? ?? '',
      pregnancyRecordId: json['pregnancy_record_id'] as String? ?? '',
      caslickDate: json['caslick_date'] != null
          ? DateTime.tryParse(json['caslick_date'] as String)
          : null,
      caslickDone: json['caslick_done'] as bool? ?? false,
      fetalSexScanDate: json['fetal_sex_scan_date'] != null
          ? DateTime.tryParse(json['fetal_sex_scan_date'] as String)
          : null,
      fetalSexScanDone: json['fetal_sex_scan_done'] as bool? ?? false,
      ffsResultDate: json['ffs_result_date'] != null
          ? DateTime.tryParse(json['ffs_result_date'] as String)
          : null,
      ffsResult: json['ffs_result'] as String?,
      ultrasoundImageUrl: json['ultrasound_image_url'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'] as String) ?? DateTime.now()
          : DateTime.now(),
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'] as String) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  AdvancedPregnancyInfo copyWith({
    String? id,
    String? pregnancyRecordId,
    DateTime? caslickDate,
    bool? caslickDone,
    DateTime? fetalSexScanDate,
    bool? fetalSexScanDone,
    DateTime? ffsResultDate,
    String? ffsResult,
    String? ultrasoundImageUrl,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return AdvancedPregnancyInfo(
      id: id ?? this.id,
      pregnancyRecordId: pregnancyRecordId ?? this.pregnancyRecordId,
      caslickDate: caslickDate ?? this.caslickDate,
      caslickDone: caslickDone ?? this.caslickDone,
      fetalSexScanDate: fetalSexScanDate ?? this.fetalSexScanDate,
      fetalSexScanDone: fetalSexScanDone ?? this.fetalSexScanDone,
      ffsResultDate: ffsResultDate ?? this.ffsResultDate,
      ffsResult: ffsResult ?? this.ffsResult,
      ultrasoundImageUrl: ultrasoundImageUrl ?? this.ultrasoundImageUrl,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
