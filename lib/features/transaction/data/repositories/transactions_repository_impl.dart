import 'package:cortex_bank_mobile/core/models/balance_summary.dart';
import 'package:cortex_bank_mobile/core/models/transaction.dart';
import 'package:cortex_bank_mobile/core/utils/failure.dart';
import 'package:cortex_bank_mobile/core/utils/result.dart';
import 'package:cortex_bank_mobile/features/transaction/data/datasources/transactions_datasource.dart';
import 'package:cortex_bank_mobile/features/transaction/data/repositories/i_transactions_repository.dart';

class TransactionsRepositoryImpl implements ITransactionsRepository {
  TransactionsRepositoryImpl(this._dataSource);

  final TransactionsDataSource _dataSource;

  @override
  Future<Result<void>> add(Transaction transaction) async {
    try {
      await _dataSource.add(transaction);
      return const Success(null);
    } catch (e) {
      return FailureResult(Failure(message: e.toString()));
    }
  }

  @override
  Future<Result<List<Transaction>>> getAll() async {
    try {
      final list = await _dataSource.getAll();
      return Success(list);
    } catch (e) {
      return FailureResult(Failure(message: e.toString()));
    }
  }

  @override
  Future<Result<void>> delete(String id) async {
    try {
      await _dataSource.delete(id);
      return const Success(null);
    } catch (e) {
      return FailureResult(Failure(message: e.toString()));
    }
  }

  @override
  Future<Result<BalanceSummary>> getBalanceSummary() async {
    try {
      final summary = await _dataSource.getBalanceSummary();
      return Success(summary);
    } catch (e) {
      return FailureResult(Failure(message: e.toString()));
    }
  }
}
