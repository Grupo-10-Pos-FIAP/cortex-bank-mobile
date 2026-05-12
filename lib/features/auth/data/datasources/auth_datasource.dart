import 'package:cortex_bank_mobile/core/utils/result.dart';
import 'package:cortex_bank_mobile/features/auth/domain/entities/user.dart';

abstract class AuthDataSource {
  /// Emite [true] quando há usuário no Firebase Auth, [false] quando não há.
  /// Cada emissão indica que a sessão mudou (login, logout, troca de conta).
  Stream<bool> watchFirebaseSessionSignedIn();

  Future<Result<User>> signIn(String email, String password);
  Future<Result<User>> signUp(String fullName, String email, String password);
  Future<Result<User>> signInWithGoogle();
  Future<User?> getCachedCurrentUser();
  Future<Result<User?>> getCurrentUser({bool forceRefresh = false});
  Future<Result<void>> signOut();
}
