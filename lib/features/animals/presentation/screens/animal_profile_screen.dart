import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/widgets/gradient_cta_button.dart';
import '../../../../core/widgets/responsive_body.dart';
import '../../../../core/widgets/section_divider_label.dart';
import '../../../../core/widgets/app_thumbnail_avatar.dart';
import '../../domain/animal.dart';
import '../providers/animal_provider.dart';
import '../../../pregnancy/presentation/providers/pregnancy_provider.dart';
import '../../../pregnancy/domain/pregnancy_record.dart';

class AnimalProfileScreen extends ConsumerStatefulWidget {
  final Animal animal;

  const AnimalProfileScreen({
    super.key,
    required this.animal,
  });

  @override
  ConsumerState<AnimalProfileScreen> createState() => _AnimalProfileScreenState();
}

class _AnimalProfileScreenState extends ConsumerState<AnimalProfileScreen> {
  late Animal _currentAnimal;

  @override
  void initState() {
    super.initState();
    _currentAnimal = widget.animal;
    _reloadAnimal();
  }

  Future<void> _reloadAnimal([Animal? passed]) async {
    if (passed != null && mounted) {
      setState(() => _currentAnimal = passed);
    }
    final repo = ref.read(animalRepositoryProvider);
    final fresh = await repo.getAnimalById(_currentAnimal.id);
    if (fresh != null && mounted) {
      setState(() => _currentAnimal = fresh);
    }
  }

