import 'package:cortex_bank_mobile/features/transaction/domain/entities/balance_summary.dart';
import 'package:cortex_bank_mobile/features/transaction/domain/entities/transaction.dart';
import 'package:cortex_bank_mobile/features/transaction/domain/pagination/transaction_page.dart';
import 'package:cortex_bank_mobile/features/transaction/domain/pagination/transaction_page_cursor.dart';
import 'package:cortex_bank_mobile/features/transaction/domain/statement/statement_filter_criteria.dart';

abstract class TransactionsDataSource {
  Future<String> add(Transaction transaction);
  Future<List<Transaction>> getAll();
  Future<void> update(Transaction transaction);
  Future<void> delete(String id);
  Future<BalanceSummary> getBalanceSummary();

  Future<TransactionPage> getPage(
    int limit, {
    TransactionPageCursor? startAfterCursor,
    StatementFilterCriteria? criteria,
  });
}
