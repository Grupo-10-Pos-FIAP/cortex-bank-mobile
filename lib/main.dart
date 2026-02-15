import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'package:cortex_bank_mobile/app.dart';
import 'package:cortex_bank_mobile/core/di/injection.dart';
import 'package:cortex_bank_mobile/core/providers/auth_provider.dart';
import 'package:cortex_bank_mobile/features/auth/data/repositories/i_auth_repository.dart';
import 'package:cortex_bank_mobile/features/transaction/data/repositories/i_transactions_repository.dart';
import 'package:cortex_bank_mobile/features/transaction/state/transactions_provider.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await dotenv.load(fileName: '.env');
  } catch (e) {
    // ignore: avoid_print
    print('Erro ao carregar .env: $e');
  }

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  configureDependencies();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => AuthProvider(getIt<IAuthRepository>())..loadCurrentUser(),
        ),
        ChangeNotifierProvider(
          create: (_) => TransactionsProvider(getIt<ITransactionsRepository>()),
        ),
      ],
      child: const App(),
    ),
  );
}
