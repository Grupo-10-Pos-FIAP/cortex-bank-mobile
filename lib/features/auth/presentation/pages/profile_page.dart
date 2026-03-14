import 'package:cortex_bank_mobile/core/widgets/app_card_container.dart';
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
      body: SafeArea(
        child: Consumer<AuthProvider>(
          builder: (context, auth, _) {
            final user = auth.user;
            if (user == null) {
              return const Center(child: Text('Usuário não logado'));
            }

            return SingleChildScrollView(
              padding: const EdgeInsets.all(AppDesignTokens.spacingLg),
              child: AppCardContainer(
                padding: const EdgeInsets.all(AppDesignTokens.spacingLg),
                child: Column(
                  children: [
                    Center(
                      child: Column(
                        children: [
                          CircleAvatar(
                            radius: 40,
                            backgroundColor: AppDesignTokens.colorPrimary,
                            child: Text(
                              user.username.isNotEmpty
                                  ? user.username[0].toUpperCase()
                                  : '?',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(height: AppDesignTokens.spacingMd),
                          Text(
                            user.username,
                            style: Theme.of(context).textTheme.titleLarge
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: AppDesignTokens.colorContentDefault,
                                ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: AppDesignTokens.spacingXl),

                    // Seção Bancária com fundo sutil para destaque
                    Container(
                      padding: const EdgeInsets.symmetric(
                        vertical: AppDesignTokens.spacingSm,
                      ),
                      decoration: BoxDecoration(
                        color: AppDesignTokens.colorBgPrimary.withValues(
                          alpha: 0.1,
                        ), // Fundo leve
                        borderRadius: BorderRadius.circular(
                          AppDesignTokens.borderRadiusDefault,
                        ),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: _infoTile(
                              context,
                              'AGÊNCIA',
                              user.branchCode,
                            ),
                          ),
                          Container(
                            width: 1,
                            height: 30,
                            color: AppDesignTokens.colorBorderDefault
                                .withValues(alpha: 0.2),
                          ),
                          Expanded(
                            child: _infoTile(
                              context,
                              'CONTA',
                              user.accountNumber,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: AppDesignTokens.spacingLg),

                    // Dados Pessoais (Alinhados à esquerda)
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _infoTile(context, 'NOME COMPLETO', user.username),
                          _infoTile(context, 'E-MAIL', user.email),
                        ],
                      ),
                    ),

                    const SizedBox(height: AppDesignTokens.spacingXl),

                    // Ação de Logout
                    SizedBox(
                      width: double.infinity,
                      child: AppButton(
                        label: 'Sair da Conta',
                        onPressed: () => _onLogout(context),
                        variant: ButtonVariant.outlined,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _infoTile(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.all(AppDesignTokens.spacingMd),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: AppDesignTokens.colorContentPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: AppDesignTokens.colorContentDefault,
            ),
          ),
        ],
      ),
    );
  }
}
