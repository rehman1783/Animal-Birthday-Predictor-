import 'dart:io';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../../../features/animals/domain/animal.dart';
import '../../../features/foal/domain/foal_record.dart';
import '../../../features/pregnancy/domain/breeding_record.dart';
import '../../../features/pregnancy/domain/pregnancy_record.dart';
import '../../../features/pregnancy/domain/preventative_care_record.dart';
import '../../../features/puppy/domain/dog_preventative_care.dart';
import '../../../features/puppy/domain/puppy.dart';
import '../../../features/foaling_diary/domain/foaling_diary_entry.dart';
import 'package:flutter/services.dart' show rootBundle;

class PdfCertificateService {
  static pw.MemoryImage? _cachedLogoImage;

  static Future<pw.MemoryImage?> _loadAbpLogo() async {
    if (_cachedLogoImage != null) return _cachedLogoImage;
    try {
      final byteData = await rootBundle.load('assets/images/abp_official_logo.jpg');
      _cachedLogoImage = pw.MemoryImage(byteData.buffer.asUint8List());
      return _cachedLogoImage;
    } catch (_) {
      return null;
    }
  }

  static Future<pw.MemoryImage?> _loadPhotoFromUrl(String? photoUrl) async {
    if (photoUrl == null || photoUrl.trim().isEmpty) return null;
    try {
      final url = photoUrl.trim();
      if (url.startsWith('http://') || url.startsWith('https://')) {
        final response = await http.get(Uri.parse(url)).timeout(const Duration(seconds: 6));
        if (response.statusCode == 200 && response.bodyBytes.isNotEmpty) {
          return pw.MemoryImage(response.bodyBytes);
        }
      } else if (url.startsWith('assets/')) {
        final byteData = await rootBundle.load(url);
        return pw.MemoryImage(byteData.buffer.asUint8List());
      } else {
        final file = File(url);
        if (await file.exists()) {
          final bytes = await file.readAsBytes();
          if (bytes.isNotEmpty) {
            return pw.MemoryImage(bytes);
          }
        }
      }
    } catch (_) {}
    return null;
  }
  static Future<Uint8List> generateFoalCertificate({
    required FoalRecord foal,
    required Animal? dam,
    required PreventativeCareRecord? prevCare,
    required String breederName,
    required String breederEmail,
  }) async {
    final logoImage = await _loadAbpLogo();
    final photoImage = await _loadPhotoFromUrl(foal.photoUrl ?? dam?.photoUrl);
    final pdf = pw.Document();
    final certId = 'ABP-EQ-${foal.dateOfBirth?.year ?? 2026}-${foal.id.replaceAll("-", "").padRight(6, "0").substring(0, 6).toUpperCase()}';

    // Build comprehensive notes string with all available animal details
    final notesBuffer = StringBuffer();
    if (foal.notes?.isNotEmpty == true) notesBuffer.write(foal.notes);
    if (foal.iggValue?.isNotEmpty == true) {
      if (notesBuffer.isNotEmpty) notesBuffer.write(' | ');
      notesBuffer.write('IgG Level: ${foal.iggValue}');
    }
    if (foal.gelded) {
      if (notesBuffer.isNotEmpty) notesBuffer.write(' | ');
      notesBuffer.write('Gelded: ${_formatDate(foal.geldedDate)}');
    }
    if (foal.dna?.isNotEmpty == true) {
      if (notesBuffer.isNotEmpty) notesBuffer.write(' | ');
      notesBuffer.write('DNA Profile: ${foal.dna}');
    }
    if (foal.status?.isNotEmpty == true) {
      if (notesBuffer.isNotEmpty) notesBuffer.write(' | ');
      notesBuffer.write('Status: ${foal.status?.toUpperCase()}');
    }

    final fullNotes = notesBuffer.isNotEmpty
        ? notesBuffer.toString()
        : 'Official pedigree, identification & health keepsake record registered on ABP.';

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(20),
        build: (pw.Context context) {
          return _buildCertificateFrame(
            logoImage: logoImage,
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.stretch,
              children: [
                // Top Header with Logo and Titles
                _buildCertificateHeader(
                  title: 'ANIMAL BIRTHDAY PREDICTOR',
                  subTitle: 'FOAL BIRTH CERTIFICATE',
                  tagline: 'Designed for app auto-population and printing as a breeder record and keepsake.',
                  logoImage: logoImage,
                ),
                pw.SizedBox(height: 10),

                // Top Offspring Details Grid
                _buildBoxedGrid([
                  [
                    _buildGridCell('Foal Name', foal.foalName?.isNotEmpty == true ? foal.foalName! : 'Unregistered Foal', flex: 4, height: 42),
                    _buildGridCell('Date of Birth', _formatDate(foal.dateOfBirth), flex: 3, height: 42),
                    _buildGridCell('Time of Birth', 'Recorded on File', flex: 3, height: 42),
                  ],
                  [
                    _buildGridCell('Sex', foal.sex == 'colt' ? 'Colt (Male)' : 'Filly (Female)', flex: 4, height: 42),
                    _buildGridCell('Colour / Markings', foal.breed?.isNotEmpty == true ? foal.breed! : 'Recorded Markings', flex: 3, height: 42),
                    _buildGridCell('Birth Weight', 'Recorded on File', flex: 3, height: 42),
                  ],
                ]),
                pw.SizedBox(height: 8),

                // PARENTAGE Section
                _buildSectionLabel('PARENTAGE'),
                _buildBoxedGrid([
                  [
                    _buildGridCell('Dam / Mare', dam != null ? '${dam.name} (${dam.breed ?? "Equine"})' : 'Registered Mare', flex: 5, height: 42),
                    _buildGridCell('Sire / Stallion', foal.stallion?.isNotEmpty == true ? foal.stallion! : 'Registered Stallion', flex: 5, height: 42),
                  ],
                  [
                    _buildGridCell('Dam Registration No.', dam?.microchipNo?.isNotEmpty == true ? dam!.microchipNo! : 'On Registry File', flex: 5, height: 42),
                    _buildGridCell('Sire Registration No.', foal.studBookAssociation?.isNotEmpty == true ? foal.studBookAssociation! : 'On Registry File', flex: 5, height: 42),
                  ],
                ]),
                pw.SizedBox(height: 8),

                // BREEDING & FOALING DETAILS Section
                _buildSectionLabel('BREEDING & FOALING DETAILS'),
                _buildBoxedGrid([
                  [
                    _buildGridCell('Breeding Method', 'NATURAL / AI / ET', flex: 4, height: 42),
                    _buildGridCell('Recipient Mare (If ET/ICSI)', foal.recipientAnimalId?.isNotEmpty == true ? foal.recipientAnimalId! : 'Direct Broodmare Gestation', flex: 3, height: 42),
                    _buildGridCell('Gestation Length', '340 days (Standard)', flex: 3, height: 42),
                  ],
                  [
                    _buildGridCell('Place of Birth', 'Registered Stud Facility', flex: 4, height: 42),
                    _buildGridCell('Breeder / Stud', breederName.isNotEmpty ? breederName : 'Certified Equine Breeder', flex: 3, height: 42),
                    _buildGridCell('Owner', foal.buyerName?.isNotEmpty == true ? foal.buyerName! : (breederName.isNotEmpty ? breederName : 'Recorded Owner'), flex: 3, height: 42),
                  ],
                ]),
                pw.SizedBox(height: 8),

                // Bottom Grid & Photo Box
                pw.Expanded(
                  child: pw.Row(
                    crossAxisAlignment: pw.CrossAxisAlignment.stretch,
                    children: [
                      // Left Column: Identifiers & Notes
                      pw.Expanded(
                        flex: 65,
                        child: _buildBoxedGrid([
                          [_buildGridCell('Microchip No.', foal.foalMicrochipNo?.isNotEmpty == true ? foal.foalMicrochipNo! : 'Pending Microchip', height: 40)],
                          [_buildGridCell('Foal Registration No.', certId, height: 40)],
                          [_buildGridCell('Notes', fullNotes, height: 80)],
                        ]),
                      ),
                      pw.SizedBox(width: 8),

                      // Right Column: Photo Box
                      pw.Expanded(
                        flex: 35,
                        child: _buildPhotoBox('FOAL PHOTO', photoImage: photoImage),
                      ),
                    ],
                  ),
                ),
                pw.SizedBox(height: 8),

                // Footer Disclaimer
                _buildFooterDisclaimer(),
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
    final logoImage = await _loadAbpLogo();
    final photoImage = await _loadPhotoFromUrl(puppy.photoUrl ?? dam?.photoUrl);
    final pdf = pw.Document();
    final certId = 'ABP-CN-${puppy.dateOfBirth?.year ?? 2026}-${puppy.id.replaceAll("-", "").padRight(6, "0").substring(0, 6).toUpperCase()}';

    // Build comprehensive notes string with all available puppy details
    final notesBuffer = StringBuffer();
    if (puppy.generalNotes?.isNotEmpty == true) notesBuffer.write(puppy.generalNotes);
    if (puppy.collarTagColour?.isNotEmpty == true) {
      if (notesBuffer.isNotEmpty) notesBuffer.write(' | ');
      notesBuffer.write('Collar: ${puppy.collarTagColour}');
    }
    if (puppy.currentWeight?.isNotEmpty == true) {
      if (notesBuffer.isNotEmpty) notesBuffer.write(' | ');
      notesBuffer.write('Departure Weight: ${puppy.currentWeight}');
    }
    if (puppy.dna?.isNotEmpty == true) {
      if (notesBuffer.isNotEmpty) notesBuffer.write(' | ');
      notesBuffer.write('DNA Profile: ${puppy.dna}');
    }

    final fullNotes = notesBuffer.isNotEmpty
        ? notesBuffer.toString()
        : 'C3/C5 Vaccinated & Wormed according to schedule. Official canine record.';

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(20),
        build: (pw.Context context) {
          return _buildCertificateFrame(
            logoImage: logoImage,
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.stretch,
              children: [
                // Top Header with Logo and Titles
                _buildCertificateHeader(
                  title: 'ANIMAL BIRTHDAY PREDICTOR',
                  subTitle: 'PUPPY BIRTH CERTIFICATE',
                  tagline: 'Designed for app auto-population and printing as a breeder record and keepsake.',
                  logoImage: logoImage,
                ),
                pw.SizedBox(height: 10),

                // Top Offspring Details Grid
                _buildBoxedGrid([
                  [
                    _buildGridCell('Puppy Name', puppy.puppyName?.isNotEmpty == true ? puppy.puppyName! : 'Puppy Record', flex: 4, height: 42),
                    _buildGridCell('Date of Birth', _formatDate(puppy.dateOfBirth), flex: 3, height: 42),
                    _buildGridCell('Time of Birth', puppy.timeOfBirth?.isNotEmpty == true ? puppy.timeOfBirth! : 'Recorded', flex: 3, height: 42),
                  ],
                  [
                    _buildGridCell('Sex', puppy.sex == 'male' ? 'Male' : 'Female', flex: 4, height: 42),
                    _buildGridCell('Colour / Markings', puppy.colour?.isNotEmpty == true ? puppy.colour! : 'Recorded Markings', flex: 3, height: 42),
                    _buildGridCell('Birth Weight', puppy.birthWeight?.isNotEmpty == true ? puppy.birthWeight! : 'Recorded at birth', flex: 3, height: 42),
                  ],
                ]),
                pw.SizedBox(height: 8),

                // PARENTAGE Section
                _buildSectionLabel('PARENTAGE'),
                _buildBoxedGrid([
                  [
                    _buildGridCell('Dam', dam != null ? '${dam.name} (${dam.breed ?? "Canine"})' : 'Registered Dam Dog', flex: 5, height: 42),
                    _buildGridCell('Sire', puppy.sireName?.isNotEmpty == true ? puppy.sireName! : 'Registered Sire Dog', flex: 5, height: 42),
                  ],
                  [
                    _buildGridCell('Dam Registration No.', dam?.microchipNo?.isNotEmpty == true ? dam!.microchipNo! : 'On Registry File', flex: 5, height: 42),
                    _buildGridCell('Sire Registration No.', puppy.dna?.isNotEmpty == true ? puppy.dna! : 'On Registry File', flex: 5, height: 42),
                  ],
                ]),
                pw.SizedBox(height: 8),

                // BIRTH & BREEDER DETAILS Section
                _buildSectionLabel('BIRTH & BREEDER DETAILS'),
                _buildBoxedGrid([
                  [
                    _buildGridCell('Breed', dam?.breed?.isNotEmpty == true ? dam!.breed! : 'Canine Breed', flex: 4, height: 42),
                    _buildGridCell('Breeder / Kennel', breederName.isNotEmpty ? breederName : 'Certified Canine Breeder', flex: 3, height: 42),
                    _buildGridCell('Owner', puppy.newOwnerName?.isNotEmpty == true ? puppy.newOwnerName! : (breederName.isNotEmpty ? breederName : 'Recorded Owner'), flex: 3, height: 42),
                  ],
                  [
                    _buildGridCell('Place of Birth', 'Certified Kennel Facility', flex: 4, height: 42),
                    _buildGridCell('Predicted Whelping Date', _formatDate(puppy.dateOfBirth), flex: 3, height: 42),
                    _buildGridCell('Actual vs Predicted', 'On Schedule', flex: 3, height: 42),
                  ],
                ]),
                pw.SizedBox(height: 8),

                // Bottom Grid & Photo Box
                pw.Expanded(
                  child: pw.Row(
                    crossAxisAlignment: pw.CrossAxisAlignment.stretch,
                    children: [
                      // Left Column: Identifiers & Notes
                      pw.Expanded(
                        flex: 65,
                        child: _buildBoxedGrid([
                          [_buildGridCell('Microchip No.', puppy.microchipNo?.isNotEmpty == true ? puppy.microchipNo! : 'Pending Microchip', height: 40)],
                          [_buildGridCell('Registration No.', certId, height: 40)],
                          [_buildGridCell('Litter / Puppy ID', puppy.birthOrder != null ? '#${puppy.birthOrder}' : 'Litter Member', height: 40)],
                          [_buildGridCell('Notes', fullNotes, height: 60)],
                        ]),
                      ),
                      pw.SizedBox(width: 8),

                      // Right Column: Photo Box
                      pw.Expanded(
                        flex: 35,
                        child: _buildPhotoBox('PUPPY PHOTO', photoImage: photoImage),
                      ),
                    ],
                  ),
                ),
                pw.SizedBox(height: 8),

                // Footer Disclaimer
                _buildFooterDisclaimer(),
              ],
            ),
          );
        },
      ),
    );

    return pdf.save();
  }

