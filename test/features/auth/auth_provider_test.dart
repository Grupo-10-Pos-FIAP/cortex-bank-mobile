import 'dart:async';

import 'package:cortex_bank_mobile/core/errors/failure.dart';
import 'package:cortex_bank_mobile/core/utils/result.dart';
import 'package:cortex_bank_mobile/features/auth/domain/entities/user.dart';
import 'package:cortex_bank_mobile/features/auth/presentation/providers/auth_provider.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/helpers.dart';

void main() {
  group('AuthProvider', () {
    test('deve autenticar quando loadCurrentUser retornar usuário', () async {
      final repo = FakeAuthRepository()
        ..currentUserResult = Success(buildUser());
      final provider = AuthProvider(repo);

      await provider.loadCurrentUser();

      expect(provider.isAuthenticated, true);
      expect(provider.user?.uid, 'u1');
      expect(provider.loading, false);
      expect(provider.errorMessage, isNull);
    });

    test('deve expor erro e limpar usuário quando signIn falhar', () async {
      final repo = FakeAuthRepository()
        ..signInResult = FailureResult(
          const Failure(message: 'Credenciais inválidas'),
        );
      final provider = AuthProvider(repo);

      await provider.signIn('gabi@example.com', '123456');

      expect(provider.isAuthenticated, false);
      expect(provider.user, isNull);
      expect(provider.loading, false);
      expect(provider.errorMessage, 'Credenciais inválidas');
    });

    test('deve limpar estado ao sair com sucesso', () async {
      final repo = FakeAuthRepository()
        ..signInResult = Success(buildUser())
        ..signOutResult = const Success(null);
      final provider = AuthProvider(repo);

      await provider.signIn('gabi@example.com', '123456');
      await provider.signOut();

      expect(repo.signOutCalls, 1);
      expect(provider.isAuthenticated, false);
      expect(provider.user, isNull);
      expect(provider.errorMessage, isNull);
      expect(provider.loading, false);
    });

    test(
      'deve definir mensagem de erro quando loadCurrentUser falhar',
      () async {
        final repo = FakeAuthRepository()
          ..currentUserResult = FailureResult(
            const Failure(message: 'Sessao expirada'),
          );
        final provider = AuthProvider(repo);

        await provider.loadCurrentUser();

        expect(provider.user, isNull);
        expect(provider.isAuthenticated, false);
        expect(provider.errorMessage, 'Sessao expirada');
        expect(provider.loading, false);
      },
    );

    test('deve autenticar usuário quando signUp for bem-sucedido', () async {
      final repo = FakeAuthRepository()..signUpResult = Success(buildUser());
      final provider = AuthProvider(repo);

      await provider.signUp('Gabrielle', 'gabi@example.com', '123456');

      expect(repo.signUpCalls, 1);
      expect(repo.lastSignUpFullName, 'Gabrielle');
      expect(provider.user?.uid, 'u1');
      expect(provider.isAuthenticated, true);
      expect(provider.errorMessage, isNull);
    });

    test('deve expor erro quando signUp falhar', () async {
      final repo = FakeAuthRepository()
        ..signUpResult = FailureResult(
          const Failure(message: 'E-mail já cadastrado'),
        );
      final provider = AuthProvider(repo);

      await provider.signUp('Gabrielle', 'gabi@example.com', '123456');

      expect(provider.isAuthenticated, false);
      expect(provider.user, isNull);
      expect(provider.errorMessage, 'E-mail já cadastrado');
    });

    test('deve manter usuário e expor erro quando signOut falhar', () async {
      final repo = FakeAuthRepository()
        ..signInResult = Success(buildUser())
        ..signOutResult = FailureResult(
          const Failure(message: 'Falha ao sair'),
        );
      final provider = AuthProvider(repo);

      await provider.signIn('gabi@example.com', '123456');
      await provider.signOut();

      expect(repo.signOutCalls, 1);
      expect(provider.isAuthenticated, true);
      expect(provider.user?.uid, 'u1');
      expect(provider.errorMessage, 'Falha ao sair');
      expect(provider.loading, false);
    });

    test('deve limpar erro ao chamar clearError', () async {
      final repo = FakeAuthRepository()
        ..signInResult = FailureResult(
          const Failure(message: 'Credenciais inválidas'),
        );
      final provider = AuthProvider(repo);

      await provider.signIn('gabi@example.com', '123456');
      provider.clearError();

      expect(provider.errorMessage, isNull);
    });

    test(
      'deve ignorar segunda chamada concorrente de signIn durante loading',
      () async {
        final repo = FakeAuthRepository()
          ..signInCompleter = Completer<Result<User>>();
        final provider = AuthProvider(repo);

        final firstCall = provider.signIn('gabi@example.com', '123456');
        final secondCall = provider.signIn('gabi@example.com', '123456');

        repo.signInCompleter!.complete(Success(buildUser()));
        await firstCall;
        await secondCall;

        expect(repo.signInCalls, 1);
        expect(provider.isAuthenticated, true);
        expect(provider.loading, false);
      },
    );

    test(
      'deve ignorar segunda chamada concorrente de signUp durante loading',
      () async {
        final repo = FakeAuthRepository()
          ..signUpCompleter = Completer<Result<User>>();
        final provider = AuthProvider(repo);

        final firstCall = provider.signUp('Gabi', 'gabi@example.com', '123456');
        final secondCall = provider.signUp(
          'Gabi',
          'gabi@example.com',
          '123456',
        );

        repo.signUpCompleter!.complete(Success(buildUser()));
        await firstCall;
        await secondCall;

        expect(repo.signUpCalls, 1);
        expect(provider.isAuthenticated, true);
      },
    );

    test(
      'deve ignorar segunda chamada concorrente de loadCurrentUser durante loading',
      () async {
        final repo = FakeAuthRepository()
          ..currentUserCompleter = Completer<Result<User?>>();
        final provider = AuthProvider(repo);

        final firstCall = provider.loadCurrentUser();
        final secondCall = provider.loadCurrentUser();

        repo.currentUserCompleter!.complete(Success(buildUser()));
        await firstCall;
        await secondCall;

        expect(repo.currentUserCalls, 1);
        expect(provider.isAuthenticated, true);
      },
    );

    test(
      'deve limpar usuario quando stream reativo emitir sessao encerrada',
      () async {
        final session = StreamController<bool>();
        final repo = FakeAuthRepository()
          ..firebaseSessionController = session
          ..currentUserResult = Success(buildUser());
        final provider = AuthProvider(repo);
        provider.startReactiveAuthListener();

        await provider.loadCurrentUser();
        expect(provider.isAuthenticated, true);

        session.add(false);
        await Future<void>.delayed(Duration.zero);

        expect(provider.isAuthenticated, false);
        expect(provider.user, isNull);
        await session.close();
      },
    );
  });
}
