class Animal {
  final String id;
  final String accountId;
  final String species; // 'horse', 'dog', 'cat', 'other'
  final String name;
  final String? breed;
  final String? colour;
  final DateTime? dateOfBirth;
  final String? microchipNo;
  final String? dna;
  final String? brand;
  final String? ownerClientName;
  final String? ownerClientPhone;
  final String? photoUrl;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Animal({
    required this.id,
    required this.accountId,
    required this.species,
    required this.name,
    this.breed,
    this.colour,
    this.dateOfBirth,
    this.microchipNo,
    this.dna,
    this.brand,
    this.ownerClientName,
    this.ownerClientPhone,
    this.photoUrl,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'account_id': accountId,
      'species': species,
      'name': name,
      'breed': breed,
      'colour': colour,
      'date_of_birth': dateOfBirth?.toIso8601String().split('T').first,
      'microchip_no': microchipNo,
      'dna': dna,
      'brand': brand,
      'owner_client_name': ownerClientName,
      'owner_client_phone': ownerClientPhone,
      'photo_url': photoUrl,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  factory Animal.fromJson(Map<String, dynamic> json) {
    return Animal(
      id: json['id'] as String? ?? '',
      accountId: json['account_id'] as String? ?? '',
      species: json['species'] as String? ?? 'horse',
      name: json['name'] as String? ?? '',
      breed: json['breed'] as String?,
      colour: json['colour'] as String?,
      dateOfBirth: json['date_of_birth'] != null
          ? DateTime.tryParse(json['date_of_birth'] as String)
          : null,
      microchipNo: json['microchip_no'] as String?,
      dna: json['dna'] as String?,
      brand: json['brand'] as String?,
      ownerClientName: json['owner_client_name'] as String?,
      ownerClientPhone: json['owner_client_phone'] as String?,
      photoUrl: json['photo_url'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'] as String) ?? DateTime.now()
          : DateTime.now(),
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'] as String) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  Animal copyWith({
    String? id,
    String? accountId,
    String? species,
    String? name,
    String? breed,
    String? colour,
    DateTime? dateOfBirth,
    String? microchipNo,
    String? dna,
    String? brand,
    String? ownerClientName,
    String? ownerClientPhone,
    String? photoUrl,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Animal(
      id: id ?? this.id,
      accountId: accountId ?? this.accountId,
      species: species ?? this.species,
      name: name ?? this.name,
      breed: breed ?? this.breed,
      colour: colour ?? this.colour,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      microchipNo: microchipNo ?? this.microchipNo,
      dna: dna ?? this.dna,
      brand: brand ?? this.brand,
      ownerClientName: ownerClientName ?? this.ownerClientName,
      ownerClientPhone: ownerClientPhone ?? this.ownerClientPhone,
      photoUrl: photoUrl ?? this.photoUrl,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
