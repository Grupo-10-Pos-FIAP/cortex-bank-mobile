import 'dart:async';

import 'package:cortex_bank_mobile/core/cache/cache_serializers.dart';
import 'package:cortex_bank_mobile/core/cache/sensitive_cache_manager.dart';
import 'package:cortex_bank_mobile/features/transaction/domain/entities/balance_summary.dart';
import 'package:cortex_bank_mobile/features/transaction/domain/entities/transaction.dart';
import 'package:cortex_bank_mobile/features/transaction/domain/pagination/transaction_page.dart';
import 'package:cortex_bank_mobile/features/transaction/domain/repositories/i_transactions_repository.dart';
import 'package:cortex_bank_mobile/features/transaction/domain/statement/statement_filter_criteria.dart';
import 'package:cortex_bank_mobile/features/transaction/presentation/state/transactions_state.dart';
import 'package:state_notifier/state_notifier.dart';

class TransactionsNotifier extends StateNotifier<TransactionsState> {
  static const _transactionsCacheKey = 'transactions_provider.transactions';
  static const _balanceSummaryCacheKey =
      'transactions_provider.balance_summary';
  static const _transactionsCacheTtl = Duration(minutes: 2);
  static const _balanceSummaryCacheTtl = Duration(seconds: 30);
  static const int _pageSize = 20;

  TransactionsNotifier(this._repository) : super(TransactionsState.initial());

  final ITransactionsRepository _repository;

  String? _boundUserId;

  /// Invalida conclusões de [loadTransactionsPaginated] / [loadMoreTransactions] obsoletas.
  int _listEpoch = 0;

  /// [hasMore] vindo de [loadMoreTransactions] (além da primeira página reativa).
  bool _extraPagesHaveMore = false;

  StreamSubscription<TransactionPage>? _firstPageStreamSub;

  /// Quando o usuário autenticado muda (login / logout / troca de conta), limpa estado e cache.
  void syncAuthUserId(String? userId) {
    if (_boundUserId == userId) return;
    _boundUserId = userId;
    _firstPageStreamSub?.cancel();
    _firstPageStreamSub = null;
    _extraPagesHaveMore = false;
    SensitiveCacheManager.remove(_transactionsCacheKey);
    SensitiveCacheManager.remove(_balanceSummaryCacheKey);
    _listEpoch++;
    state = TransactionsState.initial();
  }

  /// Expõe o id atualmente associado (útil em testes).
  String? get boundUserId => _boundUserId;

  List<Transaction> get transactions => List.unmodifiable(state.transactions);
  BalanceSummary? get balanceSummary => state.balanceSummary;
  bool get isLoading => state.isLoading;
  String? get transactionsError => state.transactionsError;
  String? get balanceSummaryError => state.balanceSummaryError;
  bool get isBalanceSummaryLoading => state.isBalanceSummaryLoading;
  bool get hasMore => state.hasMore;
  bool get isLoadingMore => state.isLoadingMore;
  StatementFilterCriteria? get currentFilterCriteria =>
      state.currentFilterCriteria;

  void _sortTransactionsNewestFirst(List<Transaction> list) {
    list.sort((a, b) {
      final byDate = b.date.compareTo(a.date);
      if (byDate != 0) return byDate;
      return b.id.compareTo(a.id);
    });
  }

  /// Atualiza [balanceSummary] a partir da lista em memória (feedback imediato).
  void _syncBalanceSummaryFromTransactions() {
    if (!mounted) return;
    final summary = BalanceSummary.fromTransactions(state.transactions);
    SensitiveCacheManager.setJson(
      _balanceSummaryCacheKey,
      CacheSerializers.balanceSummaryToJson(summary),
      ttl: _balanceSummaryCacheTtl,
    );
    state = state.copyWith(
      balanceSummary: summary,
      balancePhase: BalanceSummaryPhase.ready,
      clearBalanceSummaryError: true,
    );
  }

