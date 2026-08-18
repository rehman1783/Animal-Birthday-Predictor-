import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/widgets/gradient_cta_button.dart';
import '../../../../core/widgets/responsive_body.dart';
import '../../domain/animal.dart';
import '../providers/animal_provider.dart';
import '../widgets/animal_list_tile.dart';

import 'package:animal_birthday_predictor/features/main/presentation/providers/main_navigation_provider.dart';

class SavedAnimalsScreen extends ConsumerStatefulWidget {
  final String? initialSpecies;

  const SavedAnimalsScreen({super.key, this.initialSpecies});

  @override
  ConsumerState<SavedAnimalsScreen> createState() => _SavedAnimalsScreenState();
}

class _SavedAnimalsScreenState extends ConsumerState<SavedAnimalsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final List<String> _speciesTabs = const ['horse', 'dog', 'cat', 'other'];

  int _speciesToIndex(String? species) {
    if (species == null) return 0;
    final s = species.toLowerCase().trim();
    if (s.contains('dog') || s.contains('canine') || s.contains('pupp')) {
      return 1;
    } else if (s.contains('cat') || s.contains('feline') || s.contains('kit')) {
      return 2;
    } else if (s.contains('other')) {
      return 3;
    } else if (s.contains('horse') || s.contains('equine') || s.contains('foal') || s.contains('mare') || s.contains('stallion')) {
      return 0;
    }
    return 0;
  }

  @override
  void initState() {
    super.initState();
    int initialIndex = _speciesToIndex(widget.initialSpecies);
    _tabController = TabController(
      length: _speciesTabs.length,
      vsync: this,
      initialIndex: initialIndex,
    );
  }

  @override
  void didUpdateWidget(covariant SavedAnimalsScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialSpecies != null && widget.initialSpecies != oldWidget.initialSpecies) {
      final idx = _speciesToIndex(widget.initialSpecies);
      if (idx != _tabController.index) {
        _tabController.animateTo(idx);
      }
    }
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
    final navState = ref.watch(mainNavigationProvider);
    if (navState.selectedIndex == 1 && navState.initialSpeciesTab != null) {
      final targetIdx = _speciesToIndex(navState.initialSpeciesTab);
      if (targetIdx != _tabController.index) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted && targetIdx != _tabController.index) {
            _tabController.animateTo(targetIdx);
          }
        });
      }
    }

    ref.listen(mainNavigationProvider, (previous, next) {
      if (next.selectedIndex == 1 && next.initialSpeciesTab != null) {
        final idx = _speciesToIndex(next.initialSpeciesTab);
        if (idx != _tabController.index) {
          _tabController.animateTo(idx);
        }
      }
    });

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
          children: _speciesTabs
              .map((species) => _SpeciesAnimalList(
                    key: ValueKey('saved_animals_list_$species'),
                    species: species,
                  ))
              .toList(),
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

class _SpeciesAnimalList extends ConsumerStatefulWidget {
  final String species;

  const _SpeciesAnimalList({super.key, required this.species});

  @override
  ConsumerState<_SpeciesAnimalList> createState() => _SpeciesAnimalListState();
}

class _SpeciesAnimalListState extends ConsumerState<_SpeciesAnimalList> {
  String _selectedSubFilter = 'all'; // 'all', 'mares', 'stallions'

