import 'package:cortex_bank_mobile/core/errors/failure.dart';
import 'package:cortex_bank_mobile/core/utils/result.dart';
import 'package:cortex_bank_mobile/core/utils/safe_log.dart';
import 'package:cortex_bank_mobile/features/contacts/models/contact.dart';
import '../datasources/contacts_datasource.dart';
import 'i_contacts_repository.dart';

class ContactsRepositoryImpl implements IContactsRepository {
  final ContactsDataSource _dataSource;

  ContactsRepositoryImpl(this._dataSource);

  @override
  Future<Result<List<Contact>>> getAll() async {
    try {
      final contacts = await _dataSource.getAll();
      return Success(contacts);
    } catch (e) {
      safeLogError('Erro ao buscar lista de contatos', e);
      return FailureResult(
        Failure(message: 'Não foi possível carregar seus contatos.'),
      );
    }
  }

  @override
  Future<Result<String>> add(String name) async {
    try {
      final id = await _dataSource.add(name);
      return Success(id);
    } catch (e) {
      safeLogError('Erro ao adicionar novo contato: $name', e);
      return FailureResult(Failure(message: 'Erro ao salvar o contato.'));
    }
  }

  @override
  Future<Result<void>> updateFavorite(String id, bool isFavorite) async {
    try {
      await _dataSource.updateFavorite(id, isFavorite);
      return const Success(null);
    } catch (e) {
      safeLogError('Erro ao atualizar favorito do contato ID: $id', e);
      return FailureResult(
        Failure(message: 'Erro ao atualizar status de favorito.'),
      );
    }
  }

  @override
  Future<Result<void>> delete(String id) async {
    try {
      await _dataSource.delete(id);
      return const Success(null);
    } catch (e) {
      safeLogError('Erro ao deletar contato ID: $id', e);
      return FailureResult(Failure(message: 'Erro ao excluir o contato.'));
    }
  }
}