  Future<void> loadTransactions({bool forceRefresh = false}) async {
    if (state.listPhase == TransactionsListPhase.loading) return;
    if (!forceRefresh) {
      final cachedTransactions =
          SensitiveCacheManager.getJson<List<Transaction>>(
            _transactionsCacheKey,
            (json) =>
                CacheSerializers.transactionsFromJson(json! as List<dynamic>),
          );
      if (cachedTransactions != null) {
        var next = state;
        if (state.transactions.isEmpty) {
          final list = List<Transaction>.from(cachedTransactions);
          _sortTransactionsNewestFirst(list);
          next = next.copyWith(
            transactions: list,
            listPhase: TransactionsListPhase.ready,
          );
        }
        if (state.transactionsError != null) {
          next = next.copyWith(clearTransactionsError: true);
        }
        if (!identical(next, state)) state = next;
        return;
      }

      if (state.transactions.isNotEmpty) {
        if (state.transactionsError != null) {
          state = state.copyWith(clearTransactionsError: true);
        }
        return;
      }
    }

    state = state.copyWith(
      listPhase: TransactionsListPhase.loading,
      clearTransactionsError: true,
    );

    final result = await _repository.getAll();
    if (!mounted) {
      state = state.copyWith(listPhase: TransactionsListPhase.idle);
      return;
    }

    result.fold(
      (success) {
        final list = List<Transaction>.from(success);
        _sortTransactionsNewestFirst(list);
        SensitiveCacheManager.setJson(
          _transactionsCacheKey,
          CacheSerializers.transactionsToJson(list),
          ttl: _transactionsCacheTtl,
        );
        state = state.copyWith(
          transactions: list,
          listPhase: TransactionsListPhase.ready,
          lastCursor: null,
          clearLastCursor: true,
          hasMore: false,
          isLoadingMore: false,
        );
      },
      (failure) {
        state = state.copyWith(
          listPhase: TransactionsListPhase.failure,
          transactionsError: failure.message,
          lastCursor: null,
          clearLastCursor: true,
          hasMore: false,
          isLoadingMore: false,
        );
      },
    );
  }

  Future<void> loadTransactionsPaginated({
    StatementFilterCriteria? criteria,
  }) async {
    await _firstPageStreamSub?.cancel();
    _firstPageStreamSub = null;

    final epoch = ++_listEpoch;
    _extraPagesHaveMore = false;

    state = state.copyWith(
      transactions: const [],
      listPhase: TransactionsListPhase.loading,
      clearTransactionsError: true,
      lastCursor: null,
      clearLastCursor: true,
      hasMore: true,
      isLoadingMore: false,
      currentFilterCriteria: criteria,
      clearFilterCriteria: criteria == null,
    );

    final firstEvent = Completer<void>();
    late final StreamSubscription<TransactionPage> sub;
    sub = _repository
        .watchFirstPage(_pageSize, criteria: criteria)
        .listen(
          (page) {
            if (epoch != _listEpoch) return;
            _applyFirstPageFromStream(page, epoch);
            if (!firstEvent.isCompleted) firstEvent.complete();
          },
          onError: (Object e, StackTrace stackTrace) {
            if (epoch != _listEpoch) return;
            state = state.copyWith(
              listPhase: TransactionsListPhase.failure,
              transactionsError: 'Erro ao carregar transações',
              isLoadingMore: false,
            );
            if (!firstEvent.isCompleted) firstEvent.complete();
          },
        );
    _firstPageStreamSub = sub;

    await firstEvent.future;
    if (!mounted) {
      state = state.copyWith(listPhase: TransactionsListPhase.idle);
      return;
    }
    if (epoch != _listEpoch) {
      await sub.cancel();
    }
  }

  void _applyFirstPageFromStream(TransactionPage streamPage, int epoch) {
    if (epoch != _listEpoch) return;

    final prefixIds = streamPage.items.map((e) => e.id).toSet();
    final tail = _extraPagesHaveMore
        ? state.transactions.where((t) => !prefixIds.contains(t.id)).toList()
        : <Transaction>[];
    // Mantém itens locais (ex.: agendamento recém-criado) ainda fora do snapshot.
    final localOnly = state.transactions
        .where((t) => !prefixIds.contains(t.id))
        .where((t) => !tail.any((x) => x.id == t.id))
        .toList();
    final merged = [...streamPage.items, ...localOnly, ...tail];
    _sortTransactionsNewestFirst(merged);

    SensitiveCacheManager.setJson(
      _transactionsCacheKey,
      CacheSerializers.transactionsToJson(merged),
      ttl: _transactionsCacheTtl,
    );

    final keepCursor = tail.isNotEmpty || state.lastCursor != null;
    final nextCursor = keepCursor ? state.lastCursor : streamPage.endCursor;
    final hasMore = tail.isNotEmpty
        ? _extraPagesHaveMore
        : (streamPage.hasMore || _extraPagesHaveMore);

    state = state.copyWith(
      transactions: merged,
      listPhase: TransactionsListPhase.ready,
      lastCursor: nextCursor,
      clearLastCursor: nextCursor == null,
      hasMore: hasMore,
      isLoadingMore: state.isLoadingMore,
    );
  }

