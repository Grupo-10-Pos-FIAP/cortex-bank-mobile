import 'package:cortex_bank_mobile/features/transaction/domain/entities/balance_summary.dart';
import 'package:cortex_bank_mobile/features/transaction/domain/entities/transaction.dart';
import 'package:cortex_bank_mobile/features/transaction/domain/pagination/transaction_page_cursor.dart';
import 'package:cortex_bank_mobile/features/transaction/domain/statement/statement_filter_criteria.dart';
import 'package:flutter/foundation.dart';

/// Ciclo de vida da lista de transações (carregamento explícito).
enum TransactionsListPhase { idle, loading, ready, failure }

/// Ciclo de vida do resumo de saldo.
enum BalanceSummaryPhase { idle, loading, ready, failure }

@immutable
class TransactionsState {
  const TransactionsState({
    this.transactions = const [],
    this.listPhase = TransactionsListPhase.idle,
    this.transactionsError,
    this.balanceSummary,
    this.balancePhase = BalanceSummaryPhase.idle,
    this.balanceSummaryError,
    this.lastCursor,
    this.hasMore = true,
    this.isLoadingMore = false,
    this.currentFilterCriteria,
  });

  final List<Transaction> transactions;
  final TransactionsListPhase listPhase;
  final String? transactionsError;
  final BalanceSummary? balanceSummary;
  final BalanceSummaryPhase balancePhase;
  final String? balanceSummaryError;
  final TransactionPageCursor? lastCursor;
  final bool hasMore;
  final bool isLoadingMore;
  final StatementFilterCriteria? currentFilterCriteria;

  bool get isLoading => listPhase == TransactionsListPhase.loading;

  bool get isBalanceSummaryLoading =>
      balancePhase == BalanceSummaryPhase.loading;

  factory TransactionsState.initial() => const TransactionsState();

  TransactionsState copyWith({
    List<Transaction>? transactions,
    TransactionsListPhase? listPhase,
    String? transactionsError,
    bool clearTransactionsError = false,
    BalanceSummary? balanceSummary,
    BalanceSummaryPhase? balancePhase,
    String? balanceSummaryError,
    bool clearBalanceSummaryError = false,
    TransactionPageCursor? lastCursor,
    bool clearLastCursor = false,
    bool? hasMore,
    bool? isLoadingMore,
    StatementFilterCriteria? currentFilterCriteria,
    bool clearFilterCriteria = false,
  }) {
    return TransactionsState(
      transactions: transactions ?? this.transactions,
      listPhase: listPhase ?? this.listPhase,
      transactionsError: clearTransactionsError
          ? null
          : (transactionsError ?? this.transactionsError),
      balanceSummary: balanceSummary ?? this.balanceSummary,
      balancePhase: balancePhase ?? this.balancePhase,
      balanceSummaryError: clearBalanceSummaryError
          ? null
          : (balanceSummaryError ?? this.balanceSummaryError),
      lastCursor: clearLastCursor ? null : (lastCursor ?? this.lastCursor),
      hasMore: hasMore ?? this.hasMore,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      currentFilterCriteria: clearFilterCriteria
          ? null
          : (currentFilterCriteria ?? this.currentFilterCriteria),
    );
  }
}
