import 'package:cortex_bank_mobile/core/utils/firebase_error_translator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';

FirebaseAuthException _err(String code) =>
    FirebaseAuthException(code: code, message: 'msg');

void main() {
  group('translateFirebaseAuthError', () {
    test('deve mapear user-not-found para mensagem de login não autorizado', () {
      expect(
        translateFirebaseAuthError(_err('user-not-found')),
        'Login não autorizado. Verifique os dados informados e tente novamente.',
      );
    });

    test('deve mapear wrong-password para mensagem de login não autorizado', () {
      expect(
        translateFirebaseAuthError(_err('wrong-password')),
        'Login não autorizado. Verifique os dados informados e tente novamente.',
      );
    });

    test(
      'deve mapear invalid-credential para mensagem de login não autorizado',
      () {
        expect(
          translateFirebaseAuthError(_err('invalid-credential')),
          'Login não autorizado. Verifique os dados informados e tente novamente.',
        );
      },
    );

    test('deve mapear email-already-in-use para email já cadastrado', () {
      expect(
        translateFirebaseAuthError(_err('email-already-in-use')),
        'Este email já está cadastrado',
      );
    });

    test('deve mapear weak-password para regra de tamanho mínimo', () {
      expect(
        translateFirebaseAuthError(_err('weak-password')),
        'A senha deve ter no mínimo 8 caracteres',
      );
    });

    test('deve mapear invalid-email', () {
      expect(
        translateFirebaseAuthError(_err('invalid-email')),
        'Email inválido',
      );
    });

    test('deve mapear network-request-failed para conectividade', () {
      expect(
        translateFirebaseAuthError(_err('network-request-failed')),
        'Erro de conexão. Verifique sua internet',
      );
    });

    test('deve mapear too-many-requests', () {
      expect(
        translateFirebaseAuthError(_err('too-many-requests')),
        'Muitas tentativas. Tente novamente em alguns minutos',
      );
    });

    test('deve mapear user-disabled', () {
      expect(
        translateFirebaseAuthError(_err('user-disabled')),
        'Conta desabilitada. Entre em contato com o suporte',
      );
    });

    test('deve mapear operation-not-allowed', () {
      expect(
        translateFirebaseAuthError(_err('operation-not-allowed')),
        'Operação não permitida',
      );
    });

    test('deve usar fallback para código desconhecido', () {
      expect(
        translateFirebaseAuthError(_err('some-other-code')),
        'Login não autorizado. Verifique os dados informados e tente novamente.',
      );
    });
  });
}