  Future<void> loadMoreTransactions() async {
    if (state.isLoadingMore || !state.hasMore) return;

    final epoch = _listEpoch;
    state = state.copyWith(isLoadingMore: true);

    final result = await _repository.getPage(
      _pageSize,
      startAfterCursor: state.lastCursor,
      criteria: state.currentFilterCriteria,
    );
    if (!mounted) {
      state = state.copyWith(isLoadingMore: false);
      return;
    }
    if (epoch != _listEpoch) {
      state = state.copyWith(isLoadingMore: false);
      return;
    }

    result.fold(
      (page) {
        _extraPagesHaveMore = page.hasMore;
        final existing = state.transactions.map((t) => t.id).toSet();
        final merged = [
          ...state.transactions,
          ...page.items.where((t) => !existing.contains(t.id)),
        ];
        _sortTransactionsNewestFirst(merged);
        SensitiveCacheManager.setJson(
          _transactionsCacheKey,
          CacheSerializers.transactionsToJson(merged),
          ttl: _transactionsCacheTtl,
        );
        state = state.copyWith(
          transactions: merged,
          lastCursor: page.endCursor,
          hasMore: page.hasMore,
          isLoadingMore: false,
        );
      },
      (failure) {
        state = state.copyWith(
          transactionsError: failure.message,
          isLoadingMore: false,
        );
      },
    );
  }

  Future<void> loadBalanceSummary({bool forceRefresh = false}) async {
    if (!forceRefresh) {
      final cachedSummary = SensitiveCacheManager.getJson<BalanceSummary>(
        _balanceSummaryCacheKey,
        (json) => CacheSerializers.balanceSummaryFromJson(
          json! as Map<String, dynamic>,
        ),
      );
      if (cachedSummary != null) {
        var next = state;
        if (state.balanceSummary == null) {
          next = next.copyWith(
            balanceSummary: cachedSummary,
            balancePhase: BalanceSummaryPhase.ready,
          );
        }
        if (state.balanceSummaryError != null) {
          next = next.copyWith(clearBalanceSummaryError: true);
        }
        if (!identical(next, state)) state = next;
        return;
      }

      if (state.balanceSummary != null) {
        if (state.balanceSummaryError != null) {
          state = state.copyWith(clearBalanceSummaryError: true);
        }
        return;
      }
    }

    state = state.copyWith(
      balancePhase: BalanceSummaryPhase.loading,
      clearBalanceSummaryError: true,
    );

    final result = await _repository.getBalanceSummary();
    if (!mounted) {
      state = state.copyWith(balancePhase: BalanceSummaryPhase.idle);
      return;
    }

    result.fold(
      (success) {
        SensitiveCacheManager.setJson(
          _balanceSummaryCacheKey,
          CacheSerializers.balanceSummaryToJson(success),
          ttl: _balanceSummaryCacheTtl,
        );
        state = state.copyWith(
          balanceSummary: success,
          balancePhase: BalanceSummaryPhase.ready,
        );
      },
      (failure) {
        state = state.copyWith(
          balancePhase: BalanceSummaryPhase.failure,
          balanceSummaryError: failure.message,
        );
      },
    );
  }

  Future<Transaction?> addTransaction(
    Transaction transaction, {
    bool skipBalanceRefresh = false,
  }) async {
    state = state.copyWith(
      listPhase: TransactionsListPhase.loading,
      clearTransactionsError: true,
    );

    final result = await _repository.add(transaction);
    if (!mounted) {
      state = state.copyWith(listPhase: TransactionsListPhase.idle);
      return null;
    }

    Transaction? created;
    var added = false;
    result.fold(
      (id) {
        added = true;
        created = transaction.copyWith(id: id);
        final list = [created!, ...state.transactions];
        _sortTransactionsNewestFirst(list);
        SensitiveCacheManager.setJson(
          _transactionsCacheKey,
          CacheSerializers.transactionsToJson(list),
          ttl: _transactionsCacheTtl,
        );
        state = state.copyWith(
          transactions: list,
          listPhase: TransactionsListPhase.ready,
        );
      },
      (failure) {
        state = state.copyWith(
          listPhase: TransactionsListPhase.failure,
          transactionsError: failure.message,
        );
      },
    );

    if (added) {
      _syncBalanceSummaryFromTransactions();
      if (!skipBalanceRefresh) {
        await loadBalanceSummary(forceRefresh: true);
      }
    }

    return created;
  }

