import 'package:cortex_bank_mobile/core/models/user.dart';
import 'package:cortex_bank_mobile/core/utils/result.dart';
import 'package:cortex_bank_mobile/features/auth/data/datasources/auth_local_datasource.dart';
import 'package:cortex_bank_mobile/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:cortex_bank_mobile/features/auth/data/repositories/i_auth_repository.dart';

class AuthRepositoryImpl implements IAuthRepository {
  AuthRepositoryImpl(this._local, this._remote);

  final AuthLocalDataSource _local;
  final AuthRemoteDataSource _remote;

  @override
  Future<Result<User>> signIn(String email, String password) async {
    final result = await _remote.signIn(email, password);
    return await result.fold<Future<Result<User>>>(
      (user) async {
        await _local.saveUser(user);
        return Success(user);
      },
      (failure) => Future.value(FailureResult(failure)),
    );
  }

  @override
  Future<Result<User?>> getCurrentUser() async {
    try {
      final user = await _local.getCurrentUser();
      return Success(user);
    } catch (e) {
      return FailureResult(Failure(message: e.toString()));
    }
  }

  @override
  Future<Result<void>> signOut() async {
    try {
      await _local.clearUser();
      return const Success(null);
    } catch (e) {
      return FailureResult(Failure(message: e.toString()));
    }
  }
}
