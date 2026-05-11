import 'package:cortex_bank_mobile/features/auth/domain/entities/user.dart';

User buildUser({
  String? uid = 'u1',
  String username = 'Gabrielle',
  String email = 'gabi@example.com',
  String branchCode = '0001',
  String accountNumber = '12345-6',
}) {
  return User(
    uid: uid,
    username: username,
    email: email,
    branchCode: branchCode,
    accountNumber: accountNumber,
  );
}
