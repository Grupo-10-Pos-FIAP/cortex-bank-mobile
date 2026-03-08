import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cortex_bank_mobile/features/auth/state/auth_provider.dart';
import 'package:cortex_bank_mobile/core/widgets/app_button.dart';
import 'package:cortex_bank_mobile/shared/theme/app_design_tokens.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  Future<void> _onLogout(BuildContext context) async {
    final auth = context.read<AuthProvider>();
    await auth.signOut();
    if (!context.mounted) return;
    Navigator.of(context).pushReplacementNamed('/login');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppDesignTokens.colorBgDefault,
      appBar: AppBar(
        title: const Text('Meu Perfil'),
        backgroundColor: AppDesignTokens.colorBgDefault,
        elevation: 0,
      ),
      body: Container(
        color: AppDesignTokens.colorBgDefault,
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(AppDesignTokens.spacingLg),
            child: Consumer<AuthProvider>(
              builder: (context, auth, _) {
                final user = auth.user;
                if (user == null) {
                  return Center(
                    child: Text(
                      'Nenhum usuário autenticado',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppDesignTokens.colorContentDefault,
                      ),
                    ),
                  );
                }

                return Column(
                  children: [
                    // Avatar
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppDesignTokens.colorBgDefault,
                      ),
                      child: Center(
                        child: Text(
                          user.username.isNotEmpty
                              ? user.username[0].toUpperCase()
                              : '?',
                          style: Theme.of(context).textTheme.headlineLarge
                              ?.copyWith(
                                color: AppDesignTokens.colorContentDefault,
                              ),
                        ),
                      ),
                    ),
                    const SizedBox(height: AppDesignTokens.spacingLg),
                    // Nome
                    Container(
                      padding: const EdgeInsets.all(AppDesignTokens.spacingMd),
                      decoration: BoxDecoration(
                        color: AppDesignTokens.colorBgDefault,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Nome',
                            style: Theme.of(context).textTheme.labelSmall
                                ?.copyWith(
                                  color: AppDesignTokens.colorContentSecondary,
                                ),
                          ),
                          const SizedBox(height: AppDesignTokens.spacingSm),
                          Text(
                            user.username,
                            style: Theme.of(context).textTheme.bodyLarge
                                ?.copyWith(
                                  color: AppDesignTokens.colorContentDefault,
                                  fontWeight: FontWeight.w500,
                                ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppDesignTokens.spacingMd),
                    // Email
                    Container(
                      padding: const EdgeInsets.all(AppDesignTokens.spacingMd),
                      decoration: BoxDecoration(
                        color: AppDesignTokens.colorBgDefault,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Email',
                            style: Theme.of(context).textTheme.labelSmall
                                ?.copyWith(
                                  color: AppDesignTokens.colorContentSecondary,
                                ),
                          ),
                          const SizedBox(height: AppDesignTokens.spacingSm),
                          Text(
                            user.email,
                            style: Theme.of(context).textTheme.bodyLarge
                                ?.copyWith(
                                  color: AppDesignTokens.colorContentDefault,
                                  fontWeight: FontWeight.w500,
                                ),
                          ),
                        ],
                      ),
                    ),
                    const Spacer(),
                    // Botão Logout
                    AppButton(
                      label: 'Sair',
                      onPressed: () => _onLogout(context),
                      variant: ButtonVariant.outlined,
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
