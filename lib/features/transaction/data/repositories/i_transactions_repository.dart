import 'package:cortex_bank_mobile/features/transaction/data/datasources/transactions_datasource.dart';
import 'package:cortex_bank_mobile/features/transaction/models/balance_summary.dart';
import 'package:cortex_bank_mobile/features/transaction/models/transaction.dart';
import 'package:cortex_bank_mobile/core/utils/result.dart';

abstract class ITransactionsRepository {
  Future<Result<String>> add(Transaction transaction);
  Future<Result<List<Transaction>>> getAll();
  Future<Result<void>> update(Transaction transaction);
  Future<Result<void>> delete(String id);
  Future<Result<BalanceSummary>> getBalanceSummary();

  Future<Result<TransactionPage>> getPage(
    int limit, {
    dynamic startAfterDocument,
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
