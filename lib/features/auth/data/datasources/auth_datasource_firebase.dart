import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cortex_bank_mobile/core/cache/cache_manager.dart';
import 'package:cortex_bank_mobile/core/utils/bank_account_generator.dart';
import 'package:firebase_auth/firebase_auth.dart' as fa;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'package:cortex_bank_mobile/core/di/injection.dart';
import 'package:cortex_bank_mobile/core/errors/failure.dart';
import 'package:cortex_bank_mobile/core/utils/result.dart';
import 'package:cortex_bank_mobile/core/utils/safe_log.dart';

import 'package:cortex_bank_mobile/features/auth/data/datasources/auth_datasource.dart';
import 'package:cortex_bank_mobile/features/auth/data/datasources/user_datasource.dart';
import 'package:cortex_bank_mobile/features/auth/data/mappers/auth_error_mapper.dart';
import 'package:cortex_bank_mobile/features/auth/domain/entities/user.dart';

const _authTimeout = Duration(seconds: 25);
const _userCacheTtl = Duration(minutes: 10);

class AuthDataSourceFirebase implements AuthDataSource {
  fa.FirebaseAuth get _auth => fa.FirebaseAuth.instance;
  UserDataSource get _userDataSource => getIt<UserDataSource>();

  /// No iOS, o [GoogleSignIn] nativo exige um OAuth client id (normalmente o
  /// `CLIENT_ID` do `GoogleService-Info.plist`). Se o plist versionado estiver
  /// incompleto, use `GOOGLE_SIGN_IN_IOS_CLIENT_ID` no `.env` (mesmo valor).
  late final GoogleSignIn _googleSignIn = _createGoogleSignIn();

  static GoogleSignIn _createGoogleSignIn() {
    if (kIsWeb) {
      return GoogleSignIn();
    }
    if (defaultTargetPlatform == TargetPlatform.iOS) {
      final clientId = dotenv.env['GOOGLE_SIGN_IN_IOS_CLIENT_ID']?.trim();
      final serverClientId =
          dotenv.env['GOOGLE_SIGN_IN_SERVER_CLIENT_ID']?.trim();
      if (clientId != null && clientId.isNotEmpty) {
        return GoogleSignIn(
          clientId: clientId,
          serverClientId: (serverClientId != null && serverClientId.isNotEmpty)
              ? serverClientId
              : null,
        );
      }
    }
    return GoogleSignIn();
  }

  String _userCacheKey(String uid) => 'auth.user.$uid';

  void _cacheUser(User user) {
    final uid = user.uid;
    if (uid == null || uid.isEmpty) return;
    CacheManager.set(_userCacheKey(uid), user, ttl: _userCacheTtl);
  }

  @override
  Future<User?> getCachedCurrentUser() async {
    final firebaseUser = _auth.currentUser;
    if (firebaseUser == null) return null;
    return CacheManager.get<User>(_userCacheKey(firebaseUser.uid));
  }

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
      final user = User.fromFirestore(firebaseUser.uid, userData);
      _cacheUser(user);
      return Success(user);
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

    // 3. Gerar dados bancários
    final branch = BankAccountGenerator.generateBranch();
    final account = BankAccountGenerator.generateAccountNumber();

    // 4. Criar o Map para o Firestore
    final userMap = {
      'uid': firebaseUser.uid,
      'username': fullName.trim(),
      'email': email.trim().toLowerCase(),
      'branchCode': branch,
      'accountNumber': account,
      'balance': 0.0,
      'createdAt': FieldValue.serverTimestamp(),
    };

    // 5. Salvar no Firestore e atualizar displayName em paralelo
    await Future.wait([
      _userDataSource.createUserProfile(userMap),
      firebaseUser.updateDisplayName(fullName.trim()),
    ]);

    // 6. Retornar o Objeto User populado
    final newUser = User(
      uid: firebaseUser.uid,
      username: fullName.trim(),
      email: email.trim().toLowerCase(),
      branchCode: branch,
      accountNumber: account,
    );

    _cacheUser(newUser);

    return Success(newUser);
  }

  @override
  Future<Result<User?>> getCurrentUser({bool forceRefresh = false}) async {
    try {
      final firebaseUser = _auth.currentUser;
      if (firebaseUser == null) return const Success(null);

      final cachedUser = CacheManager.get<User>(
        _userCacheKey(firebaseUser.uid),
      );
      if (!forceRefresh && cachedUser != null) {
        return Success(cachedUser);
      }

      final userData = await _userDataSource.getUserProfile(firebaseUser.uid);
      final user = User.fromFirestore(firebaseUser.uid, userData);
      _cacheUser(user);
      return Success(user);
    } catch (e) {
      safeLogError('Erro ao obter usuário atual', e);
      return FailureResult(
        AuthErrorMapper.toFailure(e, context: AuthErrorContext.getCurrentUser),
      );
    }
  }

  @override
  Future<Result<User>> signInWithGoogle() async {
    try {
      fa.UserCredential userCredential;

      if (kIsWeb) {
        final provider = fa.GoogleAuthProvider();
        userCredential = await _auth
            .signInWithPopup(provider)
            .timeout(_authTimeout);
      } else {
        final googleUser = await _googleSignIn.signIn();
        if (googleUser == null) {
          return FailureResult(
            const Failure(message: 'Login com Google cancelado.'),
          );
        }

        final googleAuth = await googleUser.authentication;
        final credential = fa.GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );

        userCredential = await _auth
            .signInWithCredential(credential)
            .timeout(_authTimeout);
      }

      final firebaseUser = userCredential.user;
      if (firebaseUser == null) {
        return FailureResult(const Failure(message: 'Usuário não encontrado.'));
      }

      // Verifica se o perfil já existe; se não, cria um novo.
      Map<String, dynamic> userData;
      try {
        userData = await _userDataSource.getUserProfile(firebaseUser.uid);
      } catch (_) {
        userData = {};
      }

      if (userData.isEmpty) {
        final branch = BankAccountGenerator.generateBranch();
        final account = BankAccountGenerator.generateAccountNumber();
        final displayName = firebaseUser.displayName ?? '';
        final email = (firebaseUser.email ?? '').toLowerCase();

        final newUserMap = {
          'uid': firebaseUser.uid,
          'username': displayName.trim(),
          'email': email,
          'branchCode': branch,
          'accountNumber': account,
          'balance': 0.0,
          'createdAt': FieldValue.serverTimestamp(),
        };

        await _userDataSource.createUserProfile(newUserMap);
        userData = newUserMap;
      }

      final user = User.fromFirestore(firebaseUser.uid, userData);
      _cacheUser(user);
      return Success(user);
    } on TimeoutException {
      return FailureResult(
        const Failure(message: 'Tempo esgotado. Tente novamente.'),
      );
    } catch (e) {
      safeLogError('Erro no signInWithGoogle', e);
      return FailureResult(
        AuthErrorMapper.toFailure(e, context: AuthErrorContext.signIn),
      );
    }
  }

  @override
  Future<Result<void>> signOut() async {
    try {
      final currentUid = _auth.currentUser?.uid;
      await _auth.signOut();
      try {
        await _googleSignIn.signOut();
      } catch (_) {
        // Google Sign-In pode não estar configurado ou não ter sessão ativa.
      }
      if (currentUid != null && currentUid.isNotEmpty) {
        CacheManager.remove(_userCacheKey(currentUid));
      }
      return const Success(null);
    } catch (e) {
      safeLogError('Erro no signOut', e);
      return FailureResult(
        AuthErrorMapper.toFailure(e, context: AuthErrorContext.signOut),
      );
    }
  }
}
