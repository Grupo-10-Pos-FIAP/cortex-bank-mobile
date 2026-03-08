import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get_it/get_it.dart';
import 'package:cortex_bank_mobile/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:cortex_bank_mobile/features/auth/data/repositories/i_auth_repository.dart';
import 'package:cortex_bank_mobile/features/transaction/data/datasources/transactions_datasource.dart';
import 'package:cortex_bank_mobile/features/transaction/data/datasources/transactions_datasource_firestore.dart';
import 'package:cortex_bank_mobile/features/transaction/data/repositories/i_transactions_repository.dart';
import 'package:cortex_bank_mobile/features/transaction/data/repositories/transactions_repository_impl.dart';
import 'package:cortex_bank_mobile/core/services/firebase_service.dart';

final getIt = GetIt.instance;

void configureDependencies() {
  getIt.registerLazySingleton<DatabaseService>(() => FirestoreService());

  // Auth usa Firebase Auth diretamente, sem datasources locais/fake
  getIt.registerLazySingleton<IAuthRepository>(() => AuthRepositoryImpl());

  getIt.registerLazySingleton<TransactionsDataSource>(
    () => TransactionsDataSourceFirestore(FirebaseFirestore.instance),
  );
  getIt.registerLazySingleton<ITransactionsRepository>(
    () => TransactionsRepositoryImpl(getIt()),
  );
}
