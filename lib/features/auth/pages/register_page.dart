import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cortex_bank_mobile/core/providers/auth_provider.dart';
import 'package:cortex_bank_mobile/core/utils/validators.dart';
import 'package:cortex_bank_mobile/core/widgets/app_button.dart';
import 'package:cortex_bank_mobile/core/widgets/app_text_field.dart';
import 'package:cortex_bank_mobile/core/widgets/app_loading.dart';
import 'package:cortex_bank_mobile/core/widgets/app_error_message.dart';
import 'package:cortex_bank_mobile/core/theme/app_design_tokens.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _nameFocusNode = FocusNode();
  final _emailFocusNode = FocusNode();
  final _passwordFocusNode = FocusNode();
  final _confirmPasswordFocusNode = FocusNode();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _nameFocusNode.dispose();
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    _confirmPasswordFocusNode.dispose();
    super.dispose();
  }

  Future<void> _onSubmit() async {
    if (_formKey.currentState?.validate() != true) return;
    final auth = context.read<AuthProvider>();
    await auth.signUp(
      _nameController.text.trim(),
      _emailController.text.trim(),
      _passwordController.text,
    );
    if (!mounted) return;
    if (auth.isAuthenticated) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Conta criada com sucesso!')),
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
            autovalidateMode: AutovalidateMode.onUserInteraction,
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
                      const SizedBox(height: AppDesignTokens.spacing2xl),
                      // Logo
                      Text(
                        'CortexBank',
                        style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: AppDesignTokens.fontWeightBold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: AppDesignTokens.spacingSm),
                      // Tagline
                      RichText(
                        textAlign: TextAlign.center,
                        text: TextSpan(
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppDesignTokens.colorContentInverse,
                          ),
                          children: [
                            const TextSpan(text: 'O futuro das suas finanças merece esse '),
                            TextSpan(
                              text: 'up',
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.primary,
                                fontWeight: AppDesignTokens.fontWeightBold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: AppDesignTokens.spacingXl),
                      // Título
                      Text(
                        'Criar conta',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: AppDesignTokens.colorContentInverse,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: AppDesignTokens.spacingXl),
                      // Mensagem de erro
                      if (auth.errorMessage != null)
                        AppErrorMessage(
                          message: auth.errorMessage,
                          onDismiss: () => auth.clearError(),
                        ),
                      // Campo Nome
                      AppTextField(
                        label: 'Nome',
                        controller: _nameController,
                        focusNode: _nameFocusNode,
                        validator: validateFullName,
                        prefixIcon: const Icon(Icons.person_outline, color: AppDesignTokens.colorContentInverse),
                        hintText: 'Digite seu nome',
                        textInputAction: TextInputAction.next,
                        onFieldSubmitted: (_) {
                          FocusScope.of(context).requestFocus(_emailFocusNode);
                        },
                        showRequiredIndicator: true,
                        autofocus: true,
                        labelStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppDesignTokens.colorContentInverse,
                          fontWeight: AppDesignTokens.fontWeightMedium,
                        ),
                        fillColor: AppDesignTokens.colorBgDefault,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: AppDesignTokens.colorContentInverse),
                        hintStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppDesignTokens.colorGray400),
                      ),
                      const SizedBox(height: AppDesignTokens.spacingMd),
                      // Campo Email
                      AppTextField(
                        label: 'Email',
                        controller: _emailController,
                        focusNode: _emailFocusNode,
                        keyboardType: TextInputType.emailAddress,
                        validator: validateEmail,
                        prefixIcon: const Icon(Icons.email_outlined, color: AppDesignTokens.colorContentInverse),
                        hintText: 'Digite seu email',
                        textInputAction: TextInputAction.next,
                        onFieldSubmitted: (_) {
                          FocusScope.of(context).requestFocus(_passwordFocusNode);
                        },
                        showRequiredIndicator: true,
                        labelStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppDesignTokens.colorContentInverse,
                          fontWeight: AppDesignTokens.fontWeightMedium,
                        ),
                        fillColor: AppDesignTokens.colorBgDefault,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: AppDesignTokens.colorContentInverse),
                        hintStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppDesignTokens.colorGray400),
                      ),
                      const SizedBox(height: AppDesignTokens.spacingMd),
                      // Campo Senha
                      AppTextField(
                        label: 'Senha',
                        controller: _passwordController,
                        focusNode: _passwordFocusNode,
                        obscureText: _obscurePassword,
                        validator: (value) {
                          final required = requiredField(value);
                          if (required != null) return required;
                          return minLength(value, 8);
                        },
                        prefixIcon: const Icon(Icons.lock_outline, color: AppDesignTokens.colorContentInverse),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                            color: AppDesignTokens.colorContentInverse,
                          ),
                          onPressed: () {
                            setState(() {
                              _obscurePassword = !_obscurePassword;
                            });
                          },
                        ),
                        hintText: 'Mínimo 8 caracteres',
                        textInputAction: TextInputAction.next,
                        onFieldSubmitted: (_) {
                          FocusScope.of(context).requestFocus(_confirmPasswordFocusNode);
                        },
                        showRequiredIndicator: true,
                        labelStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppDesignTokens.colorContentInverse,
                          fontWeight: AppDesignTokens.fontWeightMedium,
                        ),
                        fillColor: AppDesignTokens.colorBgDefault,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: AppDesignTokens.colorContentInverse),
                        hintStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppDesignTokens.colorGray400),
                      ),
                      const SizedBox(height: AppDesignTokens.spacingMd),
                      // Campo Confirmar Senha
                      AppTextField(
                        label: 'Confirmar Senha',
                        controller: _confirmPasswordController,
                        focusNode: _confirmPasswordFocusNode,
                        obscureText: _obscureConfirmPassword,
                        validator: (value) => confirmPassword(
                          value,
                          _passwordController.text,
                        ),
                        prefixIcon: const Icon(Icons.lock_outline, color: AppDesignTokens.colorContentInverse),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscureConfirmPassword
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                            color: AppDesignTokens.colorContentInverse,
                          ),
                          onPressed: () {
                            setState(() {
                              _obscureConfirmPassword = !_obscureConfirmPassword;
                            });
                          },
                        ),
                        hintText: 'Confirme sua senha',
                        textInputAction: TextInputAction.done,
                        onFieldSubmitted: (_) => _onSubmit(),
                        showRequiredIndicator: true,
                        labelStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppDesignTokens.colorContentInverse,
                          fontWeight: AppDesignTokens.fontWeightMedium,
                        ),
                        fillColor: AppDesignTokens.colorBgDefault,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: AppDesignTokens.colorContentInverse),
                        hintStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppDesignTokens.colorGray400),
                      ),
                      const SizedBox(height: AppDesignTokens.spacingLg),
                      // Botão Criar conta
                      AppButton(
                        label: 'Criar conta',
                        loading: auth.loading,
                        onPressed: _onSubmit,
                        variant: ButtonVariant.primary,
                      ),
                      const SizedBox(height: AppDesignTokens.spacingMd),
                      // Botão Voltar para login
                      AppButton(
                        label: 'Voltar para login',
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        variant: ButtonVariant.negative,
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
