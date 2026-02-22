import 'package:cortex_bank_mobile/features/transaction/widgets/app_balance_card.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:cortex_bank_mobile/core/theme/app_design_tokens.dart';
import 'package:cortex_bank_mobile/core/utils/currency_formatter.dart';
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
      context.read<TransactionsProvider>().loadTransactions();
      context.read<TransactionsProvider>().loadBalanceSummary();
    });

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppDesignTokens.colorBgDefault,
      body: Consumer<TransactionsProvider>(
        builder: (context, tx, _) {
          if (tx.loading && tx.transactions.isEmpty) {
            return const AppLoading();
          }

          final list = tx.transactions;

          return CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Consumer<TransactionsProvider>(
                  builder: (context, tx, _) {
                    final saldoReal =
                        tx.balanceSummary?.totalIncomeCents.toDouble() ?? 0.0;
                    return AppBalanceCard(
                      mostrarSaldoInicial: true,
                      saldo: saldoReal / 100,
                    );
                  },
                ),
              ),

              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  child: Text(
                    "Suas atividades",
                    style: GoogleFonts.roboto(fontWeight: FontWeight.bold, fontSize: AppDesignTokens.fontSizeBody),
                  ),
                ),
              ),

              list.isEmpty
                  ? SliverFillRemaining(
                      child: Center(
                        child: Text(
                          tx.errorMessage ?? "Nenhuma transação encontrada",
                        ),
                      ),
                    )
                  : SliverPadding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate((context, i) {
                          final t = list[i];
                          return _TransactionTile(
                            key: ValueKey(t.id),
                            transaction: t,
                            onDelete: () => tx.deleteTransaction(t.id),
                          );
                        }, childCount: list.length),
                      ),
                    ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.of(context).pushNamed('/transaction/new'),
        backgroundColor: AppDesignTokens.colorPrimary,
        child: const Icon(Icons.add, color: AppDesignTokens.colorWhite),
      ),
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
              formatCentsToBRL(
                isIncome ? transaction.amountCents : -transaction.amountCents,
              ),
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
