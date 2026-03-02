import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart' as fa;
import 'package:cortex_bank_mobile/features/auth/models/user.dart';
import 'package:cortex_bank_mobile/core/errors/failure.dart';
import 'package:cortex_bank_mobile/core/utils/result.dart';
import 'package:cortex_bank_mobile/features/auth/data/mappers/auth_error_mapper.dart';
import 'package:cortex_bank_mobile/core/utils/safe_log.dart';

/// Timeout para operações de auth (login, cadastro, carregar usuário atual).
const _authTimeout = Duration(seconds: 25);

class AuthDatasourceFirebase {
  final fa.FirebaseAuth _auth = fa.FirebaseAuth.instance;

  /// Mapeia um fa.User para o modelo de User do app.
  User _mapFirebaseUser(fa.User firebaseUser) {
    return User(
      uid: firebaseUser.uid,
      username:
          firebaseUser.displayName ??
          firebaseUser.email?.split('@').first ??
          '',
      email: firebaseUser.email ?? '',
    );
  }

  Future<Result<User>> signIn(String email, String password) async {
    return _signInImpl(email, password).timeout(
      _authTimeout,
      onTimeout: () => FailureResult(const Failure(message: 'Tente novamente')),
    );
  }

  Future<Result<User>> _signInImpl(String email, String password) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      final firebaseUser = credential.user;
      if (firebaseUser == null) {
        return FailureResult(
          const Failure(message: 'Erro ao obter dados do usuário'),
        );
      }
      return Success(_mapFirebaseUser(firebaseUser));
    } on fa.FirebaseAuthException catch (e) {
      return FailureResult(
        AuthErrorMapper.toFailure(e, context: AuthErrorContext.signIn),
      );
    } catch (e) {
      if (e is TimeoutException) {
        return FailureResult(const Failure(message: 'Tente novamente'));
      }
      safeLogError('Erro ao fazer login', e);
      return FailureResult(
        AuthErrorMapper.toFailure(e, context: AuthErrorContext.signIn),
      );
    }
  }

  Future<Result<User>> signUp(
    String fullName,
    String email,
    String password,
  ) async {
    return _signUpImpl(fullName, email, password).timeout(
      _authTimeout,
      onTimeout: () => FailureResult(const Failure(message: 'Tente novamente')),
    );
  }

  Future<Result<User>> _signUpImpl(
    String fullName,
    String email,
    String password,
  ) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      final firebaseUser = credential.user;
      if (firebaseUser == null) {
        return FailureResult(const Failure(message: 'Erro ao criar usuário'));
      }
      // Atualiza o displayName no Firebase Auth
      await firebaseUser.updateDisplayName(fullName.trim());
      await firebaseUser.reload();
      return Success(
        User(
          uid: firebaseUser.uid,
          username: fullName.trim(),
          email: email.trim(),
        ),
      );
    } on fa.FirebaseAuthException catch (e) {
      return FailureResult(
        AuthErrorMapper.toFailure(e, context: AuthErrorContext.signUp),
      );
    } catch (e) {
      if (e is TimeoutException) {
        return FailureResult(const Failure(message: 'Tente novamente'));
      }
      safeLogError('Erro ao criar usuário no Firebase Auth', e);
      return FailureResult(
        AuthErrorMapper.toFailure(e, context: AuthErrorContext.signUp),
      );
    }
  }

  Future<Result<User?>> getCurrentUser() async {
    try {
      final firebaseUser = _auth.currentUser;
      if (firebaseUser == null) return const Success(null);
      return Success(_mapFirebaseUser(firebaseUser));
    } catch (e) {
      safeLogError('Erro ao carregar usuário atual', e);
      return FailureResult(
        AuthErrorMapper.toFailure(e, context: AuthErrorContext.getCurrentUser),
      );
    }
  }

  Future<Result<void>> signOut() async {
    try {
      await _auth.signOut();
      return const Success(null);
    } catch (e) {
      safeLogError('Erro ao fazer logout', e);
      return FailureResult(
        AuthErrorMapper.toFailure(e, context: AuthErrorContext.signOut),
      );
    }
  }
}
