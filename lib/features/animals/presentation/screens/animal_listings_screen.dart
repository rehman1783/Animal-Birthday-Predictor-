import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../../../../core/widgets/gradient_cta_button.dart';
import '../../domain/animal.dart';
import '../../domain/animal_type.dart';
import '../providers/animal_provider.dart';

class AnimalListingsScreen extends ConsumerStatefulWidget {
  const AnimalListingsScreen({super.key});

  @override
  ConsumerState<AnimalListingsScreen> createState() => _AnimalListingsScreenState();
}

class _AnimalListingsScreenState extends ConsumerState<AnimalListingsScreen> {
  final _searchController = TextEditingController();
  AnimalType? _selectedType;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showAddAnimalDialog(BuildContext context) {
    final nameController = TextEditingController();
    final breedController = TextEditingController();
    final regController = TextEditingController();
    final damController = TextEditingController();
    final sireController = TextEditingController();
    final notesController = TextEditingController();
    AnimalType selectedType = AnimalType.horse;
    String selectedGender = 'female';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.background,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 20,
                bottom: MediaQuery.of(context).viewInsets.bottom + 20,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Register New Animal',
                          style: AppTypography.displayHeadline.copyWith(fontSize: 20),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close, color: AppColors.textSecondary),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    CustomTextField(
                      label: 'Animal Name',
                      hintText: 'e.g. Starlight Eclipse',
                      leadingIcon: Icons.pets_outlined,
                      controller: nameController,
                    ),
                    const SizedBox(height: 12),

