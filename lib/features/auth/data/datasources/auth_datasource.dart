import 'package:cortex_bank_mobile/core/utils/result.dart';
import 'package:cortex_bank_mobile/features/auth/models/user.dart';

abstract class AuthDataSource {
  Future<Result<User>> signIn(String email, String password);
  Future<Result<User>> signUp(String fullName, String email, String password);
  Future<Result<User?>> getCurrentUser();
  Future<Result<void>> signOut();
}
