import 'package:cortex_bank_mobile/core/models/user.dart';
import 'package:cortex_bank_mobile/core/utils/result.dart';

/// Remote auth (e.g. Firebase Auth). TODO: implement with Firebase Auth.
abstract class AuthRemoteDataSource {
  Future<Result<User>> signIn(String email, String password);
}
