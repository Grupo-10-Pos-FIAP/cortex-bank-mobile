import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'package:cortex_bank_mobile/app.dart';
import 'package:cortex_bank_mobile/core/di/injection.dart';
import 'package:cortex_bank_mobile/features/auth/state/auth_provider.dart';
import 'package:cortex_bank_mobile/features/auth/data/repositories/i_auth_repository.dart';
import 'package:cortex_bank_mobile/features/transaction/data/repositories/i_transactions_repository.dart';
import 'package:cortex_bank_mobile/features/transaction/state/transactions_provider.dart';
import 'package:cortex_bank_mobile/core/utils/env_validator.dart';
import 'package:cortex_bank_mobile/core/utils/safe_log.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await dotenv.load(fileName: '.env');
  } catch (e) {
    safeLogError('Erro ao carregar .env', e);
  }

  final missingEnv = getMissingFirebaseEnvVars();
  if (missingEnv.isNotEmpty) {
    runApp(_ConfigErrorApp(missingKeys: missingEnv));
    return;
  }

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  configureDependencies();

  // Criar e inicializar AuthProvider antes de runApp
  final authProvider = AuthProvider(getIt<IAuthRepository>());
  await authProvider.loadCurrentUser();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: authProvider),
        ChangeNotifierProvider(
          create: (_) => TransactionsProvider(getIt<ITransactionsRepository>()),
        ),
      ],
      child: const App(),
    ),
  );
}

/// Tela exibida quando variáveis .env necessárias ao Firebase estão ausentes.
class _ConfigErrorApp extends StatelessWidget {
  const _ConfigErrorApp({required this.missingKeys});

  final List<String> missingKeys;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Cortex Bank Mobile',
      home: Scaffold(
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Icon(Icons.error_outline, size: 64, color: Colors.orange),
                const SizedBox(height: 24),
                const Text(
                  'Configuração incompleta',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Verifique o arquivo .env. Faltam variáveis necessárias para o Firebase.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 16),
                Text(
                  'Variáveis ausentes: ${missingKeys.join(", ")}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 12, fontFamily: 'monospace'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
