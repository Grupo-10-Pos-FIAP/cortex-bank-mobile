import 'package:cortex_bank_mobile/core/models/user.dart';

abstract class AuthLocalDataSource {
  Future<void> saveUser(User user);
  Future<User?> getCurrentUser();
  Future<void> clearUser();
}
