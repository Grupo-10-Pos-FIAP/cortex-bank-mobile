import 'package:cortex_bank_mobile/core/models/user.dart';
import 'package:cortex_bank_mobile/core/utils/result.dart';

/// Contrato para autenticação remota (ex.: Firebase Auth).
abstract class AuthRemoteDataSource {
  Future<Result<User>> signIn(String email, String password);
  Future<Result<User>> signUp(String fullName, String email, String password);
  Future<Result<User?>> getCurrentUser();
  Future<Result<void>> signOut();
}
