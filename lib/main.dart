import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:cortex_bank_mobile/app.dart';
import 'package:cortex_bank_mobile/core/cache/cache_manager.dart';
import 'package:cortex_bank_mobile/core/cache/sensitive_cache_manager.dart';
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

  try {
    await SensitiveCacheManager.initialize();
    await CacheManager.initialize();
    safeLogInfo('Cache managers inicializados');
  } catch (e) {
    safeLogError('Erro ao inicializar cache', e);
  }

  try {
    runApp(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(
            create: (_) => AuthProvider(getIt<IAuthRepository>()),
          ),
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
