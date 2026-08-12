import 'animal_type.dart';

class Animal {
  final String id;
  final String name;
  final AnimalType type;
  final String breed;
  final String gender; // 'male' or 'female'
  final DateTime dateOfBirth;
  final String? registrationNumber;
  final String? damName;
  final String? sireName;
  final String? photoUrl;
  final String? notes;
  final DateTime createdAt;

  const Animal({
    required this.id,
    required this.name,
    required this.type,
    required this.breed,
    required this.gender,
    required this.dateOfBirth,
    this.registrationNumber,
    this.damName,
    this.sireName,
    this.photoUrl,
    this.notes,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'type': type.name,
      'breed': breed,
      'gender': gender,
      'date_of_birth': dateOfBirth.toIso8601String(),
      'registration_number': registrationNumber,
      'dam_name': damName,
      'sire_name': sireName,
      'photo_url': photoUrl,
      'notes': notes,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory Animal.fromJson(Map<String, dynamic> json) {
    return Animal(
      id: json['id'] as String,
      name: json['name'] as String,
      type: AnimalType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => AnimalType.horse,
      ),
      breed: json['breed'] as String? ?? 'Unknown',
      gender: json['gender'] as String? ?? 'female',
      dateOfBirth: json['date_of_birth'] != null
          ? DateTime.parse(json['date_of_birth'] as String)
          : DateTime.now(),
      registrationNumber: json['registration_number'] as String?,
      damName: json['dam_name'] as String?,
      sireName: json['sire_name'] as String?,
      photoUrl: json['photo_url'] as String?,
      notes: json['notes'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
    );
  }
}
