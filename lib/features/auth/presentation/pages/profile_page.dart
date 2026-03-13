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
              return Center(
                child: Text(
                  'Nenhum usuário autenticado',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppDesignTokens.colorContentDefault,
                  ),
                ),
              );
            }

            return AppCardContainer(
              padding: EdgeInsets.zero,
              child: Padding(
                padding: const EdgeInsets.all(AppDesignTokens.spacingLg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
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
                    const SizedBox(height: AppDesignTokens.spacingMd),
                    Text(
                      'Nome',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: AppDesignTokens.colorContentSecondary,
                      ),
                    ),
                    const SizedBox(height: AppDesignTokens.spacingXs),
                    Text(
                      user.username,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: AppDesignTokens.colorContentDefault,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: AppDesignTokens.spacingMd),

                    Text(
                      'Email',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: AppDesignTokens.colorContentSecondary,
                      ),
                    ),
                    const SizedBox(height: AppDesignTokens.spacingXs),
                    Text(
                      user.email,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: AppDesignTokens.colorContentDefault,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: AppDesignTokens.spacingLg),

                    AppButton(
                      label: 'Sair',
                      onPressed: () => _onLogout(context),
                      variant: ButtonVariant.outlined,
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
}
