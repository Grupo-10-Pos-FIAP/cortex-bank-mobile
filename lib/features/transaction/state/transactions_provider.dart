import 'package:cortex_bank_mobile/features/extrato/statement_filter.dart';
import 'package:cortex_bank_mobile/features/transaction/models/balance_summary.dart';
import 'package:cortex_bank_mobile/core/cache/cache_manager.dart';
import 'package:flutter/material.dart';
import '../models/transaction.dart';
import '../data/repositories/i_transactions_repository.dart';

class TransactionsProvider extends ChangeNotifier {
  static const _transactionsCacheKey = 'transactions_provider.transactions';
  static const _balanceSummaryCacheKey =
      'transactions_provider.balance_summary';
  static const _transactionsCacheTtl = Duration(minutes: 2);
  static const _balanceSummaryCacheTtl = Duration(seconds: 30);

  final ITransactionsRepository _repository;

  TransactionsProvider(this._repository);

  bool _disposed = false;

  void _safeNotifyListeners() {
    if (_disposed) return;
    notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }

  List<Transaction> _transactions = [];
  BalanceSummary? _balanceSummary;
  bool _isLoading = false;
  String? _transactionsError;
  String? _balanceSummaryError;
  bool _isBalanceSummaryLoading = false;

  dynamic _lastDocument;
  bool _hasMore = true;
  bool _isLoadingMore = false;
  static const int _pageSize = 20;

  /// Critérios atualmente aplicados na paginação server-side.
  StatementFilterCriteria? _currentFilterCriteria;

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

  /// Falhas em lista, paginação, CRUD e anexos de transação.
  String? get transactionsError => _transactionsError;

  /// Falhas apenas em [loadBalanceSummary] (independente da lista).
  String? get balanceSummaryError => _balanceSummaryError;

  /// `true` enquanto [getBalanceSummary] do repositório está em voo (após cache miss / [forceRefresh]).
  bool get isBalanceSummaryLoading => _isBalanceSummaryLoading;

  bool get hasMore => _hasMore;
  bool get isLoadingMore => _isLoadingMore;
  StatementFilterCriteria? get currentFilterCriteria => _currentFilterCriteria;

  Future<void> loadTransactions({bool forceRefresh = false}) async {
    if (_isLoading) return;
    if (!forceRefresh) {
      final cachedTransactions = CacheManager.get<List<Transaction>>(
        _transactionsCacheKey,
      );
      if (cachedTransactions != null) {
        var changed = false;
        if (_transactions.isEmpty) {
          _transactions = List<Transaction>.from(cachedTransactions);
          _sortTransactionsNewestFirst();
          changed = true;
        }
        if (_transactionsError != null) {
          _transactionsError = null;
          changed = true;
        }
        if (changed) _safeNotifyListeners();
        return;
      }

      if (_transactions.isNotEmpty) {
        if (_transactionsError != null) {
          _transactionsError = null;
          _safeNotifyListeners();
        }
        return;
      }
    }

    _setLoading(true);
    _transactionsError = null;

    final result = await _repository.getAll();
    if (_disposed) {
      _setLoading(false);
      return;
    }

    result.fold(
      (success) {
        _transactions = List<Transaction>.from(success);
        _sortTransactionsNewestFirst();
        _lastDocument = null;
        _hasMore = false;
        CacheManager.set(
          _transactionsCacheKey,
          List<Transaction>.from(_transactions),
          ttl: _transactionsCacheTtl,
        );
      },
      (failure) {
        _transactionsError = failure.message;
        _lastDocument = null;
        _hasMore = false;
      },
    );

    _isLoadingMore = false;
    _setLoading(false);
  }

  Future<void> loadTransactionsPaginated({
    StatementFilterCriteria? criteria,
  }) async {
    _setLoading(true);
    _transactionsError = null;
    _lastDocument = null;
    _hasMore = true;
    _currentFilterCriteria = criteria;

    final result = await _repository.getPage(_pageSize, criteria: criteria);
    if (_disposed) {
      _setLoading(false);
      return;
    }

    result.fold((page) {
      _transactions = List<Transaction>.from(page.items);
      _sortTransactionsNewestFirst();
      CacheManager.set(
        _transactionsCacheKey,
        List<Transaction>.from(_transactions),
        ttl: _transactionsCacheTtl,
      );
      _lastDocument = page.lastDocument;
      _hasMore = page.hasMore;
    }, (failure) => _transactionsError = failure.message);

    _setLoading(false);
  }

  Future<void> loadMoreTransactions() async {
    if (_isLoadingMore || !_hasMore) return;

    _isLoadingMore = true;
    _safeNotifyListeners();

    final result = await _repository.getPage(
      _pageSize,
      startAfterDocument: _lastDocument,
      criteria: _currentFilterCriteria,
    );
    if (_disposed) {
      _isLoadingMore = false;
      return;
    }

    result.fold((page) {
      final existing = _transactions.map((t) => t.id).toSet();
      final merged = [
        ..._transactions,
        ...page.items.where((t) => !existing.contains(t.id)),
      ];
      _transactions = merged;
      _sortTransactionsNewestFirst();
      CacheManager.set(
        _transactionsCacheKey,
        List<Transaction>.from(_transactions),
        ttl: _transactionsCacheTtl,
      );
      _lastDocument = page.lastDocument;
      _hasMore = page.hasMore;
    }, (failure) => _transactionsError = failure.message);

    _isLoadingMore = false;
    _safeNotifyListeners();
  }

