import 'package:cortex_bank_mobile/features/auth/data/mappers/auth_error_mapper.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AuthErrorMapper.toFailure', () {
    test('deve traduzir FirebaseAuthException via tradutor', () {
      final error = FirebaseAuthException(code: 'invalid-credential');

      final failure = AuthErrorMapper.toFailure(error);

      expect(
        failure.message,
        'Login não autorizado. Verifique os dados informados e tente novamente.',
      );
    });

    test(
      'deve retornar mensagem de contexto para signIn com FirebaseException',
      () {
        final error = FirebaseException(plugin: 'cloud_firestore');

        final failure = AuthErrorMapper.toFailure(
          error,
          context: AuthErrorContext.signIn,
        );

        expect(failure.message, 'Erro ao fazer login. Tente novamente');
      },
    );

    test(
      'deve retornar mensagem de contexto para signUp com FirebaseException',
      () {
        final error = FirebaseException(plugin: 'cloud_firestore');

        final failure = AuthErrorMapper.toFailure(
          error,
          context: AuthErrorContext.signUp,
        );

        expect(failure.message, 'Erro ao criar conta. Tente novamente');
      },
    );

    test(
      'deve retornar mensagem de contexto para getCurrentUser com FirebaseException',
      () {
        final error = FirebaseException(plugin: 'cloud_firestore');

        final failure = AuthErrorMapper.toFailure(
          error,
          context: AuthErrorContext.getCurrentUser,
        );

        expect(failure.message, 'Erro ao carregar usuário atual');
      },
    );

    test(
      'deve retornar mensagem de contexto para signOut com FirebaseException',
      () {
        final error = FirebaseException(plugin: 'cloud_firestore');

        final failure = AuthErrorMapper.toFailure(
          error,
          context: AuthErrorContext.signOut,
        );

        expect(failure.message, 'Erro ao fazer logout');
      },
    );

    test(
      'deve retornar mensagem de contexto para firestore com FirebaseException',
      () {
        final error = FirebaseException(plugin: 'cloud_firestore');

        final failure = AuthErrorMapper.toFailure(
          error,
          context: AuthErrorContext.firestore,
        );

        expect(failure.message, 'Erro ao criar perfil. Tente novamente');
      },
    );

    test('deve retornar mensagem de contexto para Exception genérica', () {
      final error = Exception('boom');

      final failure = AuthErrorMapper.toFailure(
        error,
        context: AuthErrorContext.signOut,
      );

      expect(failure.message, 'Erro ao fazer logout');
    });
  });
}
