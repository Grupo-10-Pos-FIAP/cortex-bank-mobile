import 'dart:typed_data';

import 'package:cortex_bank_mobile/core/security/encryption_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late EncryptionService encryption;

  setUp(() {
    encryption = EncryptionService(
      Uint8List.fromList(List<int>.generate(32, (i) => i)),
    );
  });

  test('encryptString e decryptString são inversos', () {
    const plain = '{"uid":"u1","email":"a@b.com"}';
    final cipher = encryption.encryptString(plain);
    expect(cipher, isNot(plain));
    expect(encryption.decryptString(cipher), plain);
  });

  test('cada cifra usa IV diferente', () {
    const plain = 'same';
    final a = encryption.encryptString(plain);
    final b = encryption.encryptString(plain);
    expect(a, isNot(b));
    expect(encryption.decryptString(a), plain);
    expect(encryption.decryptString(b), plain);
  });

  test('decryptString falha com blob inválido', () {
    expect(() => encryption.decryptString('not-valid-base64!!!'), throwsA(anything));
  });
}
