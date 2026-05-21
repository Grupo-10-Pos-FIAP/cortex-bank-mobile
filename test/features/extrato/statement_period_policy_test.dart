import 'package:cortex_bank_mobile/features/extrato/constants/statement_period_policy.dart';
import 'package:cortex_bank_mobile/features/transaction/constants/transaction_date_policy.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('StatementPeriodPolicy', () {
    test('earliestSelectableStart deve ser hoje menos 89 dias', () {
      final today = TransactionDatePolicy.today;
      final earliest = StatementPeriodPolicy.earliestSelectableStart;
      final expected = today.subtract(
        const Duration(days: StatementPeriodPolicy.maxDaysBeforeToday),
      );
      expect(
        StatementPeriodPolicy.dateOnly(earliest),
        StatementPeriodPolicy.dateOnly(expected),
      );
      expect(
        StatementPeriodPolicy.inclusiveDayCount(earliest, today),
        StatementPeriodPolicy.maxInclusiveDays,
      );
    });

    test('isValidRange deve rejeitar intervalo maior que 90 dias', () {
      final today = StatementPeriodPolicy.today;
      final start = today.subtract(const Duration(days: 90));
      expect(
        StatementPeriodPolicy.isValidRange(
          DateTime(start.year, start.month, start.day),
          today,
        ),
        isFalse,
      );
    });

    test('isValidRange deve rejeitar data final após hoje', () {
      final tomorrow = StatementPeriodPolicy.today.add(const Duration(days: 1));
      expect(
        StatementPeriodPolicy.isValidRange(
          StatementPeriodPolicy.today,
          tomorrow,
        ),
        isFalse,
      );
    });

    test('maxEndDayForStart deve limitar a 90 dias corridos', () {
      final start = StatementPeriodPolicy.earliestSelectableStart;
      final maxEnd = StatementPeriodPolicy.maxEndDayForStart(start);
      expect(
        StatementPeriodPolicy.dateOnly(maxEnd),
        StatementPeriodPolicy.today,
      );
    });

    test('isValidRange deve aceitar intervalo no passado sem fim em hoje', () {
      final today = StatementPeriodPolicy.today;
      final start = today.subtract(const Duration(days: 40));
      final end = today.subtract(const Duration(days: 10));
      expect(
        StatementPeriodPolicy.isValidRange(
          DateTime(start.year, start.month, start.day),
          StatementPeriodPolicy.endOfDay(end),
        ),
        isTrue,
      );
    });

    test('isValidRange deve rejeitar início antes da janela de 90 dias', () {
      final tooOld = StatementPeriodPolicy.today.subtract(
        const Duration(days: 100),
      );
      expect(
        StatementPeriodPolicy.isValidRange(
          DateTime(tooOld.year, tooOld.month, tooOld.day),
          StatementPeriodPolicy.lastSelectableEnd,
        ),
        isFalse,
      );
    });
  });
}
