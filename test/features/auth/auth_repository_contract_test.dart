import 'package:cortex_bank_mobile/core/errors/failure.dart';
import 'package:cortex_bank_mobile/core/utils/result.dart';
import 'package:cortex_bank_mobile/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../helpers/helpers.dart';

void main() {
  group('AuthRepositoryImpl', () {
    test('deve repassar usuário quando signIn for bem-sucedido', () async {
      final remote = MockAuthDataSource();
      when(
        () => remote.signIn(any(), any()),
      ).thenAnswer((_) async => Success(buildUser()));
      final repository = AuthRepositoryImpl(remote: remote);

      final result = await repository.signIn('gabi@example.com', '123456');

      expect(result, isSuccess);
      expect(result.valueOrNull?.uid, 'u1');
      verify(() => remote.signIn('gabi@example.com', '123456')).called(1);
    });

    test('deve repassar falha quando signOut falhar', () async {
      final remote = MockAuthDataSource();
      when(() => remote.signOut()).thenAnswer(
        (_) async =>
            FailureResult<void>(const Failure(message: 'Erro ao sair')),
      );
      final repository = AuthRepositoryImpl(remote: remote);

      final result = await repository.signOut();

      expect(result, isFailureWithMessage('Erro ao sair'));
    });

    test('deve repassar usuário quando signUp for bem-sucedido', () async {
      final remote = MockAuthDataSource();
      when(
        () => remote.signUp(any(), any(), any()),
      ).thenAnswer((_) async => Success(buildUser()));
      final repository = AuthRepositoryImpl(remote: remote);

      final result = await repository.signUp(
        'Gabrielle',
        'gabi@example.com',
        '123456',
      );

      expect(result, isSuccess);
      expect(result.valueOrNull?.uid, 'u1');
      verify(
        () => remote.signUp('Gabrielle', 'gabi@example.com', '123456'),
      ).called(1);
    });

    test('deve repassar falha quando signUp falhar', () async {
      final remote = MockAuthDataSource();
      when(() => remote.signUp(any(), any(), any())).thenAnswer(
        (_) async =>
            FailureResult(const Failure(message: 'E-mail já cadastrado')),
      );
      final repository = AuthRepositoryImpl(remote: remote);

      final result = await repository.signUp(
        'Gabrielle',
        'gabi@example.com',
        '123456',
      );

      expect(result, isFailureWithMessage('E-mail já cadastrado'));
    });

    test(
      'deve repassar Success(null) quando não houver usuário atual',
      () async {
        final remote = MockAuthDataSource();
        when(
          () => remote.getCurrentUser(),
        ).thenAnswer((_) async => const Success(null));
        final repository = AuthRepositoryImpl(remote: remote);

        final result = await repository.getCurrentUser();

        expect(result, isSuccess);
        expect(result.valueOrNull, isNull);
      },
    );

    test('deve repassar falha quando signIn falhar', () async {
      final remote = MockAuthDataSource();
      when(() => remote.signIn(any(), any())).thenAnswer(
        (_) async =>
            FailureResult(const Failure(message: 'Credenciais inválidas')),
      );
      final repository = AuthRepositoryImpl(remote: remote);

      final result = await repository.signIn('a@b.com', '12345678');

      expect(result, isFailureWithMessage('Credenciais inválidas'));
    });

    test('deve repassar sucesso quando signOut for bem-sucedido', () async {
      final remote = MockAuthDataSource();
      when(() => remote.signOut()).thenAnswer((_) async => const Success(null));
      final repository = AuthRepositoryImpl(remote: remote);

      final result = await repository.signOut();

      expect(result, isSuccess);
      verify(() => remote.signOut()).called(1);
    });

    test('deve repassar falha quando getCurrentUser falhar', () async {
      final remote = MockAuthDataSource();
      when(() => remote.getCurrentUser()).thenAnswer(
        (_) async => FailureResult(const Failure(message: 'Sessão expirada')),
      );
      final repository = AuthRepositoryImpl(remote: remote);

      final result = await repository.getCurrentUser();

      expect(result, isFailureWithMessage('Sessão expirada'));
    });

    test(
      'deve repassar usuário quando getCurrentUser retornar valor',
      () async {
        final remote = MockAuthDataSource();
        when(
          () => remote.getCurrentUser(),
        ).thenAnswer((_) async => Success(buildUser(uid: 'remote-uid')));
        final repository = AuthRepositoryImpl(remote: remote);

        final result = await repository.getCurrentUser();

        expect(result, isSuccess);
        expect(result.valueOrNull?.uid, 'remote-uid');
      },
    );

    test('deve repassar stream de sessão do datasource', () async {
      final remote = MockAuthDataSource();
      when(
        () => remote.watchFirebaseSessionSignedIn(),
      ).thenAnswer((_) => Stream<bool>.fromIterable([true, false]));
      final repository = AuthRepositoryImpl(remote: remote);

      final values = await repository
          .watchFirebaseSessionSignedIn()
          .take(2)
          .toList();

      expect(values, [true, false]);
      verify(() => remote.watchFirebaseSessionSignedIn()).called(1);
    });
  });
}