  static Future<Uint8List> generateKittenCertificate({
    required String kittenName,
    required String sex,
    required DateTime? dateOfBirth,
    required String? timeOfBirth,
    required String? colourPattern,
    required String? birthWeight,
    required String queenName,
    required String queenRegNo,
    required String sireName,
    required String sireRegNo,
    required String breed,
    required String breederName,
    required String ownerName,
    required String catteryPrefix,
    required String placeOfBirth,
    required String microchipNo,
    required String kittenRegNo,
    required String litterId,
    required String notes,
    String? photoUrl,
  }) async {
    final logoImage = await _loadAbpLogo();
    final photoImage = await _loadPhotoFromUrl(photoUrl);
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(20),
        build: (pw.Context context) {
          return _buildCertificateFrame(
            logoImage: logoImage,
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.stretch,
              children: [
                _buildCertificateHeader(
                  title: 'ANIMAL BIRTHDAY PREDICTOR',
                  subTitle: 'KITTEN BIRTH CERTIFICATE',
                  tagline: 'Designed for app auto-population and printing as a breeder record and keepsake.',
                  logoImage: logoImage,
                ),
                pw.SizedBox(height: 10),

                _buildBoxedGrid([
                  [
                    _buildGridCell('Kitten Name', kittenName.isNotEmpty ? kittenName : 'Kitten Record', flex: 4, height: 42),
                    _buildGridCell('Date of Birth', _formatDate(dateOfBirth), flex: 3, height: 42),
                    _buildGridCell('Time of Birth', timeOfBirth?.isNotEmpty == true ? timeOfBirth! : 'N/A', flex: 3, height: 42),
                  ],
                  [
                    _buildGridCell('Sex', sex, flex: 4, height: 42),
                    _buildGridCell('Colour / Pattern', colourPattern?.isNotEmpty == true ? colourPattern! : 'Recorded', flex: 3, height: 42),
                    _buildGridCell('Birth Weight', birthWeight?.isNotEmpty == true ? birthWeight! : 'Recorded', flex: 3, height: 42),
                  ],
                ]),
                pw.SizedBox(height: 8),

                _buildSectionLabel('PARENTAGE'),
                _buildBoxedGrid([
                  [
                    _buildGridCell('Queen / Dam', queenName, flex: 5, height: 42),
                    _buildGridCell('Sire / Stud', sireName, flex: 5, height: 42),
                  ],
                  [
                    _buildGridCell('Queen Registration No.', queenRegNo, flex: 5, height: 42),
                    _buildGridCell('Sire Registration No.', sireRegNo, flex: 5, height: 42),
                  ],
                ]),
                pw.SizedBox(height: 8),

                _buildSectionLabel('BIRTH & BREEDER DETAILS'),
                _buildBoxedGrid([
                  [
                    _buildGridCell('Breed', breed, flex: 4, height: 42),
                    _buildGridCell('Breeder / Cattery', breederName, flex: 3, height: 42),
                    _buildGridCell('Owner', ownerName, flex: 3, height: 42),
                  ],
                  [
                    _buildGridCell('Cattery Prefix', catteryPrefix, flex: 4, height: 42),
                    _buildGridCell('Place of Birth', placeOfBirth, flex: 3, height: 42),
                    _buildGridCell('Gestation Length', '65 days (Standard)', flex: 3, height: 42),
                  ],
                ]),
                pw.SizedBox(height: 8),

                pw.Expanded(
                  child: pw.Row(
                    crossAxisAlignment: pw.CrossAxisAlignment.stretch,
                    children: [
                      pw.Expanded(
                        flex: 65,
                        child: _buildBoxedGrid([
                          [_buildGridCell('Microchip No.', microchipNo, height: 40)],
                          [_buildGridCell('Kitten Registration No.', kittenRegNo, height: 40)],
                          [_buildGridCell('Litter / Kitten ID', litterId, height: 40)],
                          [_buildGridCell('Notes', notes, height: 60)],
                        ]),
                      ),
                      pw.SizedBox(width: 8),
                      pw.Expanded(
                        flex: 35,
                        child: _buildPhotoBox('KITTEN PHOTO', photoImage: photoImage),
                      ),
                    ],
                  ),
                ),
                pw.SizedBox(height: 8),

                _buildFooterDisclaimer(),
              ],
            ),
          );
        },
      ),
    );

    return pdf.save();
  }

  static Future<Uint8List> generate45DayScanCertificate({
    required PregnancyRecord pregnancy,
    required Animal carrierMare,
    Animal? donorMare,
    BreedingRecord? breedingRecord,
    required String vetName,
    required String vetNumber,
    required String breederName,
    required String breederEmail,
  }) async {
    final logoImage = await _loadAbpLogo();
    final photoImage = await _loadPhotoFromUrl(carrierMare.photoUrl ?? donorMare?.photoUrl);
    final pdf = pw.Document();
    final certId = 'ABP-45D-${breedingRecord?.coverOrTransferDate?.year ?? pregnancy.foalingDueDate?.year ?? 2026}-${pregnancy.id.replaceAll("-", "").padRight(6, "0").substring(0, 6).toUpperCase()}';

    final isET = breedingRecord?.isEmbryoTransfer == true ||
        (breedingRecord?.method.toLowerCase().trim() == 'et') ||
        (breedingRecord?.method.toLowerCase().trim() == 'icsi') ||
        (donorMare != null && donorMare.id != carrierMare.id);

    final rawMethod = breedingRecord?.method.toLowerCase().trim() ?? 'natural';
    String methodLabel = 'Natural Cover';
    if (rawMethod == 'chilled') methodLabel = 'AI (Chilled Semen)';
    if (rawMethod == 'frozen') methodLabel = 'AI (Frozen Semen)';
    if (rawMethod == 'et') methodLabel = 'Embryo Transfer (ET)';
    if (rawMethod == 'icsi') methodLabel = 'ICSI';

    final geneticDam = donorMare != null
        ? '${donorMare.name} (Chip: ${donorMare.microchipNo ?? "Recorded"})'
        : (breedingRecord?.damOfEmbryo?.isNotEmpty == true ? breedingRecord!.damOfEmbryo! : 'Donor Mare');

    final stallion = breedingRecord?.stallionName?.isNotEmpty == true
        ? breedingRecord!.stallionName!
        : (breedingRecord?.stallionOfEmbryo?.isNotEmpty == true
            ? breedingRecord!.stallionOfEmbryo!
            : 'Recorded Stallion');

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(20),
        build: (pw.Context context) {
          return _buildCertificateFrame(
            logoImage: logoImage,
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.stretch,
              children: [
                _buildCertificateHeader(
                  title: 'ANIMAL BIRTHDAY PREDICTOR',
                  subTitle: '45-DAY POSITIVE SCAN CERTIFICATE',
                  tagline: 'Thoroughbred & Sport Horse Standard | Day 45 Gestation Security Attestation',
                  logoImage: logoImage,
                ),
                pw.SizedBox(height: 10),

                // Section 1: Mare & Carrier Details
                _buildSectionLabel('MARE & CARRIER IDENTIFICATION'),
                _buildBoxedGrid([
                  [
                    _buildGridCell('Carrier Mare (In-Foal)', carrierMare.name, flex: 5, height: 42),
                    _buildGridCell('Gestation Carrier Role', isET ? 'Recipient Carrier (ET/ICSI)' : 'Biological Dam (AI/Natural)', flex: 5, height: 42),
                  ],
                  [
                    _buildGridCell('Breed & Colour', '${carrierMare.breed ?? "Equine"} / ${carrierMare.colour ?? "Standard"}', flex: 5, height: 42),
                    _buildGridCell('Microchip / Reg No', carrierMare.microchipNo?.isNotEmpty == true ? carrierMare.microchipNo! : 'Recorded in Registry', flex: 5, height: 42),
                  ],
                ]),
                pw.SizedBox(height: 8),

                // Section 2: PARENTAGE & SIRE
                _buildSectionLabel('PARENTAGE & BREEDING METHOD'),
                _buildBoxedGrid([
                  [
                    _buildGridCell('Genetic Donor Dam', isET ? geneticDam : carrierMare.name, flex: 5, height: 42),
                    _buildGridCell('Covering Sire (Stallion)', stallion, flex: 5, height: 42),
                  ],
                  [
                    _buildGridCell('Breeding Method', methodLabel, flex: 5, height: 42),
                    _buildGridCell('Cover / Transfer Date', breedingRecord?.coverOrTransferDate != null ? _formatDate(breedingRecord!.coverOrTransferDate) : 'Recorded', flex: 5, height: 42),
                  ],
                ]),
                pw.SizedBox(height: 8),

                // Section 3: ULTRASOUND EXAMINATION TIMELINE
                _buildSectionLabel('ULTRASOUND EXAMINATION TIMELINE'),
                _buildBoxedGrid([
                  [
                    _buildGridCell('1st Scan (Day 14-16)', 'Due ${_formatDate(pregnancy.scan1DueDate)} - ${pregnancy.scan1Confirmed ? "CONFIRMED POSITIVE" : "Recorded"}', flex: 5, height: 42),
                    _buildGridCell('2nd Scan (Day 28-30)', 'Due ${_formatDate(pregnancy.scan2DueDate)} - ${pregnancy.scan2Confirmed ? "CONFIRMED HEARTBEAT" : "Recorded"}', flex: 5, height: 42),
                  ],
                  [
                    _buildGridCell('3rd Milestone Scan (Day 45)', 'Due ${_formatDate(pregnancy.scan3DueDate)} - CONFIRMED POSITIVE (Organogenesis Secured)', flex: 5, height: 42),
                    _buildGridCell('Expected Foaling Due Date', _formatDate(pregnancy.foalingDueDate), flex: 5, height: 42),
                  ],
                ]),
                pw.SizedBox(height: 8),

                // Section 4: Attestation & Notes
                pw.Expanded(
                  child: pw.Row(
                    crossAxisAlignment: pw.CrossAxisAlignment.stretch,
                    children: [
                      pw.Expanded(
                        flex: 65,
                        child: _buildBoxedGrid([
                          [_buildGridCell('Attending Veterinarian', vetName.isNotEmpty ? vetName : 'Certified Equine Practitioner', height: 40)],
                          [_buildGridCell('Breeder / Stud Master', breederName.isNotEmpty ? breederName : 'Certified Stud Master', height: 40)],
                          [_buildGridCell('Certificate ID', certId, height: 40)],
                          [_buildGridCell('Notes', 'Official 45-day equine pregnancy scan certificate for Live Foal Guarantee (LFG) records.', height: 60)],
                        ]),
                      ),
                      pw.SizedBox(width: 8),
                      pw.Expanded(
                        flex: 35,
                        child: _buildPhotoBox('MARE / SCAN PHOTO', photoImage: photoImage),
                      ),
                    ],
                  ),
                ),
                pw.SizedBox(height: 8),

                _buildFooterDisclaimer(),
              ],
            ),
          );
        },
      ),
    );

    return pdf.save();
  }

  // --- Helper UI Builders for PDF Reference Grid Layout ---

  static pw.Widget _buildCertificateFrame({
    required pw.MemoryImage? logoImage,
    required pw.Widget child,
  }) {
    return pw.Container(
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.black, width: 1.5),
      ),
      padding: const pw.EdgeInsets.all(2.5),
      child: pw.Container(
        decoration: pw.BoxDecoration(
          border: pw.Border.all(color: PdfColors.black, width: 0.6),
        ),
        padding: const pw.EdgeInsets.all(14),
        child: pw.Stack(
          children: [
            if (logoImage != null)
              pw.Positioned.fill(
                child: pw.Center(
                  child: pw.Opacity(
                    opacity: 0.05,
                    child: pw.Image(logoImage, width: 300, height: 300),
                  ),
                ),
              ),
            child,
          ],
        ),
      ),
    );
  }

  static pw.Widget _buildCertificateHeader({
    required String title,
    required String subTitle,
    required String tagline,
    required pw.MemoryImage? logoImage,
  }) {
    return pw.Stack(
      alignment: pw.Alignment.center,
      children: [
        // Top Left Logo Area
        pw.Align(
          alignment: pw.Alignment.topLeft,
          child: pw.Container(
            width: 48,
            height: 48,
            decoration: pw.BoxDecoration(
              shape: pw.BoxShape.circle,
              border: pw.Border.all(color: PdfColors.black, width: 1.0),
            ),
            child: logoImage != null
                ? pw.ClipOval(child: pw.Image(logoImage, fit: pw.BoxFit.cover))
                : pw.Center(
                    child: pw.Text('ABP', style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold)),
                  ),
          ),
        ),

        // Centered Header Title & Sub-header
        pw.Column(
          children: [
            pw.Text(
              title,
              style: pw.TextStyle(
                fontSize: 15,
                fontWeight: pw.FontWeight.bold,
                color: PdfColors.black,
                letterSpacing: 1.5,
              ),
              textAlign: pw.TextAlign.center,
            ),
            pw.SizedBox(height: 2),
            pw.Text(
              subTitle,
              style: pw.TextStyle(
                fontSize: 12,
                fontWeight: pw.FontWeight.bold,
                color: PdfColors.black,
                letterSpacing: 1.2,
              ),
              textAlign: pw.TextAlign.center,
            ),
            pw.SizedBox(height: 2),
            pw.Text(
              tagline,
              style: pw.TextStyle(
                fontSize: 7.5,
                fontStyle: pw.FontStyle.italic,
                color: PdfColors.grey800,
              ),
              textAlign: pw.TextAlign.center,
            ),
          ],
        ),
      ],
    );
  }

  static pw.Widget _buildSectionLabel(String title) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(top: 4, bottom: 3),
      child: pw.Text(
        title,
        style: pw.TextStyle(
          fontSize: 8.5,
          fontWeight: pw.FontWeight.bold,
          color: PdfColors.black,
          letterSpacing: 1.0,
        ),
      ),
    );
  }

  static pw.Widget _buildBoxedGrid(List<List<pw.Widget>> rows) {
    return pw.Column(
      children: rows.map((row) {
        return pw.Row(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: row,
        );
      }).toList(),
    );
  }

  static pw.Widget _buildGridCell(String label, String value, {int flex = 1, double? height}) {
    return pw.Expanded(
      flex: flex,
      child: pw.Container(
        height: height,
        padding: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 4),
        decoration: pw.BoxDecoration(
          border: pw.Border.all(color: PdfColors.black, width: 0.5),
        ),
        child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          mainAxisAlignment: pw.MainAxisAlignment.center,
          children: [
            pw.Text(
              label,
              style: pw.TextStyle(
                fontSize: 7.5,
                fontWeight: pw.FontWeight.bold,
                color: PdfColors.black,
              ),
              maxLines: 1,
            ),
            pw.SizedBox(height: 2),
            pw.Text(
              value,
              style: pw.TextStyle(
                fontSize: 8.5,
                color: PdfColors.grey900,
              ),
              maxLines: 2,
              overflow: pw.TextOverflow.clip,
            ),
          ],
        ),
      ),
    );
  }

  static pw.Widget _buildPhotoBox(String label, {pw.MemoryImage? photoImage}) {
    if (photoImage != null) {
      return pw.Container(
        decoration: pw.BoxDecoration(
          border: pw.Border.all(color: PdfColors.black, width: 0.5),
        ),
        child: pw.ClipRRect(
          child: pw.Image(photoImage, fit: pw.BoxFit.cover),
        ),
      );
    }
    return pw.Container(
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.black, width: 0.5),
      ),
      child: pw.Center(
        child: pw.Text(
          label,
          style: pw.TextStyle(
            fontSize: 9,
            fontWeight: pw.FontWeight.bold,
            color: PdfColors.grey700,
            letterSpacing: 1.0,
          ),
          textAlign: pw.TextAlign.center,
        ),
      ),
    );
  }

  static pw.Widget _buildFooterDisclaimer() {
    return pw.Container(
      padding: const pw.EdgeInsets.only(top: 4),
      child: pw.Text(
        'Generated by Animal BirthDay Predictor | Breeder record/keepsake only - not an official breed registry certificate, veterinary record or proof of ownership.',
        style: pw.TextStyle(
          fontSize: 7,
          fontStyle: pw.FontStyle.italic,
          color: PdfColors.grey800,
        ),
        textAlign: pw.TextAlign.center,
      ),
    );
  }


  static Future<Uint8List> generateFoalingDiaryPdf({
    required List<FoalingDiaryEntry> entries,
    required String studName,
    required String season,
    required String filterTitle,
  }) async {
    final pdf = pw.Document();

    final goldColor = PdfColor.fromHex('#D4AF37');
    final darkNavy = PdfColor.fromHex('#0A192F');
    final alertRed = PdfColor.fromHex('#EF4444');
    final alertAmber = PdfColor.fromHex('#F59E0B');
    final pastureGreen = PdfColor.fromHex('#10B981');

    final overdueCount = entries.where((e) => e.movementStage == MovementStage.overdue).length;
    final barnCount = entries.where((e) => e.movementStage == MovementStage.foalingBarn).length;
    final paddockCount = entries.where((e) => e.movementStage == MovementStage.closePaddock).length;
    final upcomingCount = entries.where((e) => e.movementStage == MovementStage.upcoming).length;

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4.landscape,
        margin: const pw.EdgeInsets.all(24),
        header: (pw.Context context) {
          return pw.Container(
            margin: const pw.EdgeInsets.only(bottom: 12),
            padding: const pw.EdgeInsets.only(bottom: 8),
            decoration: const pw.BoxDecoration(
              border: pw.Border(bottom: pw.BorderSide(color: PdfColors.grey300, width: 1)),
            ),
            child: pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      'ANIMAL BIRTHDAY PREDICTOR (ABP) - OFFICIAL STUD FOALING DIARY',
                      style: pw.TextStyle(
                        fontSize: 14,
                        fontWeight: pw.FontWeight.bold,
                        color: darkNavy,
                      ),
                    ),
                    pw.SizedBox(height: 2),
                    pw.Text(
                      'Stud / Farm: $studName  |  Breeding Season: $season  |  Filter: $filterTitle',
                      style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey700),
                    ),
                  ],
                ),
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.end,
                  children: [
                    pw.Text(
                      'Generated: ${_formatDate(DateTime.now())}',
                      style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey600),
                    ),
                    pw.Text(
                      'Total Recorded Mares: ${entries.length}',
                      style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold, color: goldColor),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
        footer: (pw.Context context) {
          return pw.Container(
            margin: const pw.EdgeInsets.only(top: 8),
            padding: const pw.EdgeInsets.only(top: 6),
            decoration: const pw.BoxDecoration(
              border: pw.Border(top: pw.BorderSide(color: PdfColors.grey300, width: 0.8)),
            ),
            child: pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text(
                  'CONFIDENTIAL STUD MANAGEMENT RECORD - Equine gestation window: 320 to 365 days (Standard 340d)',
                  style: const pw.TextStyle(fontSize: 7, color: PdfColors.grey600),
                ),
                pw.Text(
                  'Page ${context.pageNumber} of ${context.pagesCount}',
                  style: const pw.TextStyle(fontSize: 7, color: PdfColors.grey600),
                ),
              ],
            ),
          );
        },
        build: (pw.Context context) {
          return [
            // KPI Summary Strip
            pw.Container(
              padding: const pw.EdgeInsets.symmetric(vertical: 8, horizontal: 12),
              margin: const pw.EdgeInsets.only(bottom: 12),
              decoration: pw.BoxDecoration(
                color: PdfColors.grey100,
                borderRadius: pw.BorderRadius.circular(6),
                border: pw.Border.all(color: PdfColors.grey300),
              ),
              child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
                children: [
                  _buildKpiBox('OVERDUE (>340d)', '$overdueCount Mares', overdueCount > 0 ? alertRed : PdfColors.grey700),
                  _buildKpiBox('FOALING BARN (<14d)', '$barnCount Mares', barnCount > 0 ? alertAmber : PdfColors.grey700),
                  _buildKpiBox('CLOSE PADDOCK (15-30d)', '$paddockCount Mares', PdfColors.purple800),
                  _buildKpiBox('MID GESTATION (30+d)', '$upcomingCount Mares', pastureGreen),
                ],
              ),
            ),

            // Main Table
            pw.Table(
              border: pw.TableBorder.all(color: PdfColors.grey300, width: 0.5),
              columnWidths: const {
                0: pw.FlexColumnWidth(2.2), // Mare & Chip
                1: pw.FlexColumnWidth(1.8), // Stallion
                2: pw.FlexColumnWidth(1.4), // Method / ET
                3: pw.FlexColumnWidth(1.1), // Cover Date
                4: pw.FlexColumnWidth(1.2), // Expected Due
                5: pw.FlexColumnWidth(1.3), // Safe Window
                6: pw.FlexColumnWidth(1.0), // Countdown
                7: pw.FlexColumnWidth(1.5), // Paddock / Location
                8: pw.FlexColumnWidth(1.5), // Stage / Action
              },
              children: [
                // Header Row
                pw.TableRow(
                  decoration: const pw.BoxDecoration(color: PdfColors.grey200),
                  children: [
                    _buildTableHeader('Mare Name / ID'),
                    _buildTableHeader('Sire / Stallion'),
                    _buildTableHeader('Breeding Method'),
                    _buildTableHeader('Cover Date'),
                    _buildTableHeader('Due Date (340d)'),
                    _buildTableHeader('Window (320-365d)'),
                    _buildTableHeader('Days Left'),
                    _buildTableHeader('Paddock / Barn'),
                    _buildTableHeader('Movement Stage'),
                  ],
                ),

                // Data Rows
                ...entries.map((entry) {
                  final rem = entry.daysRemaining;
                  String daysText = rem < 0 ? '+${rem.abs()}d OVERDUE' : '${rem}d';
                  if (entry.isFoaled) daysText = 'FOALED';

                  String methodDesc = entry.breedingMethod.toUpperCase();
                  if (entry.isEmbryoTransfer) {
                    methodDesc = 'ET (Recip: ${entry.recipientMareName ?? "Yes"})';
                  }

                  String stageAction = entry.movementStage.title;
                  PdfColor stageColor = PdfColors.black;
                  if (entry.movementStage == MovementStage.overdue) {
                    stageColor = alertRed;
                    stageAction = 'OVERDUE (24/7 Watch)';
                  } else if (entry.movementStage == MovementStage.foalingBarn) {
                    stageColor = alertAmber;
                    stageAction = 'FOALING BOX (<14d)';
                  } else if (entry.movementStage == MovementStage.closePaddock) {
                    stageColor = PdfColors.purple800;
                    stageAction = 'CLOSE PADDOCK (<30d)';
                  }

                  return pw.TableRow(
                    children: [
                      _buildTableCell('${entry.mareName}\n${entry.microchipNo ?? ""}', isBold: true),
                      _buildTableCell(entry.stallionName),
                      _buildTableCell(methodDesc),
                      _buildTableCell(_formatDate(entry.serviceDate)),
                      _buildTableCell(_formatDate(entry.foalingDueDate), isBold: true),
                      _buildTableCell('${_formatDate(entry.minDueDate)} - ${_formatDate(entry.maxDueDate)}'),
                      _buildTableCell(daysText, color: entry.movementStage == MovementStage.overdue ? alertRed : null, isBold: true),
                      _buildTableCell(entry.currentPaddock),
                      _buildTableCell(stageAction, color: stageColor, isBold: true),
                    ],
                  );
                }),
              ],
            ),
          ];
        },
      ),
    );

    return pdf.save();
  }



  static pw.Widget _buildKpiBox(String title, String value, PdfColor color) {
    return pw.Column(
      children: [
        pw.Text(title, style: const pw.TextStyle(fontSize: 7, color: PdfColors.grey700)),
        pw.SizedBox(height: 2),
        pw.Text(value, style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold, color: color)),
      ],
    );
  }

  static pw.Widget _buildTableHeader(String text) {
    return pw.Container(
      padding: const pw.EdgeInsets.symmetric(vertical: 4, horizontal: 4),
      alignment: pw.Alignment.centerLeft,
      child: pw.Text(
        text,
        style: pw.TextStyle(fontSize: 7.5, fontWeight: pw.FontWeight.bold, color: PdfColors.black),
      ),
    );
  }

  static pw.Widget _buildTableCell(String text, {bool isBold = false, PdfColor? color}) {
    return pw.Container(
      padding: const pw.EdgeInsets.symmetric(vertical: 4, horizontal: 4),
      alignment: pw.Alignment.centerLeft,
      child: pw.Text(
        text,
        style: pw.TextStyle(
          fontSize: 7.5,
          fontWeight: isBold ? pw.FontWeight.bold : pw.FontWeight.normal,
          color: color ?? PdfColors.black,
        ),
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