  @override
  Widget build(BuildContext context) {
    final animalsAsync = ref.watch(animalsListProvider(widget.species));

    return animalsAsync.when(
      data: (allAnimals) {
        final speciesAnimals = allAnimals
            .where((a) => Animal.matchesSpeciesFilter(a.species, widget.species))
            .toList();

        final isHorseTab = widget.species.toLowerCase() == 'horse';
        
        List<Animal> displayedAnimals = speciesAnimals;
        if (isHorseTab) {
          if (_selectedSubFilter == 'mares') {
            displayedAnimals = speciesAnimals.where((a) => a.isMare).toList();
          } else if (_selectedSubFilter == 'stallions') {
            displayedAnimals = speciesAnimals.where((a) => a.isStallion).toList();
          }
        }

        if (speciesAnimals.isEmpty) {
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
                      'No ${widget.species.toUpperCase()}s Registered',
                      style: AppTypography.displayHeadline.copyWith(fontSize: 20),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Register your ${widget.species.toLowerCase()}s in the registry and view their complete profile, breeding history, and health logs.',
                      style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: 220,
                      child: GradientCtaButton(
                        text: '+ Add ${widget.species.toUpperCase()}',
                        onPressed: () async {
                          final result = await Navigator.pushNamed(
                            context,
                            '/animal-details',
                            arguments: {'species': widget.species},
                          );
                          if (result != null) {
                            ref.invalidate(animalsListProvider(widget.species));
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

        final mareCount = speciesAnimals.where((a) => a.isMare).length;
        final stallionCount = speciesAnimals.where((a) => a.isStallion).length;

        return RefreshIndicator(
          color: AppColors.primaryGold,
          backgroundColor: AppColors.surface,
          onRefresh: () async {
            ref.invalidate(animalsListProvider(widget.species));
            ref.invalidate(animalsListProvider(null));
          },
          child: ResponsiveBody(
            child: Column(
              children: [
                // Sub-filter bar for Horses (ALL, MARES, STALLIONS)
                if (isHorseTab) ...[
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Row(
                      children: [
                        ChoiceChip(
                          label: Text('ALL (${speciesAnimals.length})'),
                          selected: _selectedSubFilter == 'all',
                          selectedColor: AppColors.primaryGold,
                          backgroundColor: AppColors.surface,
                          labelStyle: TextStyle(
                            color: _selectedSubFilter == 'all' ? AppColors.background : AppColors.textPrimary,
                            fontSize: 11.5,
                            fontWeight: FontWeight.bold,
                          ),
                          onSelected: (_) => setState(() => _selectedSubFilter = 'all'),
                        ),
                        const SizedBox(width: 8),
                        ChoiceChip(
                          avatar: Icon(
                            Icons.female,
                            size: 14,
                            color: _selectedSubFilter == 'mares' ? AppColors.background : AppColors.primaryGold,
                          ),
                          label: Text('MARES ($mareCount)'),
                          selected: _selectedSubFilter == 'mares',
                          selectedColor: AppColors.primaryGold,
                          backgroundColor: AppColors.surface,
                          labelStyle: TextStyle(
                            color: _selectedSubFilter == 'mares' ? AppColors.background : AppColors.textPrimary,
                            fontSize: 11.5,
                            fontWeight: FontWeight.bold,
                          ),
                          onSelected: (_) => setState(() => _selectedSubFilter = 'mares'),
                        ),
                        const SizedBox(width: 8),
                        ChoiceChip(
                          avatar: Icon(
                            Icons.male,
                            size: 14,
                            color: _selectedSubFilter == 'stallions' ? AppColors.background : AppColors.primaryGold,
                          ),
                          label: Text('STALLIONS ($stallionCount)'),
                          selected: _selectedSubFilter == 'stallions',
                          selectedColor: AppColors.primaryGold,
                          backgroundColor: AppColors.surface,
                          labelStyle: TextStyle(
                            color: _selectedSubFilter == 'stallions' ? AppColors.background : AppColors.textPrimary,
                            fontSize: 11.5,
                            fontWeight: FontWeight.bold,
                          ),
                          onSelected: (_) => setState(() => _selectedSubFilter = 'stallions'),
                        ),
                      ],
                    ),
                  ),
                ],

                if (displayedAnimals.isEmpty) ...[
                  Expanded(
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.all(32.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              _selectedSubFilter == 'mares' ? Icons.female : Icons.male,
                              size: 48,
                              color: AppColors.primaryGold.withValues(alpha: 0.7),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'No ${_selectedSubFilter.toUpperCase()} Found',
                              style: AppTypography.displayHeadline.copyWith(fontSize: 17),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'Register a new ${_selectedSubFilter == 'mares' ? "Mare" : "Stallion"} to view it here.',
                              style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ] else ...[
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 80),
                      itemCount: displayedAnimals.length,
                      itemBuilder: (context, index) {
                        final animal = displayedAnimals[index];
                        return AnimalListTile(
                          animal: animal,
                          onTap: () async {
                            final updated = await Navigator.pushNamed(
                              context,
                              '/animal-profile',
                              arguments: animal,
                            );
                            if (updated != null) {
                              ref.invalidate(animalsListProvider(widget.species));
                              ref.invalidate(animalsListProvider(null));
                            }
                          },
                        );
                      },
                    ),
                  ),
                ],
              ],
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
