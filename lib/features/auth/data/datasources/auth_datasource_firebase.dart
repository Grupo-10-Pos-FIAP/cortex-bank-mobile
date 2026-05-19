import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cortex_bank_mobile/core/cache/cache_serializers.dart';
import 'package:cortex_bank_mobile/core/cache/sensitive_cache_manager.dart';
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

/// [SEGURANÇA] Limite de tentativas de login antes de bloquear temporariamente.
/// Complementa o bloqueio do Firebase mas protege também contra abuso local.
const _maxSignInAttempts = 5;
const _signInBlockDuration = Duration(minutes: 15);


class AuthDataSourceFirebase implements AuthDataSource {
  fa.FirebaseAuth get _auth => fa.FirebaseAuth.instance;
  UserDataSource get _userDataSource => getIt<UserDataSource>();

  // [SEGURANÇA] Controle local de tentativas por e-mail para rate-limiting
  // no lado do cliente, reduzindo chamadas desnecessárias ao Firebase em
  // ataques de força bruta.
  final Map<String, _RateLimitEntry> _signInAttempts = {};


  /// No iOS, o [GoogleSignIn] nativo exige um OAuth client id (normalmente o
  /// `CLIENT_ID` do `GoogleService-Info.plist`). Se o plist versionado estiver
  /// incompleto, use `GOOGLE_SIGN_IN_IOS_CLIENT_ID` no `.env` (mesmo valor).
  late final GoogleSignIn _googleSignIn = _createGoogleSignIn();

