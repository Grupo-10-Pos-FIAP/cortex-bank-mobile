import 'dart:convert';
import 'dart:typed_data';

import 'package:encrypt/encrypt.dart' as enc;

/// Cifra simétrica AES-256-GCM para blobs do cache sensível.
class EncryptionService {
  EncryptionService(Uint8List keyBytes)
    : _encrypter = enc.Encrypter(
        enc.AES(enc.Key(keyBytes), mode: enc.AESMode.gcm),
      );

  final enc.Encrypter _encrypter;

  /// Retorna base64(IV + ciphertext) — IV de 12 bytes por entrada.
  String encryptString(String plaintext) {
    final iv = enc.IV.fromSecureRandom(12);
    final encrypted = _encrypter.encrypt(plaintext, iv: iv);
    final combined = Uint8List.fromList([...iv.bytes, ...encrypted.bytes]);
    return base64Encode(combined);
  }

  String decryptString(String ciphertextBase64) {
    final combined = base64Decode(ciphertextBase64);
    if (combined.length < 13) {
      throw const FormatException('Ciphertext too short');
    }
    final iv = enc.IV(combined.sublist(0, 12));
    final encryptedBytes = combined.sublist(12);
    return _encrypter.decrypt(enc.Encrypted(encryptedBytes), iv: iv);
  }
}
