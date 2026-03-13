import 'package:cortex_bank_mobile/core/utils/result.dart';
import '../../models/contact.dart';

abstract class IContactsRepository {
  Future<Result<List<Contact>>> getAll();
  Future<Result<String>> add(String name);
  Future<Result<void>> updateFavorite(String id, bool isFavorite);
  Future<Result<void>> delete(String id);
}
