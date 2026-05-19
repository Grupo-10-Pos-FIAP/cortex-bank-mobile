import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Persiste a chave mestra de cifra do cache sensível no armazenamento seguro do SO.
class SecureKeyStore {
  SecureKeyStore({FlutterSecureStorage? storage})
    : _storage =
          storage ??
          const FlutterSecureStorage(
            aOptions: AndroidOptions(encryptedSharedPreferences: true),
          );

  static const _keyName = 'app.master_encryption_key';
  static const _keyLength = 32;

  final FlutterSecureStorage _storage;

  /// Garante que existe uma chave de 32 bytes; cria na primeira execução.
  Future<Uint8List> getOrCreateKey() async {
    final existing = await _storage.read(key: _keyName);
    if (existing != null && existing.isNotEmpty) {
      return base64Decode(existing);
    }
    final key = Uint8List.fromList(
      List<int>.generate(_keyLength, (_) => Random.secure().nextInt(256)),
    );
    await _storage.write(key: _keyName, value: base64Encode(key));
    return key;
  }

  /// Inicialização explícita no arranque do app.
  static Future<void> ensureKey({SecureKeyStore? store}) async {
    await (store ?? SecureKeyStore()).getOrCreateKey();
  }
}
