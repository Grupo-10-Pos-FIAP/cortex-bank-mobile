import 'package:cortex_bank_mobile/features/transaction/constants/transaction_date_policy.dart';
import 'package:cortex_bank_mobile/features/transaction/domain/entities/balance_summary.dart';
import 'package:cortex_bank_mobile/features/transaction/domain/entities/transaction.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/factories/transaction_factory.dart';

void main() {
  group('BalanceSummary.fromTransactions', () {
    test('deve somar créditos e débitos que afetam saldo agora', () {
      final summary = BalanceSummary.fromTransactions([
        buildTransaction(
          id: '1',
          type: TransactionType.credit,
          value: 100,
          status: TransactionStatus.completed,
        ),
        buildTransaction(
          id: '2',
          type: TransactionType.debit,
          value: 30,
          status: TransactionStatus.completed,
        ),
      ]);

      expect(summary.totalIncomeCents, 10000);
      expect(summary.totalExpenseCents, 3000);
      expect(summary.balanceCents, 7000);
    });

    test('deve ignorar agendada com data futura', () {
      final future = TransactionDatePolicy.maxSelectableDate;
      final summary = BalanceSummary.fromTransactions([
        buildTransaction(
          id: '1',
          type: TransactionType.debit,
          value: 50,
          date: future,
          status: TransactionStatus.scheduled,
        ),
      ]);

      expect(summary.balanceCents, 0);
    });

    test('deve ignorar pendente', () {
      final summary = BalanceSummary.fromTransactions([
        buildTransaction(
          id: '1',
          type: TransactionType.credit,
          value: 80,
          status: TransactionStatus.pending,
        ),
      ]);

      expect(summary.balanceCents, 0);
    });
  });
}
