import 'package:cortex_bank_mobile/core/utils/currency_formatter.dart';
import 'package:cortex_bank_mobile/core/widgets/app_dropdown_field.dart';
import 'package:cortex_bank_mobile/features/auth/state/auth_provider.dart';
import 'package:cortex_bank_mobile/features/contacts/state/contacts_provider.dart';
import 'package:cortex_bank_mobile/features/extrato/presentation/widgets/text_field.dart';
import 'package:cortex_bank_mobile/features/transaction/models/transaction.dart'
    as model;
import 'package:cortex_bank_mobile/features/transaction/state/transactions_provider.dart';
import 'package:cortex_bank_mobile/shared/theme/app_design_tokens.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class TransactionEditModal extends StatefulWidget {
  final model.Transaction data;

  const TransactionEditModal({super.key, required this.data});

  @override
  State<TransactionEditModal> createState() => _TransactionEditModalState();
}

class _TransactionEditModalState extends State<TransactionEditModal> {
  late TextEditingController _valueController;
  late model.TransactionType _selectedType;
  late String _selectedTo;
  late String _selectedStatus;
  late model.TransactionCategory _selectedCategory;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final valueCents = (widget.data.value * 100).round();
    _valueController = TextEditingController(
      text: formatCentsToBRL(valueCents),
    );

    _selectedType = widget.data.type;
    _selectedTo = widget.data.to ?? 'Mesma Titularidade';
    _selectedStatus = widget.data.status;

    // AJUSTE AQUI: Use o valor que vem do model diretamente.
    // Se o widget.data.category for nulo, use um valor padrão do Enum.
    _selectedCategory = widget.data.category;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ContactsProvider>().loadContacts();
    });
  }

  @override
  void dispose() {
    _valueController.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    setState(() => _isLoading = true);

    // 1. Pega o texto (ex: "R$ 1.250,50") e limpa tudo que não for número
    String text = _valueController.text.replaceAll(RegExp(r'[^0-9]'), '');

    // 2. Converte para double (dividindo por 100 para considerar os centavos)
    double newValue = (double.tryParse(text) ?? 0.0) / 100;

    // 3. Se o valor for 0 (campo vazio ou erro), decide se usa o original ou 0
    double valueToSave = newValue > 0 ? newValue : widget.data.value;

    final fromTitular =
        context.read<AuthProvider>().user?.username ?? widget.data.from;

    final updated = model.Transaction(
      id: widget.data.id,
      accountId: widget.data.accountId,
      type: _selectedType,
      category: _selectedCategory,
      value: valueToSave,
      date: DateTime.now(),
      status: _selectedStatus,
      to: _selectedTo,
      from: fromTitular,
    );

    final success = await context
        .read<TransactionsProvider>()
        .updateTransaction(updated);

    if (mounted) {
      setState(() => _isLoading = false);
      if (success) Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<dynamic> fetchedContacts = context
        .watch<ContactsProvider>()
        .contacts;

    // 2. Transforma a lista de objetos em uma lista de STRINGS (ex: pegando o nome)
    final List<String> contactNames = fetchedContacts.map((contact) {
      return contact.name
          .toString(); // Substitua '.name' pela propriedade correta do seu objeto
    }).toList();

    // 3. Opções fixas
    final List<String> fixedOptions = [
      'Mesma Titularidade',
      'Outra Titularidade',
    ];

    // 4. Une tudo em uma lista de Strings
    final List<String> allToOptions = {
      ...fixedOptions,
      ...contactNames,
    }.toList();

    // 5. Segurança: garante que o valor selecionado existe na lista de Strings
    if (!allToOptions.contains(_selectedTo)) {
      _selectedTo = allToOptions.first;
    }

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      backgroundColor: AppDesignTokens.colorWhite,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Editar Transação',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),

            _buildDropdown<model.TransactionType>(
              label: 'Tipo de transação',
              value: _selectedType,
              items: const [
                DropdownMenuItem(
                  value: model.TransactionType.ted,
                  child: Text('TED/DOC'),
                ),
                DropdownMenuItem(
                  value: model.TransactionType.credit,
                  child: Text('Crédito'),
                ),
                DropdownMenuItem(
                  value: model.TransactionType.debit,
                  child: Text('Débito'),
                ),
              ],
              onChanged: (val) => setState(() => _selectedType = val!),
            ),

            const SizedBox(height: 16),

            AppTextFieldDecorator(
              label: 'Valor a ser transferido',
              controller: _valueController,
              onChanged: (value) {},
            ),

            const SizedBox(height: 16),

            // Dropdown unificado: Opções Fixas + Contatos
            _buildDropdown<String>(
              label: 'Destino (Para)',
              value: _selectedTo,
              items: allToOptions.map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              onChanged: (val) => setState(() => _selectedTo = val!),
            ),

            const SizedBox(height: 24),
            // Dropdown de Categorias
            _buildDropdown<model.TransactionCategory>(
              label: 'Categoria',
              value:
                  _selectedCategory,
              items: model.TransactionCategory.values.map((cat) {
                return DropdownMenuItem<model.TransactionCategory>(
                  value: cat,
                  child: Text(
                    cat.label,
                  ),
                );
              }).toList(),
              onChanged: (val) => setState(() => _selectedCategory = val!),
            ),

            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancelar'),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _isLoading ? null : _handleSave,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppDesignTokens.colorPrimary,
                    foregroundColor: AppDesignTokens.colorWhite,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                        AppDesignTokens.borderRadiusDefault,
                      ),
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text('Alterar'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDropdown<T>({
    required String label,
    required T value,
    required List<DropdownMenuItem<T>> items,
    required ValueChanged<T?> onChanged,
  }) {
    return AppDropdownField<T>(
      value: value,
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: AppDesignTokens.colorWhite,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(
            AppDesignTokens.borderRadiusDefault,
          ),
        ),
      ),
      items: items,
      onChanged: onChanged,
    );
  }
}
