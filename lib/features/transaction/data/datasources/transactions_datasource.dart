import 'package:cortex_bank_mobile/features/transaction/models/balance_summary.dart';
import 'package:cortex_bank_mobile/features/transaction/models/transaction.dart';

class TransactionPage {
  final List<Transaction> items;
  final bool hasMore;
  final dynamic lastDocument;

  const TransactionPage({
    required this.items,
    required this.hasMore,
    this.lastDocument,
  });
}

abstract class TransactionsDataSource {
  Future<String> add(Transaction transaction);
  Future<List<Transaction>> getAll();
  Future<void> update(Transaction transaction);
  Future<void> delete(String id);
  Future<BalanceSummary> getBalanceSummary();

  Future<TransactionPage> getPage(int limit, {dynamic startAfterDocument});
}
