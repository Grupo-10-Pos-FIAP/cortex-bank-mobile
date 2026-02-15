import 'package:cortex_bank_mobile/core/models/balance_summary.dart';
import 'package:cortex_bank_mobile/core/models/transaction.dart';

abstract class TransactionsDataSource {
  Future<void> add(Transaction transaction);
  Future<List<Transaction>> getAll();
  Future<void> delete(String id);
  Future<BalanceSummary> getBalanceSummary();
}
