class FoalRecord {
  final String id;
  final String mareId;
  final String? recipientMareId;
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
  final DateTime createdAt;

  const FoalRecord({
    required this.id,
    required this.mareId,
    this.recipientMareId,
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
    required this.createdAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'mare_id': mareId,
      'recipient_mare_id': recipientMareId,
      'foal_name': foalName,
      'date_of_birth': dateOfBirth?.toIso8601String(),
      'stallion': stallion,
      'breed': breed,
      'sex': sex,
      'igg_value': iggValue,
      'foal_microchip_no': foalMicrochipNo,
      'dna': dna,
      'gelded': gelded,
      'gelded_date': geldedDate?.toIso8601String(),
      'stud_book_association': studBookAssociation,
      'notes': notes,
      'status': status,
      'photo_url': photoUrl,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory FoalRecord.fromJson(Map<String, dynamic> json) {
    return FoalRecord(
      id: json['id'] as String,
      mareId: json['mare_id'] as String,
      recipientMareId: json['recipient_mare_id'] as String?,
      foalName: json['foal_name'] as String?,
      dateOfBirth: json['date_of_birth'] != null
          ? DateTime.parse(json['date_of_birth'] as String)
          : null,
      stallion: json['stallion'] as String?,
      breed: json['breed'] as String?,
      sex: json['sex'] as String?,
      iggValue: json['igg_value'] as String?,
      foalMicrochipNo: json['foal_microchip_no'] as String?,
      dna: json['dna'] as String?,
      gelded: json['gelded'] as bool? ?? false,
      geldedDate: json['gelded_date'] != null
          ? DateTime.parse(json['gelded_date'] as String)
          : null,
      studBookAssociation: json['stud_book_association'] as String?,
      notes: json['notes'] as String?,
      status: json['status'] as String?,
      photoUrl: json['photo_url'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
    );
  }
}
