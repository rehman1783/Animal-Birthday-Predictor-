import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_typography.dart';
import '../../domain/animal.dart';
import '../providers/animal_provider.dart';
import 'animal_list_tile.dart';

class SelectOrAddAnimalModal {
  static Future<Animal?> show(
    BuildContext context, {
    required String title,
    String species = 'horse',
    String? requiredSex,
    String? currentSelectedId,
  }) {
    return showModalBottomSheet<Animal>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _SelectOrAddAnimalSheet(
        title: title,
        species: species,
        requiredSex: requiredSex,
        currentSelectedId: currentSelectedId,
      ),
    );
  }
}

class _SelectOrAddAnimalSheet extends ConsumerStatefulWidget {
  final String title;
  final String species;
  final String? requiredSex;
  final String? currentSelectedId;

  const _SelectOrAddAnimalSheet({
    required this.title,
    required this.species,
    this.requiredSex,
    this.currentSelectedId,
  });

  @override
  ConsumerState<_SelectOrAddAnimalSheet> createState() => _SelectOrAddAnimalSheetState();
}

class _SelectOrAddAnimalSheetState extends ConsumerState<_SelectOrAddAnimalSheet> {
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final animalsAsync = ref.watch(animalsListProvider(widget.species));

    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: const BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppSpacing.cardRadius)),
      ),
      child: Column(
        children: [
          // Drag Handle
          Center(
            child: Container(
              margin: const EdgeInsets.only(top: 12, bottom: 8),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    widget.title,
                    style: AppTypography.displayHeadline.copyWith(fontSize: 20),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: AppColors.textSecondary),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),

          // Search Field
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: TextField(
              onChanged: (val) => setState(() => _searchQuery = val.toLowerCase().trim()),
              style: const TextStyle(color: AppColors.textPrimary),
              decoration: InputDecoration(
                hintText: 'Search by name, breed, microchip...',
                hintStyle: const TextStyle(color: AppColors.textMuted),
                prefixIcon: const Icon(Icons.search, color: AppColors.primaryGold),
                filled: true,
                fillColor: AppColors.inputField,
                contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),

          const SizedBox(height: 8),

          // Action: Add New Animal Button
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: OutlinedButton.icon(
              onPressed: () async {
                final createdAnimal = await Navigator.pushNamed(
                  context,
                  '/animal-details',
                  arguments: {
                    'species': widget.species,
                    if (widget.requiredSex != null) 'sex': widget.requiredSex,
                    if (widget.requiredSex != null) 'initialSex': widget.requiredSex,
                  },
                ) as Animal?;

                if (createdAnimal != null && context.mounted) {
                  Navigator.pop(context, createdAnimal);
                }
              },
              icon: const Icon(Icons.add_circle_outline, color: AppColors.primaryGold),
              label: Text(
                () {
                  if (widget.requiredSex != null) {
                    final req = widget.requiredSex!.toLowerCase();
                    if (req == 'stallion') return 'ADD NEW STALLION';
                    if (req == 'mare') return 'ADD NEW MARE';
                    return 'ADD NEW ${widget.requiredSex!.toUpperCase()}';
                  }
                  return 'ADD NEW ${widget.species.toUpperCase()}';
                }(),
                style: AppTypography.buttonLabel.copyWith(color: AppColors.primaryGold),
              ),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: AppColors.primaryGold, width: 1.5),
                padding: const EdgeInsets.symmetric(vertical: 14),
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
                ),
              ),
            ),
          ),

          const Divider(color: AppColors.surface, height: 24),

          // Animal List / Select Existing
          Expanded(
            child: animalsAsync.when(
              data: (animals) {
                final filtered = animals.where((a) {
                  if (widget.requiredSex != null) {
                    final req = widget.requiredSex!.toLowerCase();
                    if (req == 'mare' && !a.isMare) return false;
                    if (req == 'stallion' && !a.isStallion) return false;
                    if (req == 'female' && a.isStallion) return false;
                    if (req == 'male' && !a.isStallion) return false;
                  }
                  if (_searchQuery.isEmpty) return true;
                  final nameMatch = a.name.toLowerCase().contains(_searchQuery);
                  final breedMatch = a.breed?.toLowerCase().contains(_searchQuery) ?? false;
                  final chipMatch = a.microchipNo?.toLowerCase().contains(_searchQuery) ?? false;
                  return nameMatch || breedMatch || chipMatch;
                }).toList();

                if (filtered.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.pets, size: 48, color: AppColors.primaryGold.withValues(alpha: 0.4)),
                          const SizedBox(height: 16),
                          Text(
                            animals.isEmpty ? 'No ${widget.species}s registered yet' : 'No matching results found',
                            style: AppTypography.titleLarge.copyWith(color: AppColors.textPrimary),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            animals.isEmpty
                                ? 'Tap "+ Add New ${widget.species.toUpperCase()}" above to register your first one!'
                                : 'Try searching with a different term.',
                            style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  itemCount: filtered.length,
                  itemBuilder: (context, index) {
                    final animal = filtered[index];
                    final isSelected = animal.id == widget.currentSelectedId;

                    return AnimalListTile(
                      animal: animal,
                      isSelected: isSelected,
                      onTap: () => Navigator.pop(context, animal),
                      trailing: isSelected
                          ? const Icon(Icons.check_circle, color: AppColors.primaryGold, size: 22)
                          : null,
                    );
                  },
                );
              },
              loading: () => const Center(
                child: CircularProgressIndicator(color: AppColors.primaryGold),
              ),
              error: (err, stack) => Center(
                child: Text('Error loading animals: $err', style: const TextStyle(color: Colors.redAccent)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
