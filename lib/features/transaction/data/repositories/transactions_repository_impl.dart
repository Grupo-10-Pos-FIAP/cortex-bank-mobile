import 'package:cortex_bank_mobile/core/errors/failure.dart';
import 'package:cortex_bank_mobile/core/utils/firebase_user_error_message.dart';
import 'package:cortex_bank_mobile/core/utils/result.dart';
import 'package:cortex_bank_mobile/core/utils/safe_log.dart';
import 'package:cortex_bank_mobile/features/transaction/constants/transaction_schedule_copy.dart';
import 'package:cortex_bank_mobile/features/transaction/data/datasources/receipt_storage_datasource.dart';
import 'package:cortex_bank_mobile/features/transaction/data/datasources/transactions_datasource.dart'
    show TransactionsDataSource, TransactionPage;
import 'package:cortex_bank_mobile/features/transaction/data/repositories/i_transactions_repository.dart';
import 'package:cortex_bank_mobile/features/transaction/models/balance_summary.dart';
import 'package:cortex_bank_mobile/features/transaction/models/transaction.dart';

class TransactionsRepositoryImpl implements ITransactionsRepository {
  TransactionsRepositoryImpl(this._dataSource, this._receiptStorage);

  final TransactionsDataSource _dataSource;
  final ReceiptStorageDataSource _receiptStorage;

  @override
  Future<Result<String>> add(Transaction transaction) async {
    try {
      final id = await _dataSource.add(transaction);
      return Success(id);
    } catch (e) {
      safeLogError('Erro ao adicionar transação', e);
      return FailureResult(
        Failure(
          message: firebaseErrorUserMessage(
            e,
            fallback: TransactionScheduleCopy.errorSubmitFallbackImmediate,
          ),
        ),
      );
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
  Future<Result<TransactionPage>> getPage(
    int limit, {
    dynamic startAfterDocument,
  }) async {
    try {
      final page = await _dataSource.getPage(
        limit,
        startAfterDocument: startAfterDocument,
      );
      return Success(page);
    } catch (e) {
      safeLogError('Erro ao carregar página de transações', e);
      return FailureResult(Failure(message: 'Erro ao carregar transações'));
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

  @override
  Future<Result<Transaction>> uploadReceipt(
    Transaction transaction,
    List<int> fileBytes,
    String fileName,
  ) async {
    try {
      final url = await _receiptStorage.uploadReceipt(
        transaction.id,
        fileBytes,
        fileName,
      );
      final updated = transaction.copyWith(
        receiptUrls: [...transaction.receiptUrls, url],
      );
      await _dataSource.update(updated);
      return Success(updated);
    } catch (e) {
      safeLogError('Erro ao enviar recibo', e);
      return FailureResult(
        Failure(
          message: firebaseErrorUserMessage(
            e,
            fallback:
                'Não foi possível enviar o recibo. Tente novamente ou anexe pelo extrato.',
          ),
        ),
      );
    }
  }
}
