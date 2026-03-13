import 'package:cortex_bank_mobile/features/transaction/models/balance_summary.dart';
import 'package:cortex_bank_mobile/features/transaction/models/transaction.dart';

abstract class TransactionsDataSource {
  Future<String> add(Transaction transaction);
  Future<List<Transaction>> getAll();
  Future<void> delete(String id);
  Future<BalanceSummary> getBalanceSummary();
}
