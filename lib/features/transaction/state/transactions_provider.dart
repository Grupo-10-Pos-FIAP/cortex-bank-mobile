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

  // Getters públicos (Essenciais para a UI enxergar os dados)
  List<Transaction> get transactions => List.unmodifiable(_transactions);
  BalanceSummary? get balanceSummary => _balanceSummary;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Carregar lista de transações
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

  Future<void> loadBalanceSummary() async {
    final result = await _repository.getBalanceSummary();

    result.fold((success) {
      _balanceSummary = success;
      notifyListeners();
    }, (failure) => _errorMessage = failure.message);
  }

  Future<bool> addTransaction(Transaction transaction) async {
    _setLoading(true);
    _errorMessage = null;

    final result = await _repository.add(transaction);

    final isSuccess = result.fold(
      (id) {
        // Adiciona localmente para feedback instantâneo
        _transactions = [transaction, ..._transactions];
        // Atualiza o saldo automaticamente
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
    }, (failure) => _errorMessage = failure.message);

    _setLoading(false);
  }

  // Métodos auxiliares de estado
  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
