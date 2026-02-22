import 'package:cortex_bank_mobile/shared/theme/app_design_tokens.dart';
import 'package:cortex_bank_mobile/core/utils/validators.dart';
import 'package:cortex_bank_mobile/core/widgets/app_button.dart';
import 'package:cortex_bank_mobile/core/widgets/app_card_container.dart';
import 'package:cortex_bank_mobile/core/widgets/app_dropdown_field.dart';
import 'package:cortex_bank_mobile/core/widgets/app_tabs.dart';
import 'package:cortex_bank_mobile/core/widgets/app_text_field.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppNewTransactionCard extends StatefulWidget {
  const AppNewTransactionCard({super.key});

  @override
  State<AppNewTransactionCard> createState() => _AppNewTransactionCardState();
}

class _AppNewTransactionCardState extends State<AppNewTransactionCard> {
  String? selectedValue;

  @override
  Widget build(BuildContext context) {
    return AppCardContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Nova transferência',
            style: GoogleFonts.roboto(
              fontSize: AppDesignTokens.fontSizeTitle,
              fontWeight: AppDesignTokens.fontWeightSemibold,
              color: AppDesignTokens.colorContentDefault,
            ),
          ),
          const SizedBox(height: 24),
          AppDropdownField<String>(
            label: 'Selecione o tipo de transação',
            hintText: 'Selecione o tipo de transação',
            value: selectedValue,
            items: const [
              DropdownMenuItem(value: 'credito', child: Text('Crédito')),
              DropdownMenuItem(value: 'debito', child: Text('Débito')),
              DropdownMenuItem(
                value: 'transferencia',
                child: Text('Transferência'),
              ),
            ],
            onChanged: (newValue) {
              setState(() {
                selectedValue = newValue;
              });
            },
            showRequiredIndicator: true,
            validator: (value) => value == null ? 'Campo obrigatório' : null,
          ),

          AppTabs(
            height: 100,
            titles: const ['Nova conta', 'Favoritos', 'Contatos'],
            children: const [
              Center(child: Text('Conteúdo Nova conta')),
              Center(child: Text('Conteúdo Favoritos')),
              Center(child: Text('Conteúdo Contatos')),
            ],
          ),

          const Divider(height: 1, color: AppDesignTokens.colorNeutral),

          const SizedBox(height: 24),
          AppTextField(
            label: 'Valor a ser transferido',
            controller: null,
            validator: requiredField,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            hintText: '0,00',
          ),

          const SizedBox(height: 32),

          AppButton(label: 'Concluir transação', onPressed: null),
        ],
      ),
    );
  }
}
