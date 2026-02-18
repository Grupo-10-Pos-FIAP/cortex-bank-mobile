import 'package:flutter/foundation.dart' show defaultTargetPlatform, kIsWeb, TargetPlatform;
import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Retorna as chaves de variáveis de ambiente Firebase necessárias para a plataforma atual.
List<String> getRequiredFirebaseEnvKeys() {
  if (kIsWeb) {
    return [
      'FIREBASE_API_KEY_WEB',
      'FIREBASE_APP_ID_WEB',
      'FIREBASE_MESSAGING_SENDER_ID',
      'FIREBASE_PROJECT_ID',
      'FIREBASE_AUTH_DOMAIN',
      'FIREBASE_STORAGE_BUCKET',
      'FIREBASE_MEASUREMENT_ID',
    ];
  }
  switch (defaultTargetPlatform) {
    case TargetPlatform.android:
      return [
        'FIREBASE_API_KEY_ANDROID',
        'FIREBASE_APP_ID_ANDROID',
        'FIREBASE_MESSAGING_SENDER_ID',
        'FIREBASE_PROJECT_ID',
        'FIREBASE_STORAGE_BUCKET',
      ];
    case TargetPlatform.iOS:
      return [
        'FIREBASE_API_KEY_IOS',
        'FIREBASE_APP_ID_IOS',
        'FIREBASE_MESSAGING_SENDER_ID',
        'FIREBASE_PROJECT_ID',
        'FIREBASE_STORAGE_BUCKET',
        'FIREBASE_IOS_BUNDLE_ID',
      ];
    default:
      return [];
  }
}

/// Verifica se todas as variáveis Firebase necessárias estão definidas no [dotenv].
/// Retorna lista vazia se ok; caso contrário, retorna as chaves que faltam.
List<String> getMissingFirebaseEnvVars() {
  final required = getRequiredFirebaseEnvKeys();
  final missing = <String>[];
  for (final key in required) {
    final value = dotenv.env[key];
    if (value == null || value.trim().isEmpty) {
      missing.add(key);
    }
  }
  return missing;
}