  Future<bool> updateTransaction(Transaction transaction) async {
    state = state.copyWith(
      listPhase: TransactionsListPhase.loading,
      clearTransactionsError: true,
    );

    final result = await _repository.update(transaction);
    if (!mounted) {
      state = state.copyWith(listPhase: TransactionsListPhase.idle);
      return false;
    }

    final isSuccess = result.fold(
      (_) {
        final index = state.transactions.indexWhere(
          (t) => t.id == transaction.id,
        );
        if (index != -1) {
          final list = List<Transaction>.from(state.transactions);
          list[index] = transaction;
          _sortTransactionsNewestFirst(list);
          SensitiveCacheManager.setJson(
            _transactionsCacheKey,
            CacheSerializers.transactionsToJson(list),
            ttl: _transactionsCacheTtl,
          );
          state = state.copyWith(
            transactions: list,
            listPhase: TransactionsListPhase.ready,
          );
        } else {
          state = state.copyWith(listPhase: TransactionsListPhase.ready);
        }
        return true;
      },
      (failure) {
        state = state.copyWith(
          listPhase: TransactionsListPhase.failure,
          transactionsError: failure.message,
        );
        return false;
      },
    );

    if (isSuccess) {
      _syncBalanceSummaryFromTransactions();
      await loadBalanceSummary(forceRefresh: true);
    }

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
    if (!mounted) return null;
    return result.fold(
      (updated) {
        final index = state.transactions.indexWhere((t) => t.id == updated.id);
        if (index != -1) {
          final list = List<Transaction>.from(state.transactions);
          list[index] = updated;
          SensitiveCacheManager.setJson(
            _transactionsCacheKey,
            CacheSerializers.transactionsToJson(list),
            ttl: _transactionsCacheTtl,
          );
          state = state.copyWith(transactions: list);
        }
        return updated;
      },
      (failure) {
        state = state.copyWith(transactionsError: failure.message);
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
    if (!mounted) return null;
    return result.fold(
      (updated) {
        final index = state.transactions.indexWhere((t) => t.id == updated.id);
        if (index != -1) {
          final list = List<Transaction>.from(state.transactions);
          list[index] = updated;
          SensitiveCacheManager.setJson(
            _transactionsCacheKey,
            CacheSerializers.transactionsToJson(list),
            ttl: _transactionsCacheTtl,
          );
          state = state.copyWith(transactions: list);
        }
        return updated;
      },
      (failure) {
        state = state.copyWith(transactionsError: failure.message);
        return null;
      },
    );
  }

  Future<void> deleteTransaction(String id) async {
    state = state.copyWith(listPhase: TransactionsListPhase.loading);

    final result = await _repository.delete(id);
    if (!mounted) {
      state = state.copyWith(listPhase: TransactionsListPhase.idle);
      return;
    }

    var removed = false;
    result.fold(
      (_) {
        final list = List<Transaction>.from(state.transactions)
          ..removeWhere((t) => t.id == id);
        SensitiveCacheManager.setJson(
          _transactionsCacheKey,
          CacheSerializers.transactionsToJson(list),
          ttl: _transactionsCacheTtl,
        );
        state = state.copyWith(
          transactions: list,
          listPhase: TransactionsListPhase.ready,
        );
        removed = true;
      },
      (failure) {
        state = state.copyWith(
          listPhase: TransactionsListPhase.failure,
          transactionsError: failure.message,
        );
      },
    );

    if (removed) {
      _syncBalanceSummaryFromTransactions();
      await loadBalanceSummary(forceRefresh: true);
    }
  }

  void clearError() {
    state = state.copyWith(
      clearTransactionsError: true,
      clearBalanceSummaryError: true,
    );
  }

  @override
  void dispose() {
    _firstPageStreamSub?.cancel();
    super.dispose();
  }
}
