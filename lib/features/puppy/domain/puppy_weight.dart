class PuppyWeight {
  final String id;
  final String puppyId;
  final String accountId;
  final DateTime weightDate;
  final int? ageInDays;
  final String weight;
  final String? notes;
  final DateTime createdAt;

  const PuppyWeight({
    required this.id,
    required this.puppyId,
    required this.accountId,
    required this.weightDate,
    this.ageInDays,
    required this.weight,
    this.notes,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'puppy_id': puppyId,
      'account_id': accountId,
      'weight_date': weightDate.toIso8601String().split('T').first,
      'age_in_days': ageInDays,
      'weight': weight,
      'notes': notes,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory PuppyWeight.fromJson(Map<String, dynamic> json) {
    return PuppyWeight(
      id: json['id'] as String,
      puppyId: json['puppy_id'] as String? ?? '',
      accountId: json['account_id'] as String? ?? '',
      weightDate: json['weight_date'] != null
          ? DateTime.tryParse(json['weight_date'] as String) ?? DateTime.now()
          : DateTime.now(),
      ageInDays: json['age_in_days'] as int?,
      weight: json['weight'] as String? ?? '',
      notes: json['notes'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'] as String) ?? DateTime.now()
          : DateTime.now(),
    );
  }
}
