import 'package:cortex_bank_mobile/features/auth/data/datasources/auth_datasource.dart';
import 'package:cortex_bank_mobile/features/auth/domain/repositories/i_auth_repository.dart';
import 'package:cortex_bank_mobile/features/contacts/data/datasources/contacts_datasource.dart';
import 'package:cortex_bank_mobile/features/contacts/domain/repositories/i_contacts_repository.dart';
import 'package:cortex_bank_mobile/features/transaction/data/datasources/receipt_storage_datasource.dart';
import 'package:cortex_bank_mobile/features/transaction/data/datasources/transactions_datasource.dart';
import 'package:cortex_bank_mobile/features/transaction/domain/repositories/i_transactions_repository.dart';
import 'package:mocktail/mocktail.dart';

class MockAuthDataSource extends Mock implements AuthDataSource {}

class MockAuthRepository extends Mock implements IAuthRepository {}

class MockContactsDataSource extends Mock implements ContactsDataSource {}

class MockContactsRepository extends Mock implements IContactsRepository {}

class MockTransactionsDataSource extends Mock
    implements TransactionsDataSource {}

class MockReceiptStorageDataSource extends Mock
    implements ReceiptStorageDataSource {}

class MockTransactionsRepository extends Mock
    implements ITransactionsRepository {}
