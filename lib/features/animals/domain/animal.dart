class Animal {
  final String id;
  final String accountId;
  final String species; // 'horse', 'dog', 'cat', 'other'
  final String name;
  final String? sex; // 'mare', 'stallion', 'gelding', 'female', 'male'
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
    this.sex,
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

  bool get isMare {
    if (species != 'horse') return false;
    final s = sex?.toLowerCase().trim();
    if (s == null || s.isEmpty) return true; // Default horse is Mare
    return s == 'mare' || s == 'female' || s == 'dam';
  }

  bool get isStallion {
    final s = sex?.toLowerCase().trim();
    if (s == null) return false;
    return s == 'stallion' || s == 'male' || s == 'stud' || s == 'sire';
  }

  bool get isGelding {
    final s = sex?.toLowerCase().trim();
    return s == 'gelding';
  }

  bool get isDamOrBitch {
    if (species != 'dog') return false;
    final s = sex?.toLowerCase().trim();
    if (s == null || s.isEmpty) return true;
    return s == 'dam' || s == 'bitch' || s == 'female';
  }

  bool get isStudOrDog {
    if (species != 'dog') return false;
    final s = sex?.toLowerCase().trim();
    if (s == null) return false;
    return s == 'stud' || s == 'sire' || s == 'male' || s == 'dog';
  }

  String get displaySex {
    if (species == 'horse') {
      if (isStallion) return 'Stallion';
      if (isGelding) return 'Gelding';
      return 'Mare';
    } else if (species == 'dog') {
      if (isStudOrDog) return 'Stud (Male)';
      return 'Dam / Bitch';
    } else {
      final s = sex?.toLowerCase().trim();
      return (s == 'male' || s == 'tom') ? 'Male' : 'Female';
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'account_id': accountId,
      'species': species,
      'name': name,
      if (sex != null) 'sex': sex,
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
      sex: json['sex']?.toString() ?? json['gender']?.toString() ?? json['horse_type']?.toString(),
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
    String? sex,
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
      sex: sex ?? this.sex,
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
