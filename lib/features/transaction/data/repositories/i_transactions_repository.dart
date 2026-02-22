import 'package:cortex_bank_mobile/features/transaction/models/balance_summary.dart';
import 'package:cortex_bank_mobile/features/transaction/models/transaction.dart';
import 'package:cortex_bank_mobile/core/utils/result.dart';

abstract class ITransactionsRepository {
  Future<Result<void>> add(Transaction transaction);
  Future<Result<List<Transaction>>> getAll();
  Future<Result<void>> delete(String id);
  Future<Result<BalanceSummary>> getBalanceSummary();
}
