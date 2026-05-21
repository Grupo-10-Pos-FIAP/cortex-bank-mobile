import 'package:cortex_bank_mobile/features/transaction/constants/transaction_date_policy.dart';
import 'package:cortex_bank_mobile/features/transaction/domain/entities/transaction.dart';

class BalanceSummary {
  const BalanceSummary({
    required this.totalIncomeCents,
    required this.totalExpenseCents,
    required this.balanceCents,
  });

  final int totalIncomeCents;
  final int totalExpenseCents;
  final int balanceCents;

  /// Mesma regra de [TransactionsDataSourceFirestore.getBalanceSummary].
  static BalanceSummary fromTransactions(
    Iterable<Transaction> transactions, {
    DateTime? asOf,
  }) {
    var incomeCents = 0;
    var expenseCents = 0;

    for (final t in transactions) {
      final cents = (t.value.abs() * 100).round();

      if (t.type == TransactionType.credit) {
        if (TransactionDatePolicy.transactionAffectsBalanceNow(
          t,
          asOf: asOf,
        )) {
          incomeCents += cents;
        }
      } else if (t.type == TransactionType.debit ||
          t.type == TransactionType.ted) {
        if (TransactionDatePolicy.transactionAffectsBalanceNow(
          t,
          asOf: asOf,
        )) {
          expenseCents += cents;
        }
      }
    }

    return BalanceSummary(
      totalIncomeCents: incomeCents,
      totalExpenseCents: expenseCents,
      balanceCents: incomeCents - expenseCents,
    );
  }
}
