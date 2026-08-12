import '../../animals/domain/animal_type.dart';

enum PregnancyStatus {
  active,
  dueSoon,
  delivered,
  archived,
}

class PregnancyRecord {
  final String id;
  final String damName;
  final String sireName;
  final AnimalType animalType;
  final DateTime breedingDate;
  final DateTime expectedDueDate;
  final DateTime? ultrasoundDate;
  final bool confirmedPregnancy;
  final PregnancyStatus status;
  final String? notes;
  final DateTime createdAt;

  const PregnancyRecord({
    required this.id,
    required this.damName,
    required this.sireName,
    required this.animalType,
    required this.breedingDate,
    required this.expectedDueDate,
    this.ultrasoundDate,
    this.confirmedPregnancy = true,
    this.status = PregnancyStatus.active,
    this.notes,
    required this.createdAt,
  });

  /// Calculate days elapsed since breeding
  int get elapsedDays {
    final now = DateTime.now();
    if (now.isBefore(breedingDate)) return 0;
    return now.difference(breedingDate).inDays;
  }

  /// Calculate remaining days until expected due date
  int get daysRemaining {
    final now = DateTime.now();
    if (now.isAfter(expectedDueDate)) return 0;
    return expectedDueDate.difference(now).inDays;
  }

  /// Gestation progress percentage (0.0 to 1.0)
  double get progressPercentage {
    final totalDays = animalType.averageGestationDays;
    if (totalDays <= 0) return 0.0;
    final progress = elapsedDays / totalDays;
    return progress.clamp(0.0, 1.0);
  }

  /// Check if due within 14 days
  bool get isDueSoon {
    return status == PregnancyStatus.active && daysRemaining <= 14;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'dam_name': damName,
      'sire_name': sireName,
      'animal_type': animalType.name,
      'breeding_date': breedingDate.toIso8601String(),
      'expected_due_date': expectedDueDate.toIso8601String(),
      'ultrasound_date': ultrasoundDate?.toIso8601String(),
      'confirmed_pregnancy': confirmedPregnancy,
      'status': status.name,
      'notes': notes,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory PregnancyRecord.fromJson(Map<String, dynamic> json) {
    return PregnancyRecord(
      id: json['id'] as String,
      damName: json['dam_name'] as String,
      sireName: json['sire_name'] as String,
      animalType: AnimalType.values.firstWhere(
        (e) => e.name == json['animal_type'],
        orElse: () => AnimalType.horse,
      ),
      breedingDate: DateTime.parse(json['breeding_date'] as String),
      expectedDueDate: DateTime.parse(json['expected_due_date'] as String),
      ultrasoundDate: json['ultrasound_date'] != null
          ? DateTime.parse(json['ultrasound_date'] as String)
          : null,
      confirmedPregnancy: json['confirmed_pregnancy'] as bool? ?? true,
      status: PregnancyStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => PregnancyStatus.active,
      ),
      notes: json['notes'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
    );
  }
}
