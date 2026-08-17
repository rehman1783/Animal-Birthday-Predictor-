import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/widgets/gradient_cta_button.dart';
import '../../../../core/widgets/responsive_body.dart';
import '../../../../core/widgets/app_thumbnail_avatar.dart';
import '../../domain/puppy.dart';
import '../providers/puppy_provider.dart';
import 'puppy_details_screen.dart';

class PuppyListScreen extends ConsumerStatefulWidget {
  final String? damId;

  const PuppyListScreen({super.key, this.damId});

  @override
  ConsumerState<PuppyListScreen> createState() => _PuppyListScreenState();
}

class _PuppyListScreenState extends ConsumerState<PuppyListScreen> {
  String _selectedStatus = 'all';

  @override
  Widget build(BuildContext context) {
    final puppiesAsync = ref.watch(puppiesListProvider(widget.damId));

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.textPrimary, size: 20),
          onPressed: () => Navigator.maybePop(context),
        ),
        title: const Text('PUPPY REGISTRY & LITTERS', style: AppTypography.sectionLabel),
        centerTitle: true,
      ),
      body: SafeArea(
        child: puppiesAsync.when(
          data: (puppies) {
            final filtered = puppies.where((p) {
              if (_selectedStatus == 'all') return true;
              return p.status?.toLowerCase() == _selectedStatus.toLowerCase();
            }).toList();

            if (puppies.isEmpty) {
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
                          child: const Icon(Icons.bedroom_baby_outlined, size: 36, color: AppColors.primaryGold),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          'No Puppies Registered Yet',
                          style: AppTypography.displayHeadline.copyWith(fontSize: 20),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Register individual puppies, assign collar tags, track daily weights, and manage dual-date health protocols.',
                          style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 24),
                        SizedBox(
                          width: 220,
                          child: GradientCtaButton(
                            text: '+ Add New Puppy',
                            onPressed: () async {
                              final updated = await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const PuppyDetailsScreen(),
                                ),
                              );
                              if (updated != null) {
                                ref.invalidate(puppiesListProvider(widget.damId));
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

            return Column(
              children: [
                // Status Filter Bar
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
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

                // Puppies List
                Expanded(
                  child: RefreshIndicator(
                    color: AppColors.primaryGold,
                    backgroundColor: AppColors.surface,
                    onRefresh: () async {
                      ref.invalidate(puppiesListProvider(widget.damId));
                    },
                    child: ResponsiveBody(
                      child: ListView.builder(
                        padding: const EdgeInsets.fromLTRB(16, 4, 16, 80),
                        itemCount: filtered.length,
                        itemBuilder: (context, index) {
                          final puppy = filtered[index];
                          return _PuppyListCard(
                            puppy: puppy,
                            onEdit: () async {
                              final updated = await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => PuppyDetailsScreen(puppy: puppy),
                                ),
                              );
                              if (updated != null) {
                                ref.invalidate(puppiesListProvider(widget.damId));
                              }
                            },
                            onCertificate: () {
                              Navigator.pushNamed(
                                context,
                                '/certificate',
                                arguments: {'puppy': puppy},
                              );
                            },
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
          loading: () => const Center(child: CircularProgressIndicator(color: AppColors.primaryGold)),
          error: (e, _) => Center(child: Text('Error loading puppies: $e', style: const TextStyle(color: Colors.redAccent))),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.primaryGold,
        foregroundColor: AppColors.background,
        icon: const Icon(Icons.add, color: AppColors.background),
        label: const Text('Add Puppy', style: TextStyle(fontWeight: FontWeight.bold)),
        onPressed: () async {
          final updated = await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const PuppyDetailsScreen()),
          );
          if (updated != null) {
            ref.invalidate(puppiesListProvider(widget.damId));
          }
        },
      ),
    );
  }
}

class _PuppyListCard extends StatelessWidget {
  final Puppy puppy;
  final VoidCallback onEdit;
  final VoidCallback onCertificate;

  const _PuppyListCard({
    required this.puppy,
    required this.onEdit,
    required this.onCertificate,
  });

  String _formatDate(DateTime? dt) {
    if (dt == null) return 'N/A';
    return '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year}';
  }

  @override
  Widget build(BuildContext context) {
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
                        overflow: TextOverflow.ellipsis,
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
                  onPressed: onEdit,
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: const Text('Edit Details'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: onCertificate,
                  icon: const Icon(Icons.card_membership, size: 16),
                  label: const Text('Certificate'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryGold,
                    foregroundColor: AppColors.background,
                    padding: const EdgeInsets.symmetric(vertical: 10),
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
