import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/widgets/app_thumbnail_avatar.dart';
import '../../../../core/widgets/horseshoe_icon.dart';
import '../../../../core/widgets/species_icon.dart';
import '../../../animals/domain/animal.dart';
import '../providers/pregnancy_provider.dart';

class MarePregnancyCard extends ConsumerWidget {
  final Animal mare;

  const MarePregnancyCard({
    super.key,
    required this.mare,
  });

  String _formatDate(DateTime? dt) {
    if (dt == null) return 'N/A';
    return '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year}';
  }

  String _getCountdownText(DateTime dueDate) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final due = DateTime(dueDate.year, dueDate.month, dueDate.day);
    final diff = due.difference(today).inDays;

    if (diff > 1) return '$diff Days Remaining';
    if (diff == 1) return 'Due Tomorrow!';
    if (diff == 0) return 'Due Today! 🎉';
    return 'Gestation Completed (${diff.abs()}d ago)';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pregnancyAsync = ref.watch(pregnancyRecordForCarrierProvider(mare.id));
    final breedingAsync = ref.watch(breedingRecordByMareProvider(mare.id));

    final pregnancy = pregnancyAsync.valueOrNull;
    final breeding = breedingAsync.valueOrNull;

    final isScan1Confirmed = pregnancy?.scan1Confirmed == true;
    final isScan2Confirmed = pregnancy?.scan2Confirmed == true;
    final isScan3Confirmed = pregnancy?.scan3Confirmed == true;
    final isAnyScanConfirmed = isScan1Confirmed || isScan2Confirmed || isScan3Confirmed;
    final hasBreeding = breeding != null;
    final foalingDueDate = pregnancy?.foalingDueDate;

    final sp = mare.species.toLowerCase().trim();
    final isHorse = sp == 'horse';
    final isDog = sp == 'dog';
    final isCat = sp == 'cat';

    // Determine species-specific status text & colors
    final String statusText;
    final Color statusColor;
    final IconData statusIcon;

    final String pregnantLabel = isHorse
        ? 'IN FOAL'
        : (isDog
            ? 'IN WHELP'
            : (isCat ? 'PREGNANT QUEEN' : 'PREGNANT'));
    final String notPregnantLabel = isHorse
        ? 'NOT IN FOAL'
        : (isDog
            ? 'NOT IN WHELP'
            : 'NOT PREGNANT');

    if (isScan3Confirmed) {
      statusText = 'SCAN 3 CONFIRMED • FULL GESTATION';
      statusColor = const Color(0xFF10B981); // Emerald
      statusIcon = Icons.check_circle_rounded;
    } else if (isScan2Confirmed) {
      statusText = 'SCAN 2 CONFIRMED • $pregnantLabel (30D)';
      statusColor = const Color(0xFF10B981);
      statusIcon = Icons.check_circle_rounded;
    } else if (isScan1Confirmed) {
      statusText = 'SCAN 1 CONFIRMED • $pregnantLabel (14D)';
      statusColor = const Color(0xFF10B981);
      statusIcon = Icons.check_circle_rounded;
    } else if (hasBreeding || pregnancy != null) {
      statusText = 'BREEDING LOGGED • SCAN 1 PENDING';
      statusColor = const Color(0xFFF59E0B); // Amber
      statusIcon = Icons.pending_actions_rounded;
    } else {
      statusText = 'READY FOR BREEDING • $notPregnantLabel';
      statusColor = AppColors.textMuted;
      statusIcon = Icons.favorite_border_rounded;
    }

    final String defaultSpeciesLabel = isHorse
        ? 'Equine Mare'
        : (isDog
            ? 'Canine Dam/Bitch'
            : (isCat ? 'Feline Queen' : 'Breeding Female'));

    final String dueDateTitle = isHorse
        ? 'FINAL FOALING DUE DATE'
        : (isDog
            ? 'FINAL WHELPING DUE DATE'
            : (isCat ? 'FINAL QUEENING DUE DATE' : 'FINAL GESTATION DUE DATE'));

    final String sireTitle = isHorse
        ? 'Stallion / Sire'
        : (isDog
            ? 'Stud Dog / Sire'
            : (isCat ? 'Tom Cat / Sire' : 'Sire'));

