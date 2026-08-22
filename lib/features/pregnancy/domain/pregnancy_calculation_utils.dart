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
  required String method, // 'natural', 'chilled', 'frozen', 'et', 'icsi'
  required DateTime baseDate, // Insemination date if donor mare, or transfer date (Day 7) if recipient mare
}) {
  final cleanMethod = method.toLowerCase().trim();
  final cleanCarrier = carrierType?.toLowerCase().trim() ?? '';
  final isET = isEmbryoTransfer || cleanCarrier == 'recipient_mare' || cleanMethod == 'et' || cleanMethod == 'icsi';

  if (isET) {
    // Embryo Transfer / Recipient Mare calculation
    // Transfer occurs at Day 7 post-cover/ovulation.
    // Scan 1 is at 7 days post-transfer (Day 14 post-ovulation)
    // Scan 2 is at 23 days post-transfer (Day 30 post-ovulation)
    // Scan 3 is at 38 days post-transfer (Day 45 post-ovulation)
    // Foaling due is 334 days post-transfer (341 - 7 = 334d for standard gestation; 333d for frozen/icsi)
    final isFrozenMethod = cleanMethod == 'frozen' || cleanMethod == 'icsi';
    final gestationDaysPostTransfer = isFrozenMethod ? 333 : 334;

    return CalculatedPregnancyDates(
      scan1DueDate: baseDate.add(const Duration(days: 7)),
      scan2DueDate: baseDate.add(const Duration(days: 23)),
      scan3DueDate: baseDate.add(const Duration(days: 38)),
      foalingDueDate: baseDate.add(Duration(days: gestationDaysPostTransfer)),
    );
  }

  // Donor Mare Frozen calculations (340 days, 1 day shorter than natural 341 days)
  if (cleanMethod == 'frozen') {
    return CalculatedPregnancyDates(
      scan1DueDate: baseDate.add(const Duration(days: 14)),
      scan2DueDate: baseDate.add(const Duration(days: 30)),
      scan3DueDate: baseDate.add(const Duration(days: 45)),
      foalingDueDate: baseDate.add(const Duration(days: 340)),
    );
  }

  // Natural / Chilled calculations (341 days)
  return CalculatedPregnancyDates(
    scan1DueDate: baseDate.add(const Duration(days: 14)),
    scan2DueDate: baseDate.add(const Duration(days: 30)),
    scan3DueDate: baseDate.add(const Duration(days: 45)),
    foalingDueDate: baseDate.add(const Duration(days: 341)),
  );
}
