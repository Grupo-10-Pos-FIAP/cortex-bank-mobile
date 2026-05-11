import 'package:cortex_bank_mobile/core/utils/firebase_user_error_message.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_test/flutter_test.dart';

const _fallback = 'Erro genérico';

void main() {
  group('firebaseErrorUserMessage — FirebaseException', () {
    test('deve mapear permission-denied para acesso negado', () {
      final error = FirebaseException(
        plugin: 'cloud_firestore',
        code: 'permission-denied',
      );

      final message = firebaseErrorUserMessage(error, fallback: _fallback);

      expect(
        message,
        'Acesso negado ao salvar dados. Confira se você está logado e as regras de segurança do Firebase.',
      );
    });

    test('deve mapear unauthenticated para sessão inválida', () {
      final error = FirebaseException(
        plugin: 'cloud_firestore',
        code: 'unauthenticated',
      );

      final message = firebaseErrorUserMessage(error, fallback: _fallback);

      expect(message, 'Sessão inválida ou expirada. Faça login novamente.');
    });

    test('deve mapear unavailable para serviço indisponível', () {
      final error = FirebaseException(
        plugin: 'cloud_firestore',
        code: 'unavailable',
      );

      final message = firebaseErrorUserMessage(error, fallback: _fallback);

      expect(
        message,
        'Serviço temporariamente indisponível. Verifique sua internet e tente de novo.',
      );
    });

    test('deve mapear deadline-exceeded para serviço indisponível', () {
      final error = FirebaseException(
        plugin: 'cloud_firestore',
        code: 'deadline-exceeded',
      );

      final message = firebaseErrorUserMessage(error, fallback: _fallback);

      expect(
        message,
        'Serviço temporariamente indisponível. Verifique sua internet e tente de novo.',
      );
    });

    test('deve mapear network-request-failed para conectividade', () {
      final error = FirebaseException(
        plugin: 'cloud_firestore',
        code: 'network-request-failed',
      );

      final message = firebaseErrorUserMessage(error, fallback: _fallback);

      expect(
        message,
        'Sem conexão ou falha de rede. Verifique sua internet e tente novamente.',
      );
    });

    test('deve mapear cancelled para operação cancelada', () {
      final error = FirebaseException(
        plugin: 'cloud_firestore',
        code: 'cancelled',
      );

      final message = firebaseErrorUserMessage(error, fallback: _fallback);

      expect(message, 'Operação cancelada.');
    });

    test('deve mapear quota-exceeded para limite do serviço', () {
      final error = FirebaseException(
        plugin: 'cloud_firestore',
        code: 'quota-exceeded',
      );

      final message = firebaseErrorUserMessage(error, fallback: _fallback);

      expect(
        message,
        'Limite do serviço foi atingido. Tente novamente mais tarde.',
      );
    });

    test('deve mapear storage/unauthorized para permissão de upload', () {
      final error = FirebaseException(
        plugin: 'storage',
        code: 'storage/unauthorized',
      );

      final message = firebaseErrorUserMessage(error, fallback: _fallback);

      expect(
        message,
        'Sem permissão para enviar o arquivo. Faça login novamente.',
      );
    });

    test('deve mapear unauthorized no storage para permissão de upload', () {
      final error = FirebaseException(plugin: 'storage', code: 'unauthorized');

      final message = firebaseErrorUserMessage(error, fallback: _fallback);

      expect(
        message,
        'Sem permissão para enviar o arquivo. Faça login novamente.',
      );
    });

    test('deve mapear storage/canceled para upload cancelado', () {
      final error = FirebaseException(
        plugin: 'storage',
        code: 'storage/canceled',
      );

      final message = firebaseErrorUserMessage(error, fallback: _fallback);

      expect(message, 'Envio do arquivo foi cancelado.');
    });

    test('deve mapear storage/retry-limit-exceeded', () {
      final error = FirebaseException(
        plugin: 'storage',
        code: 'storage/retry-limit-exceeded',
      );

      final message = firebaseErrorUserMessage(error, fallback: _fallback);

      expect(
        message,
        'Não foi possível enviar o arquivo após várias tentativas. Tente de novo.',
      );
    });

    test('deve mapear storage/invalid-format', () {
      final error = FirebaseException(
        plugin: 'storage',
        code: 'storage/invalid-format',
      );

      final message = firebaseErrorUserMessage(error, fallback: _fallback);

      expect(message, 'Formato do arquivo não é aceito.');
    });

    test('deve mapear storage/object-not-found', () {
      final error = FirebaseException(
        plugin: 'storage',
        code: 'storage/object-not-found',
      );

      final message = firebaseErrorUserMessage(error, fallback: _fallback);

      expect(message, 'Arquivo não encontrado no armazenamento.');
    });

    test('deve retornar fallback para código Firebase desconhecido', () {
      final error = FirebaseException(
        plugin: 'cloud_firestore',
        code: 'some-other-code',
      );

      final message = firebaseErrorUserMessage(error, fallback: _fallback);

      expect(message, _fallback);
    });

    test(
      'deve mapear variante storage com unauthorized para permissão de upload',
      () {
        // Caso onde o código contém "storage/" e "unauthorized" mas não bate em case exato.
        final error = FirebaseException(
          plugin: 'storage',
          code: 'storage/something-unauthorized',
        );

        final message = firebaseErrorUserMessage(error, fallback: _fallback);

        expect(
          message,
          'Sem permissão para enviar o arquivo. Faça login novamente.',
        );
      },
    );
  });

  group('firebaseErrorUserMessage — erros não Firebase', () {
    test('deve detectar texto unauthenticated em Exception', () {
      final error = Exception('Usuário não autenticado');

      final message = firebaseErrorUserMessage(error, fallback: _fallback);

      expect(message, 'Você precisa estar logado para continuar.');
    });

    test('deve retornar fallback para Exception genérica', () {
      final error = Exception('boom');

      final message = firebaseErrorUserMessage(error, fallback: _fallback);

      expect(message, _fallback);
    });
  });
}
