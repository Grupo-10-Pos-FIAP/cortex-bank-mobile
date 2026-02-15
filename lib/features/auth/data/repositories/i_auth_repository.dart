import 'package:cortex_bank_mobile/core/models/user.dart';
import 'package:cortex_bank_mobile/core/utils/result.dart';

abstract class IAuthRepository {
  Future<Result<User>> signIn(String email, String password);
  Future<Result<User?>> getCurrentUser();
  Future<Result<void>> signOut();
}
