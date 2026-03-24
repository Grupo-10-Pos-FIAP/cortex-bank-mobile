import 'package:cortex_bank_mobile/core/utils/currency_formatter.dart';
import 'package:cortex_bank_mobile/core/utils/date_formatter.dart';
import 'package:cortex_bank_mobile/core/utils/validators.dart';
import 'package:cortex_bank_mobile/core/widgets/app_dropdown_field.dart';
import 'package:cortex_bank_mobile/core/widgets/app_snackbar.dart';
import 'package:cortex_bank_mobile/core/widgets/app_text_field.dart';
import 'package:cortex_bank_mobile/features/transaction/constants/transaction_date_policy.dart';
import 'package:cortex_bank_mobile/features/transaction/utils/ted_recipient_line.dart';
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

  /// Mapeia o valor persistido em [Transaction.to] para o rótulo do dropdown
  /// (Mesma / Outra titularidade ou nome de contato).
  static String dropdownLabelForStoredTo(
    String? storedTo,
    Iterable<String> contactNames,
  ) {
    final t = storedTo?.trim() ?? '';
    if (t.isEmpty) return 'Mesma Titularidade';
    final lower = t.toLowerCase();
    if (lower.startsWith('mesma titularidade')) {
      return 'Mesma Titularidade';
    }
    if (TedRecipientLine.looksLike(t)) {
      return 'Outra Titularidade';
    }
    final names = contactNames
        .map((n) => n.trim())
        .where((n) => n.isNotEmpty)
        .toSet();
    if (names.contains(t)) {
      return t;
    }
    // Ex.: contato removido da agenda — mantém o texto salvo como opção válida.
    return t;
  }

  @override
  State<TransactionEditModal> createState() => _TransactionEditModalState();
}

class _TransactionEditModalState extends State<TransactionEditModal> {
  late TextEditingController _valueController;
  late TextEditingController _descriptionController;
  late TextEditingController _otherTitularNameController;
  late TextEditingController _otherTitularBranchController;
  late TextEditingController _otherTitularAccountController;
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
    _selectedTo = TransactionEditModal.dropdownLabelForStoredTo(
      widget.data.to,
      const [],
    );

