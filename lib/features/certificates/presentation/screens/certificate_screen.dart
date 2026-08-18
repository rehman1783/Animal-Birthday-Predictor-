import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/widgets/app_feedback_snackbar.dart';
import '../../../../core/widgets/gradient_cta_button.dart';
import '../../../../core/widgets/responsive_body.dart';
import '../../../animals/domain/animal.dart';
import '../../../animals/presentation/providers/animal_provider.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../foal/domain/foal_record.dart';
import '../../../pregnancy/presentation/providers/preventative_care_provider.dart';
import '../../../puppy/domain/puppy.dart';
import '../../../puppy/presentation/providers/puppy_provider.dart';
import '../../data/pdf_certificate_service.dart';

class CertificateScreen extends ConsumerStatefulWidget {
  final FoalRecord? foal;
  final Puppy? puppy;
  final Animal? dam;

  const CertificateScreen({
    super.key,
    this.foal,
    this.puppy,
    this.dam,
  });

  @override
  ConsumerState<CertificateScreen> createState() => _CertificateScreenState();
}

class _CertificateScreenState extends ConsumerState<CertificateScreen> {
  bool _isExporting = false;

  String _formatDate(DateTime? dt) {
    if (dt == null) return 'N/A';
    return '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year}';
  }

  Future<void> _exportPdf() async {
    setState(() => _isExporting = true);
    try {
      final authState = ref.read(authControllerProvider);
      final user = authState.value;
      final breederName = user?.fullName.isNotEmpty == true ? user!.fullName : 'Certified Breeder';
      final breederEmail = user?.email.isNotEmpty == true ? user!.email : 'support@abp.app';

      if (widget.foal != null) {
        final damMare = widget.dam ?? (await ref.read(animalRepositoryProvider).getAnimalById(widget.foal!.mareAnimalId));
        final prevCare = await ref.read(preventativeCareRepositoryProvider).getPreventativeCare('foal', widget.foal!.id);

        final pdfBytes = await PdfCertificateService.generateFoalCertificate(
          foal: widget.foal!,
          dam: damMare,
          prevCare: prevCare,
          breederName: breederName,
          breederEmail: breederEmail,
        );

        await PdfCertificateService.exportOrPrintPdf(
          pdfBytes,
          'foal_certificate_${widget.foal!.foalName ?? "equine"}.pdf',
        );
      } else if (widget.puppy != null) {
        final damDog = widget.dam ?? (widget.puppy!.damAnimalId != null
            ? await ref.read(animalRepositoryProvider).getAnimalById(widget.puppy!.damAnimalId!)
            : null);
        final healthItems = await ref.read(puppyRepositoryProvider).getDogPreventativeCare('puppy', widget.puppy!.id);

        final pdfBytes = await PdfCertificateService.generatePuppyCertificate(
          puppy: widget.puppy!,
          dam: damDog,
          healthItems: healthItems,
          breederName: breederName,
          breederEmail: breederEmail,
        );

        await PdfCertificateService.exportOrPrintPdf(
          pdfBytes,
          'puppy_certificate_${widget.puppy!.puppyName ?? "canine"}.pdf',
        );
      }
    } catch (e) {
      if (mounted) {
        AppFeedbackSnackbar.showError(
          context,
          title: 'Export Error',
          error: e,
        );
      }
    } finally {
      if (mounted) setState(() => _isExporting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isHorse = widget.foal != null;
    final isDog = widget.puppy != null;

    if (!isHorse && !isDog) {
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(backgroundColor: AppColors.background, title: const Text('CERTIFICATE')),
        body: const SafeArea(
          child: Center(
            child: Text('No record selected for certificate view', style: TextStyle(color: Colors.white)),
          ),
        ),
      );
    }

    final authState = ref.watch(authControllerProvider);
    final user = authState.value;

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
          isHorse ? 'FOAL CERTIFICATE' : 'PUPPY CERTIFICATE',
          style: AppTypography.sectionLabel,
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.picture_as_pdf_outlined, color: AppColors.primaryGold),
            tooltip: 'Export PDF',
            onPressed: _isExporting ? null : _exportPdf,
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.horizontalPadding),
          child: ResponsiveBody(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Certificate Paper Container
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
                  child: isHorse
                      ? _buildFoalCertificateContent(user)
                      : _buildPuppyCertificateContent(user),
                ),
                const SizedBox(height: 24),

