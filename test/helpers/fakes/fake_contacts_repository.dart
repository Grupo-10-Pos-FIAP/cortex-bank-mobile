import 'package:cortex_bank_mobile/core/errors/failure.dart';
import 'package:cortex_bank_mobile/core/utils/result.dart';
import 'package:cortex_bank_mobile/features/contacts/data/repositories/i_contacts_repository.dart';
import 'package:cortex_bank_mobile/features/contacts/models/contact.dart';

class FakeContactsRepository implements IContactsRepository {
  Result<List<Contact>>? getAllResult;
  Result<String>? addResult;
  Result<void>? updateFavoriteResult;
  Result<void>? deleteResult;

  int getAllCalls = 0;
  int addCalls = 0;
  int updateFavoriteCalls = 0;
  int deleteCalls = 0;

  String? lastAddName;
  String? lastUpdateFavoriteId;
  bool? lastUpdateFavoriteValue;
  String? lastDeleteId;

  @override
  Future<Result<String>> add(String name) async {
    addCalls += 1;
    lastAddName = name;
    return addResult ??
        FailureResult<String>(
          const Failure(message: 'addResult not configured'),
        );
  }

  @override
  Future<Result<void>> delete(String id) async {
    deleteCalls += 1;
    lastDeleteId = id;
    return deleteResult ?? const Success(null);
  }

  @override
  Future<Result<List<Contact>>> getAll() async {
    getAllCalls += 1;
    return getAllResult ?? const Success(<Contact>[]);
  }

  @override
  Future<Result<void>> updateFavorite(String id, bool isFavorite) async {
    updateFavoriteCalls += 1;
    lastUpdateFavoriteId = id;
    lastUpdateFavoriteValue = isFavorite;
    return updateFavoriteResult ?? const Success(null);
  }
}
