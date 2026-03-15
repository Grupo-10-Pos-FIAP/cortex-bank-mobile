import 'package:cortex_bank_mobile/core/utils/safe_log.dart';
import 'package:cortex_bank_mobile/features/transaction/models/balance_summary.dart';
import 'package:cortex_bank_mobile/features/transaction/models/transaction.dart';
import 'package:cortex_bank_mobile/core/errors/failure.dart';
import 'package:cortex_bank_mobile/core/utils/result.dart';
import 'package:cortex_bank_mobile/features/transaction/data/datasources/transactions_datasource.dart';
import 'package:cortex_bank_mobile/features/transaction/data/repositories/i_transactions_repository.dart';

class TransactionsRepositoryImpl implements ITransactionsRepository {
  final TransactionsDataSource _dataSource;
  TransactionsRepositoryImpl(this._dataSource);

  @override
  Future<Result<String>> add(Transaction transaction) async {
    try {
      final id = await _dataSource.add(transaction);
      return Success(id);
    } catch (e) {
      safeLogError('Erro ao adicionar transação', e);
      return FailureResult(Failure(message: 'Erro ao processar transação'));
    }
  }

  @override
  Future<Result<List<Transaction>>> getAll() async {
    try {
      final list = await _dataSource.getAll();
      return Success(list);
    } catch (e) {
      safeLogError('Erro ao obter extrato', e);
      return FailureResult(Failure(message: 'Erro ao carregar extrato'));
    }
  }

  @override
  Future<Result<void>> update(Transaction transaction) async {
    try {
      await _dataSource.update(transaction);
      return const Success(null);
    } catch (e) {
      safeLogError('Erro ao editar transação', e);
      return FailureResult(Failure(message: 'Erro ao salvar alterações'));
    }
  }


  @override
  Future<Result<void>> delete(String id) async {
    try {
      await _dataSource.delete(id);
      return const Success(null);
    } catch (e) {
      safeLogError('Erro ao deletar transação', e);
      return FailureResult(Failure(message: 'Erro ao remover item'));
    }
  }

    @override
  Future<Result<BalanceSummary>> getBalanceSummary() async {
    try {
      final summary = await _dataSource.getBalanceSummary();
      return Success(summary);
    } catch (e) {
      safeLogError('Erro ao calcular resumo de saldo', e);
      return FailureResult(Failure(message: 'Erro ao carregar saldo'));
    }
  }

}
