import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:cortex_bank_mobile/core/firebase/firebase_optimization_config.dart';
import 'package:cortex_bank_mobile/core/utils/env_validator.dart';
import 'package:cortex_bank_mobile/core/utils/safe_log.dart';
import 'package:cortex_bank_mobile/features/auth/presentation/providers/auth_provider.dart';
import 'package:cortex_bank_mobile/features/auth/presentation/pages/login_page.dart';
import 'package:cortex_bank_mobile/features/auth/presentation/shell/authenticated_app_shell.dart';
import 'package:cortex_bank_mobile/shared/theme/app_design_tokens.dart';
import 'package:cortex_bank_mobile/firebase_options.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage>
    with SingleTickerProviderStateMixin {
  // Garante que `Firebase.initializeApp()` só rode uma vez por execução do app.
  // Isso evita o erro `FirebaseException code=duplicate-app` caso o bootstrap
  // seja disparado em paralelo (ex.: hot restart/hot reload ou múltiplas
  // instâncias do widget).
  static Future<void>? _firebaseInitializationFuture;

  /// `flutter test integration_test/... --dart-define=INTEGRATION_SKIP_FIREBASE=true`
  /// evita Firebase nativo no flutter-tester (ex.: Windows/CI sem plugin móvel).
  static const bool _skipFirebaseBootstrap = bool.fromEnvironment(
    'INTEGRATION_SKIP_FIREBASE',
    defaultValue: false,
  );

  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  bool _redirectScheduled = false;
  bool _startupReady = false;
  String? _startupError;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnimation = CurvedAnimation(parent: _controller, curve: Curves.easeIn);
    _controller.forward();
    _initializeAppStartup();
  }

  Future<void> _initializeAppStartup() async {
    if (_skipFirebaseBootstrap) {
      if (!mounted) return;
      setState(() => _startupReady = true);
      await context.read<AuthProvider>().loadCurrentUser();
      if (!mounted) return;
      context.read<AuthProvider>().startReactiveAuthListener();
      _scheduleNavigationAfterAuthReady();
      return;
    }

    try {
      await dotenv.load(fileName: '.env');

      if (!mounted) return;
      final missingEnv = getMissingFirebaseEnvVars();
      if (missingEnv.isNotEmpty) {
        setState(() {
          _startupError =
              'Verifique o arquivo .env. Faltam variáveis: ${missingEnv.join(', ')}';
        });
        return;
      }

      await _initializeFirebaseOnce();

      FirebaseOptimizationConfig.configureFirestoreOptimizations();

      if (!mounted) return;
      setState(() => _startupReady = true);
      await context.read<AuthProvider>().loadCurrentUser();
      if (!mounted) return;
      context.read<AuthProvider>().startReactiveAuthListener();
      _scheduleNavigationAfterAuthReady();
    } on FirebaseException catch (e) {
      if (!mounted) return;

      // Em dev, pode existir uma inicialização implícita concorrente.
      // Se o erro for "duplicate-app", o Firebase provavelmente já está ok;
      // então seguimos o bootstrap sem travar a Splash.
      if (e.code == 'duplicate-app') {
        try {
          await context.read<AuthProvider>().loadCurrentUser();
          if (!mounted) return;
          context.read<AuthProvider>().startReactiveAuthListener();
          setState(() => _startupReady = true);
          _scheduleNavigationAfterAuthReady();
          return;
        } catch (_) {
          // Se falhar também, caímos no fluxo padrão de erro.
        }
      }

      safeLogError('Erro ao inicializar Firebase', e);
      setState(() => _startupError = 'Firebase: ${e.message ?? e.code}');
    } catch (e) {
      if (!mounted) return;
      safeLogError('Erro ao inicializar app na splash', e);
      setState(() => _startupError = '$e');
    }
  }

  Future<void> _initializeFirebaseOnce() {
    _firebaseInitializationFuture ??= () async {
      if (Firebase.apps.isNotEmpty) return;

      try {
        await Firebase.initializeApp(
          options: DefaultFirebaseOptions.currentPlatform,
        );
      } on FirebaseException catch (e) {
        // Em dev/boot, existe corrida com inicializações implícitas
        // (ex.: streams/instâncias sendo criadas antes do bootstrap).
        // Se outro "vencer", o app já está ok: só ignore.
        if (e.code == 'duplicate-app') {
          // Aguarda o "bootstrap vencedor" finalizar.
          final start = DateTime.now();
          while (Firebase.apps.isEmpty &&
              DateTime.now().difference(start) < const Duration(seconds: 5)) {
            await Future<void>.delayed(const Duration(milliseconds: 100));
          }
          return;
        }
        rethrow;
      }
    }();
    return _firebaseInitializationFuture!;
  }

  /// Navegação pós-startup: chamado após [AuthProvider.loadCurrentUser] concluir,
  /// fora do ciclo [build] (evita side effects durante reconstruções).
  void _scheduleNavigationAfterAuthReady() {
    if (!mounted ||
        _redirectScheduled ||
        !_startupReady ||
        _startupError != null) {
      return;
    }
    final auth = context.read<AuthProvider>();
    if (!auth.hasResolvedInitialAuth || auth.loading) {
      return;
    }
    _redirectScheduled = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final authNow = context.read<AuthProvider>();
      final target = authNow.isAuthenticated
          ? const AuthenticatedAppShell()
          : const LoginPage();
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          pageBuilder: (_, _, _) => target,
          transitionDuration: const Duration(milliseconds: 400),
          transitionsBuilder: (_, animation, _, child) {
            return FadeTransition(
              opacity: CurvedAnimation(parent: animation, curve: Curves.easeIn),
              child: child,
            );
          },
        ),
      );
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppDesignTokens.colorBgDefault,
      body: _startupError != null
          ? _SplashErrorView(message: _startupError!)
          : Center(
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.account_balance,
                      size: 72,
                      color: AppDesignTokens.colorPrimary,
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Cortex Bank',
                      style: TextStyle(
                        fontSize: AppDesignTokens.fontSizeTitle,
                        fontWeight: AppDesignTokens.fontWeightBold,
                        color: AppDesignTokens.colorPrimary,
                      ),
                    ),
                    const SizedBox(height: 32),
                    const CircularProgressIndicator(
                      color: AppDesignTokens.colorPrimary,
                      strokeWidth: 2,
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}

class _SplashErrorView extends StatelessWidget {
  const _SplashErrorView({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Icon(
            Icons.warning_amber_rounded,
            size: 64,
            color: Colors.orange,
          ),
          const SizedBox(height: 24),
          const Text(
            'Erro ao iniciar',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: AppDesignTokens.fontSizeTitle,
              fontWeight: AppDesignTokens.fontWeightBold,
            ),
          ),
          const SizedBox(height: 12),
          SelectableText(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: AppDesignTokens.fontSizeCaption,
              fontFamily: 'monospace',
            ),
          ),
        ],
      ),
    );
  }
}