    // Só parseia linha TED quando o destino salvo é outra titularidade; "Mesma titularidade — … | Ag.: …"
    // também contém "|" e "Ag.:" e não deve preencher os campos de favorecido.
    final parsedOutra = _selectedTo == 'Outra Titularidade'
        ? TedRecipientLine.tryParse(widget.data.to ?? '')
        : null;
    _otherTitularNameController = TextEditingController(
      text: parsedOutra?.name ?? '',
    );
    _otherTitularBranchController = TextEditingController(
      text: parsedOutra?.branch ?? '',
    );
    _otherTitularAccountController = TextEditingController(
      text: parsedOutra?.account ?? '',
    );
    _selectedCategory = widget.data.category;
    _selectedDate = TransactionDatePolicy.clampToAllowedRange(
      widget.data.date,
    );

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await context.read<ContactsProvider>().loadContacts();
      if (!mounted) return;
      final names =
          context.read<ContactsProvider>().contacts.map((c) => c.name).toList();
      setState(() {
        _selectedTo = TransactionEditModal.dropdownLabelForStoredTo(
          widget.data.to,
          names,
        );
      });
    });
  }

  @override
  void dispose() {
    _valueController.dispose();
    _descriptionController.dispose();
    _otherTitularNameController.dispose();
    _otherTitularBranchController.dispose();
    _otherTitularAccountController.dispose();
    super.dispose();
  }

  void _clearOtherTitularidadeFields() {
    _otherTitularNameController.clear();
    _otherTitularBranchController.clear();
    _otherTitularAccountController.clear();
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

    final valueError = validateMinTransferValueBRL(_valueController.text);
    if (valueError != null) {
      AppSnackBar.error(
        context,
        valueError,
        duration: const Duration(seconds: 5),
      );
      return;
    }

    if (_selectedTo == 'Outra Titularidade') {
      final name = _otherTitularNameController.text.trim();
      final branch = _otherTitularBranchController.text.trim();
      final account = _otherTitularAccountController.text.trim();
      if (name.isEmpty) {
        AppSnackBar.error(
          context,
          'Informe o nome do favorecido (outra titularidade).',
          duration: const Duration(seconds: 5),
        );
        return;
      }
      if (branch.isEmpty) {
        AppSnackBar.error(
          context,
          'Informe a agência do favorecido (outra titularidade).',
          duration: const Duration(seconds: 5),
        );
        return;
      }
      if (account.isEmpty) {
        AppSnackBar.error(
          context,
          'Informe a conta do favorecido (outra titularidade).',
          duration: const Duration(seconds: 5),
        );
        return;
      }
    }

    setState(() => _isLoading = true);

    final cents = parseBRLMaskToCents(_valueController.text);
    final valueToSave = cents / 100.0;

    final fromTitular =
        context.read<AuthProvider>().user?.username ?? widget.data.from;

    final descriptionText = _descriptionController.text.trim();

    String resolvedTo = _selectedTo;

    if (_selectedTo == 'Mesma Titularidade') {
      final initial = widget.data.to?.trim() ?? '';
      if (initial.toLowerCase().startsWith('mesma titularidade')) {
        resolvedTo = initial;
      }
    } else if (_selectedTo == 'Outra Titularidade') {
      resolvedTo = TedRecipientLine.format(
        name: _otherTitularNameController.text,
        branch: _otherTitularBranchController.text,
        account: _otherTitularAccountController.text,
      );
    }

    // Mantém o status salvo quando só outros campos mudam; só recalcula se a data mudar.
    final String resolvedStatus;
    if (TransactionDatePolicy.isSameCalendarDay(
          widget.data.date,
          _selectedDate,
        )) {
      resolvedStatus = widget.data.status;
    } else {
      // Agendada só para data estritamente futura; hoje ou passado = Completa (não Scheduled).
      resolvedStatus = TransactionDatePolicy.isStrictlyAfterToday(
            _selectedDate,
          )
          ? model.TransactionStatus.scheduled
          : model.TransactionStatus.completed;
    }

    final updated = model.Transaction(
      id: widget.data.id,
      accountId: widget.data.accountId,
      type: _selectedType,
      category: _selectedCategory,
      value: valueToSave,
      date: _selectedDate,
      status: resolvedStatus,
      to: resolvedTo,
      from: fromTitular,
      description: descriptionText.isNotEmpty ? descriptionText : null,
      receiptUrls: widget.data.receiptUrls,
    );

    final provider = context.read<TransactionsProvider>();
    final success = await provider.updateTransaction(updated);

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (success) {
      AppSnackBar.success(
        context,
        'Transação atualizada com sucesso.',
      );
      Navigator.pop(context, true);
      return;
    }

    AppSnackBar.error(
      context,
      provider.errorMessage ?? 'Não foi possível atualizar a transação.',
    );
  }

  @override
  Widget build(BuildContext context) {
    final fetchedContacts = context.watch<ContactsProvider>().contacts;

    final contactNames = fetchedContacts.map((c) => c.name).toList();

    const fixedOptions = [
      'Mesma Titularidade',
      'Outra Titularidade',
    ];

    final rawTo = widget.data.to?.trim();
    final orphanTo = rawTo != null &&
            rawTo.isNotEmpty &&
            !fixedOptions.contains(rawTo) &&
            !contactNames.contains(rawTo) &&
            !TedRecipientLine.looksLike(rawTo)
        ? rawTo
        : null;

    final allToOptions = [
      ...fixedOptions,
      ...contactNames,
      ?orphanTo,
    ];

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
              onChanged: (val) {
                setState(() {
                  _selectedTo = val!;
                  if (_selectedTo != 'Outra Titularidade') {
                    _clearOtherTitularidadeFields();
                  }
                });
              },
            ),

            if (_selectedTo == 'Outra Titularidade') ...[
              const SizedBox(height: 16),
              Text(
                'Dados do favorecido (outra titularidade)',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
              const SizedBox(height: 12),
              AppTextField(
                label: 'Nome do favorecido',
                controller: _otherTitularNameController,
                showRequiredIndicator: true,
              ),
              const SizedBox(height: 16),
              AppTextField(
                label: 'Agência',
                controller: _otherTitularBranchController,
                showRequiredIndicator: true,
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              AppTextField(
                label: 'Conta',
                controller: _otherTitularAccountController,
                showRequiredIndicator: true,
                keyboardType: TextInputType.number,
              ),
            ],

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
              isCurrency: false,
              maxLines: 3,
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
