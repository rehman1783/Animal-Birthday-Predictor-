import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/widgets/gradient_cta_button.dart';
import '../../../animals/domain/animal.dart';
import '../../../animals/presentation/providers/animal_provider.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../foal/domain/foal_record.dart';
import '../../../pregnancy/presentation/providers/preventative_care_provider.dart';

class CertificateScreen extends ConsumerWidget {
  final FoalRecord foal;
  final Animal? dam;

  const CertificateScreen({
    super.key,
    required this.foal,
    this.dam,
  });

  String _formatDate(DateTime? dt) {
    if (dt == null) return 'N/A';
    return '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year}';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authControllerProvider);
    final user = authState.value;
    final damMareAsync = dam != null
        ? AsyncValue.data(dam)
        : ref.watch(animalByIdProvider(foal.mareAnimalId));
    final prevCareAsync = ref.watch(
      preventativeCareForOwnerProvider((ownerType: 'foal', ownerId: foal.id)),
    );

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.textPrimary, size: 20),
          onPressed: () => Navigator.maybePop(context),
        ),
        title: const Text('FOAL CERTIFICATE', style: AppTypography.sectionLabel),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.share_outlined, color: AppColors.primaryGold),
            tooltip: 'Share Certificate',
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Certificate ready for export / print / PDF generation.')),
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.horizontalPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Certificate Document Container
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
                  border: Border.all(color: AppColors.primaryGold, width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primaryGold.withValues(alpha: 0.15),
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Certificate Header
                    Center(
                      child: Column(
                        children: [
                          Container(
                            width: 60,
                            height: 60,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: AppColors.goldGradient,
                            ),
                            child: const Icon(Icons.verified_rounded, size: 36, color: AppColors.background),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'OFFICIAL FOAL CERTIFICATE',
                            style: AppTypography.displayHeadline.copyWith(
                              fontSize: 20,
                              color: AppColors.primaryGold,
                              letterSpacing: 1.5,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Pedigree, Identification & Preventative Health Record',
                            style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                    const Divider(color: AppColors.primaryGold, height: 32, thickness: 1),

                    // Section 1: Identity
                    const Text('I. IDENTIFICATION', style: AppTypography.sectionLabel),
                    const SizedBox(height: 12),
                    _CertRow(label: 'Registered Name', value: foal.foalName?.isNotEmpty == true ? foal.foalName! : 'Unregistered Foal'),
                    _CertRow(label: 'Breed', value: foal.breed?.isNotEmpty == true ? foal.breed! : 'Equine'),
                    _CertRow(label: 'Sex', value: foal.sex == 'colt' ? 'Colt (Male)' : 'Filly (Female)'),
                    _CertRow(label: 'Date of Birth', value: _formatDate(foal.dateOfBirth)),
                    _CertRow(label: 'Microchip Number', value: foal.foalMicrochipNo?.isNotEmpty == true ? foal.foalMicrochipNo! : 'Not Microchipped'),
                    _CertRow(label: 'DNA Profile', value: foal.dna?.isNotEmpty == true ? foal.dna! : 'On File / Pending'),
                    _CertRow(label: 'Stud Book Association', value: foal.studBookAssociation?.isNotEmpty == true ? foal.studBookAssociation! : 'Recorded Breeder'),
                    const SizedBox(height: 20),

                    // Section 2: Parentage & Lineage
                    const Text('II. PARENTAGE & LINEAGE', style: AppTypography.sectionLabel),
                    const SizedBox(height: 12),
                    _CertRow(label: 'Sire (Father)', value: foal.stallion?.isNotEmpty == true ? foal.stallion! : 'Recorded Stallion'),
                    damMareAsync.when(
                      data: (damMare) => _CertRow(
                        label: 'Dam (Mother)',
                        value: damMare != null ? '${damMare.name} (Chip: ${damMare.microchipNo ?? "N/A"})' : 'Registered Mare',
                      ),
                      loading: () => const _CertRow(label: 'Dam (Mother)', value: 'Loading...'),
                      error: (err, stack) => const _CertRow(label: 'Dam (Mother)', value: 'Recorded Mare'),
                    ),
                    const SizedBox(height: 20),

                    // Section 3: Health & Preventative Care
                    const Text('III. HEALTH & PREVENTATIVE CARE SUMMARY', style: AppTypography.sectionLabel),
                    const SizedBox(height: 12),
                    prevCareAsync.when(
                      data: (care) {
                        return Column(
                          children: [
                            _CertRow(label: 'Tetanus Toxoid', value: care?.tetanusDone == true ? 'Given ${_formatDate(care?.tetanusDate)}' : 'Pending Primary'),
                            _CertRow(label: 'Deworming Status', value: care?.wormerDone == true ? 'Completed ${_formatDate(care?.wormerDate)}' : 'Scheduled'),
                            _CertRow(label: 'Strangles Vaccination', value: care?.stranglesDone == true ? 'Given ${_formatDate(care?.stranglesDate)}' : 'Not Recorded'),
                            _CertRow(label: 'Veterinary Dental Check', value: care?.dentalDone == true ? 'Inspected ${_formatDate(care?.dentalDate)}' : 'Scheduled at Weaning'),
                            _CertRow(label: 'Farrier / Hoof Care', value: care?.farrierDone == true ? 'Trimmed ${_formatDate(care?.farrierDate)}' : 'Scheduled Routine'),
                          ],
                        );
                      },
                      loading: () => const _CertRow(label: 'Health Records', value: 'Loading records...'),
                      error: (err, stack) => const _CertRow(label: 'Health Records', value: 'Refer to Veterinary Log'),
                    ),
                    const SizedBox(height: 20),

                    // Section 4: Breeder Details
                    const Text('IV. BREEDER & OWNER ATTESTATION', style: AppTypography.sectionLabel),
                    const SizedBox(height: 12),
                    _CertRow(label: 'Breeder / Stud Name', value: user?.fullName.isNotEmpty == true ? user!.fullName : 'Certified Equine Breeder'),
                    _CertRow(label: 'Contact Email', value: user?.email.isNotEmpty == true ? user!.email : 'breeder@abp.app'),
                    _CertRow(label: 'Certificate Issued', value: _formatDate(DateTime.now())),
                    const Divider(color: AppColors.surface, height: 32),

                    // Fixed Footer Disclaimer (Section 6.14 requirement)
                    Text(
                      'This certificate is a summary of information recorded by the breeder/owner. It is not a substitute for veterinary records, veterinary examination or professional veterinary advice.',
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.textMuted,
                        fontStyle: FontStyle.italic,
                        fontSize: 11,
                        height: 1.4,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Actions
              GradientCtaButton(
                text: 'EXPORT / PRINT CERTIFICATE',
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Opening print & document export dialog...')),
                  );
                },
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

class _CertRow extends StatelessWidget {
  final String label;
  final String value;

  const _CertRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(
              label,
              style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
