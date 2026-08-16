/// Class representing calculated pregnancy scan and foaling dates
class CalculatedPregnancyDates {
  final DateTime scan1DueDate;
  final DateTime scan2DueDate;
  final DateTime scan3DueDate;
  final DateTime foalingDueDate;

  const CalculatedPregnancyDates({
    required this.scan1DueDate,
    required this.scan2DueDate,
    required this.scan3DueDate,
    required this.foalingDueDate,
  });
}

/// Pure function to calculate pregnancy scan due dates and foaling due date
/// based on carrier role, breeding method, and base cover/transfer date.
///
/// Rules from Section 4 of ABP Master Documentation:
/// - Natural / Chilled (no ET): Scan 1 = +14d, Scan 2 = +30d, Scan 3 = +45d, Foaling Due = +341d
/// - Frozen (no ET): Scan 1 = +14d, Scan 2 = +30d, Scan 3 = +45d, Foaling Due = +340d
/// - Embryo Transfer / ICSI (Recipient Mare): Scan 1 = +7d, Scan 2 = +30d, Scan 3 = +45d, Foaling Due = +332d
CalculatedPregnancyDates calculatePregnancyDates({
  bool isEmbryoTransfer = false,
  String? carrierType,
  required String method, // 'natural', 'chilled', 'frozen', 'icsi'
  required DateTime baseDate,
}) {
  final cleanMethod = method.toLowerCase().trim();
  final cleanCarrier = carrierType?.toLowerCase().trim() ?? '';
  final isET = isEmbryoTransfer || cleanCarrier == 'recipient_mare' || cleanMethod == 'icsi';

  if (isET) {
    // Embryo Transfer / Recipient Mare / ICSI calculation
    return CalculatedPregnancyDates(
      scan1DueDate: baseDate.add(const Duration(days: 7)),
      scan2DueDate: baseDate.add(const Duration(days: 30)),
      scan3DueDate: baseDate.add(const Duration(days: 45)),
      foalingDueDate: baseDate.add(const Duration(days: 332)),
    );
  }

  // Donor Mare Frozen calculations
  if (cleanMethod == 'frozen') {
    return CalculatedPregnancyDates(
      scan1DueDate: baseDate.add(const Duration(days: 14)),
      scan2DueDate: baseDate.add(const Duration(days: 30)),
      scan3DueDate: baseDate.add(const Duration(days: 45)),
      foalingDueDate: baseDate.add(const Duration(days: 340)), // Frozen is 340 days
    );
  }

  // Natural / Chilled calculations
  return CalculatedPregnancyDates(
    scan1DueDate: baseDate.add(const Duration(days: 14)),
    scan2DueDate: baseDate.add(const Duration(days: 30)),
    scan3DueDate: baseDate.add(const Duration(days: 45)),
    foalingDueDate: baseDate.add(const Duration(days: 341)), // Natural/Chilled is 341 days
  );
}
