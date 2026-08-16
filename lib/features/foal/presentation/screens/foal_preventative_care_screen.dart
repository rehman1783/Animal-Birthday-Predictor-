import 'package:flutter/material.dart';
import '../../../pregnancy/presentation/screens/preventative_care_screen.dart';

class FoalPreventativeCareScreen extends StatelessWidget {
  final String foalId;
  final String? damMareId;

  const FoalPreventativeCareScreen({
    super.key,
    required this.foalId,
    this.damMareId,
  });

  @override
  Widget build(BuildContext context) {
    return PreventativeCareScreen(
      ownerType: 'foal',
      ownerId: foalId,
      damMareId: damMareId,
    );
  }
}
