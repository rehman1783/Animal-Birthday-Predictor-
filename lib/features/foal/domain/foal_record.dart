import '../../animals/domain/animal_type.dart';

class FoalRecord {
  final String id;
  final String pregnancyId;
  final String offspringName;
  final AnimalType animalType;
  final String damName;
  final String sireName;
  final DateTime birthDate;
  final double birthWeightKg;
  final String gender; // 'colt', 'filly', 'male', 'female'
  final String color;
  final String? healthNotes;
  final String? photoUrl;
  final DateTime createdAt;

  const FoalRecord({
    required this.id,
    required this.pregnancyId,
    required this.offspringName,
    required this.animalType,
    required this.damName,
    required this.sireName,
    required this.birthDate,
    required this.birthWeightKg,
    required this.gender,
    required this.color,
    this.healthNotes,
    this.photoUrl,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'pregnancy_id': pregnancyId,
      'offspring_name': offspringName,
      'animal_type': animalType.name,
      'dam_name': damName,
      'sire_name': sireName,
      'birth_date': birthDate.toIso8601String(),
      'birth_weight_kg': birthWeightKg,
      'gender': gender,
      'color': color,
      'health_notes': healthNotes,
      'photo_url': photoUrl,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory FoalRecord.fromJson(Map<String, dynamic> json) {
    return FoalRecord(
      id: json['id'] as String,
      pregnancyId: json['pregnancy_id'] as String,
      offspringName: json['offspring_name'] as String,
      animalType: AnimalType.values.firstWhere(
        (e) => e.name == json['animal_type'],
        orElse: () => AnimalType.horse,
      ),
      damName: json['dam_name'] as String,
      sireName: json['sire_name'] as String,
      birthDate: DateTime.parse(json['birth_date'] as String),
      birthWeightKg: (json['birth_weight_kg'] as num).toDouble(),
      gender: json['gender'] as String,
      color: json['color'] as String,
      healthNotes: json['health_notes'] as String?,
      photoUrl: json['photo_url'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
    );
  }
}
