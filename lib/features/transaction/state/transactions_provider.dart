import 'package:flutter/material.dart';
import '../models/transaction.dart';
import '../models/balance_summary.dart';
import '../data/repositories/i_transactions_repository.dart';

class TransactionsProvider extends ChangeNotifier {
  final ITransactionsRepository _repository;

  TransactionsProvider(this._repository);

  List<Transaction> _transactions = [];
  BalanceSummary? _balanceSummary;
  bool _isLoading = false;
  String? _errorMessage;

  List<Transaction> get transactions => List.unmodifiable(_transactions);
  BalanceSummary? get balanceSummary => _balanceSummary;
  bool get isLoading => _isLoading;
  bool get loading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Carregar transações
  Future<void> loadTransactions() async {
    _setLoading(true);
    _errorMessage = null;

    final result = await _repository.getAll();
    result.fold(
      (success) => _transactions = success,
      (failure) => _errorMessage = failure.message,
    );

    _setLoading(false);
  }

  // Carregar sumário de saldo
  Future<void> loadBalanceSummary() async {
    final result = await _repository.getBalanceSummary();
    result.fold((success) {
      _balanceSummary = success;
      notifyListeners();
    }, (failure) => _errorMessage = failure.message);
  }

  // Adicionar transação
  Future<bool> addTransaction(Transaction transaction) async {
    _setLoading(true);
    _errorMessage = null;

    final result = await _repository.add(transaction);

    final isSuccess = result.fold(
      (_) {
        // Adiciona no topo da lista local
        _transactions = [transaction, ..._transactions];
        // Recarrega o saldo para refletir a nova transação
        loadBalanceSummary();
        return true;
      },
      (failure) {
        _errorMessage = failure.message;
        return false;
      },
    );

    _setLoading(false);
    return isSuccess;
  }

  // Deletar transação
  Future<void> deleteTransaction(String id) async {
    _setLoading(true);
    final result = await _repository.delete(id);

    result.fold((_) {
      _transactions.removeWhere((t) => t.id == id);
      loadBalanceSummary();
      notifyListeners();
    }, (failure) => _errorMessage = failure.message);
    _setLoading(false);
  }

  // Métodos auxiliares idênticos ao ContactsProvider
  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