    final sexDisplay = (mare.sex != null && mare.sex!.isNotEmpty) ? mare.sex!.toUpperCase() : 'FEMALE';

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
        border: Border.all(
          color: isAnyScanConfirmed
              ? AppColors.primaryGold.withValues(alpha: 0.7)
              : hasBreeding
                  ? const Color(0xFFF59E0B).withValues(alpha: 0.5)
                  : AppColors.inputField,
          width: isAnyScanConfirmed ? 1.5 : 1.0,
        ),
        boxShadow: [
          if (isAnyScanConfirmed)
            BoxShadow(
              color: AppColors.primaryGold.withValues(alpha: 0.12),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 1. Mare Header & Pregnancy Status
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Animal Photo / Avatar
                    AppThumbnailAvatar(
                      imagePath: mare.photoUrl,
                      species: mare.species,
                      customFallback: SpeciesIcon(species: mare.species, size: 24, color: AppColors.primaryGold),
                      size: 48,
                      iconSize: 24,
                      isCircle: true,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            mare.name,
                            style: AppTypography.displayHeadline.copyWith(
                              fontSize: 17,
                              color: AppColors.primaryGold,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Row(
                            children: [
                              SpeciesIcon(species: mare.species, size: 13, color: AppColors.primaryGold),
                              const SizedBox(width: 5),
                              Expanded(
                                child: Text(
                                  '${mare.breed ?? defaultSpeciesLabel} • $sexDisplay',
                                  style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                          if (mare.microchipNo != null && mare.microchipNo!.isNotEmpty) ...[
                            const SizedBox(height: 2),
                            Text(
                              'Chip: ${mare.microchipNo}',
                              style: AppTypography.bodySmall.copyWith(color: AppColors.textMuted, fontSize: 11),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Status Badge Banner
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: statusColor.withValues(alpha: 0.4)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(statusIcon, color: statusColor, size: 16),
                      const SizedBox(width: 6),
                      Flexible(
                        child: Text(
                          statusText,
                          style: TextStyle(
                            color: statusColor,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const Divider(height: 1, color: AppColors.inputField),

          // 2. Breeding & Pregnancy Timeline Info
          if (hasBreeding || foalingDueDate != null) ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (breeding != null) ...[
                    Row(
                      children: [
                        const Icon(Icons.favorite_rounded, color: Color(0xFFEC4899), size: 15),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            '$sireTitle: ${breeding.stallionName?.isNotEmpty == true ? breeding.stallionName! : "Unknown"} • Method: ${breeding.method.toUpperCase()}',
                            style: AppTypography.bodySmall.copyWith(
                              color: AppColors.textPrimary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Cover / Insemination Date: ${_formatDate(breeding.coverOrTransferDate)}',
                      style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary, fontSize: 12),
                    ),
                    if (breeding.isEmbryoTransfer) ...[
                      const SizedBox(height: 2),
                      Text(
                        'Embryo Transfer • Genetic Dam: ${breeding.damOfEmbryo ?? mare.name}',
                        style: AppTypography.bodySmall.copyWith(color: AppColors.primaryGold, fontSize: 11),
                      ),
                    ],
                    const SizedBox(height: 10),
                  ],

                  // Confirmed Foaling / Due Date Banner
                  if (foalingDueDate != null) ...[
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [
                            Color(0xFF2C2213),
                            Color(0xFF1E1B13),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: AppColors.primaryGold.withValues(alpha: 0.8), width: 1.2),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              SpeciesIcon(species: mare.species, color: AppColors.primaryGold, size: 18),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  dueDateTitle,
                                  style: AppTypography.displayHeadline.copyWith(
                                    fontSize: 12,
                                    color: AppColors.primaryGold,
                                    letterSpacing: 1,
                                  ),
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: AppColors.primaryGold.withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  _getCountdownText(foalingDueDate),
                                  style: const TextStyle(
                                    color: AppColors.primaryGold,
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(
                            _formatDate(foalingDueDate),
                            style: AppTypography.displayHeadline.copyWith(
                              fontSize: 20,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),

                          // Scan mini checklist badges
                          Wrap(
                            spacing: 6,
                            runSpacing: 4,
                            children: [
                              _buildScanBadge('Scan 1 (Day 14)', isScan1Confirmed, pregnancy?.scan1DueDate),
                              _buildScanBadge('Scan 2 (Day 30)', isScan2Confirmed, pregnancy?.scan2DueDate),
                              _buildScanBadge('Scan 3 (Day 45)', isScan3Confirmed, pregnancy?.scan3DueDate),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const Divider(height: 1, color: AppColors.inputField),
          ],

          // 3. Action Buttons & Navigation Flow
          Padding(
            padding: const EdgeInsets.all(14.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Primary Action: View Pregnancy Details
                OutlinedButton.icon(
                  onPressed: () {
                    Navigator.pushNamed(
                      context,
                      '/pregnancy-details',
                      arguments: {
                        'carrierAnimalId': mare.id,
                        'pregnancyRecordId': pregnancy?.id,
                        'breedingRecordId': breeding?.id,
                      },
                    );
                  },
                  icon: const Icon(Icons.analytics_outlined, color: AppColors.primaryGold, size: 18),
                  label: const Text(
                    'VIEW PREGNANCY DETAILS & SCANS',
                    style: TextStyle(
                      color: AppColors.primaryGold,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                      fontSize: 13,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppColors.primaryGold, width: 1.3),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
                const SizedBox(height: 8),

                // Secondary Action Row: Scans & Vet + Log Breeding
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          Navigator.pushNamed(
                            context,
                            '/vet-pregnancy-scans',
                            arguments: {
                              'carrierAnimalId': mare.id,
                              'pregnancyRecordId': pregnancy?.id,
                            },
                          );
                        },
                        icon: const Icon(Icons.medical_services_outlined, size: 15, color: AppColors.textPrimary),
                        label: const FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text('Scans & Vet', style: TextStyle(color: AppColors.textPrimary, fontSize: 12)),
                        ),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: AppColors.inputField),
                          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          Navigator.pushNamed(
                            context,
                            '/breeding-details',
                            arguments: mare.id,
                          );
                        },
                        icon: Icon(
                          hasBreeding ? Icons.edit_note_rounded : Icons.favorite_outline_rounded,
                          size: 15,
                          color: AppColors.primaryGold,
                        ),
                        label: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            hasBreeding ? 'Edit Breeding' : 'Log Breeding',
                            style: const TextStyle(color: AppColors.primaryGold, fontWeight: FontWeight.bold, fontSize: 12),
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: AppColors.primaryGold),
                          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                // Tertiary Row: Advanced Info + Preventative Care
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: pregnancy != null
                            ? () {
                                Navigator.pushNamed(
                                  context,
                                  '/advanced-pregnancy',
                                  arguments: pregnancy.id,
                                );
                              }
                            : null,
                        icon: const Icon(Icons.science_outlined, size: 14),
                        label: const FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text('Advanced Info', style: TextStyle(fontSize: 11)),
                        ),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: AppColors.inputField),
                          padding: const EdgeInsets.symmetric(vertical: 9, horizontal: 4),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          Navigator.pushNamed(
                            context,
                            '/preventative-care',
                            arguments: mare.id,
                          );
                        },
                        icon: const Icon(Icons.healing_outlined, size: 14),
                        label: const FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text('Preventative Care', style: TextStyle(fontSize: 11)),
                        ),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: AppColors.inputField),
                          padding: const EdgeInsets.symmetric(vertical: 9, horizontal: 4),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                      ),
                    ),
                  ],
                ),

                // Celebrate Birth CTA (Shown when pregnant or due date set)
                if (isAnyScanConfirmed || foalingDueDate != null) ...[
                  const SizedBox(height: 10),
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pushNamed(
                        context,
                        '/congratulations',
                        arguments: {
                          'species': 'Equine',
                          'damMareId': mare.id,
                          'stallion': breeding?.stallionName,
                        },
                      );
                    },
                    icon: const Icon(Icons.celebration_rounded, size: 16, color: AppColors.background),
                    label: const Text(
                      'CELEBRATE FOAL ARRIVAL 🎉',
                      style: TextStyle(
                        color: AppColors.background,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                        letterSpacing: 0.5,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryGold,
                      padding: const EdgeInsets.symmetric(vertical: 11),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScanBadge(String label, bool confirmed, DateTime? date) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        color: confirmed
            ? const Color(0xFF10B981).withValues(alpha: 0.15)
            : AppColors.inputField,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: confirmed
              ? const Color(0xFF10B981).withValues(alpha: 0.5)
              : AppColors.inputBorder,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            confirmed ? Icons.check_circle_rounded : Icons.schedule_rounded,
            size: 11,
            color: confirmed ? const Color(0xFF10B981) : AppColors.textMuted,
          ),
          const SizedBox(width: 4),
          Text(
            '$label${date != null ? ": ${_formatDate(date)}" : ""}',
            style: TextStyle(
              fontSize: 10,
              color: confirmed ? const Color(0xFF10B981) : AppColors.textSecondary,
              fontWeight: confirmed ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}
