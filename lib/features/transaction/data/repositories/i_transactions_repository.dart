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

  /// Retorna uma página de transações com paginação por cursor.
  Future<Result<TransactionPage>> getPage(
    int limit, {
    dynamic startAfterDocument,
  });

  /// Faz upload de um recibo/documento da transação e atualiza a transação com a URL.
  Future<Result<Transaction>> uploadReceipt(
    Transaction transaction,
    List<int> fileBytes,
    String fileName,
  );
}
