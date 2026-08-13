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
/// based on carrier type, breeding method, and base cover/transfer date.
CalculatedPregnancyDates calculatePregnancyDates({
  required String carrierType, // 'mare' or 'recipient_mare'
  required String method, // 'natural', 'chilled', 'frozen', 'icsi'
  required DateTime baseDate,
}) {
  final cleanCarrier = carrierType.toLowerCase().trim();
  final cleanMethod = method.toLowerCase().trim();

  if (cleanCarrier == 'recipient_mare' || cleanMethod == 'icsi') {
    // Embryo Transfer / Recipient Mare / ICSI calculation
    return CalculatedPregnancyDates(
      scan1DueDate: baseDate.add(const Duration(days: 7)),
      scan2DueDate: baseDate.add(const Duration(days: 30)),
      scan3DueDate: baseDate.add(const Duration(days: 45)),
      foalingDueDate: baseDate.add(const Duration(days: 332)),
    );
  }

  // Donor Mare calculations
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
