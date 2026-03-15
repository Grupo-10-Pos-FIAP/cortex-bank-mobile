import 'package:cortex_bank_mobile/features/transaction/state/transactions_provider.dart';
import 'package:cortex_bank_mobile/shared/theme/app_design_tokens.dart';
import 'package:cortex_bank_mobile/core/widgets/app_card_container.dart';
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
        final balanceCents = provider.balanceSummary?.balanceCents ?? 0;
        final saldoReal = balanceCents / 100;

        Widget cardContent = AppCardContainer(
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
                  IconButton(
                    icon: Icon(
                      _exibir ? Icons.visibility : Icons.visibility_off,
                    ),
                    onPressed: () => setState(() => _exibir = !_exibir),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Text(
                    _exibir
                        ? 'R\$ ${saldoReal.toStringAsFixed(2).replaceAll('.', ',')}'
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
              ),
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
