class BreedingRecord {
  final String id;
  final String accountId;
  final String mareAnimalId;
  final String? stallionName;
  final String method; // 'natural', 'chilled', 'frozen', 'icsi'
  final DateTime? coverOrTransferDate;
  final bool isEmbryoTransfer;
  final String? recipientAnimalId;
  final String? damOfEmbryo;
  final String? stallionOfEmbryo;
  final String? photoUrl;
  final DateTime createdAt;
  final DateTime updatedAt;

  const BreedingRecord({
    required this.id,
    required this.accountId,
    required this.mareAnimalId,
    this.stallionName,
    required this.method,
    this.coverOrTransferDate,
    this.isEmbryoTransfer = false,
    this.recipientAnimalId,
    this.damOfEmbryo,
    this.stallionOfEmbryo,
    this.photoUrl,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'account_id': accountId,
      'mare_animal_id': mareAnimalId,
      'stallion_name': stallionName,
      'method': method,
      'cover_or_transfer_date': coverOrTransferDate?.toIso8601String().split('T').first,
      'is_embryo_transfer': isEmbryoTransfer,
      'recipient_animal_id': recipientAnimalId,
      'dam_of_embryo': damOfEmbryo,
      'stallion_of_embryo': stallionOfEmbryo,
      'photo_url': photoUrl,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  factory BreedingRecord.fromJson(Map<String, dynamic> json) {
    return BreedingRecord(
      id: json['id'] as String? ?? '',
      accountId: json['account_id'] as String? ?? '',
      mareAnimalId: json['mare_animal_id'] as String? ?? json['mare_id'] as String? ?? '',
      stallionName: json['stallion_name'] as String?,
      method: json['method'] as String? ?? 'natural',
      coverOrTransferDate: json['cover_or_transfer_date'] != null
          ? DateTime.tryParse(json['cover_or_transfer_date'] as String)
          : null,
      isEmbryoTransfer: json['is_embryo_transfer'] as bool? ?? false,
      recipientAnimalId: json['recipient_animal_id'] as String?,
      damOfEmbryo: json['dam_of_embryo'] as String?,
      stallionOfEmbryo: json['stallion_of_embryo'] as String?,
      photoUrl: json['photo_url'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'] as String) ?? DateTime.now()
          : DateTime.now(),
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'] as String) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  BreedingRecord copyWith({
    String? id,
    String? accountId,
    String? mareAnimalId,
    String? stallionName,
    String? method,
    DateTime? coverOrTransferDate,
    bool? isEmbryoTransfer,
    String? recipientAnimalId,
    String? damOfEmbryo,
    String? stallionOfEmbryo,
    String? photoUrl,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return BreedingRecord(
      id: id ?? this.id,
      accountId: accountId ?? this.accountId,
      mareAnimalId: mareAnimalId ?? this.mareAnimalId,
      stallionName: stallionName ?? this.stallionName,
      method: method ?? this.method,
      coverOrTransferDate: coverOrTransferDate ?? this.coverOrTransferDate,
      isEmbryoTransfer: isEmbryoTransfer ?? this.isEmbryoTransfer,
      recipientAnimalId: recipientAnimalId ?? this.recipientAnimalId,
      damOfEmbryo: damOfEmbryo ?? this.damOfEmbryo,
      stallionOfEmbryo: stallionOfEmbryo ?? this.stallionOfEmbryo,
      photoUrl: photoUrl ?? this.photoUrl,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
