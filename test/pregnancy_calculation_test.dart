import 'package:flutter_test/flutter_test.dart';
import 'package:animal_birthday_predictor/features/pregnancy/domain/pregnancy_calculation_utils.dart';

void main() {
  group('Pregnancy Date Calculation Tests', () {
    final baseDate = DateTime(2026, 1, 1);

    test('Natural breeding for donor mare (+14, +30, +45, +341 days)', () {
      final res = calculatePregnancyDates(
        carrierType: 'mare',
        method: 'natural',
        baseDate: baseDate,
      );

      expect(res.scan1DueDate, DateTime(2026, 1, 15));
      expect(res.scan2DueDate, DateTime(2026, 1, 31));
      expect(res.scan3DueDate, DateTime(2026, 2, 15));
      expect(res.foalingDueDate, baseDate.add(const Duration(days: 341)));
    });

    test('Chilled breeding for donor mare (+14, +30, +45, +341 days)', () {
      final res = calculatePregnancyDates(
        carrierType: 'mare',
        method: 'chilled',
        baseDate: baseDate,
      );

      expect(res.scan1DueDate, DateTime(2026, 1, 15));
      expect(res.scan2DueDate, DateTime(2026, 1, 31));
      expect(res.scan3DueDate, DateTime(2026, 2, 15));
      expect(res.foalingDueDate, baseDate.add(const Duration(days: 341)));
    });

    test('Frozen breeding for donor mare (+14, +30, +45, +340 days)', () {
      final res = calculatePregnancyDates(
        carrierType: 'mare',
        method: 'frozen',
        baseDate: baseDate,
      );

      expect(res.scan1DueDate, DateTime(2026, 1, 15));
      expect(res.scan2DueDate, DateTime(2026, 1, 31));
      expect(res.scan3DueDate, DateTime(2026, 2, 15));
      expect(res.foalingDueDate, baseDate.add(const Duration(days: 340))); // 340 days
    });

    test('Embryo Transfer for recipient mare (+7, +23, +38, +334 days post-transfer)', () {
      final res = calculatePregnancyDates(
        carrierType: 'recipient_mare',
        method: 'chilled',
        baseDate: baseDate,
      );

      expect(res.scan1DueDate, DateTime(2026, 1, 8)); // +7d (Day 14 post-ovulation)
      expect(res.scan2DueDate, DateTime(2026, 1, 24)); // +23d (Day 30 post-ovulation)
      expect(res.scan3DueDate, DateTime(2026, 2, 8)); // +38d (Day 45 post-ovulation)
      expect(res.foalingDueDate, baseDate.add(const Duration(days: 334)));
    });

    test('ICSI breeding (+7, +23, +38, +333 days post-transfer)', () {
      final res = calculatePregnancyDates(
        carrierType: 'recipient_mare',
        method: 'icsi',
        baseDate: baseDate,
      );

      expect(res.scan1DueDate, DateTime(2026, 1, 8)); // +7d (Day 14 post-ovulation)
      expect(res.scan2DueDate, DateTime(2026, 1, 24)); // +23d (Day 30 post-ovulation)
      expect(res.scan3DueDate, DateTime(2026, 2, 8)); // +38d (Day 45 post-ovulation)
      expect(res.foalingDueDate, baseDate.add(const Duration(days: 333)));
    });
  });
}

