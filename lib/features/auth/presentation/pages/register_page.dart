import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cortex_bank_mobile/features/auth/state/auth_provider.dart';
import 'package:cortex_bank_mobile/core/utils/validators.dart';
import 'package:cortex_bank_mobile/core/widgets/app_button.dart';
import 'package:cortex_bank_mobile/core/widgets/app_text_field.dart';
import 'package:cortex_bank_mobile/core/widgets/app_loading.dart';
import 'package:cortex_bank_mobile/core/widgets/app_error_message.dart';
import 'package:cortex_bank_mobile/shared/theme/app_design_tokens.dart';
import 'package:cortex_bank_mobile/features/auth/presentation/widgets/auth_page_header.dart';
import 'package:cortex_bank_mobile/features/auth/presentation/widgets/auth_field_styles.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameFieldKey = GlobalKey<FormFieldState<String>>();
  final _lastNameFieldKey = GlobalKey<FormFieldState<String>>();
  final _emailFieldKey = GlobalKey<FormFieldState<String>>();
  final _passwordFieldKey = GlobalKey<FormFieldState<String>>();
  final _confirmPasswordFieldKey = GlobalKey<FormFieldState<String>>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _firstNameFocusNode = FocusNode();
  final _lastNameFocusNode = FocusNode();
  final _emailFocusNode = FocusNode();
  final _passwordFocusNode = FocusNode();
  final _confirmPasswordFocusNode = FocusNode();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void initState() {
    super.initState();
    _firstNameFocusNode.addListener(_onFirstNameBlur);
    _lastNameFocusNode.addListener(_onLastNameBlur);
    _emailFocusNode.addListener(_onEmailBlur);
    _passwordFocusNode.addListener(_onPasswordBlur);
    _confirmPasswordFocusNode.addListener(_onConfirmPasswordBlur);
  }

  void _onFirstNameBlur() {
    if (!_firstNameFocusNode.hasFocus) _firstNameFieldKey.currentState?.validate();
  }

  void _onLastNameBlur() {
    if (!_lastNameFocusNode.hasFocus) _lastNameFieldKey.currentState?.validate();
  }

  void _onEmailBlur() {
    if (!_emailFocusNode.hasFocus) _emailFieldKey.currentState?.validate();
  }

  void _onPasswordBlur() {
    if (!_passwordFocusNode.hasFocus) _passwordFieldKey.currentState?.validate();
  }

  void _onConfirmPasswordBlur() {
    if (!_confirmPasswordFocusNode.hasFocus) _confirmPasswordFieldKey.currentState?.validate();
  }

  @override
  void dispose() {
    _firstNameFocusNode.removeListener(_onFirstNameBlur);
    _lastNameFocusNode.removeListener(_onLastNameBlur);
    _emailFocusNode.removeListener(_onEmailBlur);
    _passwordFocusNode.removeListener(_onPasswordBlur);
    _confirmPasswordFocusNode.removeListener(_onConfirmPasswordBlur);
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _firstNameFocusNode.dispose();
    _lastNameFocusNode.dispose();
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    _confirmPasswordFocusNode.dispose();
    super.dispose();
  }

  Future<void> _onSubmit() async {
    if (_formKey.currentState?.validate() != true) return;
    final auth = context.read<AuthProvider>();
    final fullName = '${_firstNameController.text.trim()} ${_lastNameController.text.trim()}'.trim();
    await auth.signUp(
      fullName,
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
                      const AuthPageHeader(title: 'Criar conta'),
                      // Mensagem de erro
                      if (auth.errorMessage != null)
                        AppErrorMessage(
                          message: auth.errorMessage,
                          onDismiss: () => auth.clearError(),
                        ),
                      // Campo Nome
                      AppTextField(
                        formFieldKey: _firstNameFieldKey,
                        label: 'Nome',
                        controller: _firstNameController,
                        focusNode: _firstNameFocusNode,
                        validator: requiredField,
                        prefixIcon: const Icon(Icons.person_outline, color: AppDesignTokens.colorContentInverse),
                        hintText: 'Digite seu nome',
                        textInputAction: TextInputAction.next,
                        onFieldSubmitted: (_) =>
                            FocusScope.of(context).requestFocus(_lastNameFocusNode),
                        showRequiredIndicator: true,
                        autofocus: true,
                        labelStyle: AuthFieldStyles.labelStyle(context),
                        fillColor: AppDesignTokens.colorBgDefault,
                        style: AuthFieldStyles.inputStyle(context),
                        hintStyle: AuthFieldStyles.hintStyle(context),
                      ),
                      const SizedBox(height: AppDesignTokens.spacingMd),
                      // Campo Sobrenome
                      AppTextField(
                        formFieldKey: _lastNameFieldKey,
                        label: 'Sobrenome',
                        controller: _lastNameController,
                        focusNode: _lastNameFocusNode,
                        validator: requiredField,
                        prefixIcon: const Icon(Icons.person_outline, color: AppDesignTokens.colorContentInverse),
                        hintText: 'Digite seu sobrenome',
                        textInputAction: TextInputAction.next,
                        onFieldSubmitted: (_) =>
                            FocusScope.of(context).requestFocus(_emailFocusNode),
                        showRequiredIndicator: true,
                        labelStyle: AuthFieldStyles.labelStyle(context),
                        fillColor: AppDesignTokens.colorBgDefault,
                        style: AuthFieldStyles.inputStyle(context),
                        hintStyle: AuthFieldStyles.hintStyle(context),
                      ),
                      const SizedBox(height: AppDesignTokens.spacingMd),
                      // Campo Email
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
                        labelStyle: AuthFieldStyles.labelStyle(context),
                        fillColor: AppDesignTokens.colorBgDefault,
                        style: AuthFieldStyles.inputStyle(context),
                        hintStyle: AuthFieldStyles.hintStyle(context),
                      ),
                      const SizedBox(height: AppDesignTokens.spacingMd),
                      // Campo Senha (mín. 8 caracteres)
                      AppTextField(
                        formFieldKey: _passwordFieldKey,
                        label: 'Senha',
                        controller: _passwordController,
                        focusNode: _passwordFocusNode,
                        obscureText: _obscurePassword,
                        validator: validatePassword,
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
                        hintText: 'Mínimo 8 caracteres',
                        textInputAction: TextInputAction.next,
                        onFieldSubmitted: (_) =>
                            FocusScope.of(context).requestFocus(_confirmPasswordFocusNode),
                        showRequiredIndicator: true,
                        labelStyle: AuthFieldStyles.labelStyle(context),
                        fillColor: AppDesignTokens.colorBgDefault,
                        style: AuthFieldStyles.inputStyle(context),
                        hintStyle: AuthFieldStyles.hintStyle(context),
                      ),
                      const SizedBox(height: AppDesignTokens.spacingMd),
                      // Campo Confirmar Senha
                      AppTextField(
                        formFieldKey: _confirmPasswordFieldKey,
                        label: 'Confirmar Senha',
                        controller: _confirmPasswordController,
                        focusNode: _confirmPasswordFocusNode,
                        obscureText: _obscureConfirmPassword,
                        validator: (value) =>
                            confirmPassword(value, _passwordController.text),
                        prefixIcon: const Icon(Icons.lock_outline, color: AppDesignTokens.colorContentInverse),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscureConfirmPassword
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                            color: AppDesignTokens.colorContentInverse,
                          ),
                          onPressed: () => setState(
                              () => _obscureConfirmPassword = !_obscureConfirmPassword),
                        ),
                        hintText: 'Confirme sua senha',
                        textInputAction: TextInputAction.done,
                        onFieldSubmitted: (_) => _onSubmit(),
                        showRequiredIndicator: true,
                        labelStyle: AuthFieldStyles.labelStyle(context),
                        fillColor: AppDesignTokens.colorBgDefault,
                        style: AuthFieldStyles.inputStyle(context),
                        hintStyle: AuthFieldStyles.hintStyle(context),
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
