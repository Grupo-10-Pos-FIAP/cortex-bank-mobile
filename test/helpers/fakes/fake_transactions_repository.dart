import 'dart:async';

import 'package:cortex_bank_mobile/core/utils/result.dart';
import 'package:cortex_bank_mobile/features/extrato/statement_filter.dart';
import 'package:cortex_bank_mobile/features/transaction/data/datasources/transactions_datasource.dart'
    show TransactionPage;
import 'package:cortex_bank_mobile/features/transaction/data/repositories/i_transactions_repository.dart';
import 'package:cortex_bank_mobile/features/transaction/models/balance_summary.dart';
import 'package:cortex_bank_mobile/features/transaction/models/transaction.dart';

import 'fake_transactions_timeline_mirror.dart';

class FakeTransactionsRepository implements ITransactionsRepository {
  bool mirrorTimelineInMemory = false;

  final FakeTransactionsTimelineMirror _timeline =
      FakeTransactionsTimelineMirror();

  Result<List<Transaction>>? getAllResult;
  Result<TransactionPage>? getPageResult;
  Result<TransactionPage>? getPageNextResult;
  Result<String>? addResult;
  Result<void>? deleteResult;
  Result<void>? updateResult;
  Result<BalanceSummary>? getBalanceSummaryResult;
  Result<Transaction>? uploadReceiptResult;
  Result<Transaction>? uploadReceiptsResult;

  Completer<Result<TransactionPage>>? getPageCompleter;
  Completer<Result<List<Transaction>>>? getAllCompleter;
  Completer<Result<BalanceSummary>>? getBalanceSummaryCompleter;

  int getAllCalls = 0;
  int getPageCalls = 0;
  int addCalls = 0;
  int updateCalls = 0;
  int deleteCalls = 0;
  int getBalanceSummaryCalls = 0;
  int uploadReceiptCalls = 0;
  int uploadReceiptsCalls = 0;

  Object? lastStartAfterDocument;
  StatementFilterCriteria? lastGetPageCriteria;
  Transaction? lastAdded;
  Transaction? lastUpdated;
  String? lastDeletedId;

  @override
  Future<Result<String>> add(Transaction transaction) async {
    addCalls += 1;
    lastAdded = transaction;
    final configured = addResult ?? const Success('id-1');
    return configured.fold((id) async {
      if (mirrorTimelineInMemory) {
        _timeline.mirrorAdd(id, transaction);
      }
      return Success(id);
    }, (failure) async => FailureResult<String>(failure));
  }

  @override
  Future<Result<void>> delete(String id) async {
    deleteCalls += 1;
    lastDeletedId = id;
    final configured = deleteResult ?? const Success(null);
    return configured.fold((_) async {
      if (mirrorTimelineInMemory) {
        _timeline.mirrorDelete(id);
      }
      return const Success(null);
    }, (failure) async => FailureResult<void>(failure));
  }

  @override
  Future<Result<List<Transaction>>> getAll() async {
    getAllCalls += 1;
    if (getAllCompleter != null) return getAllCompleter!.future;
    if (mirrorTimelineInMemory) {
      return _timeline.snapshotAsSuccess();
    }
    return getAllResult ?? Success(<Transaction>[]);
  }

  @override
  Future<Result<BalanceSummary>> getBalanceSummary() async {
    getBalanceSummaryCalls += 1;
    if (getBalanceSummaryCompleter != null) {
      return getBalanceSummaryCompleter!.future;
    }
    return getBalanceSummaryResult ??
        const Success(
          BalanceSummary(
            totalIncomeCents: 0,
            totalExpenseCents: 0,
            balanceCents: 0,
          ),
        );
  }

  @override
  Future<Result<TransactionPage>> getPage(
    int limit, {
    dynamic startAfterDocument,
    StatementFilterCriteria? criteria,
  }) async {
    getPageCalls += 1;
    lastStartAfterDocument = startAfterDocument;
    lastGetPageCriteria = criteria;
    if (getPageCompleter != null) return getPageCompleter!.future;

    if (mirrorTimelineInMemory) {
      return _timeline.getPage(limit, startAfterDocument: startAfterDocument);
    }

    if (startAfterDocument == null) {
      return getPageResult ??
          Success(TransactionPage(items: <Transaction>[], hasMore: false));
    }
    return getPageNextResult ??
        Success(TransactionPage(items: <Transaction>[], hasMore: false));
  }

  @override
  Future<Result<void>> update(Transaction transaction) async {
    updateCalls += 1;
    lastUpdated = transaction;
    return updateResult ?? const Success(null);
  }

  @override
  Future<Result<Transaction>> uploadReceipt(
    Transaction transaction,
    List<int> fileBytes,
    String fileName,
  ) async {
    uploadReceiptCalls += 1;
    return uploadReceiptResult ?? Success<Transaction>(transaction);
  }

  @override
  Future<Result<Transaction>> uploadReceipts(
    Transaction transaction,
    List<({List<int> bytes, String name})> attachments,
  ) async {
    uploadReceiptsCalls += 1;
    return uploadReceiptsResult ?? Success<Transaction>(transaction);
  }
}
