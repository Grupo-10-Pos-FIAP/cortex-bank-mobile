import 'package:cortex_bank_mobile/core/widgets/app_card_container.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cortex_bank_mobile/features/auth/state/auth_provider.dart';
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
              padding: const EdgeInsets.symmetric(
                horizontal: AppDesignTokens.spacingMd,
                vertical: AppDesignTokens.spacingSm,
              ),
              child: AppCardContainer(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppDesignTokens.spacingLg,
                  vertical: AppDesignTokens.spacingXl,
                ),
                child: Column(
                  children: [
                    Center(
                      child: Column(
                        children: [
                          CircleAvatar(
                            radius: 40,
                            backgroundColor: AppDesignTokens.colorBgAvatar,
                            child: Text(
                              user.username.isNotEmpty
                                  ? user.username[0].toUpperCase()
                                  : '?',
                              style: TextStyle(
                                color: AppDesignTokens.colorContentPrimary,
                                fontSize: 32,
                                fontWeight: AppDesignTokens.fontWeightBold,
                              ),
                            ),
                          ),
                          const SizedBox(height: AppDesignTokens.spacingMd),
                          Text(
                            user.username.isNotEmpty
                                ? user.username
                                : 'Usuário',
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                  fontWeight: AppDesignTokens.fontWeightBold,
                                  color: AppDesignTokens.colorContentDefault,
                                ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: AppDesignTokens.spacingXl),

                    Row(
                      children: [
                        Expanded(
                          child: _infoBlock(
                            context,
                            'Agência',
                            user.branchCode,
                          ),
                        ),
                        Expanded(
                          child: _infoBlock(
                            context,
                            'Conta',
                            user.accountNumber,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: AppDesignTokens.spacingLg),

                    Align(
                      alignment: Alignment.centerLeft,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _infoBlock(
                            context,
                            'Nome completo',
                            user.username,
                          ),
                          const SizedBox(height: AppDesignTokens.spacingMd),
                          _infoBlock(
                            context,
                            'Email',
                            user.email,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: AppDesignTokens.spacingXl),

                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: OutlinedButton.icon(
                        onPressed: () => _onLogout(context),
                        icon: Icon(
                          Icons.logout,
                          size: 20,
                          color: AppDesignTokens.colorContentDefault,
                        ),
                        label: Text(
                          'Sair da conta',
                          style: TextStyle(
                            fontSize: AppDesignTokens.fontSizeBody,
                            fontWeight: AppDesignTokens.fontWeightMedium,
                            color: AppDesignTokens.colorContentDefault,
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          backgroundColor: AppDesignTokens.colorWhite,
                          side: BorderSide(
                            color: AppDesignTokens.colorBorderDefault,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                              AppDesignTokens.borderRadiusDefault,
                            ),
                          ),
                        ),
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

  Widget _infoBlock(BuildContext context, String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppDesignTokens.colorContentMuted,
                fontSize: AppDesignTokens.fontSizeSmall,
              ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                fontWeight: AppDesignTokens.fontWeightBold,
                color: AppDesignTokens.colorContentDefault,
              ),
        ),
      ],
    );
  }
}
