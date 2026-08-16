class Puppy {
  final String id;
  final String accountId;
  final String? damAnimalId;
  final String? sireName;
  final String? sireAnimalId;
  final String? puppyName;
  final String? collarTagColour;
  final String? sex; // 'male', 'female'
  final String? colour;
  final int? birthOrder;
  final DateTime? dateOfBirth;
  final String? timeOfBirth;
  final String? birthWeight;
  final String? currentWeight;
  final String? microchipNo;
  final String? dna;
  final String? status; // 'available', 'reserved', 'sold', 'keep', 'transferred'
  final DateTime? dateGoingHome;
  final String? newOwnerName;
  final String? newOwnerPhone;
  final String? newOwnerAddress;
  final String? generalNotes;
  final String? photoUrl;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Puppy({
    required this.id,
    required this.accountId,
    this.damAnimalId,
    this.sireName,
    this.sireAnimalId,
    this.puppyName,
    this.collarTagColour,
    this.sex,
    this.colour,
    this.birthOrder,
    this.dateOfBirth,
    this.timeOfBirth,
    this.birthWeight,
    this.currentWeight,
    this.microchipNo,
    this.dna,
    this.status = 'available',
    this.dateGoingHome,
    this.newOwnerName,
    this.newOwnerPhone,
    this.newOwnerAddress,
    this.generalNotes,
    this.photoUrl,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'account_id': accountId,
      'dam_animal_id': damAnimalId,
      'sire_name': sireName,
      'sire_animal_id': sireAnimalId,
      'puppy_name': puppyName,
      'collar_tag_colour': collarTagColour,
      'sex': sex,
      'colour': colour,
      'birth_order': birthOrder,
      'date_of_birth': dateOfBirth?.toIso8601String().split('T').first,
      'time_of_birth': timeOfBirth,
      'birth_weight': birthWeight,
      'current_weight': currentWeight,
      'microchip_no': microchipNo,
      'dna': dna,
      'status': status,
      'date_going_home': dateGoingHome?.toIso8601String().split('T').first,
      'new_owner_name': newOwnerName,
      'new_owner_phone': newOwnerPhone,
      'new_owner_address': newOwnerAddress,
      'general_notes': generalNotes,
      'photo_url': photoUrl,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  factory Puppy.fromJson(Map<String, dynamic> json) {
    return Puppy(
      id: json['id'] as String,
      accountId: json['account_id'] as String? ?? '',
      damAnimalId: json['dam_animal_id'] as String?,
      sireName: json['sire_name'] as String?,
      sireAnimalId: json['sire_animal_id'] as String?,
      puppyName: json['puppy_name'] as String?,
      collarTagColour: json['collar_tag_colour'] as String?,
      sex: json['sex'] as String?,
      colour: json['colour'] as String?,
      birthOrder: json['birth_order'] as int?,
      dateOfBirth: json['date_of_birth'] != null
          ? DateTime.tryParse(json['date_of_birth'] as String)
          : null,
      timeOfBirth: json['time_of_birth'] as String?,
      birthWeight: json['birth_weight'] as String?,
      currentWeight: json['current_weight'] as String?,
      microchipNo: json['microchip_no'] as String?,
      dna: json['dna'] as String?,
      status: json['status'] as String? ?? 'available',
      dateGoingHome: json['date_going_home'] != null
          ? DateTime.tryParse(json['date_going_home'] as String)
          : null,
      newOwnerName: json['new_owner_name'] as String?,
      newOwnerPhone: json['new_owner_phone'] as String?,
      newOwnerAddress: json['new_owner_address'] as String?,
      generalNotes: json['general_notes'] as String?,
      photoUrl: json['photo_url'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'] as String) ?? DateTime.now()
          : DateTime.now(),
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'] as String) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  Puppy copyWith({
    String? id,
    String? accountId,
    String? damAnimalId,
    String? sireName,
    String? sireAnimalId,
    String? puppyName,
    String? collarTagColour,
    String? sex,
    String? colour,
    int? birthOrder,
    DateTime? dateOfBirth,
    String? timeOfBirth,
    String? birthWeight,
    String? currentWeight,
    String? microchipNo,
    String? dna,
    String? status,
    DateTime? dateGoingHome,
    String? newOwnerName,
    String? newOwnerPhone,
    String? newOwnerAddress,
    String? generalNotes,
    String? photoUrl,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Puppy(
      id: id ?? this.id,
      accountId: accountId ?? this.accountId,
      damAnimalId: damAnimalId ?? this.damAnimalId,
      sireName: sireName ?? this.sireName,
      sireAnimalId: sireAnimalId ?? this.sireAnimalId,
      puppyName: puppyName ?? this.puppyName,
      collarTagColour: collarTagColour ?? this.collarTagColour,
      sex: sex ?? this.sex,
      colour: colour ?? this.colour,
      birthOrder: birthOrder ?? this.birthOrder,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      timeOfBirth: timeOfBirth ?? this.timeOfBirth,
      birthWeight: birthWeight ?? this.birthWeight,
      currentWeight: currentWeight ?? this.currentWeight,
      microchipNo: microchipNo ?? this.microchipNo,
      dna: dna ?? this.dna,
      status: status ?? this.status,
      dateGoingHome: dateGoingHome ?? this.dateGoingHome,
      newOwnerName: newOwnerName ?? this.newOwnerName,
      newOwnerPhone: newOwnerPhone ?? this.newOwnerPhone,
      newOwnerAddress: newOwnerAddress ?? this.newOwnerAddress,
      generalNotes: generalNotes ?? this.generalNotes,
      photoUrl: photoUrl ?? this.photoUrl,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
