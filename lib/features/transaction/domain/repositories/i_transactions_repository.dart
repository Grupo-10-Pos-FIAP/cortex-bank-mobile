import 'package:cortex_bank_mobile/core/utils/result.dart';
import 'package:cortex_bank_mobile/features/transaction/domain/entities/balance_summary.dart';
import 'package:cortex_bank_mobile/features/transaction/domain/entities/transaction.dart';
import 'package:cortex_bank_mobile/features/transaction/domain/pagination/transaction_page.dart';
import 'package:cortex_bank_mobile/features/transaction/domain/pagination/transaction_page_cursor.dart';
import 'package:cortex_bank_mobile/features/transaction/domain/statement/statement_filter_criteria.dart';

abstract class ITransactionsRepository {
  Future<Result<String>> add(Transaction transaction);
  Future<Result<List<Transaction>>> getAll();
  Future<Result<void>> update(Transaction transaction);
  Future<Result<void>> delete(String id);
  Future<Result<BalanceSummary>> getBalanceSummary();

  Future<Result<TransactionPage>> getPage(
    int limit, {
    TransactionPageCursor? startAfterCursor,
    StatementFilterCriteria? criteria,
  });

  Future<Result<Transaction>> uploadReceipt(
    Transaction transaction,
    List<int> fileBytes,
    String fileName,
  );

  Future<Result<Transaction>> uploadReceipts(
    Transaction transaction,
    List<({List<int> bytes, String name})> attachments,
  );
}
