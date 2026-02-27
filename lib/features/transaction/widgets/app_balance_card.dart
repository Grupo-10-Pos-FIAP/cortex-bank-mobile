import 'package:cortex_bank_mobile/shared/theme/app_design_tokens.dart';
import 'package:cortex_bank_mobile/core/widgets/app_card_container.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppBalanceCard extends StatefulWidget {
  final bool mostrarSaldoInicial;
  final double saldo;
  final VoidCallback? onTap;

  const AppBalanceCard({
    super.key,
    this.mostrarSaldoInicial = false,
    this.saldo = 5000.00,
    this.onTap,
  });

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
    final content = AppCardContainer(
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
                icon: Icon(_exibir ? Icons.visibility : Icons.visibility_off),
                onPressed: () => setState(() => _exibir = !_exibir),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Text(
                _exibir
                    ? 'R\$ ${widget.saldo.toStringAsFixed(2).replaceAll('.', ',')}'
                    : '••••••',
                style: GoogleFonts.roboto(
                  fontSize: AppDesignTokens.fontSizeH1,
                  fontWeight: AppDesignTokens.fontWeightSemibold,
                  color: AppDesignTokens.colorContentDefault,
                ),
              ),
              const SizedBox(width: 8),
              if (_exibir) const Icon(Icons.north_east, size: 20),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Rendeu 3% desde o mês passado',
            style: GoogleFonts.roboto(
              fontSize: AppDesignTokens.fontSizeSmall,
              color: AppDesignTokens.colorFeedbackSuccess,
              fontWeight: AppDesignTokens.fontWeightMedium,
            ),
          ),
        ],
      ),
    );

    if (widget.onTap != null) {
      return InkWell(
        onTap: widget.onTap,
        borderRadius: BorderRadius.circular(8),
        child: content,
      );
    }
    return content;
  }
}
