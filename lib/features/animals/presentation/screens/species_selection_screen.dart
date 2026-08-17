import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/widgets/gradient_cta_button.dart';
import '../../../../core/widgets/responsive_body.dart';
import '../../../../core/widgets/section_divider_label.dart';
import '../providers/animal_provider.dart';
import '../widgets/species_select_card.dart';

class SpeciesSelectionScreen extends ConsumerStatefulWidget {
  const SpeciesSelectionScreen({super.key});

  @override
  ConsumerState<SpeciesSelectionScreen> createState() => _SpeciesSelectionScreenState();
}

class _SpeciesSelectionScreenState extends ConsumerState<SpeciesSelectionScreen> {
  String _selectedSpecies = 'horse';

  final List<({String key, String title, String subtitle, IconData icon})> _speciesList = const [
    (
      key: 'horse',
      title: 'Horse / Equine',
      subtitle: 'Complete breeding, pregnancy scan calculation & foal registration',
      icon: Icons.pets_rounded,
    ),
    (
      key: 'dog',
      title: 'Dog / Canine',
      subtitle: 'Canine dam/sire registration, puppy litters & dual-date health protocols',
      icon: Icons.pets,
    ),
    (
      key: 'cat',
      title: 'Cat / Feline',
      subtitle: 'Feline kittening & breeding cycle tracker (Coming soon)',
      icon: Icons.catching_pokemon,
    ),
    (
      key: 'other',
      title: 'Other Species',
      subtitle: 'Custom livestock and exotic animal gestation rules (Coming soon)',
      icon: Icons.category_rounded,
    ),
  ];

  Future<void> _handleContinue() async {
    ref.read(selectedSpeciesFilterProvider.notifier).state = _selectedSpecies;

    final created = await Navigator.pushNamed(
      context,
      '/animal-details',
      arguments: {'species': _selectedSpecies},
    );

    if (created != null && mounted) {
      Navigator.pop(context, created);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.textPrimary, size: 20),
          onPressed: () => Navigator.maybePop(context),
        ),
        title: const Text('SELECT SPECIES', style: AppTypography.sectionLabel),
        centerTitle: true,
      ),
      body: SafeArea(
        child: ResponsiveBody(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 12),
              Text(
                'What animal are you registering?',
                style: AppTypography.displayHeadline.copyWith(fontSize: 22),
              ),
              const SizedBox(height: 6),
              Text(
                'Choose the animal category to load the corresponding breeding rules and fields.',
                style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary),
              ),
              const SizedBox(height: 24),

              const SectionDividerLabel(label: 'SPECIES SELECTION'),
              const SizedBox(height: 14),

              Expanded(
                child: ListView.separated(
                  itemCount: _speciesList.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final item = _speciesList[index];
                    return SpeciesSelectCard(
                      speciesKey: item.key,
                      title: item.title,
                      subtitle: item.subtitle,
                      icon: item.icon,
                      isSelected: _selectedSpecies == item.key,
                      onTap: () => setState(() => _selectedSpecies = item.key),
                    );
                  },
                ),
              ),

              const SizedBox(height: 16),
              GradientCtaButton(
                text: 'CONTINUE TO REGISTRATION',
                onPressed: _handleContinue,
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
