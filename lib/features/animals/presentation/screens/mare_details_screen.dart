import 'package:flutter/material.dart';
import '../../domain/animal.dart';
import '../../domain/mare.dart';
import 'animal_details_screen.dart';

class MareDetailsScreen extends StatelessWidget {
  final Mare? mare;

  const MareDetailsScreen({super.key, this.mare});

  @override
  Widget build(BuildContext context) {
    final animal = mare != null
        ? Animal(
            id: mare!.id,
            accountId: mare!.accountId,
            species: 'horse',
            name: mare!.name,
            breed: mare!.breed,
            brand: mare!.brand,
            dna: mare!.dna,
            microchipNo: mare!.microchipNo,
            ownerClientName: mare!.ownerClientName,
            ownerClientPhone: mare!.ownerClientPhone,
            photoUrl: mare!.photoUrl,
            createdAt: mare!.createdAt,
            updatedAt: mare!.updatedAt,
          )
        : null;

    return AnimalDetailsScreen(
      animal: animal,
      species: 'horse',
    );
  }
}
