class DogPreventativeCareItem {
  final String id;
  final String accountId;
  final String ownerType; // 'animal', 'puppy'
  final String ownerId;
  final String treatmentType; // 'worming', 'vaccination', 'vet_check', 'microchip', 'other'
  final String title;
  final DateTime? dateGiven;
  final DateTime? dateDue;
  final bool isCompleted;
  final String? administeredBy;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;

  const DogPreventativeCareItem({
    required this.id,
    required this.accountId,
    required this.ownerType,
    required this.ownerId,
    required this.treatmentType,
    required this.title,
    this.dateGiven,
    this.dateDue,
    this.isCompleted = false,
    this.administeredBy,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'account_id': accountId,
      'owner_type': ownerType,
      'owner_id': ownerId,
      'treatment_type': treatmentType,
      'title': title,
      'date_given': dateGiven?.toIso8601String().split('T').first,
      'date_due': dateDue?.toIso8601String().split('T').first,
      'is_completed': isCompleted,
      'administered_by': administeredBy,
      'notes': notes,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  factory DogPreventativeCareItem.fromJson(Map<String, dynamic> json) {
    return DogPreventativeCareItem(
      id: json['id'] as String,
      accountId: json['account_id'] as String? ?? '',
      ownerType: json['owner_type'] as String? ?? 'puppy',
      ownerId: json['owner_id'] as String? ?? '',
      treatmentType: json['treatment_type'] as String? ?? 'other',
      title: json['title'] as String? ?? '',
      dateGiven: json['date_given'] != null
          ? DateTime.tryParse(json['date_given'] as String)
          : null,
      dateDue: json['date_due'] != null
          ? DateTime.tryParse(json['date_due'] as String)
          : null,
      isCompleted: json['is_completed'] as bool? ?? false,
      administeredBy: json['administered_by'] as String?,
      notes: json['notes'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'] as String) ?? DateTime.now()
          : DateTime.now(),
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'] as String) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  DogPreventativeCareItem copyWith({
    String? id,
    String? accountId,
    String? ownerType,
    String? ownerId,
    String? treatmentType,
    String? title,
    DateTime? dateGiven,
    DateTime? dateDue,
    bool? isCompleted,
    String? administeredBy,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return DogPreventativeCareItem(
      id: id ?? this.id,
      accountId: accountId ?? this.accountId,
      ownerType: ownerType ?? this.ownerType,
      ownerId: ownerId ?? this.ownerId,
      treatmentType: treatmentType ?? this.treatmentType,
      title: title ?? this.title,
      dateGiven: dateGiven ?? this.dateGiven,
      dateDue: dateDue ?? this.dateDue,
      isCompleted: isCompleted ?? this.isCompleted,
      administeredBy: administeredBy ?? this.administeredBy,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
