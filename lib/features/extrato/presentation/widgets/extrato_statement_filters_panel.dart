import 'package:cortex_bank_mobile/core/widgets/app_dropdown_field.dart';
import 'package:cortex_bank_mobile/features/extrato/presentation/widgets/text_field.dart';
import 'package:cortex_bank_mobile/shared/theme/app_design_tokens.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

class ExtratoStatementFiltersPanel extends StatelessWidget {
  const ExtratoStatementFiltersPanel({
    super.key,
    required this.searchController,
    required this.onSearchChanged,
    required this.periodoTexto,
    required this.onPeriodTap,
    required this.tipoFiltro,
    required this.onTipoChanged,
    required this.statusFiltro,
    required this.onStatusChanged,
    required this.minValueController,
    required this.maxValueController,
    required this.onMinMaxChanged,
    required this.onClearFilters,
  });

  final TextEditingController searchController;
  final ValueChanged<String> onSearchChanged;
  final String periodoTexto;
  final VoidCallback onPeriodTap;
  final String tipoFiltro;
  final ValueChanged<String?> onTipoChanged;
  final String statusFiltro;
  final ValueChanged<String?> onStatusChanged;
  final TextEditingController minValueController;
  final TextEditingController maxValueController;
  final VoidCallback onMinMaxChanged;
  final VoidCallback onClearFilters;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDesignTokens.spacingMd,
        vertical: AppDesignTokens.spacingSm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextField(
            controller: searchController,
            onChanged: onSearchChanged,
            decoration: InputDecoration(
              hintText: 'Buscar por origem, destino, ID ou valor...',
              prefixIcon: const Icon(Icons.search),
              filled: true,
              fillColor: AppDesignTokens.colorWhite,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(
                  AppDesignTokens.borderRadiusDefault,
                ),
              ),
            ),
          ),
          const SizedBox(height: AppDesignTokens.spacingMd),
          InkWell(
            onTap: onPeriodTap,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
              decoration: BoxDecoration(
                color: AppDesignTokens.colorWhite,
                borderRadius: BorderRadius.circular(
                  AppDesignTokens.borderRadiusDefault,
                ),
                border: Border.all(color: AppDesignTokens.colorBorderDefault),
              ),
              child: Row(
                children: [
                  const Icon(Icons.calendar_today, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    periodoTexto,
                    style: GoogleFonts.roboto(
                      fontSize: AppDesignTokens.fontSizeBody,
                      color: AppDesignTokens.colorContentDefault,
                    ),
                  ),
                  const Spacer(),
                  const Icon(Icons.arrow_drop_down),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppDesignTokens.spacingMd),
          AppDropdownField<String>(
            hintText: 'Selecione o tipo de transação',
            value: tipoFiltro,
            items: const [
              DropdownMenuItem(value: 'todas', child: Text('Todos')),
              DropdownMenuItem(value: 'credito', child: Text('Crédito')),
              DropdownMenuItem(value: 'debito', child: Text('Débito')),
              DropdownMenuItem(value: 'ted', child: Text('TED/DOC')),
            ],
            onChanged: onTipoChanged,
            validator: (value) => value == null ? 'Campo obrigatório' : null,
            decoration: InputDecoration(
              labelText: 'Tipo de Transação',
              hintText: 'R\$ 0,00',
              filled: true,
              fillColor: AppDesignTokens.colorWhite,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(
                  AppDesignTokens.borderRadiusDefault,
                ),
              ),
            ),
          ),
          const SizedBox(height: AppDesignTokens.spacingMd),
          AppDropdownField<String>(
            hintText: 'Selecione o status da transação',
            value: statusFiltro,
            items: const [
              DropdownMenuItem(value: 'todas', child: Text('Todos')),
              DropdownMenuItem(value: 'completa', child: Text('Completa')),
              DropdownMenuItem(value: 'agendada', child: Text('Agendada')),
              DropdownMenuItem(value: 'pendente', child: Text('Pendente')),
            ],
            onChanged: onStatusChanged,
            validator: (value) => value == null ? 'Campo obrigatório' : null,
            decoration: InputDecoration(
              labelText: 'Status da Transação',
              hintText: 'Selecione o status',
              filled: true,
              fillColor: AppDesignTokens.colorWhite,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(
                  AppDesignTokens.borderRadiusDefault,
                ),
              ),
            ),
          ),
          const SizedBox(height: AppDesignTokens.spacingMd),
          AppTextFieldDecorator(
            label: 'Valor Mínimo',
            controller: minValueController,
            onChanged: (_) => onMinMaxChanged(),
          ),
          const SizedBox(height: AppDesignTokens.spacingMd),
          AppTextFieldDecorator(
            label: 'Valor máximo',
            controller: maxValueController,
            onChanged: (_) => onMinMaxChanged(),
          ),
          const SizedBox(height: AppDesignTokens.spacingLg),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: onClearFilters,
              icon: Icon(MdiIcons.eraser, size: 20),
              label: const Text('Limpar Filtros'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppDesignTokens.colorPrimary,
                foregroundColor: AppDesignTokens.colorWhite,
                padding: const EdgeInsets.symmetric(
                  vertical: AppDesignTokens.spacingMd,
                  horizontal: AppDesignTokens.spacingLg,
                ),
                minimumSize: const Size.fromHeight(48),
              ),
            ),
          ),
          const SizedBox(height: AppDesignTokens.spacingLg),
        ],
      ),
    );
  }
}
