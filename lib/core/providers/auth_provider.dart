import 'package:flutter/foundation.dart';
import 'package:cortex_bank_mobile/core/models/user.dart';
import 'package:cortex_bank_mobile/features/auth/data/repositories/i_auth_repository.dart';

class AuthProvider extends ChangeNotifier {
  AuthProvider(this._authRepository);

  final IAuthRepository _authRepository;

  User? _user;
  bool _loading = false;
  String? _errorMessage;

  User? get user => _user;
  bool get loading => _loading;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _user != null;

  Future<void> loadCurrentUser() async {
    _loading = true;
    _errorMessage = null;
    notifyListeners();

    final result = await _authRepository.getCurrentUser();
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
    _loading = false;
    notifyListeners();
  }

  Future<void> signIn(String email, String password) async {
    _loading = true;
    _errorMessage = null;
    notifyListeners();

    final result = await _authRepository.signIn(email, password);
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
    _loading = false;
    notifyListeners();
  }

  Future<void> signOut() async {
    _loading = true;
    notifyListeners();

    final result = await _authRepository.signOut();
    result.fold(
      (_) {
        _user = null;
        _errorMessage = null;
      },
      (f) => _errorMessage = f.message,
    );
    _loading = false;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
