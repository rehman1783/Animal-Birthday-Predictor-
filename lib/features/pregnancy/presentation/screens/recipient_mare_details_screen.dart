import 'package:flutter/material.dart';
import '../../../animals/domain/animal.dart';
import '../../../animals/presentation/screens/animal_details_screen.dart';

class RecipientMareDetailsScreen extends StatelessWidget {
  final Animal? recipientMare;

  const RecipientMareDetailsScreen({super.key, this.recipientMare});

  @override
  Widget build(BuildContext context) {
    return AnimalDetailsScreen(
      animal: recipientMare,
      species: 'horse',
    );
  }
}