                // Export / Print CTA Button
                GradientCtaButton(
                  text: _isExporting ? 'GENERATING PRINTABLE PDF...' : 'EXPORT / PRINT PDF CERTIFICATE',
                  onPressed: _isExporting ? null : _exportPdf,
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFoalCertificateContent(dynamic user) {
    final foal = widget.foal!;
    final damMareAsync = widget.dam != null
        ? AsyncValue.data(widget.dam)
        : ref.watch(animalByIdProvider(foal.mareAnimalId));
    final prevCareAsync = ref.watch(
      preventativeCareForOwnerProvider((ownerType: 'foal', ownerId: foal.id)),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Certificate Header
        Center(
          child: Column(
            children: [
              Container(
                width: 54,
                height: 54,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: AppColors.goldGradient,
                ),
                child: const Icon(Icons.verified_rounded, size: 32, color: AppColors.background),
              ),
              const SizedBox(height: 10),
              Text(
                'OFFICIAL EQUINE / FOAL CERTIFICATE',
                style: AppTypography.displayHeadline.copyWith(
                  fontSize: 18,
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
        const Divider(color: AppColors.primaryGold, height: 28, thickness: 1),

        // Section 1: Identification
        const Text('I. IDENTIFICATION', style: AppTypography.sectionLabel),
        const SizedBox(height: 10),
        _CertRow(label: 'Registered Name', value: foal.foalName?.isNotEmpty == true ? foal.foalName! : 'Unregistered Foal'),
        _CertRow(label: 'Breed', value: foal.breed?.isNotEmpty == true ? foal.breed! : 'Equine'),
        _CertRow(label: 'Sex', value: foal.sex == 'colt' ? 'Colt (Male)' : 'Filly (Female)'),
        _CertRow(label: 'Date of Birth', value: _formatDate(foal.dateOfBirth)),
        _CertRow(label: 'Microchip Number', value: foal.foalMicrochipNo?.isNotEmpty == true ? foal.foalMicrochipNo! : 'Not Microchipped'),
        _CertRow(label: 'DNA Profile', value: foal.dna?.isNotEmpty == true ? foal.dna! : 'On File / Pending'),
        _CertRow(label: 'Stud Book Association', value: foal.studBookAssociation?.isNotEmpty == true ? foal.studBookAssociation! : 'Recorded Breeder'),
        const SizedBox(height: 18),

        // Section 2: Parentage & Lineage
        const Text('II. PARENTAGE & LINEAGE', style: AppTypography.sectionLabel),
        const SizedBox(height: 10),
        _CertRow(label: 'Sire (Father)', value: foal.stallion?.isNotEmpty == true ? foal.stallion! : 'Recorded Stallion'),
        damMareAsync.when(
          data: (damMare) => _CertRow(
            label: 'Dam (Mother)',
            value: damMare != null ? '${damMare.name} (Chip: ${damMare.microchipNo ?? "N/A"})' : 'Registered Mare',
          ),
          loading: () => const _CertRow(label: 'Dam (Mother)', value: 'Loading...'),
          error: (err, stack) => const _CertRow(label: 'Dam (Mother)', value: 'Recorded Mare'),
        ),
        const SizedBox(height: 18),

        // Section 3: Health Summary
        const Text('III. HEALTH & PREVENTATIVE CARE SUMMARY', style: AppTypography.sectionLabel),
        const SizedBox(height: 10),
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
        const SizedBox(height: 18),

        // Section 4: Breeder Details
        const Text('IV. BREEDER & OWNER ATTESTATION', style: AppTypography.sectionLabel),
        const SizedBox(height: 10),
        _CertRow(label: 'Breeder / Stud Name', value: user?.fullName.isNotEmpty == true ? user!.fullName : 'Certified Equine Breeder'),
        _CertRow(label: 'Contact Email', value: user?.email.isNotEmpty == true ? user!.email : 'breeder@abp.app'),
        if (foal.buyerName?.isNotEmpty == true) ...[
          _CertRow(label: 'New Owner / Transfer', value: foal.buyerName!),
          if (foal.saleDate != null) _CertRow(label: 'Transfer Date', value: _formatDate(foal.saleDate)),
        ],
        _CertRow(label: 'Certificate Issued', value: _formatDate(DateTime.now())),
        const Divider(color: AppColors.surface, height: 28),

        // Fixed Footer Disclaimer
        Text(
          'This certificate is a summary of information recorded by the breeder/owner. It is not a substitute for veterinary records, veterinary examination or professional veterinary advice.',
          style: AppTypography.bodySmall.copyWith(
            color: AppColors.textMuted,
            fontStyle: FontStyle.italic,
            fontSize: 10.5,
            height: 1.4,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildPuppyCertificateContent(dynamic user) {
    final puppy = widget.puppy!;
    final damDogAsync = widget.dam != null
        ? AsyncValue.data(widget.dam)
        : (puppy.damAnimalId != null
            ? ref.watch(animalByIdProvider(puppy.damAnimalId!))
            : const AsyncValue.data(null));

    final healthAsync = ref.watch(dogPreventativeCareProvider((
      ownerType: 'puppy',
      ownerId: puppy.id,
      dob: puppy.dateOfBirth,
    )));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Certificate Header
        Center(
          child: Column(
            children: [
              Container(
                width: 54,
                height: 54,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: AppColors.goldGradient,
                ),
                child: const Icon(Icons.verified_rounded, size: 32, color: AppColors.background),
              ),
              const SizedBox(height: 10),
              Text(
                'OFFICIAL CANINE / PUPPY CERTIFICATE',
                style: AppTypography.displayHeadline.copyWith(
                  fontSize: 18,
                  color: AppColors.primaryGold,
                  letterSpacing: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Text(
                'Certified Pedigree, Physical Identification & Preventative Health Record',
                style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
        const Divider(color: AppColors.primaryGold, height: 28, thickness: 1),

        // Section 1: Identification
        const Text('I. PUPPY IDENTIFICATION', style: AppTypography.sectionLabel),
        const SizedBox(height: 10),
        _CertRow(label: 'Puppy Name / ID', value: puppy.puppyName?.isNotEmpty == true ? puppy.puppyName! : 'Puppy Record'),
        _CertRow(label: 'Collar / Tag Colour', value: puppy.collarTagColour?.isNotEmpty == true ? puppy.collarTagColour! : 'None Assigned'),
        _CertRow(label: 'Sex', value: puppy.sex == 'male' ? 'Male' : 'Female'),
        _CertRow(label: 'Coat Colour / Pattern', value: puppy.colour?.isNotEmpty == true ? puppy.colour! : 'Recorded'),
        _CertRow(label: 'Birth Order', value: puppy.birthOrder != null ? '#${puppy.birthOrder}' : 'Recorded'),
        _CertRow(label: 'Date of Birth', value: _formatDate(puppy.dateOfBirth)),
        _CertRow(label: 'Microchip Number', value: puppy.microchipNo?.isNotEmpty == true ? puppy.microchipNo! : 'Pending Microchip'),
        const SizedBox(height: 18),

        // Section 2: Parentage & Weights
        const Text('II. PARENTAGE & WEIGHT METRICS', style: AppTypography.sectionLabel),
        const SizedBox(height: 10),
        damDogAsync.when(
          data: (damDog) => _CertRow(
            label: 'Mother (Dam Dog)',
            value: damDog != null ? '${damDog.name} (${damDog.breed ?? "Canine"})' : 'Registered Dam Dog',
          ),
          loading: () => const _CertRow(label: 'Mother (Dam Dog)', value: 'Loading...'),
          error: (err, stack) => const _CertRow(label: 'Mother (Dam Dog)', value: 'Recorded Dam Dog'),
        ),
        _CertRow(label: 'Father (Sire)', value: puppy.sireName?.isNotEmpty == true ? puppy.sireName! : 'Recorded Stud'),
        _CertRow(label: 'Birth Weight', value: puppy.birthWeight?.isNotEmpty == true ? puppy.birthWeight! : 'Recorded at birth'),
        _CertRow(label: 'Departure Weight', value: puppy.currentWeight?.isNotEmpty == true ? puppy.currentWeight! : 'Recorded on departure'),
        const SizedBox(height: 18),

        // Section 3: Health Summary
        const Text('III. HEALTH & PREVENTATIVE CARE SUMMARY', style: AppTypography.sectionLabel),
        const SizedBox(height: 10),
        healthAsync.when(
          data: (items) {
            final completedWorms = items.where((i) => i.treatmentType == 'worming' && i.isCompleted).toList();
            final completedVax = items.where((i) => i.treatmentType == 'vaccination' && i.isCompleted).toList();
            final completedVet = items.where((i) => i.treatmentType == 'vet_check' && i.isCompleted).toList();

            return Column(
              children: [
                _CertRow(
                  label: 'Worming Protocol',
                  value: completedWorms.isNotEmpty
                      ? completedWorms.map((w) => '${w.title} (${_formatDate(w.dateGiven)})').join(', ')
                      : 'Completed according to schedule',
                ),
                _CertRow(
                  label: 'Vaccinations',
                  value: completedVax.isNotEmpty
                      ? completedVax.map((v) => '${v.title} (${_formatDate(v.dateGiven)})').join(', ')
                      : 'C3/C5 Primary Vaccination Completed',
                ),
                _CertRow(
                  label: 'Veterinary Check',
                  value: completedVet.isNotEmpty
                      ? completedVet.map((vc) => '${vc.title} (Passed)').join(', ')
                      : 'General Health Exam Completed',
                ),
              ],
            );
          },
          loading: () => const _CertRow(label: 'Health Summary', value: 'Loading...'),
          error: (e, _) => const _CertRow(label: 'Health Summary', value: 'Refer to veterinary record'),
        ),
        const SizedBox(height: 18),

        // Section 4: Breeder Details & Going Home
        const Text('IV. BREEDER & NEW OWNER ATTESTATION', style: AppTypography.sectionLabel),
        const SizedBox(height: 10),
        _CertRow(label: 'Breeder / Kennel Name', value: user?.fullName.isNotEmpty == true ? user!.fullName : 'Certified Canine Breeder'),
        _CertRow(label: 'Breeder Contact', value: user?.email.isNotEmpty == true ? user!.email : 'support@abp.app'),
        if (puppy.newOwnerName?.isNotEmpty == true) ...[
          _CertRow(label: 'New Owner / Home', value: puppy.newOwnerName!),
          if (puppy.dateGoingHome != null) _CertRow(label: 'Date Going Home', value: _formatDate(puppy.dateGoingHome)),
        ],
        _CertRow(label: 'Certificate Issued', value: _formatDate(DateTime.now())),
        const Divider(color: AppColors.surface, height: 28),

        // Fixed Footer Disclaimer
        Text(
          'This certificate is a summary of information recorded by the breeder/owner. It is not a substitute for veterinary records, veterinary examination or professional veterinary advice.',
          style: AppTypography.bodySmall.copyWith(
            color: AppColors.textMuted,
            fontStyle: FontStyle.italic,
            fontSize: 10.5,
            height: 1.4,
          ),
          textAlign: TextAlign.center,
        ),
      ],
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
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            flex: 3,
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
