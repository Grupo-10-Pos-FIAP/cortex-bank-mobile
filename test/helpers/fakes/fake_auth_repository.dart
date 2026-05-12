import 'dart:async';

import 'package:cortex_bank_mobile/core/errors/failure.dart';
import 'package:cortex_bank_mobile/core/utils/result.dart';
import 'package:cortex_bank_mobile/features/auth/domain/repositories/i_auth_repository.dart';
import 'package:cortex_bank_mobile/features/auth/domain/entities/user.dart';

class FakeAuthRepository implements IAuthRepository {
  Result<User>? signInResult;
  Result<User>? signUpResult;
  Result<User>? signInWithGoogleResult;
  Result<User?>? currentUserResult;

  User? cachedUser;
  List<Result<User?>>? currentUserResultQueue;
  Result<void>? signOutResult;

  Completer<Result<User>>? signInCompleter;
  Completer<Result<User>>? signUpCompleter;
  Completer<Result<User>>? signInWithGoogleCompleter;
  Completer<Result<User?>>? currentUserCompleter;
  Completer<Result<void>>? signOutCompleter;

  int signInCalls = 0;
  int signUpCalls = 0;
  int signInWithGoogleCalls = 0;
  int currentUserCalls = 0;
  int signOutCalls = 0;

  /// Quando não nulo, usado por [watchFirebaseSessionSignedIn] em testes.
  StreamController<bool>? firebaseSessionController;

  @override
  Stream<bool> watchFirebaseSessionSignedIn() {
    if (firebaseSessionController != null) {
      return firebaseSessionController!.stream;
    }
    return const Stream.empty();
  }

  String? lastSignInEmail;
  String? lastSignInPassword;
  String? lastSignUpFullName;
  String? lastSignUpEmail;
  String? lastSignUpPassword;

  @override
  Future<User?> getCachedCurrentUser() async => cachedUser;

  @override
  Future<Result<User?>> getCurrentUser({bool forceRefresh = false}) {
    currentUserCalls += 1;
    if (currentUserCompleter != null) return currentUserCompleter!.future;
    final queue = currentUserResultQueue;
    if (queue != null && queue.isNotEmpty) {
      return Future.value(queue.removeAt(0));
    }
    return Future.value(currentUserResult ?? const Success(null));
  }

  @override
  Future<Result<User>> signInWithGoogle() {
    signInWithGoogleCalls += 1;
    if (signInWithGoogleCompleter != null) {
      return signInWithGoogleCompleter!.future;
    }
    return Future.value(
      signInWithGoogleResult ??
          FailureResult<User>(
            const Failure(message: 'signInWithGoogleResult not configured'),
          ),
    );
  }

  @override
  Future<Result<User>> signIn(String email, String password) {
    signInCalls += 1;
    lastSignInEmail = email;
    lastSignInPassword = password;
    if (signInCompleter != null) return signInCompleter!.future;
    return Future.value(
      signInResult ??
          FailureResult<User>(
            const Failure(message: 'signInResult not configured'),
          ),
    );
  }

  @override
  Future<Result<void>> signOut() {
    signOutCalls += 1;
    if (signOutCompleter != null) return signOutCompleter!.future;
    return Future.value(signOutResult ?? const Success(null));
  }

  @override
  Future<Result<User>> signUp(String fullName, String email, String password) {
    signUpCalls += 1;
    lastSignUpFullName = fullName;
    lastSignUpEmail = email;
    lastSignUpPassword = password;
    if (signUpCompleter != null) return signUpCompleter!.future;
    return Future.value(
      signUpResult ??
          FailureResult<User>(
            const Failure(message: 'signUpResult not configured'),
          ),
    );
  }
}
