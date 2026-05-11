import 'package:cortex_bank_mobile/core/utils/currency_formatter.dart';
import 'package:cortex_bank_mobile/core/widgets/app_card_container.dart';
import 'package:cortex_bank_mobile/core/widgets/app_error_message.dart';
import 'package:cortex_bank_mobile/features/transaction/presentation/providers/transactions_provider.dart';
import 'package:cortex_bank_mobile/shared/theme/app_design_tokens.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class AppBalanceCard extends StatefulWidget {
  final bool mostrarSaldoInicial;

  const AppBalanceCard({super.key, this.mostrarSaldoInicial = false});

  @override
  State<AppBalanceCard> createState() => _AppBalanceCardState();
}

class _AppBalanceCardState extends State<AppBalanceCard> {
  late bool _exibir;

  @override
  void initState() {
    super.initState();
    _exibir = widget.mostrarSaldoInicial;
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<TransactionsProvider>(
      builder: (context, provider, child) {
        final summary = provider.balanceSummary;
        final err = provider.balanceSummaryError;
        final loading = provider.isBalanceSummaryLoading;
        final balanceCents = summary?.balanceCents;
        final saldoReal = (balanceCents ?? 0) / 100;

        Widget body;
        if (err != null) {
          body = AppErrorMessage(
            message: err,
            onDismiss: () => context.read<TransactionsProvider>().clearError(),
          );
        } else if (loading && summary == null) {
          body = Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Row(
                children: [
                  const SizedBox(
                    height: 22,
                    width: 22,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Carregando saldo…',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontSize: AppDesignTokens.fontSizeBody,
                      color: AppDesignTokens.colorContentDisabled,
                    ),
                  ),
                ],
              ),
            ),
          );
        } else if (balanceCents == null) {
          body = Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Text(
              '—',
              style: GoogleFonts.roboto(
                fontSize: AppDesignTokens.fontSizeH1,
                fontWeight: AppDesignTokens.fontWeightSemibold,
                color: AppDesignTokens.colorContentDisabled,
              ),
            ),
          );
        } else {
          body = Row(
            children: [
              Text(
                _exibir
                    ? formatCentsToBRLWithThousands(balanceCents)
                    : '••••••',
                style: GoogleFonts.roboto(
                  fontSize: AppDesignTokens.fontSizeH1,
                  fontWeight: AppDesignTokens.fontWeightSemibold,
                  color: !_exibir
                      ? AppDesignTokens.colorContentDefault
                      : (saldoReal < 0
                            ? AppDesignTokens.colorFeedbackAlert
                            : AppDesignTokens.colorContentDefault),
                ),
              ),
              const SizedBox(width: 8),
              if (_exibir)
                Icon(
                  Icons.north_east,
                  size: 20,
                  color: saldoReal < 0
                      ? AppDesignTokens.colorFeedbackAlert
                      : AppDesignTokens.colorContentDefault,
                ),
            ],
          );
        }

        final cardContent = AppCardContainer(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Saldo',
                    style: GoogleFonts.roboto(
                      fontSize: AppDesignTokens.fontSizeH3,
                      fontWeight: AppDesignTokens.fontWeightSemibold,
                      color: AppDesignTokens.colorContentDefault,
                    ),
                  ),
                  if (err == null && balanceCents != null)
                    IconButton(
                      icon: Icon(
                        _exibir ? Icons.visibility : Icons.visibility_off,
                      ),
                      onPressed: () => setState(() => _exibir = !_exibir),
                    ),
                ],
              ),
              const SizedBox(height: 8),
              body,
            ],
          ),
        );

        return InkWell(
          onTap: () => Navigator.pushNamed(context, '/extrato'),
          borderRadius: BorderRadius.circular(8),
          child: cardContent,
        );
      },
    );
  }
}
