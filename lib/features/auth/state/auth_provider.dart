import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:cortex_bank_mobile/features/auth/models/user.dart';
import 'package:cortex_bank_mobile/features/auth/data/repositories/i_auth_repository.dart';

class AuthProvider extends ChangeNotifier {
  AuthProvider(this._authRepository);

  final IAuthRepository _authRepository;

  User? _user;
  bool _loading = false;
  bool _hasResolvedInitialAuth = false;
  String? _errorMessage;
  Future<void>? _pendingLoadCurrentUser;
  Future<void>? _backgroundRefreshCurrentUser;

  User? get user => _user;
  bool get loading => _loading;
  bool get hasResolvedInitialAuth => _hasResolvedInitialAuth;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _user != null;

  Future<void> loadCurrentUser({bool force = false}) {
    if (_pendingLoadCurrentUser != null) {
      return _pendingLoadCurrentUser!;
    }
    if (_hasResolvedInitialAuth && !force) {
      return Future.value();
    }

    final future = _loadCurrentUserImpl(force: force);
    _pendingLoadCurrentUser = future;
    future.whenComplete(() => _pendingLoadCurrentUser = null);
    return future;
  }

  Future<void> _loadCurrentUserImpl({required bool force}) async {
    if (!force) {
      final cachedUser = await _authRepository.getCachedCurrentUser();
      if (cachedUser != null) {
        _user = cachedUser;
        _errorMessage = null;
        _hasResolvedInitialAuth = true;
        _loading = false;
        notifyListeners();
        _scheduleBackgroundRefreshCurrentUser();
        return;
      }
    }

    _loading = true;
    _errorMessage = null;
    notifyListeners();

    final result = await _authRepository.getCurrentUser(forceRefresh: force);
    result.fold(
      (u) {
        _user = u;
        _errorMessage = null;
      },
      (f) {
        _user = null;
        _errorMessage = f.message;
      },
    );
    _hasResolvedInitialAuth = true;
    _loading = false;
    notifyListeners();
  }

  void _scheduleBackgroundRefreshCurrentUser() {
    if (_backgroundRefreshCurrentUser != null) return;

    final future = _refreshCurrentUserInBackground();
    _backgroundRefreshCurrentUser = future;
    future.whenComplete(() => _backgroundRefreshCurrentUser = null);
  }

  Future<void> _refreshCurrentUserInBackground() async {
    final result = await _authRepository.getCurrentUser(forceRefresh: true);
    result.fold(
      (u) {
        if (u == null) {
          _user = null;
          _errorMessage = null;
        } else {
          _user = u;
          _errorMessage = null;
        }
        _hasResolvedInitialAuth = true;
        notifyListeners();
      },
      (f) {
        // Mantém o usuário em cache na UI e apenas registra o erro para inspeção.
        _errorMessage = f.message;
        notifyListeners();
      },
    );
  }

  Future<void> signIn(String email, String password) async {
    if (_loading) return;
    _loading = true;
    _errorMessage = null;
    notifyListeners();

    final result = await _authRepository.signIn(email, password);
    result.fold(
      (u) {
        _user = u;
        _hasResolvedInitialAuth = true;
        _errorMessage = null;
      },
      (f) {
        _user = null;
        _hasResolvedInitialAuth = true;
        _errorMessage = f.message;
      },
    );
    _loading = false;
    notifyListeners();
  }

  Future<void> signUp(String fullName, String email, String password) async {
    if (_loading) return;
    _loading = true;
    _errorMessage = null;
    notifyListeners();

    final result = await _authRepository.signUp(fullName, email, password);
    result.fold(
      (u) {
        _user = u;
        _hasResolvedInitialAuth = true;
        _errorMessage = null;
      },
      (f) {
        _user = null;
        _hasResolvedInitialAuth = true;
        _errorMessage = f.message;
      },
    );
    _loading = false;
    notifyListeners();
  }

  Future<void> signOut() async {
    if (_loading) return;
    _loading = true;
    notifyListeners();

    final result = await _authRepository.signOut();
    result.fold((_) {
      _user = null;
      _hasResolvedInitialAuth = true;
      _errorMessage = null;
    }, (f) => _errorMessage = f.message);
    _loading = false;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
