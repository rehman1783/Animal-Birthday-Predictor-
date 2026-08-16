import 'package:flutter/material.dart';
import 'preventative_care_screen.dart';

class MarePreventativeCareScreen extends StatelessWidget {
  final String mareId;

  const MarePreventativeCareScreen({super.key, required this.mareId});

  @override
  Widget build(BuildContext context) {
    return PreventativeCareScreen(
      ownerType: 'animal',
      ownerId: mareId,
    );
  }
}
