import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:animal_birthday_predictor/core/constants/app_colors.dart';
import 'package:animal_birthday_predictor/core/constants/app_spacing.dart';
import 'package:animal_birthday_predictor/core/constants/app_typography.dart';
import 'package:animal_birthday_predictor/core/widgets/app_thumbnail_avatar.dart';
import 'package:animal_birthday_predictor/core/widgets/gradient_cta_button.dart';
import 'package:animal_birthday_predictor/core/widgets/responsive_body.dart';
import 'package:animal_birthday_predictor/features/foal/domain/foal_record.dart';
import 'package:animal_birthday_predictor/features/foal/presentation/providers/foal_provider.dart';
import 'package:animal_birthday_predictor/features/puppy/domain/puppy.dart';
import 'package:animal_birthday_predictor/features/puppy/presentation/providers/puppy_provider.dart';
import 'package:animal_birthday_predictor/features/puppy/presentation/screens/puppy_details_screen.dart';
import 'package:animal_birthday_predictor/features/main/presentation/providers/main_navigation_provider.dart';

class FoalModuleScreen extends ConsumerStatefulWidget {
  final String? initialCategory;
  final int? initialTab;

  const FoalModuleScreen({
    super.key,
    this.initialCategory,
    this.initialTab,
  });

  @override
  ConsumerState<FoalModuleScreen> createState() => _FoalModuleScreenState();
}

