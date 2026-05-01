import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:cortex_bank_mobile/core/firebase/firebase_optimization_config.dart';
import 'package:cortex_bank_mobile/core/utils/env_validator.dart';
import 'package:cortex_bank_mobile/core/utils/safe_log.dart';
import 'package:cortex_bank_mobile/features/auth/state/auth_provider.dart';
import 'package:cortex_bank_mobile/features/auth/presentation/pages/login_page.dart';
import 'package:cortex_bank_mobile/features/home/presentation/pages/home_page.dart';
import 'package:cortex_bank_mobile/shared/theme/app_design_tokens.dart';
import 'package:cortex_bank_mobile/firebase_options.dart';

/// Tela de splash exibida enquanto o estado de autenticação é verificado.
/// Exibe o nome do app com animação de fade e redireciona automaticamente.
class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage>
    with SingleTickerProviderStateMixin {
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
    try {
      await dotenv.load(fileName: '.env');

      final missingEnv = getMissingFirebaseEnvVars();
      if (missingEnv.isNotEmpty) {
        setState(() {
          _startupError =
              'Verifique o arquivo .env. Faltam variáveis: ${missingEnv.join(', ')}';
        });
        return;
      }

      if (Firebase.apps.isEmpty) {
        await Firebase.initializeApp(
          options: DefaultFirebaseOptions.currentPlatform,
        );
      }

      FirebaseOptimizationConfig.configureFirestoreOptimizations();

      if (!mounted) return;
      setState(() => _startupReady = true);
      await context.read<AuthProvider>().loadCurrentUser();
    } on FirebaseException catch (e) {
      if (!mounted) return;
      safeLogError('Erro ao inicializar Firebase', e);
      setState(() => _startupError = 'Firebase: ${e.message ?? e.code}');
    } catch (e) {
      if (!mounted) return;
      safeLogError('Erro ao inicializar app na splash', e);
      setState(() => _startupError = '$e');
    }
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
      body: Consumer<AuthProvider>(
        builder: (context, auth, _) {
          if (_startupError != null) {
            return _SplashErrorView(message: _startupError!);
          }

          // Quando a verificação inicial terminar, redireciona uma única vez.
          if (_startupReady &&
              auth.hasResolvedInitialAuth &&
              !auth.loading &&
              !_redirectScheduled) {
            _redirectScheduled = true;
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (!mounted) return;
              final target = auth.isAuthenticated
                  ? const HomePage()
                  : const LoginPage();
              Navigator.of(context).pushReplacement(
                PageRouteBuilder(
                  pageBuilder: (_, __, ___) => target,
                  transitionDuration: const Duration(milliseconds: 400),
                  transitionsBuilder: (_, animation, __, child) {
                    return FadeTransition(
                      opacity: CurvedAnimation(
                        parent: animation,
                        curve: Curves.easeIn,
                      ),
                      child: child,
                    );
                  },
                ),
              );
            });
          }

          return Center(
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
          );
        },
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