  static GoogleSignIn _createGoogleSignIn() {
    if (kIsWeb) return GoogleSignIn();

    if (defaultTargetPlatform == TargetPlatform.iOS) {
      final clientId = dotenv.env['GOOGLE_SIGN_IN_IOS_CLIENT_ID']?.trim();
      final serverClientId = dotenv.env['GOOGLE_SIGN_IN_SERVER_CLIENT_ID']
          ?.trim();

      if (clientId != null && clientId.isNotEmpty) {
        return GoogleSignIn(
          clientId: clientId,
          serverClientId: (serverClientId?.isNotEmpty ?? false)
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
    SensitiveCacheManager.setJson(
      _userCacheKey(uid),
      CacheSerializers.userToJson(user),
      ttl: _userCacheTtl,
    );
  }


  /// [SEGURANÇA] Verifica se o e-mail está bloqueado por excesso de tentativas.
  /// Retorna uma [Failure] se bloqueado, ou `null` se pode prosseguir.
  Failure? _checkRateLimit(String email) {
    final entry = _signInAttempts[email];
    if (entry == null) return null;

    if (entry.isBlocked) {
      final remaining = entry.unblocksAt.difference(DateTime.now());
      final minutes = remaining.inMinutes + 1;
      return Failure(
        message: 'Muitas tentativas. Tente novamente em $minutes minuto(s).',
      );
    }
    return null;
  }

  /// [SEGURANÇA] Registra uma tentativa falha para o e-mail informado.
  void _recordFailedAttempt(String email) {
    final entry = _signInAttempts[email] ?? _RateLimitEntry();
    entry.increment(_signInBlockDuration, _maxSignInAttempts);
    _signInAttempts[email] = entry;
  }

  /// [SEGURANÇA] Limpa o contador de tentativas após login bem-sucedido.
  void _clearAttempts(String email) => _signInAttempts.remove(email);


  @override
  Stream<bool> watchFirebaseSessionSignedIn() =>
      _auth.authStateChanges().map((u) => u != null);


  @override
  Future<User?> getCachedCurrentUser() async {
    final firebaseUser = _auth.currentUser;
    if (firebaseUser == null) return null;
    return SensitiveCacheManager.getJson<User>(
      _userCacheKey(firebaseUser.uid),
      (json) => CacheSerializers.userFromJson(json! as Map<String, dynamic>),
    );
  }


  @override
  Future<Result<User>> signIn(String email, String password) async {
    // [SEGURANÇA] Sanitização básica antes de qualquer chamada de rede.
    final sanitizedEmail = email.trim().toLowerCase();

    // [SEGURANÇA] Rate-limiting local: bloqueia após N tentativas falhas.
    final rateLimitFailure = _checkRateLimit(sanitizedEmail);
    if (rateLimitFailure != null) return FailureResult(rateLimitFailure);

    try {
      final credential = await _auth
          .signInWithEmailAndPassword(email: sanitizedEmail, password: password)
          .timeout(_authTimeout);

      final firebaseUser = credential.user;
      if (firebaseUser == null) {
        // [SEGURANÇA] Não revela se o e-mail existe ou não.
        return FailureResult(const Failure(message: 'Credenciais inválidas.'));
      }

      _clearAttempts(sanitizedEmail);

      final userData = await _userDataSource.getUserProfile(firebaseUser.uid);

      // Perfil ainda não sincronizado (ex: offline persistence com doc novo).
      // Não bloqueia o login — o shell carrega o perfil completo depois.
      if (userData.isEmpty) {
        final minimalUser = User(
          uid: firebaseUser.uid,
          username: firebaseUser.displayName ?? '',
          email: sanitizedEmail,
          branchCode: '',
          accountNumber: '',
        );
        return Success(minimalUser);
      }

      final user = User.fromFirestore(firebaseUser.uid, userData);
      _cacheUser(user);
      return Success(user);
    } on TimeoutException {
      return FailureResult(
        const Failure(message: 'Tempo esgotado. Tente novamente.'),
      );
    } catch (e) {
      // [SEGURANÇA] Incrementa contador apenas para erros de credencial,
      // evitando penalizar erros de rede ou do servidor.
      if (_isCredentialError(e)) _recordFailedAttempt(sanitizedEmail);
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
    // [SEGURANÇA] Validações de entrada antes de qualquer chamada de rede.
    final validationError = _validateSignUpInput(fullName, email, password);
    if (validationError != null) return FailureResult(validationError);

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
    final sanitizedEmail = email.trim().toLowerCase();
    final sanitizedName = fullName.trim();

    // 1. Criar usuário no Firebase Auth
    final credential = await _auth.createUserWithEmailAndPassword(
      email: sanitizedEmail,
      password: password,
    );

    final firebaseUser = credential.user;
    if (firebaseUser == null) throw Exception('Erro ao criar credenciais.');

    // [SEGURANÇA] Envia verificação de e-mail imediatamente após o cadastro.
    await firebaseUser.sendEmailVerification();

    // 2. Gerar dados bancários
    final branch = BankAccountGenerator.generateBranch();
    final account = BankAccountGenerator.generateAccountNumber();

    // 3. Criar o Map para o Firestore
    // [SEGURANÇA] Nunca persiste a senha — apenas os dados necessários.
    final userMap = {
      'uid': firebaseUser.uid,
      'username': sanitizedName,
      'email': sanitizedEmail,
      'branchCode': branch,
      'accountNumber': account,
      'balance': 0.0,
      'createdAt': FieldValue.serverTimestamp(),
    };

    // 4. Salvar no Firestore e atualizar displayName em paralelo
    await Future.wait([
      _userDataSource.createUserProfile(userMap),
      firebaseUser.updateDisplayName(sanitizedName),
    ]);

    // [SEGURANÇA] Faz logout após cadastro para forçar verificação de e-mail
    // antes do primeiro acesso — evita acesso com e-mail não confirmado.
    await _auth.signOut();

    final newUser = User(
      uid: firebaseUser.uid,
      username: sanitizedName,
      email: sanitizedEmail,
      branchCode: branch,
      accountNumber: account,
    );

    // [SEGURANÇA] Não faz cache de usuário não verificado.
    return Success(newUser);
  }


  @override
  Future<Result<User?>> getCurrentUser({bool forceRefresh = false}) async {
    try {
      final firebaseUser = _auth.currentUser;
      if (firebaseUser == null) return const Success(null);

      // [SEGURANÇA] Refresca o token do Firebase para garantir que a sessão
      // ainda é válida (detecta revogação server-side).
      if (forceRefresh) {
        await firebaseUser.reload();
        final refreshed = _auth.currentUser;
        if (refreshed == null) return const Success(null);
      }

      final cachedUser = SensitiveCacheManager.getJson<User>(
        _userCacheKey(firebaseUser.uid),
        (json) => CacheSerializers.userFromJson(json! as Map<String, dynamic>),
      );
      if (!forceRefresh && cachedUser != null) return Success(cachedUser);

      final userData = await _userDataSource.getUserProfile(firebaseUser.uid);

      // Perfil não encontrado (doc ainda não existe ou offline sem cache).
      // Retorna null para que o shell aguarde ou recarregue — não propaga erro.
      if (userData.isEmpty) return const Success(null);

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
        // [SEGURANÇA] Solicita conta explicitamente para evitar login silencioso
        // com conta errada em sessões compartilhadas.
        provider.setCustomParameters({'prompt': 'select_account'});
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

        // [SEGURANÇA] Valida que os tokens foram retornados antes de usá-los.
        if (googleAuth.idToken == null) {
          return FailureResult(
            const Failure(message: 'Falha ao obter credenciais do Google.'),
          );
        }

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

        // [SEGURANÇA] Sanitiza os dados vindos do Google antes de persistir.
        final displayName = _sanitizeDisplayName(
          firebaseUser.displayName ?? '',
        );
        final email = (firebaseUser.email ?? '').trim().toLowerCase();

        final newUserMap = {
          'uid': firebaseUser.uid,
          'username': displayName,
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

      // [SEGURANÇA] Remove cache ANTES do signOut para evitar janela de
      // acesso a dados de outra sessão em caso de re-login imediato.
      if (currentUid != null && currentUid.isNotEmpty) {
        SensitiveCacheManager.remove(_userCacheKey(currentUid));
      }

      await _auth.signOut();

      try {
        await _googleSignIn.signOut();
      } catch (_) {
        // Google Sign-In pode não estar configurado ou não ter sessão ativa.
      }

      // [SEGURANÇA] Limpa todos os contadores de rate-limit ao sair.
      _signInAttempts.clear();

      return const Success(null);
    } catch (e) {
      safeLogError('Erro no signOut', e);
      return FailureResult(
        AuthErrorMapper.toFailure(e, context: AuthErrorContext.signOut),
      );
    }
  }


  /// [SEGURANÇA] Valida entrada do cadastro no cliente antes de chamar o Firebase,
  /// reduzindo requisições malformadas e fornecendo feedback imediato.
  Failure? _validateSignUpInput(
    String fullName,
    String email,
    String password,
  ) {
    if (fullName.trim().isEmpty) {
      return const Failure(message: 'Nome completo é obrigatório.');
    }
    if (fullName.trim().length < 3) {
      return const Failure(message: 'Nome deve ter pelo menos 3 caracteres.');
    }

    final emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
    if (!emailRegex.hasMatch(email.trim())) {
      return const Failure(message: 'E-mail inválido.');
    }

    // [SEGURANÇA] Política de senha: mínimo 8 caracteres, ao menos uma letra
    // maiúscula, uma minúscula e um número.
    if (password.length < 8) {
      return const Failure(
        message: 'A senha deve ter pelo menos 8 caracteres.',
      );
    }
    if (!RegExp(r'[A-Z]').hasMatch(password)) {
      return const Failure(
        message: 'A senha deve conter pelo menos uma letra maiúscula.',
      );
    }
    if (!RegExp(r'[a-z]').hasMatch(password)) {
      return const Failure(
        message: 'A senha deve conter pelo menos uma letra minúscula.',
      );
    }
    if (!RegExp(r'[0-9]').hasMatch(password)) {
      return const Failure(
        message: 'A senha deve conter pelo menos um número.',
      );
    }

    return null;
  }

  /// [SEGURANÇA] Remove caracteres perigosos do nome vindo de provedores externos
  /// para prevenir injeção de dados no Firestore / exibição de HTML malicioso.
  String _sanitizeDisplayName(String name) {
    return name
        .trim()
        .replaceAll(RegExp(r'[<>&"\x00-\x1F]'), '')
        .substring(0, name.trim().length.clamp(0, 100));
  }

  /// Retorna `true` para erros que indicam credenciais erradas (não erros de rede),
  /// usado para decidir se deve incrementar o contador de rate-limit.
  bool _isCredentialError(Object e) {
    if (e is fa.FirebaseAuthException) {
      return const {
        'wrong-password',
        'user-not-found',
        'invalid-credential',
        'invalid-email',
      }.contains(e.code);
    }
    return false;
  }
}


class _RateLimitEntry {
  int attempts = 0;
  DateTime unblocksAt = DateTime.fromMillisecondsSinceEpoch(0);

  bool get isBlocked => DateTime.now().isBefore(unblocksAt);

  void increment(Duration blockDuration, int maxAttempts) {
    attempts++;
    if (attempts >= maxAttempts) {
      unblocksAt = DateTime.now().add(blockDuration);
      attempts = 0; // Reseta para a próxima janela
    }
  }
}
