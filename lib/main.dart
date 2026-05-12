import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:cortex_bank_mobile/app.dart';
import 'package:cortex_bank_mobile/core/cache/cache_manager.dart';
import 'package:cortex_bank_mobile/core/di/injection.dart';
import 'package:cortex_bank_mobile/features/auth/presentation/providers/auth_provider.dart';
import 'package:cortex_bank_mobile/features/auth/domain/repositories/i_auth_repository.dart';
import 'package:cortex_bank_mobile/core/utils/safe_log.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    configureDependencies();
  } catch (e) {
    safeLogError('Erro ao configurar dependências', e);
    runApp(
      MaterialApp(
        home: Scaffold(body: Center(child: Text('Dependências: $e'))),
      ),
    );
    return;
  }

  // Inicializar cache local
  CacheManager.initialize().then((_) {
    safeLogInfo('Cache Manager inicializado');
  });

  try {
    final authProvider = AuthProvider(getIt<IAuthRepository>());

    runApp(
      MultiProvider(
        providers: [
          ChangeNotifierProvider.value(value: authProvider),
        ],
        child: const App(),
      ),
    );
  } catch (e) {
    safeLogError('Erro ao iniciar app', e);
    runApp(
      MaterialApp(
        home: Scaffold(body: Center(child: Text('$e'))),
      ),
    );
  }
}
