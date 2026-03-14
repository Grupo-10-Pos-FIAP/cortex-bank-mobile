import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as fa;

import 'package:cortex_bank_mobile/core/di/injection.dart';
import 'package:cortex_bank_mobile/core/errors/failure.dart';
import 'package:cortex_bank_mobile/core/utils/result.dart';
import 'package:cortex_bank_mobile/core/utils/safe_log.dart';

import 'package:cortex_bank_mobile/features/auth/data/datasources/auth_datasource.dart';
import 'package:cortex_bank_mobile/features/auth/data/datasources/user_datasource.dart';
import 'package:cortex_bank_mobile/features/auth/data/mappers/auth_error_mapper.dart';
import 'package:cortex_bank_mobile/features/auth/models/user.dart';

const _authTimeout = Duration(seconds: 25);

class AuthDataSourceFirebase implements AuthDataSource {
  final fa.FirebaseAuth _auth = fa.FirebaseAuth.instance;
  final _userDataSource = getIt<UserDataSource>();

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

  @override
  Future<Result<User>> signIn(String email, String password) async {
    try {
      return await _signInImpl(email, password).timeout(_authTimeout);
    } on TimeoutException {
      return FailureResult(
        const Failure(message: 'Tempo esgotado. Tente novamente.'),
      );
    } catch (e) {
      return FailureResult(
        AuthErrorMapper.toFailure(e, context: AuthErrorContext.signIn),
      );
    }
  }

  Future<Result<User>> _signInImpl(String email, String password) async {
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
  }

  @override
  Future<Result<User>> signUp(
    String fullName,
    String email,
    String password,
  ) async {
    try {
      return await _signUpImpl(fullName, email, password).timeout(_authTimeout);
    } on TimeoutException {
      return FailureResult(
        const Failure(message: 'Tempo esgotado. Tente novamente.'),
      );
    } catch (e) {
      safeLogError('Erro no signUp', e);
      return FailureResult(
        AuthErrorMapper.toFailure(e, context: AuthErrorContext.signUp),
      );
    }
  }

  Future<Result<User>> _signUpImpl(
    String fullName,
    String email,
    String password,
  ) async {
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );

    final firebaseUser = credential.user;
    if (firebaseUser == null) throw Exception('User is null');

    await firebaseUser.updateDisplayName(fullName.trim());
    await firebaseUser.reload();

    // Cria o perfil no Firestore via UserDataSource
    await _userDataSource.createUserProfile({
      'uid': firebaseUser.uid,
      'fullName': fullName.trim(),
      'email': email.trim(),
      'balance': 0.0,
      'createdAt': FieldValue.serverTimestamp(),
    });

    return Success(
      User(
        uid: firebaseUser.uid,
        username: fullName.trim(),
        email: email.trim(),
      ),
    );
  }

  @override
  Future<Result<User?>> getCurrentUser() async {
    try {
      final firebaseUser = _auth.currentUser;
      if (firebaseUser == null) return const Success(null);
      return Success(_mapFirebaseUser(firebaseUser));
    } catch (e) {
      return FailureResult(
        AuthErrorMapper.toFailure(e, context: AuthErrorContext.getCurrentUser),
      );
    }
  }

  @override
  Future<Result<void>> signOut() async {
    try {
      await _auth.signOut();
      return const Success(null);
    } catch (e) {
      return FailureResult(
        AuthErrorMapper.toFailure(e, context: AuthErrorContext.signOut),
      );
    }
  }
}
