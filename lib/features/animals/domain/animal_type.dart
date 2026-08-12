import 'package:flutter/material.dart';

enum AnimalType {
  horse,
  dog,
  cat,
  cow,
  sheep,
}

extension AnimalTypeX on AnimalType {
  String get displayName {
    switch (this) {
      case AnimalType.horse:
        return 'Horse / Equine';
      case AnimalType.dog:
        return 'Dog / Canine';
      case AnimalType.cat:
        return 'Cat / Feline';
      case AnimalType.cow:
        return 'Cow / Bovine';
      case AnimalType.sheep:
        return 'Sheep / Ovine';
    }
  }

  String get shortName {
    switch (this) {
      case AnimalType.horse:
        return 'Horse';
      case AnimalType.dog:
        return 'Dog';
      case AnimalType.cat:
        return 'Cat';
      case AnimalType.cow:
        return 'Cow';
      case AnimalType.sheep:
        return 'Sheep';
    }
  }

  IconData get icon {
    switch (this) {
      case AnimalType.horse:
        return Icons.pets_rounded;
      case AnimalType.dog:
        return Icons.bedroom_baby_outlined;
      case AnimalType.cat:
        return Icons.catching_pokemon;
      case AnimalType.cow:
        return Icons.grass_rounded;
      case AnimalType.sheep:
        return Icons.cloud_outlined;
    }
  }

  /// Average gestation period in days
  int get averageGestationDays {
    switch (this) {
      case AnimalType.horse:
        return 340; // Range: 320 - 370
      case AnimalType.dog:
        return 63; // Range: 58 - 68
      case AnimalType.cat:
        return 65; // Range: 63 - 67
      case AnimalType.cow:
        return 283; // Range: 279 - 287
      case AnimalType.sheep:
        return 147; // Range: 144 - 152
    }
  }

  int get minGestationDays {
    switch (this) {
      case AnimalType.horse:
        return 320;
      case AnimalType.dog:
        return 58;
      case AnimalType.cat:
        return 63;
      case AnimalType.cow:
        return 279;
      case AnimalType.sheep:
        return 144;
    }
  }

  int get maxGestationDays {
    switch (this) {
      case AnimalType.horse:
        return 370;
      case AnimalType.dog:
        return 68;
      case AnimalType.cat:
        return 67;
      case AnimalType.cow:
        return 287;
      case AnimalType.sheep:
        return 152;
    }
  }

  String get birthTerm {
    switch (this) {
      case AnimalType.horse:
        return 'Foaling';
      case AnimalType.dog:
        return 'Whelping';
      case AnimalType.cat:
        return 'Kittening';
      case AnimalType.cow:
        return 'Calving';
      case AnimalType.sheep:
        return 'Lambing';
    }
  }

  String get offspringName {
    switch (this) {
      case AnimalType.horse:
        return 'Foal';
      case AnimalType.dog:
        return 'Puppy';
      case AnimalType.cat:
        return 'Kitten';
      case AnimalType.cow:
        return 'Calf';
      case AnimalType.sheep:
        return 'Lamb';
    }
  }

  String get femaleTerm {
    switch (this) {
      case AnimalType.horse:
        return 'Mare (Dam)';
      case AnimalType.dog:
        return 'Bitch (Dam)';
      case AnimalType.cat:
        return 'Queen (Dam)';
      case AnimalType.cow:
        return 'Cow (Dam)';
      case AnimalType.sheep:
        return 'Ewe (Dam)';
    }
  }

  String get maleTerm {
    switch (this) {
      case AnimalType.horse:
        return 'Stallion (Sire)';
      case AnimalType.dog:
        return 'Stud (Sire)';
      case AnimalType.cat:
        return 'Tom (Sire)';
      case AnimalType.cow:
        return 'Bull (Sire)';
      case AnimalType.sheep:
        return 'Ram (Sire)';
    }
  }

  /// Calculate predicted due date range given a breeding date
  DateTime calculateDueDate(DateTime breedingDate) {
    return breedingDate.add(Duration(days: averageGestationDays));
  }
}
