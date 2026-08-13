class BreedingRecord {
  final String id;
  final String mareId;
  final String method; // 'natural', 'chilled', 'frozen', 'icsi'
  final bool isEmbryoTransfer;
  final DateTime? coverOrTransferDate;
  final String? photoUrl;
  final DateTime createdAt;

  const BreedingRecord({
    required this.id,
    required this.mareId,
    required this.method,
    this.isEmbryoTransfer = false,
    this.coverOrTransferDate,
    this.photoUrl,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'mare_id': mareId,
      'method': method,
      'is_embryo_transfer': isEmbryoTransfer,
      'cover_or_transfer_date': coverOrTransferDate?.toIso8601String(),
      'photo_url': photoUrl,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory BreedingRecord.fromJson(Map<String, dynamic> json) {
    return BreedingRecord(
      id: json['id'] as String,
      mareId: json['mare_id'] as String,
      method: json['method'] as String,
      isEmbryoTransfer: json['is_embryo_transfer'] as bool? ?? false,
      coverOrTransferDate: json['cover_or_transfer_date'] != null
          ? DateTime.parse(json['cover_or_transfer_date'] as String)
          : null,
      photoUrl: json['photo_url'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
    );
  }
}
