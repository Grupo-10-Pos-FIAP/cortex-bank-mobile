import 'dart:typed_data';

import 'package:cortex_bank_mobile/core/cache/cache_serializers.dart';
import 'package:cortex_bank_mobile/core/cache/sensitive_cache_manager.dart';
import 'package:cortex_bank_mobile/core/security/encryption_service.dart';
import 'package:cortex_bank_mobile/features/auth/domain/entities/user.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  setUp(() async {
    SensitiveCacheManager.useEncryptionForTests(
      EncryptionService(
        Uint8List.fromList(List<int>.generate(32, (i) => i + 1)),
      ),
    );
    SensitiveCacheManager.clear();
  });

  test('setJson e getJson preservam User', () {
    final user = User(
      uid: 'uid-1',
      username: 'Ana',
      email: 'ana@test.com',
      branchCode: '0001',
      accountNumber: '12345-6',
    );
    SensitiveCacheManager.setJson(
      'auth.user.uid-1',
      CacheSerializers.userToJson(user),
    );
    final read = SensitiveCacheManager.getJson<User>(
      'auth.user.uid-1',
      (json) => CacheSerializers.userFromJson(json! as Map<String, dynamic>),
    );
    expect(read?.email, 'ana@test.com');
    expect(read?.accountNumber, '12345-6');
  });

  test('entrada expirada retorna null', () async {
    SensitiveCacheManager.setJson(
      'k',
      {'x': 1},
      ttl: const Duration(milliseconds: 50),
    );
    await Future<void>.delayed(const Duration(milliseconds: 60));
    final read = SensitiveCacheManager.getJson<int>(
      'k',
      (json) => (json as Map<String, dynamic>)['x'] as int,
    );
    expect(read, isNull);
  });

  test('blob adulterado é removido e retorna null', () {
    SensitiveCacheManager.setJson('k', {'ok': true});
    // Força ciphertext inválido via reflexão indireta: remove e set manual não exposto.
    // Simula falha de decrypt regravando com initialize + tamper interno impossível;
    // em vez disso, testamos decrypt falhando com chave diferente.
    SensitiveCacheManager.useEncryptionForTests(
      EncryptionService(
        Uint8List.fromList(List<int>.generate(32, (i) => i + 2)),
      ),
    );
    final read = SensitiveCacheManager.getJson<bool>(
      'k',
      (json) => (json as Map<String, dynamic>)['ok'] as bool,
    );
    expect(read, isNull);
  });
}
