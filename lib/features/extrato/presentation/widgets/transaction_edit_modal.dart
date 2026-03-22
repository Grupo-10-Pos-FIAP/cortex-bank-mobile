import 'package:cortex_bank_mobile/core/utils/currency_formatter.dart';
import 'package:cortex_bank_mobile/core/utils/date_formatter.dart';
import 'package:cortex_bank_mobile/core/widgets/app_dropdown_field.dart';
import 'package:cortex_bank_mobile/core/widgets/app_snackbar.dart';
import 'package:cortex_bank_mobile/features/transaction/constants/transaction_date_policy.dart';
import 'package:cortex_bank_mobile/features/transaction/constants/transaction_schedule_copy.dart';
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
  late TextEditingController _descriptionController;
  late model.TransactionType _selectedType;
  late String _selectedTo;
  late model.TransactionCategory _selectedCategory;
  late DateTime _selectedDate;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final valueCents = (widget.data.value * 100).round();
    _valueController = TextEditingController(
      text: formatCentsToBRL(valueCents),
    );
    _descriptionController = TextEditingController(
      text: widget.data.description ?? '',
    );

    _selectedType = widget.data.type;
    _selectedTo = widget.data.to ?? 'Mesma Titularidade';
    _selectedCategory = widget.data.category;
    _selectedDate = TransactionDatePolicy.clampToAllowedRange(
      widget.data.date,
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ContactsProvider>().loadContacts();
    });
  }

  @override
  void dispose() {
    _valueController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    if (!TransactionDatePolicy.isAllowed(_selectedDate)) {
      AppSnackBar.error(
        context,
        TransactionDatePolicy.validationMessage,
        duration: const Duration(seconds: 5),
      );
      return;
    }

    setState(() => _isLoading = true);

    final text = _valueController.text.replaceAll(RegExp(r'[^0-9]'), '');
    final newValue = (double.tryParse(text) ?? 0.0) / 100;
    final valueToSave = newValue > 0 ? newValue : widget.data.value;

    final fromTitular =
        context.read<AuthProvider>().user?.username ?? widget.data.from;

    final descriptionText = _descriptionController.text.trim();

    final resolvedStatus = TransactionDatePolicy.isStrictlyAfterToday(
          _selectedDate,
        )
        ? model.TransactionStatus.pending
        : model.TransactionStatus.completed;

    final updated = model.Transaction(
      id: widget.data.id,
      accountId: widget.data.accountId,
      type: _selectedType,
      category: _selectedCategory,
      value: valueToSave,
      date: _selectedDate,
      status: resolvedStatus,
      to: _selectedTo,
      from: fromTitular,
      description: descriptionText.isNotEmpty ? descriptionText : null,
      receiptUrls: widget.data.receiptUrls,
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
    final fetchedContacts = context.watch<ContactsProvider>().contacts;

    final contactNames = fetchedContacts.map((c) => c.name).toList();

    const fixedOptions = [
      'Mesma Titularidade',
      'Outra Titularidade',
    ];

    final allToOptions = {...fixedOptions, ...contactNames}.toList();

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

            InkWell(
              onTap: () async {
                final minD = TransactionDatePolicy.today;
                final maxD = TransactionDatePolicy.maxSelectableDate;
                final initial = TransactionDatePolicy.clampToAllowedRange(
                  _selectedDate,
                );
                final picked = await showDatePicker(
                  context: context,
                  initialDate: initial,
                  firstDate: minD,
                  lastDate: maxD,
                  helpText:
                      'Hoje até ${TransactionDatePolicy.futureDaysInclusive} dias à frente',
                );
                if (picked != null) {
                  setState(() => _selectedDate = picked);
                }
              },
              child: InputDecorator(
                decoration: InputDecoration(
                  labelText: 'Data da transação',
                  filled: true,
                  fillColor: AppDesignTokens.colorWhite,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(
                      AppDesignTokens.borderRadiusDefault,
                    ),
                  ),
                  suffixIcon: const Icon(Icons.calendar_today),
                ),
                child: Text(
                  DateFormatter.formatDate(_selectedDate),
                ),
              ),
            ),
            if (TransactionDatePolicy.isStrictlyAfterToday(_selectedDate))
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  TransactionScheduleCopy.hintFutureDate,
                  style: TextStyle(
                    fontSize: 12,
                    color: AppDesignTokens.colorContentDisabled,
                  ),
                ),
              ),

            const SizedBox(height: 16),

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

            const SizedBox(height: 16),

            AppTextFieldDecorator(
              label: 'Descrição (opcional)',
              controller: _descriptionController,
              onChanged: (value) {},
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
