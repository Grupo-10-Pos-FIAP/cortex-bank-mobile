import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

/// Loga erro sem incluir o objeto exceção completo (evita PII/stack em release).
/// Usa apenas [runtimeType] e [code] quando disponível.
void safeLogError(String context, Object e) {
  String code = 'n/a';
  if (e is FirebaseAuthException) {
    code = e.code;
  } else if (e is FirebaseException) {
    code = e.code;
  }
  debugPrint('$context type=${e.runtimeType} code=$code');
}
