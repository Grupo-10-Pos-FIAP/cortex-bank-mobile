import 'package:cortex_bank_mobile/features/transaction/models/balance_summary.dart';
import 'package:flutter/material.dart';
import '../models/transaction.dart';
import '../data/repositories/i_transactions_repository.dart';

class TransactionsProvider extends ChangeNotifier {
  final ITransactionsRepository _repository;

  TransactionsProvider(this._repository);

  List<Transaction> _transactions = [];
  BalanceSummary? _balanceSummary;
  bool _isLoading = false;
  String? _errorMessage;

  dynamic _lastDocument;
  bool _hasMore = true;
  bool _isLoadingMore = false;
  static const int _pageSize = 20;

  /// Mais recente primeiro; empate por id (mesma regra do índice Firestore).
  void _sortTransactionsNewestFirst() {
    _transactions.sort((a, b) {
      final byDate = b.date.compareTo(a.date);
      if (byDate != 0) return byDate;
      return b.id.compareTo(a.id);
    });
  }

  List<Transaction> get transactions => List.unmodifiable(_transactions);
  BalanceSummary? get balanceSummary => _balanceSummary;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get hasMore => _hasMore;
  bool get isLoadingMore => _isLoadingMore;

  Future<void> loadTransactions() async {
    _setLoading(true);
    _errorMessage = null;

    final result = await _repository.getAll();

    result.fold(
      (success) {
        _transactions = success;
        _sortTransactionsNewestFirst();
      },
      (failure) => _errorMessage = failure.message,
    );

    _setLoading(false);
  }

  Future<void> loadTransactionsPaginated() async {
    _setLoading(true);
    _errorMessage = null;
    _lastDocument = null;
    _hasMore = true;

    final result = await _repository.getPage(_pageSize);

    result.fold(
      (page) {
        _transactions = page.items;
        _sortTransactionsNewestFirst();
        _lastDocument = page.lastDocument;
        _hasMore = page.hasMore;
      },
      (failure) => _errorMessage = failure.message,
    );

    _setLoading(false);
  }

  Future<void> loadMoreTransactions() async {
    if (_isLoadingMore || !_hasMore) return;

    _isLoadingMore = true;
    notifyListeners();

    final result = await _repository.getPage(
      _pageSize,
      startAfterDocument: _lastDocument,
    );

    result.fold(
      (page) {
        final existing = _transactions.map((t) => t.id).toSet();
        final merged = [
          ..._transactions,
          ...page.items.where((t) => !existing.contains(t.id)),
        ];
        _transactions = merged;
        _sortTransactionsNewestFirst();
        _lastDocument = page.lastDocument;
        _hasMore = page.hasMore;
      },
      (failure) => _errorMessage = failure.message,
    );

    _isLoadingMore = false;
    notifyListeners();
  }

  Future<void> loadBalanceSummary() async {
    final result = await _repository.getBalanceSummary();

    result.fold((success) {
      _balanceSummary = success;
      notifyListeners();
    }, (failure) => _errorMessage = failure.message);
  }

  Future<Transaction?> addTransaction(
    Transaction transaction, {
    bool skipBalanceRefresh = false,
  }) async {
    _setLoading(true);
    _errorMessage = null;

    final result = await _repository.add(transaction);

    Transaction? created;
    result.fold(
      (id) {
        created = transaction.copyWith(id: id);
        _transactions = [created!, ..._transactions];
        _sortTransactionsNewestFirst();
        if (!skipBalanceRefresh) {
          loadBalanceSummary();
        }
      },
      (failure) {
        _errorMessage = failure.message;
      },
    );

    _setLoading(false);
    return created;
  }

  Future<bool> updateTransaction(Transaction transaction) async {
    _setLoading(true);
    _errorMessage = null;

    final result = await _repository.update(transaction);

    final isSuccess = result.fold(
      (_) {
        final index = _transactions.indexWhere((t) => t.id == transaction.id);
        if (index != -1) {
          _transactions[index] = transaction;
          _sortTransactionsNewestFirst();
        }
        loadBalanceSummary();
        return true;
      },
      (failure) {
        _errorMessage = failure.message;
        return false;
      },
    );

    _setLoading(false);
    notifyListeners();
    return isSuccess;
  }

  Future<Transaction?> uploadReceipt(
    Transaction transaction,
    List<int> fileBytes,
    String fileName,
  ) async {
    final result = await _repository.uploadReceipt(
      transaction,
      fileBytes,
      fileName,
    );
    return result.fold(
      (updated) {
        final index = _transactions.indexWhere((t) => t.id == updated.id);
        if (index != -1) _transactions[index] = updated;
        notifyListeners();
        return updated;
      },
      (failure) {
        _errorMessage = failure.message;
        notifyListeners();
        return null;
      },
    );
  }

  Future<Transaction?> uploadReceipts(
    Transaction transaction,
    List<({List<int> bytes, String name})> attachments,
  ) async {
    if (attachments.isEmpty) return transaction;
    final result = await _repository.uploadReceipts(transaction, attachments);
    return result.fold(
      (updated) {
        final index = _transactions.indexWhere((t) => t.id == updated.id);
        if (index != -1) _transactions[index] = updated;
        notifyListeners();
        return updated;
      },
      (failure) {
        _errorMessage = failure.message;
        notifyListeners();
        return null;
      },
    );
  }

  Future<void> deleteTransaction(String id) async {
    _setLoading(true);
    final result = await _repository.delete(id);

    result.fold((_) {
      _transactions.removeWhere((t) => t.id == id);
      loadBalanceSummary();
    }, (failure) => _errorMessage = failure.message);

    _setLoading(false);
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
