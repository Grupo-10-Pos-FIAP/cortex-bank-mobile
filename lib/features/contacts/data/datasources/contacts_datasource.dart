import 'package:cortex_bank_mobile/features/contacts/domain/entities/contact.dart';

abstract class ContactsDataSource {
  Future<List<Contact>> getAll();
  Future<String> add(String name);
  Future<void> updateFavorite(String id, bool isFavorite);
  Future<void> delete(String id);
}
