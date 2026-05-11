import 'package:cortex_bank_mobile/features/contacts/data/repositories/contacts_repository_impl.dart';
import 'package:cortex_bank_mobile/features/contacts/domain/entities/contact.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../helpers/helpers.dart';

void main() {
  group('ContactsRepositoryImpl', () {
    test(
      'deve retornar contatos do datasource quando getAll for bem-sucedido',
      () async {
        final ds = MockContactsDataSource();
        when(
          () => ds.getAll(),
        ).thenAnswer((_) async => [buildContact(id: '1', name: 'Alice')]);
        final repository = ContactsRepositoryImpl(ds);

        final result = await repository.getAll();

        expect(result, isSuccess);
        expect(result.valueOrNull?.first.name, 'Alice');
        verify(() => ds.getAll()).called(1);
      },
    );

    test(
      'deve mapear exceção para falha amigável quando getAll lançar',
      () async {
        final ds = MockContactsDataSource();
        when(() => ds.getAll()).thenThrow(Exception('db down'));
        final repository = ContactsRepositoryImpl(ds);

        final result = await repository.getAll();

        expect(
          result,
          isFailureWithMessage('Não foi possível carregar seus contatos.'),
        );
      },
    );

    test('deve repassar id quando add for bem-sucedido', () async {
      final ds = MockContactsDataSource();
      when(() => ds.add(any())).thenAnswer((_) async => 'id-1');
      final repository = ContactsRepositoryImpl(ds);

      final result = await repository.add('Alice');

      expect(result, isSuccess);
      expect(result.valueOrNull, 'id-1');
      verify(() => ds.add('Alice')).called(1);
    });

    test('deve mapear exceção quando add lançar', () async {
      final ds = MockContactsDataSource();
      when(() => ds.add(any())).thenThrow(Exception('db down'));
      final repository = ContactsRepositoryImpl(ds);

      final result = await repository.add('Alice');

      expect(result, isFailureWithMessage('Erro ao salvar o contato.'));
    });

    test(
      'deve retornar sucesso quando updateFavorite for bem-sucedido',
      () async {
        final ds = MockContactsDataSource();
        when(() => ds.updateFavorite(any(), any())).thenAnswer((_) async {});
        final repository = ContactsRepositoryImpl(ds);

        final result = await repository.updateFavorite('1', true);

        expect(result, isSuccess);
        verify(() => ds.updateFavorite('1', true)).called(1);
      },
    );

    test('deve mapear exceção quando updateFavorite lançar', () async {
      final ds = MockContactsDataSource();
      when(() => ds.updateFavorite(any(), any())).thenThrow(Exception('boom'));
      final repository = ContactsRepositoryImpl(ds);

      final result = await repository.updateFavorite('1', true);

      expect(
        result,
        isFailureWithMessage('Erro ao atualizar status de favorito.'),
      );
    });

    test('deve retornar sucesso quando delete for bem-sucedido', () async {
      final ds = MockContactsDataSource();
      when(() => ds.delete(any())).thenAnswer((_) async {});
      final repository = ContactsRepositoryImpl(ds);

      final result = await repository.delete('1');

      expect(result, isSuccess);
      verify(() => ds.delete('1')).called(1);
    });

    test('deve mapear exceção quando delete lançar', () async {
      final ds = MockContactsDataSource();
      when(() => ds.delete(any())).thenThrow(Exception('boom'));
      final repository = ContactsRepositoryImpl(ds);

      final result = await repository.delete('1');

      expect(result, isFailureWithMessage('Erro ao excluir o contato.'));
    });

    test(
      'deve retornar lista vazia quando datasource não tiver contatos',
      () async {
        final ds = MockContactsDataSource();
        when(() => ds.getAll()).thenAnswer((_) async => <Contact>[]);
        final repository = ContactsRepositoryImpl(ds);

        final result = await repository.getAll();

        expect(result, isSuccess);
        expect(result.valueOrNull, isEmpty);
      },
    );
  });
}
