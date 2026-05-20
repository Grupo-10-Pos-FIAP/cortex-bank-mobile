import 'dart:convert';

import 'package:cortex_bank_mobile/core/security/encryption_service.dart';
import 'package:cortex_bank_mobile/core/security/secure_key_store.dart';

/// Cache em memória com valores cifrados (AES-256-GCM) para dados sensíveis (PII).
class SensitiveCacheManager {
  SensitiveCacheManager._();

  static final Map<String, _SensitiveCacheEntry> _cache = {};
  static EncryptionService? _encryption;

  /// Inicializa chave no secure storage e o serviço de cifra.
  static Future<void> initialize({
    SecureKeyStore? keyStore,
    EncryptionService? encryptionForTests,
  }) async {
    _cache.clear();
    if (encryptionForTests != null) {
      _encryption = encryptionForTests;
      return;
    }
    final keyBytes = await (keyStore ?? SecureKeyStore()).getOrCreateKey();
    _encryption = EncryptionService(keyBytes);
  }

  /// Apenas para testes: injeta cifra sem secure storage.
  static void useEncryptionForTests(EncryptionService encryption) {
    _encryption = encryption;
  }

  static EncryptionService get _enc {
    final e = _encryption;
    if (e == null) {
      throw StateError(
        'SensitiveCacheManager not initialized. Call initialize() in main.',
      );
    }
    return e;
  }

  static void setJson(String key, Object jsonValue, {Duration? ttl}) {
    final plaintext = jsonEncode(jsonValue);
    final ciphertext = _enc.encryptString(plaintext);
    final expiry = ttl != null ? DateTime.now().add(ttl) : null;
    _cache[key] = _SensitiveCacheEntry(ciphertext: ciphertext, expiry: expiry);
  }

  static T? getJson<T>(String key, T Function(Object? json) decode) {
    final entry = _cache[key];
    if (entry == null) return null;
    if (entry.isExpired) {
      _cache.remove(key);
      return null;
    }
    try {
      final plaintext = _enc.decryptString(entry.ciphertext);
      final decoded = jsonDecode(plaintext);
      return decode(decoded);
    } catch (_) {
      _cache.remove(key);
      return null;
    }
  }

  static void remove(String key) => _cache.remove(key);

  static void clear() => _cache.clear();

  static bool isFresh(String key) {
    final entry = _cache[key];
    if (entry == null) return false;
    return !entry.isExpired;
  }

  static int get size => _cache.length;
}

class _SensitiveCacheEntry {
  final String ciphertext;
  final DateTime? expiry;

  const _SensitiveCacheEntry({required this.ciphertext, this.expiry});

  bool get isExpired => expiry != null && DateTime.now().isAfter(expiry!);
}
