import 'package:firebase_auth/firebase_auth.dart';

/// Translates Firebase Auth error codes to user-friendly Portuguese messages.
String translateFirebaseAuthError(FirebaseAuthException e) {
  switch (e.code) {
    case 'user-not-found':
    case 'wrong-password':
    case 'invalid-credential':
      return 'Login não autorizado. Verifique os dados informados e tente novamente.';
    case 'email-already-in-use':
      return 'Este email já está cadastrado';
    case 'weak-password':
      return 'A senha deve ter no mínimo 8 caracteres';
    case 'invalid-email':
      return 'Email inválido';
    case 'network-request-failed':
      return 'Erro de conexão. Verifique sua internet';
    case 'too-many-requests':
      return 'Muitas tentativas. Tente novamente em alguns minutos';
    case 'user-disabled':
      return 'Conta desabilitada. Entre em contato com o suporte';
    case 'operation-not-allowed':
      return 'Operação não permitida';
    default:
      return 'Login não autorizado. Verifique os dados informados e tente novamente.';
  }
}
