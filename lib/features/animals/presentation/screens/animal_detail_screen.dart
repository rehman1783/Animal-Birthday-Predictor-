import 'package:flutter/material.dart';
import '../../domain/animal.dart';
import 'animal_details_screen.dart';

class AnimalDetailScreen extends StatelessWidget {
  final Animal? animal;

  const AnimalDetailScreen({super.key, this.animal});

  @override
  Widget build(BuildContext context) {
    return AnimalDetailsScreen(animal: animal);
  }
}
