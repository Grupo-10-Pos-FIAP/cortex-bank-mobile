import 'package:cortex_bank_mobile/core/errors/failure.dart';
import 'package:cortex_bank_mobile/core/utils/result.dart';
import 'package:cortex_bank_mobile/features/contacts/state/contacts_provider.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/helpers.dart';

void main() {
  group('ContactsProvider', () {
    test('deve preencher lista quando loadContacts for bem-sucedido', () async {
      final repo = FakeContactsRepository()
        ..getAllResult = Success([
          buildContact(id: '1', name: 'Alice'),
          buildContact(id: '2', name: 'Bob'),
        ]);
      final provider = ContactsProvider(repo);

      await provider.loadContacts();

      expect(provider.contacts.length, 2);
      expect(provider.contacts.map((c) => c.name).toList(), ['Alice', 'Bob']);
      expect(provider.errorMessage, isNull);
      expect(provider.isLoading, false);
    });

    test(
      'deve reverter favorito otimista quando toggleFavorite falhar',
      () async {
        final repo = FakeContactsRepository()
          ..updateFavoriteResult = FailureResult(
            const Failure(message: 'Falha ao atualizar favorito'),
          );
        final provider = ContactsProvider(repo);
        final contact = buildContact(id: '1', name: 'Alice');

        await provider.toggleFavorite(contact);

        expect(contact.isFavorite, false);
        expect(repo.lastUpdateFavoriteId, '1');
        expect(repo.lastUpdateFavoriteValue, true);
        expect(provider.errorMessage, 'Falha ao atualizar favorito');
      },
    );

    test(
      'deve manter novo estado quando toggleFavorite for bem-sucedido',
      () async {
        final repo = FakeContactsRepository()
          ..updateFavoriteResult = const Success(null);
        final provider = ContactsProvider(repo);
        final contact = buildContact(id: '1');

        await provider.toggleFavorite(contact);

        expect(contact.isFavorite, true);
        expect(provider.errorMessage, isNull);
      },
    );

    test(
      'deve expor erro e esvaziar lista quando loadContacts falhar',
      () async {
        final repo = FakeContactsRepository()
          ..getAllResult = FailureResult(
            const Failure(message: 'Erro ao carregar contatos'),
          );
        final provider = ContactsProvider(repo);

        await provider.loadContacts();

        expect(provider.contacts, isEmpty);
        expect(provider.errorMessage, 'Erro ao carregar contatos');
        expect(provider.isLoading, false);
      },
    );

    test(
      'deve acrescentar contato quando addContact for bem-sucedido',
      () async {
        final repo = FakeContactsRepository()..addResult = const Success('c3');
        final provider = ContactsProvider(repo);

        await provider.addContact('Carol');

        expect(repo.addCalls, 1);
        expect(repo.lastAddName, 'Carol');
        expect(provider.contacts.map((c) => c.id).toList(), ['c3']);
        expect(provider.contacts.first.name, 'Carol');
        expect(provider.errorMessage, isNull);
      },
    );

    test(
      'deve definir erro e não alterar lista quando addContact falhar',
      () async {
        final repo = FakeContactsRepository()
          ..addResult = FailureResult(
            const Failure(message: 'Erro ao salvar contato'),
          );
        final provider = ContactsProvider(repo);

        await provider.addContact('Carol');

        expect(provider.contacts, isEmpty);
        expect(provider.errorMessage, 'Erro ao salvar contato');
        expect(provider.isLoading, false);
      },
    );

    test('deve remover item quando deleteContact for bem-sucedido', () async {
      final repo = FakeContactsRepository()
        ..getAllResult = Success([
          buildContact(id: '1', name: 'Alice'),
          buildContact(id: '2', name: 'Bob'),
        ]);
      final provider = ContactsProvider(repo);
      await provider.loadContacts();

      await provider.deleteContact('1');

      expect(repo.deleteCalls, 1);
      expect(provider.contacts.map((c) => c.id).toList(), ['2']);
      expect(provider.errorMessage, isNull);
    });

    test(
      'deve manter lista e expor erro quando deleteContact falhar',
      () async {
        final repo = FakeContactsRepository()
          ..getAllResult = Success([buildContact(id: '1', name: 'Alice')])
          ..deleteResult = FailureResult(
            const Failure(message: 'Erro ao excluir contato'),
          );
        final provider = ContactsProvider(repo);
        await provider.loadContacts();

        await provider.deleteContact('1');

        expect(provider.contacts.map((c) => c.id).toList(), ['1']);
        expect(provider.errorMessage, 'Erro ao excluir contato');
      },
    );

    test('favoriteContacts deve retornar apenas favoritos', () async {
      final repo = FakeContactsRepository()
        ..getAllResult = Success([
          buildContact(id: '1', name: 'Alice', isFavorite: true),
          buildContact(id: '2', name: 'Bob'),
        ]);
      final provider = ContactsProvider(repo);

      await provider.loadContacts();

      expect(provider.favoriteContacts.map((c) => c.id).toList(), ['1']);
    });

    test('deve limpar mensagem de erro ao chamar clearError', () async {
      final repo = FakeContactsRepository()
        ..addResult = FailureResult(
          const Failure(message: 'Erro ao salvar contato'),
        );
      final provider = ContactsProvider(repo);
      await provider.addContact('Carol');

      provider.clearError();

      expect(provider.errorMessage, isNull);
    });

    test('setSelectedContactId deve refletir em selectedContact', () async {
      final repo = FakeContactsRepository()
        ..getAllResult = Success([
          buildContact(id: '1', name: 'Alice'),
          buildContact(id: '2', name: 'Bob'),
        ]);
      final provider = ContactsProvider(repo);
      await provider.loadContacts();

      provider.setSelectedContactId('2');

      expect(provider.selectedContactId, '2');
      expect(provider.selectedContact?.name, 'Bob');
    });

    test(
      'deleteContact deve limpar seleção quando o contato selecionado for removido',
      () async {
        final repo = FakeContactsRepository()
          ..getAllResult = Success([buildContact(id: '1', name: 'Alice')])
          ..deleteResult = const Success(null);
        final provider = ContactsProvider(repo);
        await provider.loadContacts();
        provider.setSelectedContactId('1');

        await provider.deleteContact('1');

        expect(provider.selectedContactId, isNull);
        expect(provider.selectedContact, isNull);
      },
    );
  });
}
