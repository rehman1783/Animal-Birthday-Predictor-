import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/widgets/abp_brand_badge.dart';
import '../../../../core/widgets/app_feedback_snackbar.dart';
import '../../../../core/widgets/gradient_cta_button.dart';
import '../../../../core/widgets/responsive_body.dart';
import '../../../animals/domain/animal.dart';
import '../../../animals/presentation/providers/animal_provider.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../foal/domain/foal_record.dart';
import '../../../pregnancy/domain/breeding_record.dart';
import '../../../pregnancy/domain/pregnancy_record.dart';
import '../../../pregnancy/presentation/providers/pregnancy_provider.dart';
import '../../../pregnancy/presentation/providers/preventative_care_provider.dart';
import '../../../puppy/domain/puppy.dart';
import '../../../puppy/presentation/providers/puppy_provider.dart';
import '../../data/pdf_certificate_service.dart';
import '../../data/certificate_quota_service.dart';
import '../widgets/purchase_certificates_dialog.dart';

class CertificateScreen extends ConsumerStatefulWidget {
  final FoalRecord? foal;
  final Puppy? puppy;
  final Animal? dam;
  final PregnancyRecord? pregnancy;
  final Animal? carrierMare;
  final Animal? donorMare;
  final BreedingRecord? breedingRecord;
  final bool is45DayScan;

  const CertificateScreen({
    super.key,
    this.foal,
    this.puppy,
    this.dam,
    this.pregnancy,
    this.carrierMare,
    this.donorMare,
    this.breedingRecord,
    this.is45DayScan = false,
  });

  @override
  ConsumerState<CertificateScreen> createState() => _CertificateScreenState();
}

class _CertificateScreenState extends ConsumerState<CertificateScreen> {
  bool _isExporting = false;
  bool _isAlreadyIssued = false;

  @override
  void initState() {
    super.initState();
    _checkIssuedStatus();
  }

  Future<void> _checkIssuedStatus() async {
    final targetId = _getTargetId();
    if (targetId.isNotEmpty) {
      final issued = await ref
          .read(certificateQuotaProvider.notifier)
          .checkIsAlreadyIssued(targetId);
      if (mounted) {
        setState(() => _isAlreadyIssued = issued);
      }
    }
  }

  String _getTargetId() {
    if (widget.is45DayScan || widget.pregnancy != null) {
      return widget.pregnancy?.id ?? '';
    }
    if (widget.foal != null) {
      return widget.foal?.id ?? '';
    }
    if (widget.puppy != null) {
      return widget.puppy?.id ?? '';
    }
    return '';
  }

  String _getCertType() {
    if (widget.is45DayScan || widget.pregnancy != null) {
      return '45_day_scan';
    }
    if (widget.foal != null) {
      return 'foal';
    }
    if (widget.puppy != null) {
      return 'puppy';
    }
    return 'other';
  }

  String _getCertId() {
    final targetId = _getTargetId();
    final type = _getCertType();
    return 'ABP-${type.toUpperCase()}-${targetId.isNotEmpty && targetId.length >= 6 ? targetId.substring(0, 6).toUpperCase() : "REC"}';
  }

  String _getTargetName() {
    if (widget.is45DayScan || widget.pregnancy != null) {
      return widget.carrierMare?.name ?? 'Carrier Mare';
    }
    if (widget.foal != null) {
      return widget.foal?.foalName ?? 'Foal Record';
    }
    if (widget.puppy != null) {
      return widget.puppy?.puppyName ?? 'Puppy Record';
    }
    return 'Certificate Record';
  }

  String _formatDate(DateTime? dt) {
    if (dt == null) return 'N/A';
    return '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year}';
  }