                    Text('Species', style: AppTypography.inputLabel),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.inputField,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.inputBorder),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<AnimalType>(
                          value: selectedType,
                          dropdownColor: AppColors.surface,
                          isExpanded: true,
                          items: AnimalType.values.map((type) {
                            return DropdownMenuItem<AnimalType>(
                              value: type,
                              child: Text(type.displayName, style: AppTypography.inputText),
                            );
                          }).toList(),
                          onChanged: (val) {
                            if (val != null) setModalState(() => selectedType = val);
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),

                    CustomTextField(
                      label: 'Breed',
                      hintText: 'e.g. Thoroughbred, German Shepherd',
                      leadingIcon: Icons.category_outlined,
                      controller: breedController,
                    ),
                    const SizedBox(height: 12),

                    Row(
                      children: [
                        Expanded(
                          child: CustomTextField(
                            label: 'Registration #',
                            hintText: 'e.g. REG-99421',
                            leadingIcon: Icons.badge_outlined,
                            controller: regController,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Gender', style: AppTypography.inputLabel),
                              const SizedBox(height: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12),
                                decoration: BoxDecoration(
                                  color: AppColors.inputField,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: AppColors.inputBorder),
                                ),
                                child: DropdownButtonHideUnderline(
                                  child: DropdownButton<String>(
                                    value: selectedGender,
                                    dropdownColor: AppColors.surface,
                                    isExpanded: true,
                                    items: const [
                                      DropdownMenuItem(value: 'female', child: Text('Female (Dam)')),
                                      DropdownMenuItem(value: 'male', child: Text('Male (Sire)')),
                                    ],
                                    onChanged: (val) {
                                      if (val != null) setModalState(() => selectedGender = val);
                                    },
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    CustomTextField(
                      label: 'Dam Name (Mother)',
                      hintText: 'e.g. Celestial Queen',
                      leadingIcon: Icons.female_outlined,
                      controller: damController,
                    ),
                    const SizedBox(height: 12),

                    CustomTextField(
                      label: 'Sire Name (Father)',
                      hintText: 'e.g. Northern Dancer',
                      leadingIcon: Icons.male_outlined,
                      controller: sireController,
                    ),
                    const SizedBox(height: 12),

                    CustomTextField(
                      label: 'Notes / Pedigree Details',
                      hintText: 'e.g. Health history, breeding record notes',
                      leadingIcon: Icons.notes_outlined,
                      controller: notesController,
                    ),
                    const SizedBox(height: 20),

                    GradientCtaButton(
                      text: 'Save Animal Record',
                      onPressed: () async {
                        if (nameController.text.trim().isEmpty) return;
                        final newAnimal = Animal(
                          id: DateTime.now().millisecondsSinceEpoch.toString(),
                          name: nameController.text.trim(),
                          type: selectedType,
                          breed: breedController.text.trim().isEmpty ? 'Standard' : breedController.text.trim(),
                          gender: selectedGender,
                          dateOfBirth: DateTime.now(),
                          registrationNumber: regController.text.trim(),
                          damName: damController.text.trim(),
                          sireName: sireController.text.trim(),
                          notes: notesController.text.trim(),
                          createdAt: DateTime.now(),
                        );

                        await ref.read(animalListProvider.notifier).addAnimal(newAnimal);
                        if (context.mounted) Navigator.pop(context);
                      },
                    ),
                    const SizedBox(height: 10),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final animalState = ref.watch(animalListProvider);
    final searchQuery = _searchController.text.trim().toLowerCase();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: Text(
          'Registered Animals',
          style: AppTypography.displayHeadline.copyWith(fontSize: 22),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline_rounded, color: AppColors.primaryGold, size: 28),
            onPressed: () => _showAddAnimalDialog(context),
          ),
        ],
      ),
      body: Column(
        children: [
          // Filter Chips & Search Bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.horizontalPadding),
            child: Column(
              children: [
                TextField(
                  controller: _searchController,
                  onChanged: (val) => setState(() {}),
                  style: AppTypography.inputText,
                  decoration: InputDecoration(
                    hintText: 'Search animals by name, breed, or reg #...',
                    hintStyle: AppTypography.inputHint,
                    prefixIcon: const Icon(Icons.search_rounded, color: AppColors.primaryGold),
                    filled: true,
                    fillColor: AppColors.inputField,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppColors.inputBorder),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppColors.primaryGold),
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // Species Filter Horizontal List
                SizedBox(
                  height: 38,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: FilterChip(
                          label: const Text('All Species'),
                          selected: _selectedType == null,
                          selectedColor: AppColors.primaryGold,
                          backgroundColor: AppColors.surface,
                          labelStyle: TextStyle(
                            color: _selectedType == null ? AppColors.background : AppColors.textSecondary,
                            fontWeight: FontWeight.bold,
                          ),
                          onSelected: (val) => setState(() => _selectedType = null),
                        ),
                      ),
                      ...AnimalType.values.map((type) {
                        final isSelected = _selectedType == type;
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: FilterChip(
                            avatar: Icon(type.icon, size: 14, color: isSelected ? AppColors.background : AppColors.primaryGold),
                            label: Text(type.shortName),
                            selected: isSelected,
                            selectedColor: AppColors.primaryGold,
                            backgroundColor: AppColors.surface,
                            labelStyle: TextStyle(
                              color: isSelected ? AppColors.background : AppColors.textSecondary,
                              fontWeight: FontWeight.bold,
                            ),
                            onSelected: (val) => setState(() => _selectedType = isSelected ? null : type),
                          ),
                        );
                      }),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Animal List View
          Expanded(
            child: animalState.when(
              data: (animals) {
                var filtered = animals.where((a) {
                  final matchesType = _selectedType == null || a.type == _selectedType;
                  final matchesQuery = searchQuery.isEmpty ||
                      a.name.toLowerCase().contains(searchQuery) ||
                      a.breed.toLowerCase().contains(searchQuery) ||
                      (a.registrationNumber ?? '').toLowerCase().contains(searchQuery);
                  return matchesType && matchesQuery;
                }).toList();

                if (filtered.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.pets_outlined, size: 48, color: AppColors.textMuted),
                        const SizedBox(height: 12),
                        const Text('No animals found', style: AppTypography.body),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.surface,
                            foregroundColor: AppColors.primaryGold,
                          ),
                          onPressed: () => _showAddAnimalDialog(context),
                          child: const Text('+ Add New Animal'),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.horizontalPadding),
                  itemCount: filtered.length,
                  itemBuilder: (context, index) {
                    final animal = filtered[index];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
                        border: Border.all(color: AppColors.inputBorder),
                      ),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: AppColors.background,
                          child: Icon(animal.type.icon, color: AppColors.primaryGold),
                        ),
                        title: Text(animal.name, style: AppTypography.featureTitle),
                        subtitle: Text(
                          '${animal.type.shortName} • ${animal.breed} (${animal.gender})',
                          style: AppTypography.body.copyWith(fontSize: 12),
                        ),
                        trailing: const Icon(Icons.chevron_right, color: AppColors.textMuted),
                        onTap: () {
                          ref.read(selectedAnimalProvider.notifier).state = animal;
                          Navigator.pushNamed(context, '/animal-detail');
                        },
                      ),
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator(color: AppColors.primaryGold)),
              error: (e, s) => Center(child: Text('Error loading animals: $e', style: AppTypography.body)),
            ),
          ),
        ],
      ),
    );
  }
}
