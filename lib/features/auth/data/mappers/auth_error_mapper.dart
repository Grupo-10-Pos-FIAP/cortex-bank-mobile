import 'package:firebase_auth/firebase_auth.dart';
import 'package:cortex_bank_mobile/core/utils/failure.dart';
import 'package:cortex_bank_mobile/core/utils/firebase_error_translator.dart';

/// Contexto da operação de auth, usado para mensagem genérica.
enum AuthErrorContext {
  signIn,
  signUp,
  getCurrentUser,
  signOut,
  firestore,
}

/// Centraliza a tradução de exceções de auth/Firebase em [Failure].
class AuthErrorMapper {
  AuthErrorMapper._();

  /// Converte [e] em [Failure] usando [firebase_error_translator] quando for [FirebaseAuthException].
  static Failure toFailure(Object e, {AuthErrorContext context = AuthErrorContext.signIn}) {
    if (e is FirebaseAuthException) {
      return Failure(message: translateFirebaseAuthError(e));
    }
    if (e is FirebaseException) {
      return Failure(message: _messageForContext(context));
    }
    return Failure(message: _messageForContext(context));
  }

  static String _messageForContext(AuthErrorContext context) {
    switch (context) {
      case AuthErrorContext.signIn:
        return 'Erro ao fazer login. Tente novamente';
      case AuthErrorContext.signUp:
        return 'Erro ao criar conta. Tente novamente';
      case AuthErrorContext.getCurrentUser:
        return 'Erro ao carregar usuário atual';
      case AuthErrorContext.signOut:
        return 'Erro ao fazer logout';
      case AuthErrorContext.firestore:
        return 'Erro ao criar perfil. Tente novamente';
    }
  }
}
