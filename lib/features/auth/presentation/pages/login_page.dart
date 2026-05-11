import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:cortex_bank_mobile/features/auth/presentation/providers/auth_provider.dart';
import 'package:cortex_bank_mobile/core/utils/validators.dart';
import 'package:cortex_bank_mobile/core/widgets/app_button.dart';
import 'package:cortex_bank_mobile/core/widgets/app_text_field.dart';
import 'package:cortex_bank_mobile/core/widgets/app_loading.dart';
import 'package:cortex_bank_mobile/core/widgets/app_error_message.dart';
import 'package:cortex_bank_mobile/core/widgets/app_snackbar.dart';
import 'package:cortex_bank_mobile/shared/theme/app_design_tokens.dart';
import 'package:cortex_bank_mobile/features/auth/presentation/widgets/auth_page_header.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:cortex_bank_mobile/features/auth/presentation/widgets/auth_field_styles.dart';
import 'package:cortex_bank_mobile/features/home/presentation/pages/home_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailFieldKey = GlobalKey<FormFieldState<String>>();
  final _passwordFieldKey = GlobalKey<FormFieldState<String>>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _emailFocusNode = FocusNode();
  final _passwordFocusNode = FocusNode();
  bool _obscurePassword = true;

  @override
  void initState() {
    super.initState();
    _emailFocusNode.addListener(_onEmailFocusChange);
    _passwordFocusNode.addListener(_onPasswordFocusChange);
  }

  void _onEmailFocusChange() {
    if (!_emailFocusNode.hasFocus) {
      _emailFieldKey.currentState?.validate();
    }
  }

  void _onPasswordFocusChange() {
    if (!_passwordFocusNode.hasFocus) {
      _passwordFieldKey.currentState?.validate();
    }
  }

  Future<void> _onContactEmailPressed() async {
    final uri = Uri.parse('mailto:cortexbank.contato@gmail.com');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      if (!mounted) return;
      AppSnackBar.error(context, 'Não foi possível abrir o cliente de email.');
    }
  }

  @override
  void dispose() {
    _emailFocusNode.removeListener(_onEmailFocusChange);
    _passwordFocusNode.removeListener(_onPasswordFocusChange);
    _emailController.dispose();
    _passwordController.dispose();
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    super.dispose();
  }

  Future<void> _onSubmit() async {
    if (_formKey.currentState?.validate() != true) return;
    final auth = context.read<AuthProvider>();
    await auth.signIn(_emailController.text.trim(), _passwordController.text);
    if (!mounted) return;
    if (auth.isAuthenticated) {
      AppSnackBar.success(context, 'Bem-vindo!');
      Navigator.of(context).pushReplacementNamed('/');
    }
  }

  Future<void> _onGoogleSignIn() async {
    final auth = context.read<AuthProvider>();
    await auth.signInWithGoogle();
    if (!mounted) return;
    if (auth.isAuthenticated) {
      AppSnackBar.success(context, 'Bem-vindo!');
      Navigator.of(context).pushAndRemoveUntil(
        PageRouteBuilder(
          pageBuilder: (_, primaryAnimation, secondaryAnimation) =>
              const HomePage(),
          transitionDuration: const Duration(milliseconds: 400),
          transitionsBuilder: (_, animation, secondaryAnimation, child) =>
              FadeTransition(
                opacity: CurvedAnimation(
                  parent: animation,
                  curve: Curves.easeIn,
                ),
                child: child,
              ),
        ),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppDesignTokens.colorBgDefaultDark,
      body: Container(
        color: AppDesignTokens.colorBgDefaultDark,
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(AppDesignTokens.spacingLg),
            child: Form(
              key: _formKey,
              autovalidateMode: AutovalidateMode.disabled,
              child: Consumer<AuthProvider>(
                builder: (context, auth, _) {
                  if (auth.loading && !auth.isAuthenticated) {
                    return const AppLoading();
                  }
                  return SingleChildScrollView(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const AuthPageHeader(title: 'Acesso para clientes'),
                        // Mensagem de erro
                        if (auth.errorMessage != null)
                          AppErrorMessage(
                            message: auth.errorMessage,
                            onDismiss: () => auth.clearError(),
                          ),
                        // Campo Email — validação ao sair do campo (blur)
                        AppTextField(
                          key: const Key('login.email'),
                          formFieldKey: _emailFieldKey,
                          label: 'Email',
                          controller: _emailController,
                          focusNode: _emailFocusNode,
                          keyboardType: TextInputType.emailAddress,
                          validator: validateEmail,
                          prefixIcon: const Icon(
                            Icons.email_outlined,
                            color: AppDesignTokens.colorContentInverse,
                          ),
                          hintText: 'Digite seu email',
                          textInputAction: TextInputAction.next,
                          onFieldSubmitted: (_) => FocusScope.of(
                            context,
                          ).requestFocus(_passwordFocusNode),
                          showRequiredIndicator: true,
                          autofocus: true,
                          labelStyle: AuthFieldStyles.labelStyle(context),
                          fillColor: AppDesignTokens.colorBgDefaultDark,
                          style: AuthFieldStyles.inputStyle(context),
                          hintStyle: AuthFieldStyles.hintStyle(context),
                        ),
                        const SizedBox(height: AppDesignTokens.spacingMd),
                        // Campo Senha — validação ao blur ou ao submeter
                        AppTextField(
                          key: const Key('login.password'),
                          formFieldKey: _passwordFieldKey,
                          label: 'Senha',
                          controller: _passwordController,
                          focusNode: _passwordFocusNode,
                          obscureText: _obscurePassword,
                          validator: requiredField,
                          prefixIcon: const Icon(
                            Icons.lock_outline,
                            color: AppDesignTokens.colorContentInverse,
                          ),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword
                                  ? Icons.visibility_outlined
                                  : Icons.visibility_off_outlined,
                              color: AppDesignTokens.colorContentInverse,
                            ),
                            onPressed: () => setState(
                              () => _obscurePassword = !_obscurePassword,
                            ),
                          ),
                          hintText: 'Digite sua senha',
                          textInputAction: TextInputAction.done,
                          onFieldSubmitted: (_) => _onSubmit(),
                          showRequiredIndicator: true,
                          labelStyle: AuthFieldStyles.labelStyle(context),
                          fillColor: AppDesignTokens.colorBgDefaultDark,
                          style: AuthFieldStyles.inputStyle(context),
                          hintStyle: AuthFieldStyles.hintStyle(context),
                        ),
                        const SizedBox(height: AppDesignTokens.spacingLg),
                        // Botão Entrar
                        AppButton(
                          key: const Key('login.submit'),
                          label: 'Entrar',
                          loading: auth.loading,
                          onPressed: _onSubmit,
                          variant: ButtonVariant.primary,
                        ),
                        const SizedBox(height: AppDesignTokens.spacingMd),
                        // Botão Entrar com Google
                        AppButton(
                          label: 'Entrar com Google',
                          loading: auth.loading,
                          onPressed: _onGoogleSignIn,
                          variant: ButtonVariant.negative,
                          backgroundColor: AppDesignTokens.colorBgDefaultDark,
                          icon: SvgPicture.string(
                            '''<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 48 48">
                              <path fill="#EA4335" d="M24 9.5c3.1 0 5.9 1.1 8.1 2.9l6-6C34.5 3.1 29.5 1 24 1 14.8 1 7 6.7 3.7 14.6l7 5.4C12.4 13.7 17.7 9.5 24 9.5z"/>
                              <path fill="#4285F4" d="M46.5 24.5c0-1.6-.1-3.1-.4-4.5H24v8.5h12.7c-.6 3-2.3 5.5-4.8 7.2l7.4 5.7c4.3-4 6.8-9.9 6.8-16.9z"/>
                              <path fill="#FBBC05" d="M10.7 28.5A14.5 14.5 0 0 1 9.5 24c0-1.6.3-3.1.7-4.5l-7-5.4A23.9 23.9 0 0 0 .1 24c0 3.9.9 7.5 2.6 10.7l8-6.2z"/>
                              <path fill="#34A853" d="M24 47c5.5 0 10.1-1.8 13.5-4.9l-7.4-5.7c-1.8 1.2-4.1 2-6.1 2-6.3 0-11.6-4.2-13.3-10l-8 6.2C7 42.3 14.8 47 24 47z"/>
                            </svg>''',
                            height: 20,
                            width: 20,
                          ),
                        ),
                        const SizedBox(height: AppDesignTokens.spacingMd),
                        // Botão Criar conta
                        AppButton(
                          key: const Key('login.register'),
                          label: 'Criar conta',
                          onPressed: () {
                            Navigator.of(context).pushNamed('/register');
                          },
                          variant: ButtonVariant.negative,
                          backgroundColor: AppDesignTokens.colorBgDefaultDark,
                        ),
                        const SizedBox(height: AppDesignTokens.spacingXl),
                        // Texto de suporte
                        Text(
                          'Não tem ou esqueceu a senha? Entre em contato com nossa equipe, através do email:',
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(
                                color: AppDesignTokens.colorContentInverse,
                              ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: AppDesignTokens.spacingSm),
                        TextButton(
                          onPressed: _onContactEmailPressed,
                          child: Text(
                            'cortexbank.contato@gmail.com',
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(
                                  color: AppDesignTokens.colorLink,
                                  decoration: TextDecoration.underline,
                                  decorationColor: AppDesignTokens.colorLink,
                                ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}
