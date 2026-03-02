import 'package:cortex_bank_mobile/features/auth/models/user.dart';
import 'package:cortex_bank_mobile/core/utils/result.dart';
import 'package:cortex_bank_mobile/features/auth/data/repositories/i_auth_repository.dart';

import 'package:cortex_bank_mobile/features/auth/data/datasources/auth_datasource_firebase.dart';

class AuthRepositoryImpl implements IAuthRepository {
  AuthRepositoryImpl() : _remote = AuthDatasourceFirebase();

  final AuthDatasourceFirebase _remote;

  @override
  Future<Result<User>> signIn(String email, String password) async {
    return await _remote.signIn(email, password);
  }

  @override
  Future<Result<User>> signUp(
    String fullName,
    String email,
    String password,
  ) async {
    return await _remote.signUp(fullName, email, password);
  }

  @override
  Future<Result<User?>> getCurrentUser() async {
    return await _remote.getCurrentUser();
  }

  @override
  Future<Result<void>> signOut() async {
    return await _remote.signOut();
  }
}