class _FoalModuleScreenState extends ConsumerState<FoalModuleScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final List<String> _categoryTabs = const ['foals', 'puppies', 'kittens', 'other'];

  int _categoryToIndex(String? category) {
    if (category == null) return 0;
    final cat = category.toLowerCase();
    if (cat.contains('puppy') || cat.contains('dog')) {
      return 1;
    } else if (cat.contains('kitten') || cat.contains('cat')) {
      return 2;
    } else if (cat.contains('other')) {
      return 3;
    }
    return 0;
  }

  @override
  void initState() {
    super.initState();
    int initialIndex = widget.initialTab ?? _categoryToIndex(widget.initialCategory);
    if (initialIndex < 0 || initialIndex >= _categoryTabs.length) {
      initialIndex = 0;
    }

    _tabController = TabController(
      length: _categoryTabs.length,
      vsync: this,
      initialIndex: initialIndex,
    );
    _tabController.addListener(() {
      if (mounted) setState(() {});
    });
  }

  @override
  void didUpdateWidget(covariant FoalModuleScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialCategory != null && widget.initialCategory != oldWidget.initialCategory) {
      final targetIdx = _categoryToIndex(widget.initialCategory);
      if (targetIdx != _tabController.index) {
        _tabController.animateTo(targetIdx);
      }
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _onFabPressed() async {
    switch (_tabController.index) {
      case 0:
        final res = await Navigator.pushNamed(context, '/foal-details');
        if (res != null) ref.invalidate(foalsListProvider);
        break;
      case 1:
        final res = await Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const PuppyDetailsScreen()),
        );
        if (res != null) ref.invalidate(puppiesListProvider(null));
        break;
      case 2:
      case 3:
        final res = await Navigator.pushNamed(context, '/species-select');
        if (res != null) {
          ref.invalidate(foalsListProvider);
          ref.invalidate(puppiesListProvider(null));
        }
        break;
    }
  }

  String _getFabLabel() {
    switch (_tabController.index) {
      case 0:
        return 'Add Foal';
      case 1:
        return 'Add Puppy';
      case 2:
        return 'Add Kitten';
      default:
        return 'Add Newborn';
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(mainNavigationProvider, (previous, next) {
      if (next.selectedIndex == 3 && next.initialCategory != null) {
        final targetIdx = _categoryToIndex(next.initialCategory);
        if (targetIdx != _tabController.index) {
          _tabController.animateTo(targetIdx);
        }
      }
    });

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: const Text('BIRTH LOG & REGISTRY', style: AppTypography.sectionLabel),
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.primaryGold,
          labelColor: AppColors.primaryGold,
          unselectedLabelColor: AppColors.textMuted,
          labelStyle: AppTypography.buttonLabel.copyWith(fontSize: 12),
          tabs: const [
            Tab(text: 'FOALS'),
            Tab(text: 'PUPPIES'),
            Tab(text: 'KITTENS'),
            Tab(text: 'OTHER'),
          ],
        ),
      ),
      body: SafeArea(
        child: TabBarView(
          controller: _tabController,
          children: const [
            _FoalsBirthListView(),
            _PuppiesBirthListView(),
            _KittensBirthListView(),
            _OtherBirthListView(),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'birth_log_screen_fab',
        backgroundColor: AppColors.primaryGold,
        foregroundColor: AppColors.background,
        icon: const Icon(Icons.add, color: AppColors.background),
        label: Text(_getFabLabel(), style: const TextStyle(fontWeight: FontWeight.bold)),
        onPressed: _onFabPressed,
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// 1. FOALS BIRTH LIST VIEW
// ---------------------------------------------------------------------------
class _FoalsBirthListView extends ConsumerStatefulWidget {
  const _FoalsBirthListView();

  @override
  ConsumerState<_FoalsBirthListView> createState() => _FoalsBirthListViewState();
}

class _FoalsBirthListViewState extends ConsumerState<_FoalsBirthListView> {
  String _selectedStatus = 'all';

  String _formatDate(DateTime? dt) {
    if (dt == null) return 'N/A';
    return '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year}';
  }

  @override
  Widget build(BuildContext context) {
    final foalsAsync = ref.watch(foalsListProvider);

    return foalsAsync.when(
      data: (allFoals) {
        final foals = allFoals.where((f) {
          if (_selectedStatus == 'all') return true;
          return (f.status ?? 'keep').toLowerCase() == _selectedStatus.toLowerCase();
        }).toList();

        return RefreshIndicator(
          color: AppColors.primaryGold,
          backgroundColor: AppColors.surface,
          onRefresh: () async {
            ref.invalidate(foalsListProvider);
          },
          child: ResponsiveBody(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
              children: [
                // Header CTA Banner
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
                          const Icon(Icons.pets_rounded, color: AppColors.primaryGold, size: 20),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Register Newborn Foal',
                              style: AppTypography.displayHeadline.copyWith(fontSize: 17),
                              softWrap: true,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Record foal identity, auto-link to Dam & Recipient mares, track preventative health, and generate official certificates.',
                        style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary),
                      ),
                      const SizedBox(height: 14),
                      GradientCtaButton(
                        text: '+ REGISTER NEW FOAL',
                        onPressed: () async {
                          final res = await Navigator.pushNamed(context, '/foal-details');
                          if (res != null) ref.invalidate(foalsListProvider);
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Status Chips Filter Bar
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: ['all', 'keep', 'available', 'reserved', 'sold'].map((st) {
                      final isSel = _selectedStatus == st;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: ChoiceChip(
                          label: Text(st.toUpperCase()),
                          selected: isSel,
                          selectedColor: AppColors.primaryGold,
                          backgroundColor: AppColors.surface,
                          labelStyle: TextStyle(
                            color: isSel ? AppColors.background : AppColors.textPrimary,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                          onSelected: (_) => setState(() => _selectedStatus = st),
                        ),
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 16),

                if (foals.isEmpty) ...[
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 64,
                            height: 64,
                            decoration: BoxDecoration(
                              color: AppColors.surface,
                              shape: BoxShape.circle,
                              border: Border.all(color: AppColors.primaryGold.withValues(alpha: 0.5)),
                            ),
                            child: const Icon(Icons.child_care, size: 32, color: AppColors.primaryGold),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No Foal Records Found',
                            style: AppTypography.displayHeadline.copyWith(fontSize: 18),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'When a mare gives birth, register new foals here to maintain identity and lineage records.',
                            style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),
                ] else ...[
                  ...foals.map((foal) => _buildFoalCard(context, foal)),
                ],
              ],
            ),
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator(color: AppColors.primaryGold)),
      error: (e, _) => Center(child: Text('Error loading foals: $e', style: const TextStyle(color: Colors.redAccent))),
    );
  }

  Widget _buildFoalCard(BuildContext context, FoalRecord foal) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
        border: Border.all(color: AppColors.surface),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    AppThumbnailAvatar(
                      imagePath: foal.photoUrl,
                      fallbackIcon: Icons.pets_rounded,
                      size: 40,
                      iconSize: 20,
                      isCircle: true,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        foal.foalName?.isNotEmpty == true ? foal.foalName! : 'Unnamed Foal',
                        style: AppTypography.displayHeadline.copyWith(
                          fontSize: 16,
                          color: AppColors.primaryGold,
                        ),
                        softWrap: true,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.inputField,
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: AppColors.primaryGold.withValues(alpha: 0.5)),
                ),
                child: Text(
                  (foal.status ?? 'keep').toUpperCase(),
                  style: const TextStyle(
                    color: AppColors.primaryGold,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'DOB: ${_formatDate(foal.dateOfBirth)} • ${foal.sex == "colt" ? "Colt" : "Filly"} • ${foal.breed ?? "Equine"}',
            style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary),
          ),
          if (foal.foalMicrochipNo?.isNotEmpty == true) ...[
            const SizedBox(height: 4),
            Text(
              'Microchip: ${foal.foalMicrochipNo}',
              style: AppTypography.bodySmall.copyWith(color: AppColors.textMuted, fontSize: 11),
            ),
          ],
          if (foal.stallion?.isNotEmpty == true) ...[
            const SizedBox(height: 4),
            Text(
              'Sire: ${foal.stallion}',
              style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary, fontSize: 11),
            ),
          ],
          if (foal.buyerName?.isNotEmpty == true) ...[
            const SizedBox(height: 4),
            Text(
              'Buyer: ${foal.buyerName}',
              style: AppTypography.bodySmall.copyWith(color: AppColors.primaryGold, fontSize: 11),
            ),
          ],
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () async {
                    final res = await Navigator.pushNamed(context, '/foal-details', arguments: foal);
                    if (res != null) ref.invalidate(foalsListProvider);
                  },
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: const FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text('Edit Details'),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pushNamed(
                      context,
                      '/certificate',
                      arguments: {'foal': foal},
                    );
                  },
                  icon: const Icon(Icons.card_membership, size: 16),
                  label: const FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text('Certificate'),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryGold,
                    foregroundColor: AppColors.background,
                    padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// 2. PUPPIES BIRTH LIST VIEW
// ---------------------------------------------------------------------------
class _PuppiesBirthListView extends ConsumerStatefulWidget {
  const _PuppiesBirthListView();

  @override
  ConsumerState<_PuppiesBirthListView> createState() => _PuppiesBirthListViewState();
}

class _PuppiesBirthListViewState extends ConsumerState<_PuppiesBirthListView> {
  String _selectedStatus = 'all';

  String _formatDate(DateTime? dt) {
    if (dt == null) return 'N/A';
    return '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year}';
  }

  @override
  Widget build(BuildContext context) {
    final puppiesAsync = ref.watch(puppiesListProvider(null));

    return puppiesAsync.when(
      data: (allPuppies) {
        final puppies = allPuppies.where((p) {
          if (_selectedStatus == 'all') return true;
          return (p.status ?? 'available').toLowerCase() == _selectedStatus.toLowerCase();
        }).toList();

        return RefreshIndicator(
          color: AppColors.primaryGold,
          backgroundColor: AppColors.surface,
          onRefresh: () async {
            ref.invalidate(puppiesListProvider(null));
          },
          child: ResponsiveBody(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
              children: [
                // Header CTA Banner
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
                          const Icon(Icons.bedroom_baby_outlined, color: AppColors.primaryGold, size: 20),
                          const SizedBox(width: 8),
                          Text('Register Newborn Puppy', style: AppTypography.displayHeadline.copyWith(fontSize: 17)),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Record puppy identity, assign collar tags, track daily weights, and manage dual-date health protocols.',
                        style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary),
                      ),
                      const SizedBox(height: 14),
                      GradientCtaButton(
                        text: '+ REGISTER NEW PUPPY',
                        onPressed: () async {
                          final res = await Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const PuppyDetailsScreen()),
                          );
                          if (res != null) ref.invalidate(puppiesListProvider(null));
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Status Chips Filter Bar
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: ['all', 'available', 'reserved', 'sold', 'keep', 'transferred'].map((st) {
                      final isSel = _selectedStatus == st;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: ChoiceChip(
                          label: Text(st.toUpperCase()),
                          selected: isSel,
                          selectedColor: AppColors.primaryGold,
                          backgroundColor: AppColors.surface,
                          labelStyle: TextStyle(
                            color: isSel ? AppColors.background : AppColors.textPrimary,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                          onSelected: (_) => setState(() => _selectedStatus = st),
                        ),
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 16),

                if (puppies.isEmpty) ...[
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 64,
                            height: 64,
                            decoration: BoxDecoration(
                              color: AppColors.surface,
                              shape: BoxShape.circle,
                              border: Border.all(color: AppColors.primaryGold.withValues(alpha: 0.5)),
                            ),
                            child: const Icon(Icons.bedroom_baby_outlined, size: 32, color: AppColors.primaryGold),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No Puppy Records Found',
                            style: AppTypography.displayHeadline.copyWith(fontSize: 18),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Register newborn puppies and litters to track health protocols and generate certificates.',
                            style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),
                ] else ...[
                  ...puppies.map((puppy) => _buildPuppyCard(context, puppy)),
                ],
              ],
            ),
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator(color: AppColors.primaryGold)),
      error: (e, _) => Center(child: Text('Error loading puppies: $e', style: const TextStyle(color: Colors.redAccent))),
    );
  }

  Widget _buildPuppyCard(BuildContext context, Puppy puppy) {
    final collar = puppy.collarTagColour?.isNotEmpty == true ? puppy.collarTagColour! : null;
    final birthOrder = puppy.birthOrder != null ? '#${puppy.birthOrder}' : null;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
        border: Border.all(color: AppColors.surface),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    AppThumbnailAvatar(
                      imagePath: puppy.photoUrl,
                      fallbackIcon: Icons.pets,
                      size: 40,
                      iconSize: 20,
                      isCircle: true,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        puppy.puppyName?.isNotEmpty == true
                            ? puppy.puppyName!
                            : (birthOrder != null ? 'Puppy $birthOrder' : 'Unnamed Puppy'),
                        style: AppTypography.displayHeadline.copyWith(
                          fontSize: 16,
                          color: AppColors.primaryGold,
                        ),
                        softWrap: true,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.inputField,
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: AppColors.primaryGold.withValues(alpha: 0.5)),
                ),
                child: Text(
                  (puppy.status ?? 'available').toUpperCase(),
                  style: const TextStyle(
                    color: AppColors.primaryGold,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            [
              if (puppy.dateOfBirth != null) 'DOB: ${_formatDate(puppy.dateOfBirth)}',
              if (puppy.sex?.isNotEmpty == true) (puppy.sex!.toLowerCase() == 'male' ? 'Male' : 'Female'),
              if (collar != null) 'Collar: $collar',
              if (birthOrder != null) 'Birth Order: $birthOrder',
            ].join(' • '),
            style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary),
          ),
          if (puppy.microchipNo?.isNotEmpty == true) ...[
            const SizedBox(height: 4),
            Text(
              'Microchip: ${puppy.microchipNo}',
              style: AppTypography.bodySmall.copyWith(color: AppColors.textMuted, fontSize: 11),
            ),
          ],
          if (puppy.currentWeight?.isNotEmpty == true || puppy.birthWeight?.isNotEmpty == true) ...[
            const SizedBox(height: 4),
            Text(
              'Weight: ${puppy.currentWeight?.isNotEmpty == true ? puppy.currentWeight! : puppy.birthWeight!}',
              style: const TextStyle(color: AppColors.primaryGold, fontSize: 11),
            ),
          ],
          if (puppy.newOwnerName?.isNotEmpty == true) ...[
            const SizedBox(height: 4),
            Text(
              'Buyer: ${puppy.newOwnerName}',
              style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary, fontSize: 11),
            ),
          ],
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () async {
                    final res = await Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => PuppyDetailsScreen(puppy: puppy)),
                    );
                    if (res != null) ref.invalidate(puppiesListProvider(null));
                  },
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: const FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text('Edit Details'),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pushNamed(
                      context,
                      '/certificate',
                      arguments: {'puppy': puppy},
                    );
                  },
                  icon: const Icon(Icons.card_membership, size: 16),
                  label: const FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text('Certificate'),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryGold,
                    foregroundColor: AppColors.background,
                    padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// 3. KITTENS BIRTH LIST VIEW
