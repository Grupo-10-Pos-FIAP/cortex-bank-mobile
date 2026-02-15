import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cortex_bank_mobile/core/providers/auth_provider.dart';
import 'package:cortex_bank_mobile/core/utils/currency_formatter.dart';
import 'package:cortex_bank_mobile/core/widgets/app_button.dart';
import 'package:cortex_bank_mobile/core/widgets/app_loading.dart';
import 'package:cortex_bank_mobile/features/transaction/state/transactions_provider.dart';
import 'package:cortex_bank_mobile/core/models/transaction.dart' as model;

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
      final auth = context.read<AuthProvider>();
      if (!auth.isAuthenticated) {
        Navigator.of(context).pushReplacementNamed('/login');
        return;
      }
      context.read<TransactionsProvider>().loadTransactions();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, auth, _) {
        if (!auth.isAuthenticated) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        return Scaffold(
          appBar: AppBar(
            title: const Text('Extrato'),
            actions: [
              IconButton(
                icon: const Icon(Icons.logout),
                onPressed: () async {
                  await auth.signOut();
                  if (!mounted) return;
                  Navigator.of(context).pushReplacementNamed('/login');
                },
              ),
            ],
          ),
          body: Consumer<TransactionsProvider>(
            builder: (context, tx, _) {
              if (tx.loading && tx.transactions.isEmpty) {
                return const AppLoading();
              }
              if (tx.errorMessage != null && tx.transactions.isEmpty) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(tx.errorMessage!, textAlign: TextAlign.center),
                        const SizedBox(height: 16),
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
                padding: const EdgeInsets.all(16),
                itemCount: list.length,
                itemBuilder: (context, i) {
                  final t = list[i];
                  return _TransactionTile(
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
    required this.transaction,
    required this.onDelete,
  });

  final model.Transaction transaction;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final isIncome = transaction.type == model.TransactionType.income;
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
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
                fontWeight: FontWeight.bold,
                color: isIncome ? Colors.green : Colors.red,
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
