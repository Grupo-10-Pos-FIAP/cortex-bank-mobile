import 'package:cortex_bank_mobile/core/models/user.dart';
import 'package:cortex_bank_mobile/core/utils/safe_log.dart';
import 'package:cortex_bank_mobile/core/utils/failure.dart';
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
  Future<Result<User>> signUp(String fullName, String email, String password) async {
    final result = await _remote.signUp(fullName, email, password);
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
      final remoteResult = await _remote.getCurrentUser();
      return await remoteResult.fold<Future<Result<User?>>>(
        (user) async {
          if (user != null) {
            await _local.saveUser(user);
          }
          return Success(user);
        },
        (failure) => Future.value(FailureResult(failure)),
      );
    } catch (e) {
      safeLogError('Erro inesperado em getCurrentUser', e);
      return FailureResult(Failure(message: 'Erro ao carregar usuário. Tente novamente'));
    }
  }

  @override
  Future<Result<void>> signOut() async {
    try {
      final remoteResult = await _remote.signOut();
      return await remoteResult.fold<Future<Result<void>>>(
        (_) async {
          await _local.clearUser();
          return const Success(null);
        },
        (failure) => Future.value(FailureResult(failure)),
      );
    } catch (e) {
      safeLogError('Erro inesperado em signOut', e);
      return FailureResult(Failure(message: 'Erro ao fazer logout'));
    }
  }
}
