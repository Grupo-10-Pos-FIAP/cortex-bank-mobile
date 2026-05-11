import 'package:cortex_bank_mobile/features/transaction/domain/entities/balance_summary.dart';
import 'package:cortex_bank_mobile/features/transaction/domain/entities/transaction.dart';

final DateTime kDefaultTxDate = DateTime(2024, 5, 1);

Transaction buildTransaction({
  String id = 't1',
  String accountId = 'acc',
  TransactionType type = TransactionType.debit,
  double value = 100,
  DateTime? date,
  String? to,
  String? from,
  String status = TransactionStatus.completed,
  TransactionCategory category = TransactionCategory.others,
  String? description,
  List<String>? receiptUrls,
}) {
  return Transaction(
    id: id,
    accountId: accountId,
    type: type,
    value: value,
    date: date ?? kDefaultTxDate,
    to: to,
    from: from,
    status: status,
    category: category,
    description: description,
    receiptUrls: receiptUrls,
  );
}

BalanceSummary buildBalanceSummary({
  int totalIncomeCents = 0,
  int totalExpenseCents = 0,
  int balanceCents = 0,
}) {
  return BalanceSummary(
    totalIncomeCents: totalIncomeCents,
    totalExpenseCents: totalExpenseCents,
    balanceCents: balanceCents,
  );
}
