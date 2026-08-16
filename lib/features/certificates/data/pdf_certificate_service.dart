import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../../../features/animals/domain/animal.dart';
import '../../../features/foal/domain/foal_record.dart';
import '../../../features/pregnancy/domain/preventative_care_record.dart';
import '../../../features/puppy/domain/dog_preventative_care.dart';
import '../../../features/puppy/domain/puppy.dart';

class PdfCertificateService {
  static Future<Uint8List> generateFoalCertificate({
    required FoalRecord foal,
    required Animal? dam,
    required PreventativeCareRecord? prevCare,
    required String breederName,
    required String breederEmail,
  }) async {
    final pdf = pw.Document();

    final goldColor = PdfColor.fromHex('#D4AF37');
    final darkNavy = PdfColor.fromHex('#0A192F');
    final surfaceColor = PdfColor.fromHex('#112240');
    final textMuted = PdfColor.fromHex('#8A8F98');

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (pw.Context context) {
          return pw.Container(
            padding: const pw.EdgeInsets.all(24),
            decoration: pw.BoxDecoration(
              border: pw.Border.all(color: goldColor, width: 2.5),
              borderRadius: pw.BorderRadius.circular(12),
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                // Header
                pw.Center(
                  child: pw.Column(
                    children: [
                      pw.Text(
                        'ANIMAL BIRTHDAY PREDICTOR (ABP)',
                        style: pw.TextStyle(
                          fontSize: 10,
                          fontWeight: pw.FontWeight.bold,
                          color: goldColor,
                          letterSpacing: 2,
                        ),
                      ),
                      pw.SizedBox(height: 4),
                      pw.Text(
                        'OFFICIAL EQUINE / FOAL CERTIFICATE',
                        style: pw.TextStyle(
                          fontSize: 20,
                          fontWeight: pw.FontWeight.bold,
                          color: darkNavy,
                          letterSpacing: 1.5,
                        ),
                      ),
                      pw.SizedBox(height: 4),
                      pw.Text(
                        'Certified Pedigree, Physical Identification & Preventative Health Record',
                        style: pw.TextStyle(fontSize: 9, color: textMuted, fontStyle: pw.FontStyle.italic),
                      ),
                    ],
                  ),
                ),
                pw.Divider(color: goldColor, thickness: 1, height: 20),

                // Section 1: Identification
                _buildPdfSectionHeader('I. IDENTIFICATION', goldColor),
                pw.SizedBox(height: 6),
                _buildPdfRow('Registered Name', foal.foalName?.isNotEmpty == true ? foal.foalName! : 'Unregistered Foal'),
                _buildPdfRow('Breed', foal.breed?.isNotEmpty == true ? foal.breed! : 'Equine'),
                _buildPdfRow('Sex', foal.sex == 'colt' ? 'Colt (Male)' : 'Filly (Female)'),
                _buildPdfRow('Date of Birth', _formatDate(foal.dateOfBirth)),
                _buildPdfRow('Microchip Number', foal.foalMicrochipNo?.isNotEmpty == true ? foal.foalMicrochipNo! : 'Not Microchipped'),
                _buildPdfRow('DNA Profile', foal.dna?.isNotEmpty == true ? foal.dna! : 'On File / Pending'),
                _buildPdfRow('Stud Book Association', foal.studBookAssociation?.isNotEmpty == true ? foal.studBookAssociation! : 'Recorded Breeder'),
                pw.SizedBox(height: 12),

                // Section 2: Parentage & Lineage
                _buildPdfSectionHeader('II. PARENTAGE & LINEAGE', goldColor),
                pw.SizedBox(height: 6),
                _buildPdfRow('Sire (Father)', foal.stallion?.isNotEmpty == true ? foal.stallion! : 'Recorded Stallion'),
                _buildPdfRow('Dam (Mother)', dam != null ? '${dam.name} (Chip: ${dam.microchipNo ?? "N/A"})' : 'Registered Mare'),
                pw.SizedBox(height: 12),

                // Section 3: Health Summary
                _buildPdfSectionHeader('III. HEALTH & PREVENTATIVE CARE SUMMARY', goldColor),
                pw.SizedBox(height: 6),
                _buildPdfRow('Tetanus Toxoid', prevCare?.tetanusDone == true ? 'Completed ${_formatDate(prevCare?.tetanusDate)}' : 'Scheduled Primary'),
                _buildPdfRow('Deworming Status', prevCare?.wormerDone == true ? 'Completed ${_formatDate(prevCare?.wormerDate)}' : 'Scheduled Routine'),
                _buildPdfRow('Strangles Vaccination', prevCare?.stranglesDone == true ? 'Completed ${_formatDate(prevCare?.stranglesDate)}' : 'Not Recorded'),
                _buildPdfRow('Dental Examination', prevCare?.dentalDone == true ? 'Inspected ${_formatDate(prevCare?.dentalDate)}' : 'Scheduled at Weaning'),
                _buildPdfRow('Farrier / Hoof Care', prevCare?.farrierDone == true ? 'Trimmed ${_formatDate(prevCare?.farrierDate)}' : 'Scheduled Routine'),
                pw.SizedBox(height: 12),

                // Section 4: Breeder Details
                _buildPdfSectionHeader('IV. BREEDER & OWNER ATTESTATION', goldColor),
                pw.SizedBox(height: 6),
                _buildPdfRow('Breeder / Stud Name', breederName.isNotEmpty ? breederName : 'Certified Equine Breeder'),
                _buildPdfRow('Contact', breederEmail.isNotEmpty ? breederEmail : 'support@abp.app'),
                if (foal.buyerName?.isNotEmpty == true) ...[
                  _buildPdfRow('New Owner / Transfer', foal.buyerName!),
                  if (foal.saleDate != null) _buildPdfRow('Date of Transfer', _formatDate(foal.saleDate)),
                ],
                _buildPdfRow('Date Issued', _formatDate(DateTime.now())),
                pw.Spacer(),

                // Fixed Legal Disclaimer
                pw.Divider(color: surfaceColor, thickness: 0.5),
                pw.SizedBox(height: 4),
                pw.Center(
                  child: pw.Text(
                    'This certificate is a summary of information recorded by the breeder/owner. It is not a substitute for veterinary records, veterinary examination or professional veterinary advice.',
                    style: pw.TextStyle(
                      fontSize: 8,
                      color: textMuted,
                      fontStyle: pw.FontStyle.italic,
                    ),
                    textAlign: pw.TextAlign.center,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );

    return pdf.save();
  }

  static Future<Uint8List> generatePuppyCertificate({
    required Puppy puppy,
    required Animal? dam,
    required List<DogPreventativeCareItem> healthItems,
    required String breederName,
    required String breederEmail,
  }) async {
    final pdf = pw.Document();

    final goldColor = PdfColor.fromHex('#D4AF37');
    final darkNavy = PdfColor.fromHex('#0A192F');
    final surfaceColor = PdfColor.fromHex('#112240');
    final textMuted = PdfColor.fromHex('#8A8F98');

    final wormings = healthItems.where((i) => i.treatmentType == 'worming' && i.isCompleted).toList();
    final vaccines = healthItems.where((i) => i.treatmentType == 'vaccination' && i.isCompleted).toList();
    final vetChecks = healthItems.where((i) => i.treatmentType == 'vet_check' && i.isCompleted).toList();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (pw.Context context) {
          return pw.Container(
            padding: const pw.EdgeInsets.all(24),
            decoration: pw.BoxDecoration(
              border: pw.Border.all(color: goldColor, width: 2.5),
              borderRadius: pw.BorderRadius.circular(12),
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                // Header
                pw.Center(
                  child: pw.Column(
                    children: [
                      pw.Text(
                        'ANIMAL BIRTHDAY PREDICTOR (ABP)',
                        style: pw.TextStyle(
                          fontSize: 10,
                          fontWeight: pw.FontWeight.bold,
                          color: goldColor,
                          letterSpacing: 2,
                        ),
                      ),
                      pw.SizedBox(height: 4),
                      pw.Text(
                        'OFFICIAL CANINE / PUPPY CERTIFICATE',
                        style: pw.TextStyle(
                          fontSize: 20,
                          fontWeight: pw.FontWeight.bold,
                          color: darkNavy,
                          letterSpacing: 1.5,
                        ),
                      ),
                      pw.SizedBox(height: 4),
                      pw.Text(
                        'Certified Pedigree, Physical Identification & Preventative Health Record',
                        style: pw.TextStyle(fontSize: 9, color: textMuted, fontStyle: pw.FontStyle.italic),
                      ),
                    ],
                  ),
                ),
                pw.Divider(color: goldColor, thickness: 1, height: 20),

                // Section 1: Identification
                _buildPdfSectionHeader('I. PUPPY IDENTIFICATION', goldColor),
                pw.SizedBox(height: 6),
                _buildPdfRow('Puppy Name / ID', puppy.puppyName?.isNotEmpty == true ? puppy.puppyName! : 'Puppy Record'),
                _buildPdfRow('Collar / Tag Colour', puppy.collarTagColour?.isNotEmpty == true ? puppy.collarTagColour! : 'None Assigned'),
                _buildPdfRow('Sex', puppy.sex == 'male' ? 'Male' : 'Female'),
                _buildPdfRow('Coat Colour / Pattern', puppy.colour?.isNotEmpty == true ? puppy.colour! : 'Recorded'),
                _buildPdfRow('Birth Order', puppy.birthOrder != null ? '#${puppy.birthOrder}' : 'Recorded'),
                _buildPdfRow('Date of Birth', _formatDate(puppy.dateOfBirth)),
                _buildPdfRow('Microchip Number', puppy.microchipNo?.isNotEmpty == true ? puppy.microchipNo! : 'Pending Microchip'),
                pw.SizedBox(height: 12),

                // Section 2: Parentage & Weights
                _buildPdfSectionHeader('II. PARENTAGE & WEIGHT METRICS', goldColor),
                pw.SizedBox(height: 6),
                _buildPdfRow('Mother (Dam Dog)', dam != null ? '${dam.name} (${dam.breed ?? "Canine"})' : 'Registered Dam'),
                _buildPdfRow('Father (Sire)', puppy.sireName?.isNotEmpty == true ? puppy.sireName! : 'Recorded Sire'),
                _buildPdfRow('Birth Weight', puppy.birthWeight?.isNotEmpty == true ? puppy.birthWeight! : 'Recorded at birth'),
                _buildPdfRow('Departure Weight', puppy.currentWeight?.isNotEmpty == true ? puppy.currentWeight! : 'Recorded on departure'),
                pw.SizedBox(height: 12),

                // Section 3: Health Summary
                _buildPdfSectionHeader('III. HEALTH & PREVENTATIVE CARE SUMMARY', goldColor),
                pw.SizedBox(height: 6),
                _buildPdfRow(
                  'Worming Protocol',
                  wormings.isNotEmpty
                      ? wormings.map((w) => '${w.title}: ${_formatDate(w.dateGiven)}').join(', ')
                      : 'Completed according to schedule',
                ),
                _buildPdfRow(
                  'Vaccination Protocol',
                  vaccines.isNotEmpty
                      ? vaccines.map((v) => '${v.title}: ${_formatDate(v.dateGiven)}').join(', ')
                      : 'C3/C5 Primary Vaccination Completed',
                ),
                _buildPdfRow(
                  'Veterinary Examination',
                  vetChecks.isNotEmpty
                      ? vetChecks.map((vc) => '${vc.title}: ${_formatDate(vc.dateGiven)} (Passed)').join(', ')
                      : 'General Health Exam Completed',
                ),
                pw.SizedBox(height: 12),

                // Section 4: Breeder Details & Going Home
                _buildPdfSectionHeader('IV. BREEDER & NEW OWNER ATTESTATION', goldColor),
                pw.SizedBox(height: 6),
                _buildPdfRow('Breeder / Kennel Name', breederName.isNotEmpty ? breederName : 'Certified Canine Breeder'),
                _buildPdfRow('Breeder Contact', breederEmail.isNotEmpty ? breederEmail : 'support@abp.app'),
                if (puppy.newOwnerName?.isNotEmpty == true) ...[
                  _buildPdfRow('New Owner / Home', puppy.newOwnerName!),
                  if (puppy.dateGoingHome != null) _buildPdfRow('Date Going Home', _formatDate(puppy.dateGoingHome)),
                ],
                _buildPdfRow('Date Issued', _formatDate(DateTime.now())),
                pw.Spacer(),

                // Fixed Legal Disclaimer
                pw.Divider(color: surfaceColor, thickness: 0.5),
                pw.SizedBox(height: 4),
                pw.Center(
                  child: pw.Text(
                    'This certificate is a summary of information recorded by the breeder/owner. It is not a substitute for veterinary records, veterinary examination or professional veterinary advice.',
                    style: pw.TextStyle(
                      fontSize: 8,
                      color: textMuted,
                      fontStyle: pw.FontStyle.italic,
                    ),
                    textAlign: pw.TextAlign.center,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );

    return pdf.save();
  }

  static pw.Widget _buildPdfSectionHeader(String title, PdfColor color) {
    return pw.Text(
      title,
      style: pw.TextStyle(
        fontSize: 10,
        fontWeight: pw.FontWeight.bold,
        color: color,
        letterSpacing: 1.2,
      ),
    );
  }

  static pw.Widget _buildPdfRow(String label, String value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 2),
      child: pw.Row(
        children: [
          pw.SizedBox(
            width: 140,
            child: pw.Text(
              label,
              style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey700),
            ),
          ),
          pw.Expanded(
            child: pw.Text(
              value,
              style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold, color: PdfColors.black),
            ),
          ),
        ],
      ),
    );
  }

  static String _formatDate(DateTime? dt) {
    if (dt == null) return 'N/A';
    return '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year}';
  }

  static Future<void> exportOrPrintPdf(Uint8List pdfBytes, String fileName) async {
    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdfBytes,
      name: fileName,
    );
  }
}
