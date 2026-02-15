import 'package:flutter/foundation.dart';
import 'package:cortex_bank_mobile/core/models/balance_summary.dart';
import 'package:cortex_bank_mobile/core/models/transaction.dart';
import 'package:cortex_bank_mobile/features/transaction/data/repositories/i_transactions_repository.dart';

class TransactionsProvider extends ChangeNotifier {
  TransactionsProvider(this._repository);

  final ITransactionsRepository _repository;

  List<Transaction> _transactions = [];
  BalanceSummary? _balanceSummary;
  bool _loading = false;
  String? _errorMessage;

  List<Transaction> get transactions => List.unmodifiable(_transactions);
  BalanceSummary? get balanceSummary => _balanceSummary;
  bool get loading => _loading;
  String? get errorMessage => _errorMessage;

  Future<void> loadTransactions() async {
    _loading = true;
    _errorMessage = null;
    notifyListeners();

    final result = await _repository.getAll();
    result.fold(
      (list) {
        _transactions = list;
        _errorMessage = null;
      },
      (f) => _errorMessage = f.message,
    );
    _loading = false;
    notifyListeners();
  }

  Future<void> loadBalanceSummary() async {
    final result = await _repository.getBalanceSummary();
    result.fold(
      (s) {
        _balanceSummary = s;
        notifyListeners();
      },
      (_) {},
    );
  }

  Future<bool> addTransaction(Transaction transaction) async {
    _loading = true;
    _errorMessage = null;
    notifyListeners();

    final result = await _repository.add(transaction);
    var ok = false;
    result.fold(
      (_) {
        _transactions = [..._transactions, transaction];
        _errorMessage = null;
        ok = true;
      },
      (f) => _errorMessage = f.message,
    );
    _loading = false;
    notifyListeners();
    return ok;
  }

  Future<bool> deleteTransaction(String id) async {
    _loading = true;
    _errorMessage = null;
    notifyListeners();

    final result = await _repository.delete(id);
    var ok = false;
    result.fold(
      (_) {
        _transactions = _transactions.where((t) => t.id != id).toList();
        _errorMessage = null;
        ok = true;
      },
      (f) => _errorMessage = f.message,
    );
    _loading = false;
    notifyListeners();
    return ok;
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
