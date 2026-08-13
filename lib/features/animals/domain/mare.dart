class Mare {
  final String id;
  final String accountId;
  final String name;
  final String? breed;
  final String? brand;
  final String? dna;
  final String? microchipNo;
  final String? ownerClientName;
  final String? ownerClientPhone;
  final String? photoUrl;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Mare({
    required this.id,
    required this.accountId,
    required this.name,
    this.breed,
    this.brand,
    this.dna,
    this.microchipNo,
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
      'name': name,
      'breed': breed,
      'brand': brand,
      'dna': dna,
      'microchip_no': microchipNo,
      'owner_client_name': ownerClientName,
      'owner_client_phone': ownerClientPhone,
      'photo_url': photoUrl,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  factory Mare.fromJson(Map<String, dynamic> json) {
    return Mare(
      id: json['id'] as String,
      accountId: json['account_id'] as String? ?? '',
      name: json['name'] as String,
      breed: json['breed'] as String?,
      brand: json['brand'] as String?,
      dna: json['dna'] as String?,
      microchipNo: json['microchip_no'] as String?,
      ownerClientName: json['owner_client_name'] as String?,
      ownerClientPhone: json['owner_client_phone'] as String?,
      photoUrl: json['photo_url'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : DateTime.now(),
    );
  }
}

class RecipientMare {
  final String id;
  final String accountId;
  final String? breedingRecordId;
  final String nameNo;
  final DateTime? dateOfBirth;
  final String? colour;
  final String? microchipNo;
  final String? damOfEmbryo;
  final String? stallionOfEmbryo;
  final DateTime? transferDate;
  final String? photoUrl;
  final DateTime createdAt;

  const RecipientMare({
    required this.id,
    required this.accountId,
    this.breedingRecordId,
    required this.nameNo,
    this.dateOfBirth,
    this.colour,
    this.microchipNo,
    this.damOfEmbryo,
    this.stallionOfEmbryo,
    this.transferDate,
    this.photoUrl,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'account_id': accountId,
      'breeding_record_id': breedingRecordId,
      'name_no': nameNo,
      'date_of_birth': dateOfBirth?.toIso8601String(),
      'colour': colour,
      'microchip_no': microchipNo,
      'dam_of_embryo': damOfEmbryo,
      'stallion_of_embryo': stallionOfEmbryo,
      'transfer_date': transferDate?.toIso8601String(),
      'photo_url': photoUrl,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory RecipientMare.fromJson(Map<String, dynamic> json) {
    return RecipientMare(
      id: json['id'] as String,
      accountId: json['account_id'] as String? ?? '',
      breedingRecordId: json['breeding_record_id'] as String?,
      nameNo: json['name_no'] as String,
      dateOfBirth: json['date_of_birth'] != null
          ? DateTime.parse(json['date_of_birth'] as String)
          : null,
      colour: json['colour'] as String?,
      microchipNo: json['microchip_no'] as String?,
      damOfEmbryo: json['dam_of_embryo'] as String?,
      stallionOfEmbryo: json['stallion_of_embryo'] as String?,
      transferDate: json['transfer_date'] != null
          ? DateTime.parse(json['transfer_date'] as String)
          : null,
      photoUrl: json['photo_url'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
    );
  }
}
