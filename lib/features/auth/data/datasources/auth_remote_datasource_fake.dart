import 'package:cortex_bank_mobile/features/auth/models/user.dart';
import 'package:cortex_bank_mobile/core/errors/failure.dart';
import 'package:cortex_bank_mobile/core/utils/result.dart';
import 'package:cortex_bank_mobile/features/auth/data/datasources/auth_remote_datasource.dart';

/// Fake implementation: any non-empty user/pass authenticates. Replace with Firebase Auth when ready.
class AuthRemoteDataSourceFake implements AuthRemoteDataSource {
  @override
  Future<Result<User>> signIn(String email, String password) async {
    final e = email.trim();
    final p = password.trim();
    if (e.isEmpty || p.isEmpty) {
      return FailureResult(
        const Failure(message: 'Email e senha são obrigatórios'),
      );
    }
    return Success(
      User(
        id: 'fake-${DateTime.now().millisecondsSinceEpoch}',
        name: e,
        email: e,
        token: 'fake-token-$e',
      ),
    );
  }

  @override
  Future<Result<User>> signUp(String fullName, String email, String password) async {
    final e = email.trim();
    final p = password.trim();
    final n = fullName.trim();
    if (e.isEmpty || p.isEmpty || n.isEmpty) {
      return FailureResult(
        const Failure(message: 'Todos os campos são obrigatórios'),
      );
    }
    return Success(
      User(
        id: 'fake-${DateTime.now().millisecondsSinceEpoch}',
        name: n,
        email: e,
        token: 'fake-token-$e',
      ),
    );
  }

  @override
  Future<Result<User?>> getCurrentUser() async {
    return const Success(null);
  }

  @override
  Future<Result<void>> signOut() async {
    return const Success(null);
  }
}