// ---------------------------------------------------------------------------
class _KittensBirthListView extends ConsumerWidget {
  const _KittensBirthListView();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ResponsiveBody(
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(32.0),
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
                child: const Icon(Icons.catching_pokemon, size: 36, color: AppColors.primaryGold),
              ),
              const SizedBox(height: 20),
              Text(
                'No Kitten Records Yet',
                style: AppTypography.displayHeadline.copyWith(fontSize: 20),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Register newborn kittens and feline litters to track pedigree details, weight logs, and vaccinations.',
                style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: 220,
                child: GradientCtaButton(
                  text: '+ Register Kitten / Litter',
                  onPressed: () async {
                    await Navigator.pushNamed(
                      context,
                      '/animal-details',
                      arguments: {'species': 'cat'},
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// 4. OTHER SPECIES BIRTH LIST VIEW
// ---------------------------------------------------------------------------
class _OtherBirthListView extends ConsumerWidget {
  const _OtherBirthListView();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ResponsiveBody(
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(32.0),
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
                child: const Icon(Icons.category_rounded, size: 36, color: AppColors.primaryGold),
              ),
              const SizedBox(height: 20),
              Text(
                'No Other Newborns Registered',
                style: AppTypography.displayHeadline.copyWith(fontSize: 20),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Register newborn animals of other species and generate official birth certificates.',
                style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: 220,
                child: GradientCtaButton(
                  text: '+ Register Newborn',
                  onPressed: () async {
                    await Navigator.pushNamed(context, '/species-select');
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
