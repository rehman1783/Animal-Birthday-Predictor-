class Contact {
  final String id;
  final String accountId;
  final String name;
  final String? phone;
  final String? email;
  final String role; // 'vet', 'farrier', 'dentist', 'owner', 'buyer', 'general'
  final String? clinicOrBusiness;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Contact({
    required this.id,
    required this.accountId,
    required this.name,
    this.phone,
    this.email,
    this.role = 'general',
    this.clinicOrBusiness,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'account_id': accountId,
      'name': name,
      'phone': phone,
      'email': email,
      'role': role,
      'clinic_or_business': clinicOrBusiness,
      'notes': notes,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  factory Contact.fromMap(Map<String, dynamic> map) {
    return Contact(
      id: map['id'] as String,
      accountId: map['account_id'] as String? ?? '',
      name: map['name'] as String? ?? '',
      phone: map['phone'] as String?,
      email: map['email'] as String?,
      role: map['role'] as String? ?? 'general',
      clinicOrBusiness: map['clinic_or_business'] as String?,
      notes: map['notes'] as String?,
      createdAt: map['created_at'] != null ? DateTime.parse(map['created_at']) : DateTime.now(),
      updatedAt: map['updated_at'] != null ? DateTime.parse(map['updated_at']) : DateTime.now(),
    );
  }

  Contact copyWith({
    String? id,
    String? accountId,
    String? name,
    String? phone,
    String? email,
    String? role,
    String? clinicOrBusiness,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Contact(
      id: id ?? this.id,
      accountId: accountId ?? this.accountId,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      role: role ?? this.role,
      clinicOrBusiness: clinicOrBusiness ?? this.clinicOrBusiness,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
