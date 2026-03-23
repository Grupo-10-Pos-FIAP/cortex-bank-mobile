import 'package:cortex_bank_mobile/features/transaction/constants/transaction_date_policy.dart';
import 'package:cortex_bank_mobile/features/transaction/models/transaction.dart';

/// Normaliza o status persistido para exibição/regras do app na leitura (legado / inconsistências).
String normalizeTransactionStatusForRead(
  String storedStatus,
  DateTime transactionDate,
) {
  var status = storedStatus;
  if (status == TransactionStatus.pending &&
      TransactionDatePolicy.isStrictlyAfterToday(transactionDate)) {
    status = TransactionStatus.scheduled;
  }
  if (status == TransactionStatus.completed &&
      TransactionDatePolicy.isStrictlyAfterToday(transactionDate)) {
    status = TransactionStatus.scheduled;
  }
  if (status == TransactionStatus.scheduled &&
      !TransactionDatePolicy.isStrictlyAfterToday(transactionDate)) {
    status = TransactionStatus.completed;
  }
  return status;
}
