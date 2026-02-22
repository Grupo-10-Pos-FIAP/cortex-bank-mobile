import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as fa;
import 'package:flutter/foundation.dart';
import 'package:cortex_bank_mobile/features/auth/models/user.dart';
import 'package:cortex_bank_mobile/core/errors/failure.dart';
import 'package:cortex_bank_mobile/core/utils/result.dart';
import 'package:cortex_bank_mobile/features/auth/data/mappers/auth_error_mapper.dart';
import 'package:cortex_bank_mobile/core/utils/safe_log.dart';
import 'package:cortex_bank_mobile/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:cortex_bank_mobile/features/auth/data/mappers/user_mapper.dart';

/// Timeout para operações de auth (login, cadastro, carregar usuário atual).
const _authTimeout = Duration(seconds: 25);

class AuthDatasourceFirebase implements AuthRemoteDataSource {
  final fa.FirebaseAuth _auth = fa.FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Tenta remover o usuário do Auth no rollback do signUp. Falhas são logadas sem PII.
  Future<void> _tryRollbackDeleteUser(fa.User? firebaseUser) async {
    if (firebaseUser == null) return;
    try {
      await firebaseUser.delete();
    } catch (e) {
      final code = e is fa.FirebaseAuthException ? e.code : null;
      final type = e.runtimeType.toString();
      debugPrint('Rollback signUp: falha ao remover usuário do Auth. type=$type code=${code ?? "n/a"}');
    }
  }

  @override
  Future<Result<User>> signIn(String email, String password) async {
    return _signInImpl(email, password).timeout(
      _authTimeout,
      onTimeout: () => FailureResult(const Failure(message: 'Tente novamente')),
    );
  }

  Future<Result<User>> _signInImpl(String email, String password) async {
    try {
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      final uid = userCredential.user?.uid;
      if (uid == null) {
        return FailureResult(
          const Failure(message: 'Erro ao obter dados do usuário'),
        );
      }

      final userDoc = await _firestore.collection('users').doc(uid).get();
      if (!userDoc.exists) {
        return FailureResult(
          const Failure(message: 'Perfil não encontrado. Faça login novamente'),
        );
      }

      final data = userDoc.data()!;
      final user = UserMapper.fromFirestore(data, id: uid, fallbackEmail: email);

      return Success(user);
    } on fa.FirebaseAuthException catch (e) {
      return FailureResult(AuthErrorMapper.toFailure(e, context: AuthErrorContext.signIn));
    } catch (e) {
      if (e is TimeoutException) {
        return FailureResult(const Failure(message: 'Tente novamente'));
      }
      safeLogError('Erro ao fazer login', e);
      return FailureResult(AuthErrorMapper.toFailure(e, context: AuthErrorContext.signIn));
    }
  }

  @override
  Future<Result<User>> signUp(String fullName, String email, String password) async {
    return _signUpImpl(fullName, email, password).timeout(
      _authTimeout,
      onTimeout: () => FailureResult(const Failure(message: 'Tente novamente')),
    );
  }

  Future<Result<User>> _signUpImpl(String fullName, String email, String password) async {
    fa.UserCredential? userCredential;

    try {
      userCredential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      final uid = userCredential.user?.uid;
      if (uid == null) {
        return FailureResult(
          const Failure(message: 'Erro ao criar usuário'),
        );
      }

      // Tentar criar perfil no Firestore
      try {
        await _firestore.collection('users').doc(uid).set({
          'fullName': fullName.trim(),
          'email': email.trim(),
          'createdAt': FieldValue.serverTimestamp(),
        });
      } on FirebaseException catch (e) {
        // Rollback: deletar usuário Auth se Firestore falhar
        safeLogError('Erro ao criar perfil no Firestore', e);
        await _tryRollbackDeleteUser(userCredential.user);
        return FailureResult(AuthErrorMapper.toFailure(e, context: AuthErrorContext.firestore));
      } catch (e) {
        // Rollback para qualquer exceção não-Firebase
        safeLogError('Erro ao criar perfil no Firestore (exceção genérica)', e);
        await _tryRollbackDeleteUser(userCredential.user);
        return FailureResult(AuthErrorMapper.toFailure(e, context: AuthErrorContext.firestore));
      }

      final user = UserMapper.fromFirestore(
        {'fullName': fullName.trim(), 'email': email.trim()},
        id: uid,
      );

      return Success(user);
    } on fa.FirebaseAuthException catch (e) {
      return FailureResult(AuthErrorMapper.toFailure(e, context: AuthErrorContext.signUp));
    } catch (e) {
      if (e is TimeoutException) {
        return FailureResult(const Failure(message: 'Tente novamente'));
      }
      // Rollback se houver exceção genérica antes de criar Firestore
      safeLogError('Erro ao criar usuário no Firebase Auth', e);
      await _tryRollbackDeleteUser(userCredential?.user);
      return FailureResult(AuthErrorMapper.toFailure(e, context: AuthErrorContext.signUp));
    }
  }

  @override
  Future<Result<User?>> getCurrentUser() async {
    return _getCurrentUserImpl().timeout(
      _authTimeout,
      onTimeout: () => FailureResult(Failure(message: 'Tente novamente')),
    );
  }

  Future<Result<User?>> _getCurrentUserImpl() async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) {
        return const Success(null);
      }

      final userDoc = await _firestore.collection('users').doc(currentUser.uid).get();
      if (!userDoc.exists) {
        return const Success(null);
      }

      final data = userDoc.data()!;
      final user = UserMapper.fromFirestore(
        data,
        id: currentUser.uid,
        fallbackEmail: currentUser.email,
      );

      return Success(user);
    } catch (e) {
      if (e is TimeoutException) {
        return FailureResult(const Failure(message: 'Tente novamente'));
      }
      safeLogError('Erro ao carregar usuário atual', e);
      return FailureResult(AuthErrorMapper.toFailure(e, context: AuthErrorContext.getCurrentUser));
    }
  }

  @override
  Future<Result<void>> signOut() async {
    try {
      await _auth.signOut();
      return const Success(null);
    } catch (e) {
      safeLogError('Erro ao fazer logout', e);
      return FailureResult(AuthErrorMapper.toFailure(e, context: AuthErrorContext.signOut));
    }
  }
}
