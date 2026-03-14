import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cortex_bank_mobile/core/utils/bank_account_generator.dart';
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

  @override
  Future<Result<User>> signIn(String email, String password) async {
    try {
      final credential = await _auth
          .signInWithEmailAndPassword(email: email.trim(), password: password)
          .timeout(_authTimeout);

      final firebaseUser = credential.user;
      if (firebaseUser == null) {
        return FailureResult(const Failure(message: 'Usuário não encontrado.'));
      }

      final userData = await _userDataSource.getUserProfile(firebaseUser.uid);
      return Success(User.fromFirestore(firebaseUser.uid, userData));
    } on TimeoutException {
      return FailureResult(
        const Failure(message: 'Tempo esgotado. Tente novamente.'),
      );
    } catch (e) {
      safeLogError('Erro no signIn', e);
      return FailureResult(
        AuthErrorMapper.toFailure(e, context: AuthErrorContext.signIn),
      );
    }
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
    // 1. Criar usuário no Firebase Auth
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );

    final firebaseUser = credential.user;
    if (firebaseUser == null) throw Exception('Erro ao criar credenciais.');

    // 2. Atualizar Profile do Auth (opcional, mas bom para paridade)
    await firebaseUser.updateDisplayName(fullName.trim());
    await firebaseUser.reload();

    // 3. Gerar dados bancários
    final branch = BankAccountGenerator.generateBranch();
    final account = BankAccountGenerator.generateAccountNumber();

    // 4. Criar o Map para o Firestore
    // Certifique-se de que os campos batem com o que o User.fromFirestore espera
    final userMap = {
      'uid': firebaseUser.uid,
      'username': fullName.trim(),
      'email': email.trim().toLowerCase(),
      'branchCode': branch,
      'accountNumber': account,
      'balance': 0.0,
      'createdAt': FieldValue.serverTimestamp(),
    };

    // 5. Salvar no Firestore via UserDataSource
    await _userDataSource.createUserProfile(userMap);

    // 6. Retornar o Objeto User populado
    // Usamos os dados locais para evitar uma segunda chamada de rede imediata
    final newUser = User(
      uid: firebaseUser.uid,
      username: fullName.trim(),
      email: email.trim().toLowerCase(),
      branchCode: branch,
      accountNumber: account,
    );

    return Success(newUser);
  }

  @override
  Future<Result<User?>> getCurrentUser() async {
    try {
      final firebaseUser = _auth.currentUser;
      if (firebaseUser == null) return const Success(null);

      final userData = await _userDataSource.getUserProfile(firebaseUser.uid);
      return Success(User.fromFirestore(firebaseUser.uid, userData));
    } catch (e) {
      safeLogError('Erro ao obter usuário atual', e);
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
      safeLogError('Erro no signOut', e);
      return FailureResult(
        AuthErrorMapper.toFailure(e, context: AuthErrorContext.signOut),
      );
    }
  }
}
