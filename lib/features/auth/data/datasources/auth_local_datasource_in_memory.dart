import 'package:cortex_bank_mobile/features/auth/models/user.dart';
import 'package:cortex_bank_mobile/features/auth/data/datasources/auth_local_datasource.dart';

/// In-memory implementation. For production, replace with local persistence (e.g. Hive/SecureStorage).
class AuthLocalDataSourceInMemory implements AuthLocalDataSource {
  User? _user;

  @override
  Future<void> saveUser(User user) async {
    _user = user;
  }

  @override
  Future<User?> getCurrentUser() async => _user;

  @override
  Future<void> clearUser() async {
    _user = null;
  }
}
