import 'package:get_it/get_it.dart';
import 'package:cortex_bank_mobile/features/auth/data/datasources/auth_local_datasource.dart';
import 'package:cortex_bank_mobile/features/auth/data/datasources/auth_local_datasource_in_memory.dart';
import 'package:cortex_bank_mobile/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:cortex_bank_mobile/features/auth/data/datasources/auth_remote_datasource_fake.dart';
import 'package:cortex_bank_mobile/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:cortex_bank_mobile/features/auth/data/repositories/i_auth_repository.dart';
import 'package:cortex_bank_mobile/features/transaction/data/datasources/transactions_datasource.dart';
import 'package:cortex_bank_mobile/features/transaction/data/datasources/transactions_datasource_in_memory.dart';
import 'package:cortex_bank_mobile/features/transaction/data/repositories/i_transactions_repository.dart';
import 'package:cortex_bank_mobile/features/transaction/data/repositories/transactions_repository_impl.dart';

final getIt = GetIt.instance;

void configureDependencies() {
  getIt.registerLazySingleton<AuthLocalDataSource>(
    () => AuthLocalDataSourceInMemory(),
  );
  getIt.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceFake(),
  );
  getIt.registerLazySingleton<IAuthRepository>(
    () => AuthRepositoryImpl(getIt(), getIt()),
  );

  getIt.registerLazySingleton<TransactionsDataSource>(
    () => TransactionsDataSourceInMemory(),
  );
  getIt.registerLazySingleton<ITransactionsRepository>(
    () => TransactionsRepositoryImpl(getIt()),
  );
}
