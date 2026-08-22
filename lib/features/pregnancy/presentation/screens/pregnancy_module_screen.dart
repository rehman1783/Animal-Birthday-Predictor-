import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/widgets/app_error_view.dart';
import '../../../../core/widgets/app_loading_view.dart';
import '../../../../core/widgets/gradient_cta_button.dart';
import '../../../../core/widgets/horseshoe_icon.dart';
import '../../../../core/widgets/responsive_body.dart';
import '../../../../core/widgets/section_divider_label.dart';
import '../../../../core/widgets/species_icon.dart';
import '../../../animals/domain/animal.dart';
import '../../../animals/presentation/providers/animal_provider.dart';
import '../providers/pregnancy_provider.dart';
import '../widgets/mare_pregnancy_card.dart';

class PregnancyModuleScreen extends ConsumerStatefulWidget {
  final String? initialSpecies;

  const PregnancyModuleScreen({
    super.key,
    this.initialSpecies,
  });

  @override
  ConsumerState<PregnancyModuleScreen> createState() => _PregnancyModuleScreenState();
}

class _PregnancyModuleScreenState extends ConsumerState<PregnancyModuleScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  static const List<String> _speciesTabs = ['horse', 'dog', 'cat', 'other'];

  @override
  void initState() {
    super.initState();
    int initialIdx = 0;
    if (widget.initialSpecies != null) {
      final idx = _speciesTabs.indexOf(widget.initialSpecies!.toLowerCase().trim());
      if (idx != -1) initialIdx = idx;
    }
    _tabController = TabController(length: _speciesTabs.length, vsync: this, initialIndex: initialIdx);
  }

  @override
  void didUpdateWidget(covariant PregnancyModuleScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialSpecies != null && widget.initialSpecies != oldWidget.initialSpecies) {
      final idx = _speciesTabs.indexOf(widget.initialSpecies!.toLowerCase().trim());
      if (idx != -1 && idx != _tabController.index) {
        _tabController.animateTo(idx);
      }
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: const Text('PREGNANCY & BREEDING TRACKER', style: AppTypography.sectionLabel),
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.primaryGold,
          labelColor: AppColors.primaryGold,
          unselectedLabelColor: AppColors.textMuted,
          labelStyle: AppTypography.buttonLabel.copyWith(fontSize: 11),
          isScrollable: true,
          tabs: const [
            Tab(
              icon: HorseshoeIcon(size: 14, color: AppColors.primaryGold),
              text: 'MARES & HORSES',
            ),
            Tab(
              icon: Icon(Icons.pets, size: 15, color: AppColors.primaryGold),
              text: 'DAMS/BITCHES & DOGS',
            ),
            Tab(
              icon: SpeciesIcon(species: 'cat', size: 15, color: AppColors.primaryGold),
              text: 'QUEENS & CATS',
            ),
            Tab(
              icon: SpeciesIcon(species: 'other', size: 15, color: AppColors.primaryGold),
              text: 'OTHER',
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: TabBarView(
          controller: _tabController,
          children: _speciesTabs
              .map((sp) => _SpeciesPregnancyListView(
                    key: ValueKey('pregnancy_list_$sp'),
                    species: sp,
                  ))
              .toList(),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'pregnancy_screen_fab',
        backgroundColor: AppColors.primaryGold,
        foregroundColor: AppColors.background,
        icon: const Icon(Icons.favorite_rounded, color: AppColors.background),
        label: const Text('Log Breeding', style: TextStyle(fontWeight: FontWeight.bold)),
        onPressed: () async {
          final currentSpecies = _speciesTabs[_tabController.index];
          await Navigator.pushNamed(
            context,
            '/breeding-details',
            arguments: {'species': currentSpecies},
          );
          if (mounted) ref.invalidate(animalsListProvider(currentSpecies));
        },
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// SPECIES PREGNANCY LIST VIEW
// ---------------------------------------------------------------------------
class _SpeciesPregnancyListView extends ConsumerStatefulWidget {
  final String species;

  const _SpeciesPregnancyListView({
    super.key,
    required this.species,
  });

  @override
  ConsumerState<_SpeciesPregnancyListView> createState() => _SpeciesPregnancyListViewState();
}

class _SpeciesPregnancyListViewState extends ConsumerState<_SpeciesPregnancyListView> {
  String _selectedStatusFilter = 'all'; // 'all', 'confirmed', 'breeding', 'ready'

  String _getBannerTitle() {
    switch (widget.species.toLowerCase()) {
      case 'horse':
        return 'Record Mare Breeding & Scans';
      case 'dog':
        return 'Record Dam / Bitch Breeding & Scans';
      case 'cat':
        return 'Record Queen Breeding & Scans';
      default:
        return 'Record Breeding & Gestation Event';
    }
  }

  String _getBannerSubtitle() {
    switch (widget.species.toLowerCase()) {
      case 'horse':
        return 'Select a mare, choose breeding method (Natural, Chilled, Frozen, ICSI), and auto-calculate 14d, 30d, 45d scans & foaling due date.';
      case 'dog':
        return 'Select a dam dog, log mating or insemination dates, and auto-calculate ultrasound scan schedule & whelping due date.';
      case 'cat':
        return 'Select a queen, track breeding dates, and auto-calculate gestation scan reminders & queening due date.';
      default:
        return 'Select breeding female, log service/cover date, and track ultrasound scans & gestation due date.';
    }
  }

  String _getEmptyTitle() {
    switch (widget.species.toLowerCase()) {
      case 'horse':
        return 'No Mares / Horses in Breeding Tracker';
      case 'dog':
        return 'No Dam / Bitch Dogs in Breeding Tracker';
      case 'cat':
        return 'No Queens / Cats in Breeding Tracker';
      default:
        return 'No Breeding Females Registered Yet';
    }
  }

  String _getEmptySubtitle() {
    switch (widget.species.toLowerCase()) {
      case 'horse':
        return 'Register your mares to track ovulation, cover dates, ultrasound scans, and foaling countdowns.';
      case 'dog':
        return 'Register breeding female dogs to track matings, ultrasound scans, and whelping countdowns.';
      case 'cat':
        return 'Register breeding queens to manage mating records, ultrasound confirmations, and queening countdowns.';
      default:
        return 'Register female breeding animals of this species to track gestation timelines and scans.';
    }
  }

  String _getRegisterButtonLabel() {
    switch (widget.species.toLowerCase()) {
      case 'horse':
        return '+ Register First Mare';
      case 'dog':
        return '+ Register First Dam Dog';
      case 'cat':
        return '+ Register First Queen';
      default:
        return '+ Register Breeding Animal';
    }
  }

  String _getSectionTitle() {
    switch (widget.species.toLowerCase()) {
      case 'horse':
        return 'REGISTERED MARES & PREGNANCY STATUS';
      case 'dog':
        return 'REGISTERED DAMS/BITCHES & PREGNANCY STATUS';
      case 'cat':
        return 'REGISTERED QUEENS & PREGNANCY STATUS';
      default:
        return 'REGISTERED BREEDING FEMALES & PREGNANCY STATUS';
    }
  }

  @override
  Widget build(BuildContext context) {
    final animalsAsync = ref.watch(animalsListProvider(widget.species));

    return animalsAsync.when(
      data: (allAnimals) {
        final sp = widget.species.toLowerCase().trim();
        final speciesAnimals = allAnimals.where((a) {
          if (sp == 'other') {
            final s = a.species.toLowerCase().trim();
            return s != 'horse' && s != 'dog' && s != 'cat';
          }
          return a.species.toLowerCase().trim() == sp;
        }).toList();

        return RefreshIndicator(
          color: AppColors.primaryGold,
          backgroundColor: AppColors.surface,
          onRefresh: () async {
            ref.invalidate(animalsListProvider(widget.species));
          },
          child: ResponsiveBody(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
              children: [
                // 1. Header CTA Banner
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
                    border: Border.all(color: AppColors.primaryGold.withValues(alpha: 0.6)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          SpeciesIcon(species: widget.species, size: 20, color: AppColors.primaryGold),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              _getBannerTitle(),
                              style: AppTypography.displayHeadline.copyWith(fontSize: 17),
                              softWrap: true,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _getBannerSubtitle(),
                        style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary),
                      ),
                      const SizedBox(height: 14),
                      Row(
                        children: [
                          Expanded(
                            child: GradientCtaButton(
                              text: '+ LOG BREEDING',
                              onPressed: () async {
                                final res = await Navigator.pushNamed(
                                  context,
                                  '/breeding-details',
                                  arguments: {'species': widget.species},
                                );
                                if (res != null) ref.invalidate(animalsListProvider(widget.species));
                              },
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () => Navigator.pushNamed(context, '/vet-pregnancy-scans'),
                              icon: const Icon(Icons.medical_services_outlined, color: AppColors.primaryGold, size: 16),
                              label: const FittedBox(
                                fit: BoxFit.scaleDown,
                                child: Text(
                                  'VET & SCANS',
                                  style: TextStyle(color: AppColors.primaryGold, fontWeight: FontWeight.bold),
                                ),
                              ),
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(color: AppColors.primaryGold),
                                padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSpacing.cardRadius)),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16.0),

                // 2. Status Filter Chips
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildFilterChip('all', 'ALL RECORDS'),
                      _buildFilterChip('confirmed', widget.species == 'horse' ? 'IN FOAL (CONFIRMED)' : (widget.species == 'dog' ? 'IN WHELP (CONFIRMED)' : 'CONFIRMED PREGNANT')),
                      _buildFilterChip('breeding', 'BREEDING LOGGED'),
                      _buildFilterChip('ready', 'READY FOR BREEDING'),
                    ],
                  ),
                ),
                const SizedBox(height: 16.0),

                SectionDividerLabel(label: _getSectionTitle()),
                const SizedBox(height: 14.0),

                // 3. Animal Cards or Empty State
                if (speciesAnimals.isEmpty) ...[
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 68,
                            height: 68,
                            decoration: BoxDecoration(
                              color: AppColors.surface,
                              shape: BoxShape.circle,
                              border: Border.all(color: AppColors.primaryGold.withValues(alpha: 0.5)),
                            ),
                            child: Center(
                              child: SpeciesIcon(species: widget.species, size: 32, color: AppColors.primaryGold),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            _getEmptyTitle(),
                            style: AppTypography.displayHeadline.copyWith(fontSize: 18),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 6),
                          Text(
                            _getEmptySubtitle(),
                            style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 20),
                          SizedBox(
                            width: 230,
                            child: GradientCtaButton(
                              text: _getRegisterButtonLabel(),
                              onPressed: () async {
                                await Navigator.pushNamed(
                                  context,
                                  '/animal-details',
                                  arguments: {'species': widget.species},
                                );
                                if (mounted) ref.invalidate(animalsListProvider(widget.species));
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ] else ...[
                  ...speciesAnimals.map((animal) => _FilteredPregnancyCard(
                        key: ValueKey('animal_preg_${animal.id}'),
                        animal: animal,
                        filter: _selectedStatusFilter,
                      )),
                ],
              ],
            ),
          ),
        );
      },
      loading: () => const AppLoadingView(message: 'Loading pregnancy tracker...'),
      error: (e, _) => AppErrorView(
        error: e,
        onRetry: () => ref.invalidate(animalsListProvider(widget.species)),
      ),
    );
  }

  Widget _buildFilterChip(String filterKey, String label) {
    final isSelected = _selectedStatusFilter == filterKey;
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: ChoiceChip(
        label: Text(label),
        selected: isSelected,
        selectedColor: AppColors.primaryGold,
        backgroundColor: AppColors.surface,
        labelStyle: TextStyle(
          color: isSelected ? AppColors.background : AppColors.textPrimary,
          fontSize: 11,
          fontWeight: FontWeight.bold,
        ),
        onSelected: (_) => setState(() => _selectedStatusFilter = filterKey),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// FILTERED PREGNANCY CARD WRAPPER
// ---------------------------------------------------------------------------
class _FilteredPregnancyCard extends ConsumerWidget {
  final Animal animal;
  final String filter;

  const _FilteredPregnancyCard({
    super.key,
    required this.animal,
    required this.filter,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (filter == 'all') {
      return MarePregnancyCard(mare: animal);
    }

    final pregnancyAsync = ref.watch(pregnancyRecordForCarrierProvider(animal.id));
    final breedingAsync = ref.watch(breedingRecordByMareProvider(animal.id));

    final pregnancy = pregnancyAsync.valueOrNull;
    final breeding = breedingAsync.valueOrNull;

    final isConfirmed = pregnancy?.scan1Confirmed == true ||
        pregnancy?.scan2Confirmed == true ||
        pregnancy?.scan3Confirmed == true;
    final hasBreeding = breeding != null || pregnancy != null;

    if (filter == 'confirmed' && !isConfirmed) {
      return const SizedBox.shrink();
    }
    if (filter == 'breeding' && (!hasBreeding || isConfirmed)) {
      return const SizedBox.shrink();
    }
    if (filter == 'ready' && hasBreeding) {
      return const SizedBox.shrink();
    }

    return MarePregnancyCard(mare: animal);
  }
}