  Future<void> loadBalanceSummary({bool forceRefresh = false}) async {
    if (!forceRefresh) {
      final cachedSummary = CacheManager.get<BalanceSummary>(
        _balanceSummaryCacheKey,
      );
      if (cachedSummary != null) {
        var changed = false;
        if (_balanceSummary == null) {
          _balanceSummary = cachedSummary;
          changed = true;
        }
        if (_balanceSummaryError != null) {
          _balanceSummaryError = null;
          changed = true;
        }
        if (changed) _safeNotifyListeners();
        return;
      }

      if (_balanceSummary != null) {
        if (_balanceSummaryError != null) {
          _balanceSummaryError = null;
          _safeNotifyListeners();
        }
        return;
      }
    }

    _isBalanceSummaryLoading = true;
    _balanceSummaryError = null;
    _safeNotifyListeners();

    final result = await _repository.getBalanceSummary();
    if (_disposed) {
      _isBalanceSummaryLoading = false;
      return;
    }

    _isBalanceSummaryLoading = false;
    result.fold((success) {
      _balanceSummary = success;
      CacheManager.set(
        _balanceSummaryCacheKey,
        success,
        ttl: _balanceSummaryCacheTtl,
      );
    }, (failure) => _balanceSummaryError = failure.message);
    _safeNotifyListeners();
  }

  Future<Transaction?> addTransaction(
    Transaction transaction, {
    bool skipBalanceRefresh = false,
  }) async {
    _setLoading(true);
    _transactionsError = null;

    final result = await _repository.add(transaction);
    if (_disposed) {
      _setLoading(false);
      return null;
    }

    Transaction? created;
    var added = false;
    result.fold(
      (id) {
        added = true;
        created = transaction.copyWith(id: id);
        _transactions = [created!, ..._transactions];
        _sortTransactionsNewestFirst();
        CacheManager.set(
          _transactionsCacheKey,
          List<Transaction>.from(_transactions),
          ttl: _transactionsCacheTtl,
        );
      },
      (failure) {
        _transactionsError = failure.message;
      },
    );

    if (added && !skipBalanceRefresh) {
      await loadBalanceSummary(forceRefresh: true);
    }

    _setLoading(false);
    return created;
  }

  Future<bool> updateTransaction(Transaction transaction) async {
    _setLoading(true);
    _transactionsError = null;

    final result = await _repository.update(transaction);
    if (_disposed) {
      _setLoading(false);
      return false;
    }

    final isSuccess = result.fold(
      (_) {
        final index = _transactions.indexWhere((t) => t.id == transaction.id);
        if (index != -1) {
          _transactions[index] = transaction;
          _sortTransactionsNewestFirst();
          CacheManager.set(
            _transactionsCacheKey,
            List<Transaction>.from(_transactions),
            ttl: _transactionsCacheTtl,
          );
        }
        return true;
      },
      (failure) {
        _transactionsError = failure.message;
        return false;
      },
    );

    if (isSuccess) {
      await loadBalanceSummary(forceRefresh: true);
    }

    _setLoading(false);
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
    if (_disposed) return null;
    return result.fold(
      (updated) {
        final index = _transactions.indexWhere((t) => t.id == updated.id);
        if (index != -1) {
          _transactions[index] = updated;
          CacheManager.set(
            _transactionsCacheKey,
            List<Transaction>.from(_transactions),
            ttl: _transactionsCacheTtl,
          );
        }
        _safeNotifyListeners();
        return updated;
      },
      (failure) {
        _transactionsError = failure.message;
        _safeNotifyListeners();
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
    if (_disposed) return null;
    return result.fold(
      (updated) {
        final index = _transactions.indexWhere((t) => t.id == updated.id);
        if (index != -1) {
          _transactions[index] = updated;
          CacheManager.set(
            _transactionsCacheKey,
            List<Transaction>.from(_transactions),
            ttl: _transactionsCacheTtl,
          );
        }
        _safeNotifyListeners();
        return updated;
      },
      (failure) {
        _transactionsError = failure.message;
        _safeNotifyListeners();
        return null;
      },
    );
  }

  Future<void> deleteTransaction(String id) async {
    _setLoading(true);
    final result = await _repository.delete(id);
    if (_disposed) {
      _setLoading(false);
      return;
    }

    var removed = false;
    result.fold((_) {
      _transactions.removeWhere((t) => t.id == id);
      CacheManager.set(
        _transactionsCacheKey,
        List<Transaction>.from(_transactions),
        ttl: _transactionsCacheTtl,
      );
      removed = true;
    }, (failure) => _transactionsError = failure.message);

    if (removed) {
      await loadBalanceSummary(forceRefresh: true);
    }

    _setLoading(false);
  }

  void _setLoading(bool value) {
    _isLoading = value;
    _safeNotifyListeners();
  }

  void clearError() {
    _transactionsError = null;
    _balanceSummaryError = null;
    _safeNotifyListeners();
  }
}
