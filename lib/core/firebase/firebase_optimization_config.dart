import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cortex_bank_mobile/core/utils/safe_log.dart';

/// Configurações de otimização do Firebase Firestore.
/// Habilita offline persistence para que o app funcione sem internet.
class FirebaseOptimizationConfig {
  FirebaseOptimizationConfig._();

  /// Habilita cache offline do Firestore (100 MB).
  /// Deve ser chamado antes de qualquer operação do Firestore.
  static void configureFirestoreOptimizations() {
    try {
      FirebaseFirestore.instance.settings = const Settings(
        persistenceEnabled: true,
        cacheSizeBytes: 104857600, // 100 MB
      );
      safeLogInfo('Firestore offline persistence enabled');
    } catch (e) {
      safeLogError('Erro ao configurar Firestore persistence', e);
    }
  }
}
