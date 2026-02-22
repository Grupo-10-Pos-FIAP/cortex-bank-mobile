import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:cortex_bank_mobile/features/auth/state/auth_provider.dart';
import 'package:cortex_bank_mobile/core/utils/validators.dart';
import 'package:cortex_bank_mobile/core/widgets/app_button.dart';
import 'package:cortex_bank_mobile/core/widgets/app_text_field.dart';
import 'package:cortex_bank_mobile/core/widgets/app_loading.dart';
import 'package:cortex_bank_mobile/core/widgets/app_error_message.dart';
import 'package:cortex_bank_mobile/shared/theme/app_design_tokens.dart';
import 'package:cortex_bank_mobile/features/auth/presentation/widgets/auth_page_header.dart';
import 'package:cortex_bank_mobile/features/auth/presentation/widgets/auth_field_styles.dart';

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
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Não foi possível abrir o cliente de email.'),
        ),
      );
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
    await auth.signIn(
      _emailController.text.trim(),
      _passwordController.text,
    );
    if (!mounted) return;
    if (auth.isAuthenticated) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Bem-vindo!')),
      );
      Navigator.of(context).pushReplacementNamed('/extrato');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppDesignTokens.colorBgDefault,

      body: SafeArea(
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
                        formFieldKey: _emailFieldKey,
                        label: 'Email',
                        controller: _emailController,
                        focusNode: _emailFocusNode,
                        keyboardType: TextInputType.emailAddress,
                        validator: validateEmail,
                        prefixIcon: const Icon(Icons.email_outlined, color: AppDesignTokens.colorContentInverse),
                        hintText: 'Digite seu email',
                        textInputAction: TextInputAction.next,
                        onFieldSubmitted: (_) =>
                            FocusScope.of(context).requestFocus(_passwordFocusNode),
                        showRequiredIndicator: true,
                        autofocus: true,
                        labelStyle: AuthFieldStyles.labelStyle(context),
                        fillColor: AppDesignTokens.colorBgDefault,
                        style: AuthFieldStyles.inputStyle(context),
                        hintStyle: AuthFieldStyles.hintStyle(context),
                      ),
                      const SizedBox(height: AppDesignTokens.spacingMd),
                      // Campo Senha — validação ao blur ou ao submeter
                      AppTextField(
                        formFieldKey: _passwordFieldKey,
                        label: 'Senha',
                        controller: _passwordController,
                        focusNode: _passwordFocusNode,
                        obscureText: _obscurePassword,
                        validator: requiredField,
                        prefixIcon: const Icon(Icons.lock_outline, color: AppDesignTokens.colorContentInverse),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                            color: AppDesignTokens.colorContentInverse,
                          ),
                          onPressed: () =>
                              setState(() => _obscurePassword = !_obscurePassword),
                        ),
                        hintText: 'Digite sua senha',
                        textInputAction: TextInputAction.done,
                        onFieldSubmitted: (_) => _onSubmit(),
                        showRequiredIndicator: true,
                        labelStyle: AuthFieldStyles.labelStyle(context),
                        fillColor: AppDesignTokens.colorBgDefault,
                        style: AuthFieldStyles.inputStyle(context),
                        hintStyle: AuthFieldStyles.hintStyle(context),
                      ),
                      const SizedBox(height: AppDesignTokens.spacingLg),
                      // Botão Entrar
                      AppButton(
                        label: 'Entrar',
                        loading: auth.loading,
                        onPressed: _onSubmit,
                        variant: ButtonVariant.primary,
                      ),
                      const SizedBox(height: AppDesignTokens.spacingMd),
                      // Botão Criar conta
                      AppButton(
                        label: 'Criar conta',
                        onPressed: () {
                          Navigator.of(context).pushNamed('/register');
                        },
                        variant: ButtonVariant.negative,
                      ),
                      const SizedBox(height: AppDesignTokens.spacingXl),
                      // Texto de suporte
                      Text(
                        'Não tem ou esqueceu a senha? Entre em contato com nossa equipe, através do email:',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppDesignTokens.colorContentInverse,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: AppDesignTokens.spacingSm),
                      TextButton(
                        onPressed: _onContactEmailPressed,
                        child: Text(
                          'cortexbank.contato@gmail.com',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
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
    );
  }
}