  String _calculateAge(DateTime? dob) {
    if (dob == null) return 'Not Specified';
    final now = DateTime.now();
    int years = now.year - dob.year;
    int months = now.month - dob.month;
    if (now.day < dob.day) {
      months--;
    }
    if (months < 0) {
      years--;
      months += 12;
    }
    if (years < 0) return 'Just Born';
    if (years == 0 && months == 0) return 'Under 1 Month';
    if (years == 0) return '$months ${months == 1 ? "Month" : "Months"}';
    if (months == 0) return '$years ${years == 1 ? "Year" : "Years"}';
    return '$years ${years == 1 ? "Yr" : "Yrs"} $months ${months == 1 ? "Mo" : "Mos"}';
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'Not Specified';
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  IconData _getSpeciesIcon(String species) {
    switch (species.toLowerCase()) {
      case 'horse':
        return Icons.pets_rounded;
      case 'dog':
        return Icons.pets;
      case 'cat':
        return Icons.catching_pokemon;
      default:
        return Icons.category_rounded;
    }
  }

  Future<void> _callNumber(String phoneNumber) async {
    final cleanPhone = phoneNumber.replaceAll(RegExp(r'[^\d+]'), '');
    final uri = Uri(scheme: 'tel', path: cleanPhone);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not dial $phoneNumber')),
        );
      }
    }
  }

  Future<void> _confirmDelete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSpacing.cardRadius)),
        title: Row(
          children: [
            const Icon(Icons.warning_amber_rounded, color: Colors.redAccent),
            const SizedBox(width: 10),
            Text('Delete ${_currentAnimal.name}', style: AppTypography.displayHeadline.copyWith(fontSize: 18)),
          ],
        ),
        content: Text(
          'Are you sure you want to permanently remove ${_currentAnimal.name} from the registry?',
          style: AppTypography.bodyMedium.copyWith(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('CANCEL', style: TextStyle(color: AppColors.textMuted)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('DELETE ANIMAL', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final repo = ref.read(animalRepositoryProvider);
      await repo.deleteAnimal(_currentAnimal.id);
      ref.invalidate(animalsListProvider(_currentAnimal.species));
      ref.invalidate(animalsListProvider('horse'));
      ref.invalidate(animalsListProvider('dog'));
      ref.invalidate(animalsListProvider('cat'));
      ref.invalidate(animalsListProvider(null));
      ref.invalidate(animalByIdProvider(_currentAnimal.id));

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${_currentAnimal.name} removed from registry.')),
        );
        Navigator.pop(context, true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final species = _currentAnimal.species.toLowerCase().trim();
    final isHorse = species == 'horse';
    final isDog = species == 'dog';

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.textPrimary, size: 20),
          onPressed: () => Navigator.maybePop(context),
        ),
        title: Text(
          '${_currentAnimal.name.toUpperCase()} PROFILE',
          style: AppTypography.sectionLabel,
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined, color: AppColors.primaryGold),
            tooltip: 'Edit Animal',
            onPressed: () async {
              final updated = await Navigator.pushNamed(
                context,
                '/animal-details',
                arguments: {'animal': _currentAnimal, 'species': _currentAnimal.species},
              );
              if (updated is Animal) {
                _reloadAnimal(updated);
              } else if (updated != null) {
                _reloadAnimal();
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
            tooltip: 'Delete Animal',
            onPressed: _confirmDelete,
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.horizontalPadding,
            vertical: 16.0,
          ),
          child: ResponsiveBody(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // 1. Hero Profile Header Card
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
                    border: Border.all(color: AppColors.primaryGold.withValues(alpha: 0.6), width: 1.5),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.3),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      // Photo or Emblem
                      AppThumbnailAvatar(
                        imagePath: _currentAnimal.photoUrl,
                        fallbackIcon: _getSpeciesIcon(_currentAnimal.species),
                        size: 96,
                        iconSize: 44,
                      ),
                      const SizedBox(height: 14),

                      // Name
                      Text(
                        _currentAnimal.name,
                        style: AppTypography.displayHeadline.copyWith(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),

                      // Badges
                      Wrap(
                        spacing: 8,
                        runSpacing: 6,
                        alignment: WrapAlignment.center,
                        children: [
                          _buildBadge(
                            label: _currentAnimal.species.toUpperCase(),
                            icon: _getSpeciesIcon(_currentAnimal.species),
                            isGold: true,
                          ),
                          _buildBadge(
                            label: _currentAnimal.displaySex.toUpperCase(),
                            icon: _currentAnimal.isStallion ? Icons.male : Icons.female,
                            isGold: false,
                          ),
                          if (_currentAnimal.breed?.isNotEmpty == true)
                            _buildBadge(
                              label: _currentAnimal.breed!,
                              icon: Icons.bookmark_border,
                            ),
                          if (_currentAnimal.colour?.isNotEmpty == true)
                            _buildBadge(
                              label: _currentAnimal.colour!,
                              icon: Icons.palette_outlined,
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // 2. Identity & Registration Details Card
                const SectionDividerLabel(label: 'REGISTRY & IDENTIFICATION'),
                const SizedBox(height: 12),

                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
                    border: Border.all(color: AppColors.surface),
                  ),
                  child: Column(
                    children: [
                      _buildInfoRow(
                        icon: _currentAnimal.isStallion ? Icons.male : Icons.female,
                        label: _currentAnimal.species == 'horse' ? 'Horse Classification' : 'Sex / Gender',
                        value: _currentAnimal.displaySex,
                      ),
                      const Divider(color: AppColors.inputField, height: 20),
                      _buildInfoRow(
                        icon: Icons.cake_outlined,
                        label: 'Date of Birth',
                        value: _formatDate(_currentAnimal.dateOfBirth),
                        subtitle: 'Age: ${_calculateAge(_currentAnimal.dateOfBirth)}',
                      ),
                      const Divider(color: AppColors.inputField, height: 20),
                      _buildInfoRow(
                        icon: Icons.qr_code_2_outlined,
                        label: 'Microchip Number',
                        value: _currentAnimal.microchipNo?.isNotEmpty == true ? _currentAnimal.microchipNo! : 'Not Registered',
                        trailing: _currentAnimal.microchipNo?.isNotEmpty == true
                            ? IconButton(
                                icon: const Icon(Icons.copy, size: 16, color: AppColors.primaryGold),
                                onPressed: () {
                                  Clipboard.setData(ClipboardData(text: _currentAnimal.microchipNo!));
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Microchip copied to clipboard!')),
                                  );
                                },
                              )
                            : null,
                      ),
                      const Divider(color: AppColors.inputField, height: 20),
                      _buildInfoRow(
                        icon: Icons.local_offer_outlined,
                        label: 'Brand / Tattoo',
                        value: _currentAnimal.brand?.isNotEmpty == true ? _currentAnimal.brand! : 'None Recorded',
                      ),
                      const Divider(color: AppColors.inputField, height: 20),
                      _buildInfoRow(
                        icon: Icons.biotech_outlined,
                        label: 'DNA Profile / Case #',
                        value: _currentAnimal.dna?.isNotEmpty == true ? _currentAnimal.dna! : 'None Recorded',
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // 3. Owner & Client Contact Card
                const SectionDividerLabel(label: 'OWNER & CLIENT DETAILS'),
                const SizedBox(height: 12),

                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
                    border: Border.all(color: AppColors.surface),
                  ),
                  child: Column(
                    children: [
                      _buildInfoRow(
                        icon: Icons.person_outline,
                        label: 'Owner / Client Name',
                        value: _currentAnimal.ownerClientName?.isNotEmpty == true
                            ? _currentAnimal.ownerClientName!
                            : 'Not Specified',
                      ),
                      const Divider(color: AppColors.inputField, height: 20),
                      _buildInfoRow(
                        icon: Icons.phone_outlined,
                        label: 'Contact Phone',
                        value: _currentAnimal.ownerClientPhone?.isNotEmpty == true
                            ? _currentAnimal.ownerClientPhone!
                            : 'Not Specified',
                        trailing: _currentAnimal.ownerClientPhone?.isNotEmpty == true
                            ? ElevatedButton.icon(
                                onPressed: () => _callNumber(_currentAnimal.ownerClientPhone!),
                                icon: const Icon(Icons.call, size: 14),
                                label: const Text('CALL'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primaryGold,
                                  foregroundColor: AppColors.background,
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                  textStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                                ),
                              )
                            : null,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Live Pregnancy & Scans Status Card (for Horses or any animal with active pregnancy)
                if (isHorse) ...[
                  ref.watch(pregnancyRecordForCarrierProvider(_currentAnimal.id)).when(
                    data: (pregRecord) {
                      if (pregRecord == null) return const SizedBox.shrink();
                      final completedCount = (pregRecord.scan1Confirmed ? 1 : 0) +
                          (pregRecord.scan2Confirmed ? 1 : 0) +
                          (pregRecord.scan3Confirmed ? 1 : 0);

                      return Container(
                        margin: const EdgeInsets.only(bottom: 20),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
                          border: Border.all(
                            color: completedCount == 3
                                ? Colors.greenAccent.withValues(alpha: 0.8)
                                : AppColors.primaryGold.withValues(alpha: 0.6),
                            width: 1.5,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    const Icon(Icons.favorite, color: AppColors.primaryGold, size: 18),
                                    const SizedBox(width: 8),
                                    Text(
                                      'PREGNANCY & SCANS',
                                      style: AppTypography.sectionLabel.copyWith(color: AppColors.primaryGold),
                                    ),
                                  ],
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: completedCount == 3
                                        ? Colors.green.withValues(alpha: 0.2)
                                        : AppColors.primaryGold.withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(4),
                                    border: Border.all(
                                      color: completedCount == 3 ? Colors.greenAccent : AppColors.primaryGold,
                                    ),
                                  ),
                                  child: Text(
                                    '$completedCount / 3 SCANS CONFIRMED',
                                    style: TextStyle(
                                      color: completedCount == 3 ? Colors.greenAccent : AppColors.primaryGold,
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            if (pregRecord.foalingDueDate != null) ...[
                              Text(
                                'Estimated Foaling: ${_formatDate(pregRecord.foalingDueDate)}',
                                style: AppTypography.displayHeadline.copyWith(fontSize: 15),
                              ),
                              const SizedBox(height: 10),
                            ],
                            // 3 Scans Row
                            Row(
                              children: [
                                _buildScanBadge('Scan 1 (+14d)', pregRecord.scan1Confirmed, pregRecord.scan1DueDate),
                                const SizedBox(width: 6),
                                _buildScanBadge('Scan 2 (+30d)', pregRecord.scan2Confirmed, pregRecord.scan2DueDate),
                                const SizedBox(width: 6),
                                _buildScanBadge('Scan 3 (+45d)', pregRecord.scan3Confirmed, pregRecord.scan3DueDate),
                              ],
                            ),
                            if (pregRecord.vetName?.isNotEmpty == true || pregRecord.vetNumber?.isNotEmpty == true) ...[
                              const SizedBox(height: 10),
                              Text(
                                'Veterinarian: ${pregRecord.vetName ?? "Assigned Vet"} ${pregRecord.vetNumber?.isNotEmpty == true ? "(${pregRecord.vetNumber})" : ""}',
                                style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary, fontSize: 11),
                              ),
                            ],
                            const SizedBox(height: 12),
                            SizedBox(
                              width: double.infinity,
                              child: OutlinedButton.icon(
                                onPressed: () async {
                                  await Navigator.pushNamed(
                                    context,
                                    '/vet-pregnancy-scans',
                                    arguments: {'carrierAnimalId': _currentAnimal.id},
                                  );
                                  ref.invalidate(pregnancyRecordForCarrierProvider(_currentAnimal.id));
                                },
                                icon: const Icon(Icons.medical_services_outlined, size: 14, color: AppColors.primaryGold),
                                label: const Text('VIEW & UPDATE SCANS', style: TextStyle(color: AppColors.primaryGold, fontSize: 11, fontWeight: FontWeight.bold)),
                                style: OutlinedButton.styleFrom(
                                  side: const BorderSide(color: AppColors.primaryGold),
                                  padding: const EdgeInsets.symmetric(vertical: 8),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                    loading: () => const SizedBox.shrink(),
                    error: (_, __) => const SizedBox.shrink(),
                  ),
                ],

                // 4. Action Hub
                const SectionDividerLabel(label: 'QUICK ACTIONS & PROCEDURES'),
                const SizedBox(height: 14),

                // Primary Edit CTA
                GradientCtaButton(
                  text: 'EDIT ANIMAL DETAILS',
                  icon: const Icon(Icons.edit, color: AppColors.background, size: 18),
                  onPressed: () async {
                    final updated = await Navigator.pushNamed(
                      context,
                      '/animal-details',
                      arguments: {'animal': _currentAnimal, 'species': _currentAnimal.species},
                    );
                    if (updated is Animal) {
                      _reloadAnimal(updated);
                    } else if (updated != null) {
                      _reloadAnimal();
                    }
                  },
                ),
                const SizedBox(height: 12),

                // Equine Specific Actions
                if (isHorse) ...[
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () async {
                            await Navigator.pushNamed(
                              context,
                              '/breeding-details',
                              arguments: _currentAnimal.id,
                            );
                            ref.invalidate(pregnancyRecordForCarrierProvider(_currentAnimal.id));
                          },
                          icon: const Icon(Icons.favorite_outline, color: AppColors.primaryGold, size: 16),
                          label: const FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text('LOG BREEDING', style: TextStyle(color: AppColors.primaryGold, fontWeight: FontWeight.bold)),
                          ),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: AppColors.primaryGold),
                            padding: const EdgeInsets.symmetric(vertical: 13, horizontal: 8),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () async {
                            await Navigator.pushNamed(
                              context,
                              '/vet-pregnancy-scans',
                              arguments: {'carrierAnimalId': _currentAnimal.id},
                            );
                            ref.invalidate(pregnancyRecordForCarrierProvider(_currentAnimal.id));
                          },
                          icon: const Icon(Icons.medical_services_outlined, color: AppColors.primaryGold, size: 16),
                          label: const FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text('SCANS & VET', style: TextStyle(color: AppColors.primaryGold, fontWeight: FontWeight.bold)),
                          ),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: AppColors.primaryGold),
                            padding: const EdgeInsets.symmetric(vertical: 13, horizontal: 8),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {
                            Navigator.pushNamed(
                              context,
                              '/preventative-care',
                              arguments: {
                                'ownerType': 'animal',
                                'ownerId': _currentAnimal.id,
                                'title': '${_currentAnimal.name} (Mare)',
                              },
                            );
                          },
                          icon: const Icon(Icons.healing_outlined, color: AppColors.primaryGold, size: 16),
                          label: const FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text('HEALTH & CARE', style: TextStyle(color: AppColors.primaryGold, fontWeight: FontWeight.bold)),
                          ),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: AppColors.surface),
                            padding: const EdgeInsets.symmetric(vertical: 13, horizontal: 8),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {
                            Navigator.pushNamed(
                              context,
                              '/markings',
                              arguments: {
                                'ownerType': 'animal',
                                'ownerId': _currentAnimal.id,
                              },
                            );
                          },
                          icon: const Icon(Icons.brush_outlined, color: AppColors.primaryGold, size: 16),
                          label: const FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text('MARKINGS', style: TextStyle(color: AppColors.primaryGold, fontWeight: FontWeight.bold)),
                          ),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: AppColors.surface),
                            padding: const EdgeInsets.symmetric(vertical: 13, horizontal: 8),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],

                // Canine Specific Actions
                if (isDog) ...[
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {
                            Navigator.pushNamed(
                              context,
                              '/puppies',
                              arguments: _currentAnimal.id,
                            );
                          },
                          icon: const Icon(Icons.bedroom_baby_outlined, color: AppColors.primaryGold, size: 16),
                          label: const FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text('PUPPIES / LITTER', style: TextStyle(color: AppColors.primaryGold, fontWeight: FontWeight.bold)),
                          ),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: AppColors.primaryGold),
                            padding: const EdgeInsets.symmetric(vertical: 13, horizontal: 8),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {
                            Navigator.pushNamed(
                              context,
                              '/dog-preventative-care',
                              arguments: {
                                'ownerType': 'dam',
                                'ownerId': _currentAnimal.id,
                                'title': '${_currentAnimal.name} (Dam)',
                                'dateOfBirth': _currentAnimal.dateOfBirth,
                              },
                            );
                          },
                          icon: const Icon(Icons.healing_outlined, color: AppColors.primaryGold, size: 16),
                          label: const FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text('HEALTH PROTOCOLS', style: TextStyle(color: AppColors.primaryGold, fontWeight: FontWeight.bold)),
                          ),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: AppColors.primaryGold),
                            padding: const EdgeInsets.symmetric(vertical: 13, horizontal: 8),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],

                const SizedBox(height: 28),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildScanBadge(String label, bool confirmed, DateTime? dueDate) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
        decoration: BoxDecoration(
          color: confirmed
              ? Colors.green.withValues(alpha: 0.15)
              : AppColors.inputField,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: confirmed ? Colors.greenAccent : AppColors.surface,
          ),
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  confirmed ? Icons.check_circle : Icons.schedule,
                  size: 12,
                  color: confirmed ? Colors.greenAccent : AppColors.primaryGold,
                ),
                const SizedBox(width: 3),
                Flexible(
                  child: Text(
                    label,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: confirmed ? Colors.greenAccent : AppColors.textPrimary,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 3),
            Text(
              confirmed
                  ? 'CONFIRMED'
                  : (dueDate != null ? '${dueDate.day}/${dueDate.month}' : 'PENDING'),
              style: TextStyle(
                fontSize: 9,
                fontWeight: FontWeight.w600,
                color: confirmed ? Colors.greenAccent : AppColors.textMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBadge({required String label, required IconData icon, bool isGold = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: isGold ? AppColors.primaryGold.withValues(alpha: 0.15) : AppColors.inputField,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isGold ? AppColors.primaryGold : AppColors.surface,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: isGold ? AppColors.primaryGold : AppColors.textSecondary),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: isGold ? AppColors.primaryGold : AppColors.textPrimary,
              fontSize: 11,
              fontWeight: isGold ? FontWeight.bold : FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
    String? subtitle,
    Widget? trailing,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: AppColors.inputField,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: AppColors.primaryGold, size: 18),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: AppTypography.bodySmall.copyWith(color: AppColors.textMuted, fontSize: 11),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: AppTypography.bodyMedium.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (subtitle != null) ...[
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(color: AppColors.primaryGold.withValues(alpha: 0.9), fontSize: 11, fontWeight: FontWeight.w500),
                ),
              ],
            ],
          ),
        ),
        ?trailing,
      ],
    );
  }
}
