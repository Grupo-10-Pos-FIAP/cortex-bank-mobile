import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cortex_bank_mobile/features/auth/state/auth_provider.dart';
import 'package:cortex_bank_mobile/shared/theme/app_design_tokens.dart';
import 'package:cortex_bank_mobile/core/utils/currency_formatter.dart';
import 'package:cortex_bank_mobile/core/widgets/app_button.dart';
import 'package:cortex_bank_mobile/core/widgets/app_loading.dart';
import 'package:cortex_bank_mobile/features/transaction/state/transactions_provider.dart';
import 'package:cortex_bank_mobile/features/transaction/models/transaction.dart' as model;

class ExtratoPage extends StatefulWidget {
  const ExtratoPage({super.key});

  @override
  State<ExtratoPage> createState() => _ExtratoPageState();
}

class _ExtratoPageState extends State<ExtratoPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Com login obrigatório: redirecionar se não autenticado
      // final auth = context.read<AuthProvider>();
      // if (!auth.isAuthenticated) {
      //   Navigator.of(context).pushReplacementNamed('/login');
      //   return;
      // }
      context.read<TransactionsProvider>().loadTransactions();
    });
  }

  Future<void> _onSignOut() async {
    await context.read<AuthProvider>().signOut();
    if (!mounted) return;
    // Com login obrigatório: redirecionar para login após logout
    // Navigator.of(context).pushReplacementNamed('/login');
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, auth, _) {
        // Com login obrigatório: mostrar loading enquanto não autenticado
        // if (!auth.isAuthenticated) {
        //   return const Scaffold(
        //     body: Center(child: CircularProgressIndicator()),
        //   );
        // }
        return Scaffold(
          backgroundColor: AppDesignTokens.colorBgDefault,
          body: Consumer<TransactionsProvider>(
            builder: (context, tx, _) {
              if (tx.loading && tx.transactions.isEmpty) {
                return const AppLoading();
              }
              if (tx.errorMessage != null && tx.transactions.isEmpty) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(AppDesignTokens.spacingLg),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          tx.errorMessage!,
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        const SizedBox(height: AppDesignTokens.spacingMd),
                        AppButton(
                          label: 'Tentar novamente',
                          onPressed: () => tx.loadTransactions(),
                        ),
                      ],
                    ),
                  ),
                );
              }
              final list = tx.transactions;
              return ListView.builder(
                padding: const EdgeInsets.all(AppDesignTokens.spacingMd),
                itemCount: list.length,
                itemBuilder: (context, i) {
                  final t = list[i];
                  return _TransactionTile(
                    key: ValueKey(t.id),
                    transaction: t,
                    onDelete: () => tx.deleteTransaction(t.id),
                  );
                },
              );
            },
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () => Navigator.of(context).pushNamed('/transaction/new'),
            child: const Icon(Icons.add),
          ),
        );
      },
    );
  }
}

class _TransactionTile extends StatelessWidget {
  const _TransactionTile({
    super.key,
    required this.transaction,
    required this.onDelete,
  });

  final model.Transaction transaction;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final isIncome = transaction.type == model.TransactionType.income;
    return Card(
      margin: const EdgeInsets.only(bottom: AppDesignTokens.spacingSm),
      child: ListTile(
        title: Text(transaction.title),
        subtitle: Text(
          '${transaction.date.day}/${transaction.date.month}/${transaction.date.year}',
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              formatCentsToBRL(isIncome ? transaction.amountCents : -transaction.amountCents),
              style: TextStyle(
                fontWeight: AppDesignTokens.fontWeightBold,
                color: isIncome
                    ? AppDesignTokens.colorFeedbackSuccess
                    : AppDesignTokens.colorFeedbackError,
              ),
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline),
              onPressed: onDelete,
            ),
          ],
        ),
      ),
    );
  }
}
