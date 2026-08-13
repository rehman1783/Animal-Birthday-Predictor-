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
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'pregnancy_record_id': pregnancyRecordId,
      'caslick_date': caslickDate?.toIso8601String(),
      'caslick_done': caslickDone,
      'fetal_sex_scan_date': fetalSexScanDate?.toIso8601String(),
      'fetal_sex_scan_done': fetalSexScanDone,
      'ffs_result_date': ffsResultDate?.toIso8601String(),
      'ffs_result': ffsResult,
      'ultrasound_image_url': ultrasoundImageUrl,
    };
  }

  factory AdvancedPregnancyInfo.fromJson(Map<String, dynamic> json) {
    return AdvancedPregnancyInfo(
      id: json['id'] as String,
      pregnancyRecordId: json['pregnancy_record_id'] as String,
      caslickDate: json['caslick_date'] != null
          ? DateTime.parse(json['caslick_date'] as String)
          : null,
      caslickDone: json['caslick_done'] as bool? ?? false,
      fetalSexScanDate: json['fetal_sex_scan_date'] != null
          ? DateTime.parse(json['fetal_sex_scan_date'] as String)
          : null,
      fetalSexScanDone: json['fetal_sex_scan_done'] as bool? ?? false,
      ffsResultDate: json['ffs_result_date'] != null
          ? DateTime.parse(json['ffs_result_date'] as String)
          : null,
      ffsResult: json['ffs_result'] as String?,
      ultrasoundImageUrl: json['ultrasound_image_url'] as String?,
    );
  }
}
