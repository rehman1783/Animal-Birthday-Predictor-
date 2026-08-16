class FoalRecord {
  final String id;
  final String accountId;
  final String mareAnimalId;
  final String? recipientAnimalId;
  final String? foalName;
  final DateTime? dateOfBirth;
  final String? stallion;
  final String? breed;
  final String? sex; // 'filly', 'colt'
  final String? iggValue;
  final String? foalMicrochipNo;
  final String? dna;
  final bool gelded;
  final DateTime? geldedDate;
  final String? studBookAssociation;
  final String? notes;
  final String? status; // 'sold', 'keep', 'transferred'
  final String? photoUrl;
  // Buyer / New Owner Fields
  final String? buyerName;
  final String? buyerPhone;
  final String? buyerAddress;
  final DateTime? saleDate;
  final String? salePrice;

  final DateTime createdAt;
  final DateTime updatedAt;

  const FoalRecord({
    required this.id,
    required this.accountId,
    required this.mareAnimalId,
    this.recipientAnimalId,
    this.foalName,
    this.dateOfBirth,
    this.stallion,
    this.breed,
    this.sex,
    this.iggValue,
    this.foalMicrochipNo,
    this.dna,
    this.gelded = false,
    this.geldedDate,
    this.studBookAssociation,
    this.notes,
    this.status,
    this.photoUrl,
    this.buyerName,
    this.buyerPhone,
    this.buyerAddress,
    this.saleDate,
    this.salePrice,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'account_id': accountId,
      'mare_animal_id': mareAnimalId,
      'recipient_animal_id': recipientAnimalId,
      'foal_name': foalName,
      'date_of_birth': dateOfBirth?.toIso8601String().split('T').first,
      'stallion': stallion,
      'breed': breed,
      'sex': sex,
      'igg_value': iggValue,
      'foal_microchip_no': foalMicrochipNo,
      'dna': dna,
      'gelded': gelded,
      'gelded_date': geldedDate?.toIso8601String().split('T').first,
      'stud_book_association': studBookAssociation,
      'notes': notes,
      'status': status,
      'photo_url': photoUrl,
      'buyer_name': buyerName,
      'buyer_phone': buyerPhone,
      'buyer_address': buyerAddress,
      'sale_date': saleDate?.toIso8601String().split('T').first,
      'sale_price': salePrice,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  factory FoalRecord.fromJson(Map<String, dynamic> json) {
    return FoalRecord(
      id: json['id'] as String? ?? '',
      accountId: json['account_id'] as String? ?? '',
      mareAnimalId: json['mare_animal_id'] as String? ?? json['mare_id'] as String? ?? '',
      recipientAnimalId: json['recipient_animal_id'] as String? ?? json['recipient_mare_id'] as String?,
      foalName: json['foal_name'] as String?,
      dateOfBirth: json['date_of_birth'] != null
          ? DateTime.tryParse(json['date_of_birth'] as String)
          : null,
      stallion: json['stallion'] as String?,
      breed: json['breed'] as String?,
      sex: json['sex'] as String?,
      iggValue: json['igg_value'] as String?,
      foalMicrochipNo: json['foal_microchip_no'] as String?,
      dna: json['dna'] as String?,
      gelded: json['gelded'] as bool? ?? false,
      geldedDate: json['gelded_date'] != null
          ? DateTime.tryParse(json['gelded_date'] as String)
          : null,
      studBookAssociation: json['stud_book_association'] as String?,
      notes: json['notes'] as String?,
      status: json['status'] as String?,
      photoUrl: json['photo_url'] as String?,
      buyerName: json['buyer_name'] as String?,
      buyerPhone: json['buyer_phone'] as String?,
      buyerAddress: json['buyer_address'] as String?,
      saleDate: json['sale_date'] != null
          ? DateTime.tryParse(json['sale_date'] as String)
          : null,
      salePrice: json['sale_price'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'] as String) ?? DateTime.now()
          : DateTime.now(),
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'] as String) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  FoalRecord copyWith({
    String? id,
    String? accountId,
    String? mareAnimalId,
    String? recipientAnimalId,
    String? foalName,
    DateTime? dateOfBirth,
    String? stallion,
    String? breed,
    String? sex,
    String? iggValue,
    String? foalMicrochipNo,
    String? dna,
    bool? gelded,
    DateTime? geldedDate,
    String? studBookAssociation,
    String? notes,
    String? status,
    String? photoUrl,
    String? buyerName,
    String? buyerPhone,
    String? buyerAddress,
    DateTime? saleDate,
    String? salePrice,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return FoalRecord(
      id: id ?? this.id,
      accountId: accountId ?? this.accountId,
      mareAnimalId: mareAnimalId ?? this.mareAnimalId,
      recipientAnimalId: recipientAnimalId ?? this.recipientAnimalId,
      foalName: foalName ?? this.foalName,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      stallion: stallion ?? this.stallion,
      breed: breed ?? this.breed,
      sex: sex ?? this.sex,
      iggValue: iggValue ?? this.iggValue,
      foalMicrochipNo: foalMicrochipNo ?? this.foalMicrochipNo,
      dna: dna ?? this.dna,
      gelded: gelded ?? this.gelded,
      geldedDate: geldedDate ?? this.geldedDate,
      studBookAssociation: studBookAssociation ?? this.studBookAssociation,
      notes: notes ?? this.notes,
      status: status ?? this.status,
      photoUrl: photoUrl ?? this.photoUrl,
      buyerName: buyerName ?? this.buyerName,
      buyerPhone: buyerPhone ?? this.buyerPhone,
      buyerAddress: buyerAddress ?? this.buyerAddress,
      saleDate: saleDate ?? this.saleDate,
      salePrice: salePrice ?? this.salePrice,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
