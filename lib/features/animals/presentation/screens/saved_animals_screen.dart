import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/widgets/gradient_cta_button.dart';
import '../../../../core/widgets/responsive_body.dart';
import '../providers/animal_provider.dart';
import '../widgets/animal_list_tile.dart';

class SavedAnimalsScreen extends ConsumerStatefulWidget {
  const SavedAnimalsScreen({super.key});

  @override
  ConsumerState<SavedAnimalsScreen> createState() => _SavedAnimalsScreenState();
}

class _SavedAnimalsScreenState extends ConsumerState<SavedAnimalsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final List<String> _speciesTabs = const ['horse', 'dog', 'cat', 'other'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _speciesTabs.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _refreshCurrentTab() {
    final currentSpecies = _speciesTabs[_tabController.index];
    ref.invalidate(animalsListProvider(currentSpecies));
    ref.invalidate(animalsListProvider(null));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: const Text('SAVED ANIMALS REGISTRY', style: AppTypography.sectionLabel),
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.primaryGold,
          labelColor: AppColors.primaryGold,
          unselectedLabelColor: AppColors.textMuted,
          labelStyle: AppTypography.buttonLabel.copyWith(fontSize: 12),
          tabs: const [
            Tab(text: 'HORSES'),
            Tab(text: 'DOGS'),
            Tab(text: 'CATS'),
            Tab(text: 'OTHER'),
          ],
        ),
      ),
      body: SafeArea(
        child: TabBarView(
          controller: _tabController,
          children: _speciesTabs.map((species) => _SpeciesAnimalList(species: species)).toList(),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.primaryGold,
        foregroundColor: AppColors.background,
        icon: const Icon(Icons.add, color: AppColors.background),
        label: const Text('Add Animal', style: TextStyle(fontWeight: FontWeight.bold)),
        onPressed: () async {
          final result = await Navigator.pushNamed(context, '/species-select');
          if (result != null) {
            _refreshCurrentTab();
          }
        },
      ),
    );
  }
}

class _SpeciesAnimalList extends ConsumerWidget {
  final String species;

  const _SpeciesAnimalList({required this.species});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final animalsAsync = ref.watch(animalsListProvider(species));

    return animalsAsync.when(
      data: (animals) {
        if (animals.isEmpty) {
          return Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(32.0),
              child: ResponsiveBody(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 72,
                      height: 72,
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.primaryGold.withValues(alpha: 0.5)),
                      ),
                      child: const Icon(Icons.pets, size: 36, color: AppColors.primaryGold),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'No ${species.toUpperCase()}s Registered',
                      style: AppTypography.displayHeadline.copyWith(fontSize: 20),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Register your animals once in the universal registry and select them anytime across breeding and foal records.',
                      style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: 220,
                      child: GradientCtaButton(
                        text: '+ Add ${species.toUpperCase()}',
                        onPressed: () async {
                          final result = await Navigator.pushNamed(
                            context,
                            '/animal-details',
                            arguments: {'species': species},
                          );
                          if (result != null) {
                            ref.invalidate(animalsListProvider(species));
                            ref.invalidate(animalsListProvider(null));
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        return RefreshIndicator(
          color: AppColors.primaryGold,
          backgroundColor: AppColors.surface,
          onRefresh: () async {
            ref.invalidate(animalsListProvider(species));
            ref.invalidate(animalsListProvider(null));
          },
          child: ResponsiveBody(
            child: ListView.builder(
              padding: const EdgeInsets.all(AppSpacing.horizontalPadding),
              itemCount: animals.length,
              itemBuilder: (context, index) {
                final animal = animals[index];
                return AnimalListTile(
                  animal: animal,
                  onTap: () async {
                    final updated = await Navigator.pushNamed(
                      context,
                      '/animal-details',
                      arguments: {'animal': animal, 'species': species},
                    );
                    if (updated != null) {
                      ref.invalidate(animalsListProvider(species));
                      ref.invalidate(animalsListProvider(null));
                    }
                  },
                );
              },
            ),
          ),
        );
      },
      loading: () => const Center(
        child: CircularProgressIndicator(color: AppColors.primaryGold),
      ),
      error: (e, _) => Center(
        child: Text('Error loading animals: $e', style: const TextStyle(color: Colors.redAccent)),
      ),
    );
  }
}