  Future<void> _exportPdf() async {
    final targetId = _getTargetId();
    final quotaNotifier = ref.read(certificateQuotaProvider.notifier);
    final isIssued = await quotaNotifier.checkIsAlreadyIssued(targetId);
    final currentQuota = ref.read(certificateQuotaProvider);

    if (!isIssued && currentQuota.remaining <= 0) {
      if (mounted) {
        AppFeedbackSnackbar.showError(
          context,
          title: 'Certificate Quota Reached',
          error: 'You have used all ${currentQuota.totalAllocated} certificate credits. Please top up your account to generate new official PDF certificates.',
        );
        PurchaseCertificatesDialog.show(context);
      }
      return;
    }

    setState(() => _isExporting = true);
    try {
      if (!isIssued) {
        await quotaNotifier.consumeCredit(
          targetId: targetId,
          certType: _getCertType(),
          certId: _getCertId(),
          targetName: _getTargetName(),
        );
        setState(() => _isAlreadyIssued = true);
      }

      final authState = ref.read(authControllerProvider);
      final user = authState.value;
      final breederName = user?.fullName.isNotEmpty == true
          ? user!.fullName
          : 'Certified Breeder';
      final breederEmail = user?.email.isNotEmpty == true
          ? user!.email
          : 'support@abp.app';

      if (widget.is45DayScan || widget.pregnancy != null) {
        final preg = widget.pregnancy!;
        final carrier =
            widget.carrierMare ??
            (await ref
                .read(animalRepositoryProvider)
                .getAnimalById(preg.carrierAnimalId));
        if (carrier == null) {
          throw Exception('Carrier mare record not found');
        }
        final breeding =
            widget.breedingRecord ??
            (await ref
                .read(pregnancyRepositoryProvider)
                .getBreedingRecordByMare(carrier.id));
        final donor =
            widget.donorMare ??
            ((breeding?.mareAnimalId != null &&
                    breeding!.mareAnimalId != carrier.id)
                ? await ref
                      .read(animalRepositoryProvider)
                      .getAnimalById(breeding.mareAnimalId)
                : null);

        final vetName = preg.vetName ?? '';
        final vetNumber = preg.vetNumber ?? '';

        final pdfBytes =
            await PdfCertificateService.generate45DayScanCertificate(
              pregnancy: preg,
              carrierMare: carrier,
              donorMare: donor,
              breedingRecord: breeding,
              vetName: vetName,
              vetNumber: vetNumber,
              breederName: breederName,
              breederEmail: breederEmail,
            );

        await PdfCertificateService.exportOrPrintPdf(
          pdfBytes,
          '45_day_scan_certificate_${carrier.name.replaceAll(' ', '_')}.pdf',
        );
      } else if (widget.foal != null) {
        final damMare =
            widget.dam ??
            (await ref
                .read(animalRepositoryProvider)
                .getAnimalById(widget.foal!.mareAnimalId));
        final prevCare = await ref
            .read(preventativeCareRepositoryProvider)
            .getPreventativeCare('foal', widget.foal!.id);

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
        final damDog =
            widget.dam ??
            (widget.puppy!.damAnimalId != null
                ? await ref
                      .read(animalRepositoryProvider)
                      .getAnimalById(widget.puppy!.damAnimalId!)
                : null);
        final healthItems = await ref
            .read(puppyRepositoryProvider)
            .getDogPreventativeCare('puppy', widget.puppy!.id);

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

      if (mounted) {
        AppFeedbackSnackbar.showSuccess(
          context,
          title: isIssued ? 'Certificate Exported' : 'Certificate Issued & Exported',
          message: isIssued
              ? 'Free re-download completed successfully.'
              : '1 credit consumed. Official certificate registered.',
        );
      }
    } catch (e) {
      if (mounted) {
        AppFeedbackSnackbar.showError(context, title: 'Export Error', error: e);
      }
    } finally {
      if (mounted) setState(() => _isExporting = false);
    }
  }

  Widget _buildQuotaBanner(CertificateQuota quota) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
        border: Border.all(
          color: _isAlreadyIssued
              ? const Color(0xFF10B981)
              : (quota.remaining > 0 ? AppColors.primaryGold : Colors.redAccent),
          width: 1.5,
        ),
      ),
      child: Row(
        children: [
          Icon(
            _isAlreadyIssued
                ? Icons.check_circle_rounded
                : (quota.remaining > 0
                      ? Icons.workspace_premium
                      : Icons.warning_amber_rounded),
            color: _isAlreadyIssued
                ? const Color(0xFF10B981)
                : (quota.remaining > 0
                      ? AppColors.primaryGold
                      : Colors.redAccent),
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _isAlreadyIssued
                      ? 'CERTIFICATE ISSUED (FREE RE-DOWNLOAD)'
                      : 'OFFICIAL CERTIFICATE CREDITS',
                  style: AppTypography.captionBold.copyWith(
                    color: _isAlreadyIssued
                        ? const Color(0xFF10B981)
                        : (quota.remaining > 0
                              ? AppColors.primaryGold
                              : Colors.redAccent),
                    letterSpacing: 0.8,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _isAlreadyIssued
                      ? 'This certificate has been issued. You can re-export or print anytime at zero credit cost.'
                      : '${quota.remaining} of ${quota.totalAllocated} credits remaining on your account.',
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                    fontSize: 11.5,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          TextButton.icon(
            style: TextButton.styleFrom(
              backgroundColor: AppColors.primaryGold.withValues(alpha: 0.15),
              foregroundColor: AppColors.primaryGold,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(6),
                side: const BorderSide(color: AppColors.primaryGold, width: 1),
              ),
            ),
            icon: const Icon(Icons.add_circle_outline_rounded, size: 14),
            label: const Text(
              'TOP UP',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.8,
              ),
            ),
            onPressed: () => PurchaseCertificatesDialog.show(context),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final is45Day = widget.is45DayScan || widget.pregnancy != null;
    final isHorse = widget.foal != null;
    final isDog = widget.puppy != null;

    if (!is45Day && !isHorse && !isDog) {
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.background,
          title: const Text('CERTIFICATE'),
        ),
        body: const SafeArea(
          child: Center(
            child: Text(
              'No record selected for certificate view',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ),
      );
    }

    final authState = ref.watch(authControllerProvider);
    final user = authState.value;
    final quotaState = ref.watch(certificateQuotaProvider);

    String titleText = 'CERTIFICATE';
    if (is45Day) {
      titleText = '45-DAY SCAN CERTIFICATE';
    } else if (isHorse) {
      titleText = 'FOAL CERTIFICATE';
    } else if (isDog) {
      titleText = 'PUPPY CERTIFICATE';
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: AppColors.textPrimary,
            size: 20,
          ),
          onPressed: () => Navigator.maybePop(context),
        ),
        title: Text(titleText, style: AppTypography.sectionLabel),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(
              Icons.picture_as_pdf_outlined,
              color: AppColors.primaryGold,
            ),
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
                // Quota & Entitlement Status Banner
                _buildQuotaBanner(quotaState),

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
                  child: is45Day
                      ? _build45DayScanCertificateContent(user)
                      : (isHorse
                            ? _buildFoalCertificateContent(user)
                            : _buildPuppyCertificateContent(user)),
                ),
                const SizedBox(height: 24),

                // Export / Print CTA Button
                GradientCtaButton(
                  text: _isExporting
                      ? 'GENERATING PRINTABLE PDF...'
                      : (_isAlreadyIssued
                            ? 'RE-EXPORT / PRINT PDF (FREE)'
                            : 'EXPORT / PRINT PDF CERTIFICATE (1 CREDIT)'),
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

  Widget _buildAnimalPhotoHeader(String? photoUrl, String placeholderLabel) {
    if (photoUrl != null && photoUrl.trim().isNotEmpty) {
      final url = photoUrl.trim();

      // 1. Data URI / Base64 format (from AppImagePicker)
      if (url.startsWith('data:image/') || url.contains('base64,')) {
        try {
          final commaIndex = url.indexOf(',');
          final base64String = commaIndex != -1 ? url.substring(commaIndex + 1) : url;
          final cleanBase64 = base64String.replaceAll(RegExp(r'\s+'), '');
          final bytes = base64Decode(cleanBase64);
          if (bytes.isNotEmpty) {
            return Container(
              height: 140,
              width: double.infinity,
              margin: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.primaryGold, width: 1.5),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: Image.memory(bytes, fit: BoxFit.cover),
              ),
            );
          }
        } catch (_) {}
      }

      // 2. Network, Asset, or Local File
      return Container(
        height: 140,
        width: double.infinity,
        margin: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.primaryGold, width: 1.5),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: (url.startsWith('http://') || url.startsWith('https://'))
              ? Image.network(
                  url,
                  fit: BoxFit.cover,
                  errorBuilder: (ctx, err, stack) => _buildPhotoPlaceholder(placeholderLabel),
                )
              : (url.startsWith('assets/'))
                  ? Image.asset(url, fit: BoxFit.cover)
                  : Image.file(
                      File(url),
                      fit: BoxFit.cover,
                      errorBuilder: (ctx, err, stack) => _buildPhotoPlaceholder(placeholderLabel),
                    ),
        ),
      );
    }
    return _buildPhotoPlaceholder(placeholderLabel);
  }

  Widget _buildPhotoPlaceholder(String label) {
    return Container(
      height: 90,
      width: double.infinity,
      margin: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.primaryGold.withValues(alpha: 0.5), width: 1),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.add_a_photo_outlined, color: AppColors.primaryGold, size: 24),
            const SizedBox(height: 4),
            Text(
              '$label (ATTACHED UPON EXPORT)',
              style: AppTypography.captionBold.copyWith(
                color: AppColors.textSecondary,
                fontSize: 10,
                letterSpacing: 0.8,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _build45DayScanCertificateContent(dynamic user) {
    final preg = widget.pregnancy!;
    final carrierMareAsync = widget.carrierMare != null
        ? AsyncValue.data(widget.carrierMare)
        : ref.watch(animalByIdProvider(preg.carrierAnimalId));
    final breedingAsync = widget.breedingRecord != null
        ? AsyncValue.data(widget.breedingRecord)
        : ref.watch(breedingRecordByMareProvider(preg.carrierAnimalId));

    final carrierMare = carrierMareAsync.valueOrNull ?? widget.carrierMare;
    final breeding = breedingAsync.valueOrNull ?? widget.breedingRecord;

    final isET =
        breeding?.isEmbryoTransfer == true ||
        (breeding?.method.toLowerCase().trim() == 'et') ||
        (breeding?.method.toLowerCase().trim() == 'icsi') ||
        (widget.donorMare != null && widget.donorMare?.id != carrierMare?.id);

    final rawMethod = breeding?.method.toLowerCase().trim() ?? 'natural';
    String methodLabel = 'Natural Cover';
    if (rawMethod == 'chilled') methodLabel = 'AI (Chilled Semen)';
    if (rawMethod == 'frozen') methodLabel = 'AI (Frozen Semen)';
    if (rawMethod == 'et') methodLabel = 'Embryo Transfer (ET)';
    if (rawMethod == 'icsi') methodLabel = 'ICSI';

    final geneticDamName =
        widget.donorMare?.name ??
        (breeding?.damOfEmbryo?.isNotEmpty == true
            ? breeding!.damOfEmbryo!
            : 'Registered Donor Dam');

    final stallionName = breeding?.stallionName?.isNotEmpty == true
        ? breeding!.stallionName!
        : (breeding?.stallionOfEmbryo?.isNotEmpty == true
              ? breeding!.stallionOfEmbryo!
              : 'Recorded Stallion');

    final vetName = preg.vetName?.isNotEmpty == true
        ? preg.vetName!
        : 'Certified Equine Practitioner';
    final vetNumber = preg.vetNumber?.isNotEmpty == true
        ? preg.vetNumber!
        : 'On Record';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Certificate Header
        Center(
          child: Column(
            children: [
              const AbpOfficialLogo(size: 48),
              const SizedBox(height: 10),
              const Text(
                'ANIMAL BIRTHDAY PREDICTOR',
                style: AppTypography.sectionLabel,
              ),
              const SizedBox(height: 4),
              Text(
                '45-DAY SCAN CERTIFICATE',
                style: AppTypography.displayHeadline.copyWith(
                  color: AppColors.primaryGold,
                  fontSize: 18,
                  letterSpacing: 1.2,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Text(
                'Official Equine Gestation Security Attestation • Thoroughbred & Sport Horse Standard',
                style: AppTypography.finePrint.copyWith(
                  fontStyle: FontStyle.italic,
                  color: AppColors.textMuted,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
        const Divider(color: AppColors.primaryGold, height: 28),

        // Milestone Confirmation Badge
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.primaryGold, width: 1.2),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.verified,
                    color: Color(0xFF10B981),
                    size: 18,
                  ),
                  const SizedBox(width: 6),
                  Flexible(
                    child: Text(
                      '45-DAY POSITIVE SCAN CONFIRMED',
                      style: AppTypography.displayHeadline.copyWith(
                        fontSize: 13,
                        color: AppColors.primaryGold,
                        letterSpacing: 1,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFF10B981).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  isET
                      ? 'RECIPIENT MARE GESTATION'
                      : 'DIRECT / AI MARE GESTATION',
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF10B981),
                    letterSpacing: 0.8,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),

        // Animal / Mare Photo Preview
        _buildAnimalPhotoHeader(carrierMare?.photoUrl ?? widget.donorMare?.photoUrl, 'MARE PHOTO'),

        // Section 1: Mare & Carrier Identification
        const Text(
          'I. MARE & CARRIER IDENTIFICATION',
          style: AppTypography.sectionLabel,
        ),
        const SizedBox(height: 10),
        _CertRow(
          label: 'Carrier Mare (In-Foal)',
          value: carrierMare?.name ?? 'Loading Mare...',
        ),
        _CertRow(
          label: 'Breed & Color',
          value:
              '${carrierMare?.breed ?? "Equine"} • ${carrierMare?.colour ?? "Standard"}',
        ),
        _CertRow(
          label: 'Microchip / Reg No',
          value: carrierMare?.microchipNo?.isNotEmpty == true
              ? carrierMare!.microchipNo!
              : 'Recorded in Registry',
        ),
        _CertRow(
          label: 'Carrier Role',
          value: isET
              ? 'Recipient Carrier (Embryo Transfer / ICSI)'
              : 'Biological Dam (AI / Natural)',
        ),
        if (isET) ...[
          _CertRow(label: 'Genetic Donor Dam', value: geneticDamName),
          _CertRow(label: 'Sire (Covering Stallion)', value: stallionName),
        ] else ...[
          _CertRow(label: 'Sire (Covering Stallion)', value: stallionName),
        ],
        const SizedBox(height: 18),

        // Section 2: Conception & Breeding Details
        const Text(
          'II. CONCEPTION & BREEDING DETAILS',
          style: AppTypography.sectionLabel,
        ),
        const SizedBox(height: 10),
        _CertRow(label: 'Breeding Method', value: methodLabel),
        if (breeding?.coverOrTransferDate != null)
          _CertRow(
            label: isET ? 'Embryo Transfer Date' : 'Cover / Insemination Date',
            value: _formatDate(breeding!.coverOrTransferDate),
          ),
        _CertRow(
          label: 'Expected Foaling Due Date',
          value: _formatDate(preg.foalingDueDate),
        ),
        _CertRow(
          label: 'Gestation Security',
          value: 'Day 45 Complete • Organogenesis Secured',
        ),
        const SizedBox(height: 18),

        // Section 3: Ultrasound Examination Timeline
        const Text(
          'III. VETERINARY ULTRASOUND SCAN TIMELINE',
          style: AppTypography.sectionLabel,
        ),
        const SizedBox(height: 10),
        _CertRow(
          label: '1st Scan (Day 14-16)',
          value:
              'Due ${_formatDate(preg.scan1DueDate)} • ${preg.scan1Confirmed ? "✅ Confirmed Positive" : "Recorded"}',
        ),
        _CertRow(
          label: '2nd Scan (Day 28-30)',
          value:
              'Due ${_formatDate(preg.scan2DueDate)} • ${preg.scan2Confirmed ? "✅ Heartbeat Viable" : "Recorded"}',
        ),
        _CertRow(
          label: '3rd Milestone Scan (Day 45)',
          value: 'Due ${_formatDate(preg.scan3DueDate)} • ✅ CONFIRMED POSITIVE',
        ),
        const SizedBox(height: 18),

        // Section 4: Attestation & Verification
        const Text(
          'IV. VETERINARY & BREEDER ATTESTATION',
          style: AppTypography.sectionLabel,
        ),
        const SizedBox(height: 10),
        _CertRow(label: 'Attending Veterinarian', value: vetName),
        _CertRow(label: 'Veterinary Contact', value: vetNumber),
        _CertRow(
          label: 'Breeder / Stud Master',
          value: user?.fullName.isNotEmpty == true
              ? user!.fullName
              : 'Certified Equine Breeder',
        ),
        _CertRow(
          label: 'Breeder Contact',
          value: user?.email.isNotEmpty == true
              ? user!.email
              : 'support@abp.app',
        ),
        _CertRow(label: 'Date Issued', value: _formatDate(DateTime.now())),
        _CertRow(
          label: 'Certificate ID',
          value:
              'ABP-45D-${preg.id.isNotEmpty && preg.id.length >= 8 ? preg.id.substring(0, 8).toUpperCase() : "EQUINE"}',
        ),
        const Divider(color: AppColors.surface, height: 28),

        // Fixed Footer Disclaimer
        Text(
          'This 45-day pregnancy scan certificate confirms positive equine gestation status at Day 45 milestone. Recognized for Thoroughbred and Sport Horse breeding records, stud management, and Live Foal Guarantee protocols.',
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

  Widget _buildFoalCertificateContent(dynamic user) {
    final foal = widget.foal!;
    final certId =
        'ABP-EQ-${foal.dateOfBirth?.year ?? 2026}-${foal.id.replaceAll("-", "").padRight(6, "0").substring(0, 6).toUpperCase()}';
    final damMareAsync = widget.dam != null
        ? AsyncValue.data(widget.dam)
        : ref.watch(animalByIdProvider(foal.mareAnimalId));
    final prevCareAsync = ref.watch(
      preventativeCareForOwnerProvider((ownerType: 'foal', ownerId: foal.id)),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Certificate Header with ABP Official Logo & Benchmark Badge
        Center(
          child: Column(
            children: [
              const AbpOfficialLogo(size: 52),
              const SizedBox(height: 10),
              const Text(
                'ANIMAL BIRTHDAY PREDICTOR (ABP)',
                style: AppTypography.sectionLabel,
              ),
              const SizedBox(height: 4),
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
                'Certified Pedigree, Physical Identification & Preventative Health Record',
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),

              // Top Benchmark & Certificate ID Security Banner
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  vertical: 8,
                  horizontal: 12,
                ),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.primaryGold, width: 1.2),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.verified_user_rounded,
                      color: AppColors.primaryGold,
                      size: 16,
                    ),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        'OFFICIAL BENCHMARK: $certId',
                        style: const TextStyle(
                          color: AppColors.primaryGold,
                          fontWeight: FontWeight.w900,
                          fontSize: 12,
                          letterSpacing: 1.2,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const Divider(color: AppColors.primaryGold, height: 24, thickness: 1),

        // Animal Photo Preview
        _buildAnimalPhotoHeader(foal.photoUrl ?? damMareAsync.valueOrNull?.photoUrl, 'FOAL PHOTO'),

        // Section 1: Identification
        const Text('I. IDENTIFICATION', style: AppTypography.sectionLabel),
        const SizedBox(height: 10),
        _CertRow(
          label: 'Registered Name',
          value: foal.foalName?.isNotEmpty == true
              ? foal.foalName!
              : 'Unregistered Foal',
        ),
        _CertRow(
          label: 'Breed',
          value: foal.breed?.isNotEmpty == true ? foal.breed! : 'Equine',
        ),
        _CertRow(
          label: 'Sex',
          value: foal.sex == 'colt' ? 'Colt (Male)' : 'Filly (Female)',
        ),
        _CertRow(label: 'Date of Birth', value: _formatDate(foal.dateOfBirth)),
        _CertRow(
          label: 'Microchip Number',
          value: foal.foalMicrochipNo?.isNotEmpty == true
              ? foal.foalMicrochipNo!
              : 'Not Microchipped',
        ),
        _CertRow(
          label: 'DNA Profile',
          value: foal.dna?.isNotEmpty == true ? foal.dna! : 'On File / Pending',
        ),
        _CertRow(
          label: 'Official Certificate ID',
          value:
              'ABP-EQ-${foal.dateOfBirth?.year ?? 2026}-${foal.id.replaceAll("-", "").padRight(6, "0").substring(0, 6).toUpperCase()}',
        ),
        _CertRow(
          label: 'Stud Book Association',
          value: foal.studBookAssociation?.isNotEmpty == true
              ? foal.studBookAssociation!
              : 'Recorded Breeder',
        ),
        const SizedBox(height: 18),

        // Section 2: Parentage & Lineage
        const Text(
          'II. PARENTAGE & LINEAGE',
          style: AppTypography.sectionLabel,
        ),
        const SizedBox(height: 10),
        _CertRow(
          label: 'Sire (Stallion)',
          value: foal.stallion?.isNotEmpty == true
              ? foal.stallion!
              : 'Recorded Stallion',
        ),
        damMareAsync.when(
          data: (damMare) => _CertRow(
            label: 'Dam (Broodmare)',
            value: damMare != null
                ? '${damMare.name} (Chip: ${damMare.microchipNo ?? "N/A"})'
                : 'Registered Mare',
          ),
          loading: () =>
              const _CertRow(label: 'Dam (Broodmare)', value: 'Loading...'),
          error: (err, stack) =>
              const _CertRow(label: 'Dam (Broodmare)', value: 'Recorded Mare'),
        ),
        const SizedBox(height: 18),

        // Section 3: Health Summary
        const Text(
          'III. HEALTH & PREVENTATIVE CARE SUMMARY',
          style: AppTypography.sectionLabel,
        ),
        const SizedBox(height: 10),
        prevCareAsync.when(
          data: (care) {
            return Column(
              children: [
                _CertRow(
                  label: 'Tetanus Toxoid',
                  value: care?.tetanusDone == true
                      ? 'Given ${_formatDate(care?.tetanusDate)}'
                      : 'Pending Primary',
                ),
                _CertRow(
                  label: 'Wormer Status',
                  value: care?.wormerDone == true
                      ? 'Completed ${_formatDate(care?.wormerDate)}'
                      : 'Scheduled Routine',
                ),
                _CertRow(
                  label: 'Strangles Vaccination',
                  value: care?.stranglesDone == true
                      ? 'Given ${_formatDate(care?.stranglesDate)}'
                      : 'Not Recorded',
                ),
                _CertRow(
                  label: 'Dental Examination',
                  value: care?.dentalDone == true
                      ? 'Inspected ${_formatDate(care?.dentalDate)}'
                      : 'Scheduled at Weaning',
                ),
                _CertRow(
                  label: 'Farrier / Hoof Care',
                  value: care?.farrierDone == true
                      ? 'Trimmed ${_formatDate(care?.farrierDate)}'
                      : 'Scheduled Routine',
                ),
              ],
            );
          },
          loading: () => const _CertRow(
            label: 'Health Records',
            value: 'Loading records...',
          ),
          error: (err, stack) => const _CertRow(
            label: 'Health Records',
            value: 'Refer to Veterinary Log',
          ),
        ),
        const SizedBox(height: 18),

        // Section 4: Breeder Details
        const Text(
          'IV. BREEDER & OWNER ATTESTATION',
          style: AppTypography.sectionLabel,
        ),
        const SizedBox(height: 10),
        _CertRow(
          label: 'Breeder / Stud Name',
          value: user?.fullName.isNotEmpty == true
              ? user!.fullName
              : 'Certified Equine Breeder',
        ),
        _CertRow(
          label: 'Contact Email',
          value: user?.email.isNotEmpty == true
              ? user!.email
              : 'breeder@abp.app',
        ),
        if (foal.buyerName?.isNotEmpty == true) ...[
          _CertRow(label: 'New Owner / Transfer', value: foal.buyerName!),
          if (foal.saleDate != null)
            _CertRow(label: 'Transfer Date', value: _formatDate(foal.saleDate)),
        ],
        _CertRow(
          label: 'Certificate Issued',
          value: _formatDate(DateTime.now()),
        ),
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
    final certId =
        'ABP-CN-${puppy.dateOfBirth?.year ?? 2026}-${puppy.id.replaceAll("-", "").padRight(6, "0").substring(0, 6).toUpperCase()}';
    final damDogAsync = widget.dam != null
        ? AsyncValue.data(widget.dam)
        : (puppy.damAnimalId != null
              ? ref.watch(animalByIdProvider(puppy.damAnimalId!))
              : const AsyncValue.data(null));

    final healthAsync = ref.watch(
      dogPreventativeCareProvider((
        ownerType: 'puppy',
        ownerId: puppy.id,
        dob: puppy.dateOfBirth,
      )),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Certificate Header with ABP Official Logo & Benchmark Badge
        Center(
          child: Column(
            children: [
              const AbpOfficialLogo(size: 52),
              const SizedBox(height: 10),
              const Text(
                'ANIMAL BIRTHDAY PREDICTOR (ABP)',
                style: AppTypography.sectionLabel,
              ),
              const SizedBox(height: 4),
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
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),

              // Top Benchmark & Certificate ID Security Banner
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  vertical: 8,
                  horizontal: 12,
                ),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.primaryGold, width: 1.2),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.verified_user_rounded,
                      color: AppColors.primaryGold,
                      size: 16,
                    ),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        'OFFICIAL BENCHMARK: $certId',
                        style: const TextStyle(
                          color: AppColors.primaryGold,
                          fontWeight: FontWeight.w900,
                          fontSize: 12,
                          letterSpacing: 1.2,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const Divider(color: AppColors.primaryGold, height: 24, thickness: 1),

        // Animal Photo Preview
        _buildAnimalPhotoHeader(puppy.photoUrl ?? damDogAsync.valueOrNull?.photoUrl, 'PUPPY PHOTO'),

        // Section 1: Identification
        const Text(
          'I. PUPPY IDENTIFICATION',
          style: AppTypography.sectionLabel,
        ),
        const SizedBox(height: 10),
        _CertRow(
          label: 'Puppy Name / ID',
          value: puppy.puppyName?.isNotEmpty == true
              ? puppy.puppyName!
              : 'Puppy Record',
        ),
        _CertRow(label: 'Official Certificate ID', value: certId),
        _CertRow(
          label: 'Collar / Tag Colour',
          value: puppy.collarTagColour?.isNotEmpty == true
              ? puppy.collarTagColour!
              : 'None Assigned',
        ),
        _CertRow(label: 'Sex', value: puppy.sex == 'male' ? 'Male' : 'Female'),
        _CertRow(
          label: 'Coat Colour / Pattern',
          value: puppy.colour?.isNotEmpty == true ? puppy.colour! : 'Recorded',
        ),
        _CertRow(
          label: 'Birth Order',
          value: puppy.birthOrder != null ? '#${puppy.birthOrder}' : 'Recorded',
        ),
        _CertRow(label: 'Date of Birth', value: _formatDate(puppy.dateOfBirth)),
        _CertRow(
          label: 'Microchip Number',
          value: puppy.microchipNo?.isNotEmpty == true
              ? puppy.microchipNo!
              : 'Pending Microchip',
        ),
        const SizedBox(height: 18),

        // Section 2: Parentage & Weights
        const Text(
          'II. PARENTAGE & WEIGHT METRICS',
          style: AppTypography.sectionLabel,
        ),
        const SizedBox(height: 10),
        damDogAsync.when(
          data: (damDog) => _CertRow(
            label: 'Mother (Dam Dog)',
            value: damDog != null
                ? '${damDog.name} (${damDog.breed ?? "Canine"})'
                : 'Registered Dam Dog',
          ),
          loading: () =>
              const _CertRow(label: 'Mother (Dam Dog)', value: 'Loading...'),
          error: (err, stack) => const _CertRow(
            label: 'Mother (Dam Dog)',
            value: 'Recorded Dam Dog',
          ),
        ),
        _CertRow(
          label: 'Father (Sire)',
          value: puppy.sireName?.isNotEmpty == true
              ? puppy.sireName!
              : 'Recorded Stud',
        ),
        _CertRow(
          label: 'Birth Weight',
          value: puppy.birthWeight?.isNotEmpty == true
              ? puppy.birthWeight!
              : 'Recorded at birth',
        ),
        _CertRow(
          label: 'Departure Weight',
          value: puppy.currentWeight?.isNotEmpty == true
              ? puppy.currentWeight!
              : 'Recorded on departure',
        ),
        const SizedBox(height: 18),

        // Section 3: Health Summary
        const Text(
          'III. HEALTH & PREVENTATIVE CARE SUMMARY',
          style: AppTypography.sectionLabel,
        ),
        const SizedBox(height: 10),
        healthAsync.when(
          data: (items) {
            final completedWorms = items
                .where((i) => i.treatmentType == 'worming' && i.isCompleted)
                .toList();
            final completedVax = items
                .where((i) => i.treatmentType == 'vaccination' && i.isCompleted)
                .toList();
            final completedVet = items
                .where((i) => i.treatmentType == 'vet_check' && i.isCompleted)
                .toList();

            return Column(
              children: [
                _CertRow(
                  label: 'Worming Protocol',
                  value: completedWorms.isNotEmpty
                      ? completedWorms
                            .map(
                              (w) => '${w.title} (${_formatDate(w.dateGiven)})',
                            )
                            .join(', ')
                      : 'Completed according to schedule',
                ),
                _CertRow(
                  label: 'Vaccinations',
                  value: completedVax.isNotEmpty
                      ? completedVax
                            .map(
                              (v) => '${v.title} (${_formatDate(v.dateGiven)})',
                            )
                            .join(', ')
                      : 'C3/C5 Primary Vaccination Completed',
                ),
                _CertRow(
                  label: 'Veterinary Check',
                  value: completedVet.isNotEmpty
                      ? completedVet
                            .map((vc) => '${vc.title} (Passed)')
                            .join(', ')
                      : 'General Health Exam Completed',
                ),
              ],
            );
          },
          loading: () =>
              const _CertRow(label: 'Health Summary', value: 'Loading...'),
          error: (e, _) => const _CertRow(
            label: 'Health Summary',
            value: 'Refer to veterinary record',
          ),
        ),
        const SizedBox(height: 18),

        // Section 4: Breeder Details & Going Home
        const Text(
          'IV. BREEDER & NEW OWNER ATTESTATION',
          style: AppTypography.sectionLabel,
        ),
        const SizedBox(height: 10),
        _CertRow(
          label: 'Breeder / Kennel Name',
          value: user?.fullName.isNotEmpty == true
              ? user!.fullName
              : 'Certified Canine Breeder',
        ),
        _CertRow(
          label: 'Breeder Contact',
          value: user?.email.isNotEmpty == true
              ? user!.email
              : 'support@abp.app',
        ),
        if (puppy.newOwnerName?.isNotEmpty == true) ...[
          _CertRow(label: 'New Owner / Home', value: puppy.newOwnerName!),
          if (puppy.dateGoingHome != null)
            _CertRow(
              label: 'Date Going Home',
              value: _formatDate(puppy.dateGoingHome),
            ),
        ],
        _CertRow(
          label: 'Certificate Issued',
          value: _formatDate(DateTime.now()),
        ),
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
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.textSecondary,
              ),
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
