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
    final rawSpecies = json['species']?.toString();
    final normalized = rawSpecies != null && rawSpecies.trim().isNotEmpty
        ? Animal.normalizeSpecies(rawSpecies)
        : 'horse';

    return Animal(
      id: json['id']?.toString() ?? '',
      accountId: json['account_id']?.toString() ?? '',
      species: normalized,
      name: json['name']?.toString() ?? '',
      breed: json['breed']?.toString(),
      colour: json['colour']?.toString(),
      dateOfBirth: json['date_of_birth'] != null
          ? DateTime.tryParse(json['date_of_birth'].toString())
          : null,
      microchipNo: json['microchip_no']?.toString(),
      dna: json['dna']?.toString(),
      brand: json['brand']?.toString(),
      ownerClientName: json['owner_client_name']?.toString(),
      ownerClientPhone: json['owner_client_phone']?.toString(),
      photoUrl: json['photo_url']?.toString(),
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString()) ?? DateTime.now()
          : DateTime.now(),
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'].toString()) ?? DateTime.now()
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

  static String normalizeSpecies(String? raw) {
    if (raw == null) return 'horse';
    final s = raw.toLowerCase().trim();
    if (s.isEmpty) return 'horse';

    // 1. Dog / Canine check
    if (s == 'dog' ||
        s == 'dogs' ||
        s == 'canine' ||
        s == 'puppy' ||
        s == 'bitch' ||
        s == 'hound' ||
        s.contains('dog') ||
        s.contains('canine') ||
        s.contains('puppy') ||
        s.contains('hound')) {
      return 'dog';
    }

    // 2. Cat / Feline check
    if (s == 'cat' ||
        s == 'cats' ||
        s == 'feline' ||
        s == 'kitten' ||
        s.contains('cat') ||
        s.contains('feline') ||
        s.contains('kitten')) {
      return 'cat';
    }

    // 3. Horse / Equine check
    if (s == 'horse' ||
        s == 'horses' ||
        s == 'equine' ||
        s == 'mare' ||
        s == 'stallion' ||
        s == 'foal' ||
        s.contains('horse') ||
        s.contains('equine') ||
        s.contains('mare') ||
        s.contains('stallion') ||
        s.contains('foal')) {
      return 'horse';
    }

    // 4. Other check
    if (s == 'other' || s.contains('other')) {
      return 'other';
    }

    return s;
  }

  static bool matchesSpeciesFilter(String? animalSpecies, String? filterTab) {
    if (filterTab == null || filterTab.isEmpty) return true;
    final normalizedAnimal = normalizeSpecies(animalSpecies);
    final normalizedFilter = normalizeSpecies(filterTab);

    if (normalizedFilter == 'other') {
      return normalizedAnimal != 'horse' && normalizedAnimal != 'dog' && normalizedAnimal != 'cat';
    }
    return normalizedAnimal == normalizedFilter;
  }
}
