import 'dart:async';

import 'package:cortex_bank_mobile/core/utils/currency_formatter.dart';
import 'package:cortex_bank_mobile/core/utils/date_formatter.dart';
import 'package:cortex_bank_mobile/core/utils/validators.dart';
import 'package:cortex_bank_mobile/core/widgets/app_button.dart';
import 'package:cortex_bank_mobile/core/widgets/app_card_container.dart';
import 'package:cortex_bank_mobile/core/widgets/app_dropdown_field.dart';
import 'package:cortex_bank_mobile/core/widgets/app_tabs.dart';
import 'package:cortex_bank_mobile/core/widgets/app_text_field.dart';
import 'package:cortex_bank_mobile/core/widgets/app_snackbar.dart';
import 'package:cortex_bank_mobile/features/auth/state/auth_provider.dart';
import 'package:cortex_bank_mobile/features/contacts/models/contact.dart';
import 'package:cortex_bank_mobile/features/contacts/presentation/widgets/add_contact_dialog_widget.dart';
import 'package:cortex_bank_mobile/features/contacts/presentation/widgets/contact_list_item.dart';
import 'package:cortex_bank_mobile/features/contacts/state/contacts_provider.dart';
import 'package:cortex_bank_mobile/features/transaction/constants/attachment_constants.dart';
import 'package:cortex_bank_mobile/features/transaction/constants/transaction_date_policy.dart';
import 'package:cortex_bank_mobile/features/transaction/constants/transaction_schedule_copy.dart';
import 'package:cortex_bank_mobile/features/transaction/models/transaction.dart';
import 'package:cortex_bank_mobile/features/transaction/state/transactions_provider.dart';
import 'package:cortex_bank_mobile/shared/theme/app_design_tokens.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';

class AppNewTransactionCard extends StatefulWidget {
  const AppNewTransactionCard({super.key});

  @override
  State<AppNewTransactionCard> createState() => _AppNewTransactionCardState();
}

class _AppNewTransactionCardState extends State<AppNewTransactionCard> {
  final _formKey = GlobalKey<FormState>();
  final _valueFieldKey = GlobalKey<FormFieldState<String>>();
  final TextEditingController _valueController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _otherTitularNameController =
      TextEditingController();
  final TextEditingController _otherTitularBranchController =
      TextEditingController();
  final TextEditingController _otherTitularAccountController =
      TextEditingController();
  Timer? _valueValidationTimer;

  String? selectedValueType;
  String? selectedValueCategory;
  int? selectedTitularidade;
  DateTime _selectedDate = DateTime.now();
  final List<({List<int> bytes, String name})> _attachments = [];
  bool _debugCreatePending = false;

  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ContactsProvider>().loadContacts();
    });
    _valueController.addListener(_validateValueAfterTyping);
  }

  void _validateValueAfterTyping() {
    _valueValidationTimer?.cancel();
    _valueValidationTimer = Timer(const Duration(milliseconds: 600), () {
      if (!mounted) return;
      final field = _valueFieldKey.currentState;
      if (field == null) return;
      if (_valueController.text.trim().isEmpty && !field.hasInteractedByUser) {
        return;
      }
      field.validate();
      setState(() {});
    });
  }

  @override
  void dispose() {
    _valueValidationTimer?.cancel();
    _valueController.removeListener(_validateValueAfterTyping);
    _valueController.dispose();
    _descriptionController.dispose();
    _otherTitularNameController.dispose();
    _otherTitularBranchController.dispose();
    _otherTitularAccountController.dispose();
    super.dispose();
  }

  static String _formatTedRecipientLine({
    required String name,
    required String branch,
    required String account,
  }) {
    final n = name.trim();
    final b = branch.trim();
    final a = account.trim();
    return '$n | Ag.: $b | Cc.: $a';
  }

  void _clearOtherTitularidadeFields() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _otherTitularNameController.value = TextEditingValue.empty;
      _otherTitularBranchController.value = TextEditingValue.empty;
      _otherTitularAccountController.value = TextEditingValue.empty;
    });
  }

  String? _firstValidationError() {
    if (selectedValueType == null) {
      return 'Tipo de transação é obrigatório.';
    }

    Contact? selectedContact;
    try {
      selectedContact = context.read<ContactsProvider>().contacts.firstWhere(
            (c) => c.isSelected,
          );
    } catch (_) {
      selectedContact = null;
    }
    if (selectedContact == null && selectedTitularidade == null) {
      return 'Informe a titularidade (mesma ou outra) ou selecione um contato.';
    }

    if (selectedContact == null) {
      if (selectedTitularidade == 0) {
        final u = context.read<AuthProvider>().user;
        final name = u?.username.trim() ?? '';
        final branch = u?.branchCode.trim() ?? '';
        final account = u?.accountNumber.trim() ?? '';
        if (name.isEmpty) {
          return 'Nome no perfil é obrigatório para mesma titularidade.';
        }
        if (branch.isEmpty) {
          return 'Agência no perfil é obrigatória para mesma titularidade.';
        }
        if (account.isEmpty) {
          return 'Conta no perfil é obrigatória para mesma titularidade.';
        }
      } else if (selectedTitularidade == 1) {
        if (_otherTitularNameController.text.trim().isEmpty) {
          return 'Informe o nome do favorecido (outra titularidade).';
        }
        if (_otherTitularBranchController.text.trim().isEmpty) {
          return 'Informe a agência do favorecido (outra titularidade).';
        }
        if (_otherTitularAccountController.text.trim().isEmpty) {
          return 'Informe a conta do favorecido (outra titularidade).';
        }
      }
    }

    final valueMsg = validateMinTransferValueBRL(_valueController.text);
    if (valueMsg != null) {
      return 'Valor: $valueMsg';
    }

    if (selectedValueCategory == null) {
      return 'Categoria é obrigatória.';
    }

    if (!TransactionDatePolicy.isAllowed(_selectedDate)) {
      return TransactionDatePolicy.validationMessage;
    }

    return null;
  }

  bool _validateFormAndShowFeedback() {
    final msg = _firstValidationError();
    if (msg != null) {
      AppSnackBar.error(context, msg);
      return false;
    }
    return true;
  }

  Future<void> _submitTransaction() async {
    final preSubmitMsg = _firstValidationError();
    if (preSubmitMsg != null) {
      if (mounted) AppSnackBar.error(context, preSubmitMsg);
      return;
    }

    setState(() => _isSubmitting = true);
    try {
      if (!TransactionDatePolicy.isAllowed(_selectedDate)) {
        if (mounted) {
          AppSnackBar.error(
            context,
            TransactionDatePolicy.validationMessage,
            duration: const Duration(seconds: 5),
          );
        }
        return;
      }

      final contactsProvider = context.read<ContactsProvider>();
      final txProvider = context.read<TransactionsProvider>();
      final authProvider = context.read<AuthProvider>();

      final cents = parseBRLMaskToCents(_valueController.text);
      final valueToSave = cents / 100.0;

      Contact? selectedContact;
      try {
        selectedContact = contactsProvider.contacts.firstWhere(
          (c) => c.isSelected,
        );
      } catch (_) {
        selectedContact = null;
      }

      final tipo = selectedValueType;
      final categoria = selectedValueCategory;
      if (tipo == null || categoria == null) {
        if (mounted) {
          AppSnackBar.error(
            context,
            'Não foi possível identificar o tipo ou a categoria. Verifique os campos obrigatórios.',
            duration: const Duration(seconds: 5),
          );
        }
        return;
      }

      final loggedUser = authProvider.user;
      final titularName = loggedUser?.username ?? '';
      final accountId = authProvider.user?.uid ?? '';
      if (accountId.isEmpty) {
        if (mounted) {
          AppSnackBar.error(
            context,
            'Sua sessão não está válida. Faça login novamente para registrar a transação.',
            duration: const Duration(seconds: 5),
          );
        }
        return;
      }
      final descriptionText = _descriptionController.text.trim();

      final isFutureSchedule =
          TransactionDatePolicy.isStrictlyAfterToday(_selectedDate);
      final scheduleDateLabel = DateFormatter.formatDate(_selectedDate);

      String? counterpartyToValue;
      if (selectedContact != null) {
        counterpartyToValue = selectedContact.name;
      } else if (selectedTitularidade == 0 && loggedUser != null) {
        counterpartyToValue =
            'Mesma titularidade — ${_formatTedRecipientLine(name: loggedUser.username, branch: loggedUser.branchCode, account: loggedUser.accountNumber)}';
      } else if (selectedTitularidade == 1) {
        counterpartyToValue = _formatTedRecipientLine(
          name: _otherTitularNameController.text,
          branch: _otherTitularBranchController.text,
          account: _otherTitularAccountController.text,
        );
      }

      final transaction = Transaction(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        accountId: accountId,
        type: TransactionTypeExtension.fromString(tipo),
        category: TransactionCategoryExtension.fromString(categoria),
        value: valueToSave,
        date: _selectedDate,
        from: titularName.isNotEmpty ? titularName : null,
        to: counterpartyToValue,
        status: kDebugMode && _debugCreatePending
            ? TransactionStatus.pending
            : TransactionDatePolicy.isStrictlyAfterToday(_selectedDate)
                ? TransactionStatus.pending
                : TransactionStatus.completed,
        description: descriptionText.isNotEmpty ? descriptionText : null,
      );

      final hasAttachments = _attachments.isNotEmpty;
      final created = await txProvider.addTransaction(
        transaction,
        skipBalanceRefresh: hasAttachments,
      );

      if (created != null && mounted) {
        final failedReceiptNames = <String>[];

        if (hasAttachments) {
          final updated = await txProvider.uploadReceipts(
            created,
            _attachments,
          );
          if (updated == null) {
            failedReceiptNames.addAll(_attachments.map((a) => a.name));
          }
          await txProvider.loadBalanceSummary();
        }

        if (!mounted) return;

        _valueValidationTimer?.cancel();
        _valueController.clear();
        _descriptionController.clear();
        setState(() {
          selectedValueType = null;
          selectedValueCategory = null;
          selectedTitularidade = null;
          _clearOtherTitularidadeFields();
          _selectedDate = TransactionDatePolicy.today;
          _attachments.clear();
          for (var c in contactsProvider.contacts) {
            c.isSelected = false;
          }
        });

        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;
          _formKey.currentState?.reset();
        });

        if (failedReceiptNames.isEmpty) {
          AppSnackBar.success(
            context,
            TransactionScheduleCopy.successAllOk(
              isScheduled: isFutureSchedule,
              formattedDate: scheduleDateLabel,
            ),
            duration: const Duration(seconds: 5),
          );
        } else {
          final files = failedReceiptNames.join(', ');
          final detail = txProvider.errorMessage;
          AppSnackBar.warning(
            context,
            TransactionScheduleCopy.warningReceiptPartial(
              isScheduled: isFutureSchedule,
              files: files,
              count: failedReceiptNames.length,
              detail: detail,
            ),
            duration: const Duration(seconds: 8),
          );
        }
      } else if (mounted) {
        AppSnackBar.error(
          context,
          txProvider.errorMessage?.trim().isNotEmpty == true
              ? txProvider.errorMessage!.trim()
              : TransactionScheduleCopy.errorSubmitFallback(
                  isScheduled: isFutureSchedule,
                ),
          duration: const Duration(seconds: 6),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  Widget _buildTitularidadeTile({required String title, required int index}) {
    final isSelected = selectedTitularidade == index;
    return ListTile(
      title: Text(title),
      trailing: const Icon(Icons.chevron_right),
      tileColor: isSelected
          ? AppDesignTokens.colorPrimary.withValues(alpha: 0.1)
          : null,
      selected: isSelected,
      selectedTileColor: AppDesignTokens.colorPrimary.withValues(alpha: 0.15),
      onTap: () {
        final contacts = context.read<ContactsProvider>().contacts;
        setState(() {
          selectedTitularidade = index;
          for (var c in contacts) {
            c.isSelected = false;
          }
          if (index != 1) {
            _clearOtherTitularidadeFields();
          }
        });
      },
    );
  }

  Widget _buildTitularidadeTab() {
    return Column(
      children: [
        _buildTitularidadeTile(title: 'Mesma titularidade', index: 0),
        _buildTitularidadeTile(title: 'Outra titularidade', index: 1),
      ],
    );
  }

  Widget _buildListTab(
    List<Contact> list,
    ContactsProvider provider,
    String textEmpty,
  ) {
    if (provider.isLoading) return Center(child: CircularProgressIndicator());

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: AppButton(
            label: 'Adicionar contato',
            onPressed: () async {
              final name = await showDialog<String>(
                context: context,
                builder: (ctx) => const AddContactDialogWidget(),
              );
              if (name != null && name.isNotEmpty) {
                await provider.addContact(name);
              }
            },
          ),
        ),
        Expanded(
          child: list.isEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(textEmpty),
                  ),
                )
              : SingleChildScrollView(
                  child: Column(
                    children: list
                        .map(
                          (contact) => ContactListItem(
                            contact: contact,
                            onToggleFavorite: () =>
                                provider.toggleFavorite(contact),
                            onSelectChanged: (value) {
                              setState(() {
                                for (var c in provider.contacts) {
                                  c.isSelected = false;
                                }
                                contact.isSelected = value ?? false;
                                if (contact.isSelected) {
                                  selectedTitularidade = null;
                                  _clearOtherTitularidadeFields();
                                }
                              });
                            },
                          ),
                        )
                        .toList(),
                  ),
                ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final contactsProvider = context.watch<ContactsProvider>();

    return AppCardContainer(
      title: TransactionScheduleCopy.cardSectionTitle,
      child: Stack(
        children: [
          AbsorbPointer(
            absorbing: _isSubmitting,
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
            AppDropdownField<String>(
              label: 'Selecione o tipo de transação',
              hintText: 'Selecione o tipo de transação',
              value: selectedValueType,
              showRequiredIndicator: true,
              items: const [
                DropdownMenuItem(value: 'credito', child: Text('Crédito')),
                DropdownMenuItem(value: 'debito', child: Text('Débito')),
                DropdownMenuItem(value: 'ted', child: Text('TED/DOC')),
              ],
              onChanged: (newValue) =>
                  setState(() => selectedValueType = newValue),
              validator: (value) =>
                  value == null || value.isEmpty ? 'Campo obrigatório' : null,
            ),
            AppTabs(
              marginTop: 16,
              height: 160,
              titles: const ['Nova conta', 'Contatos', 'Favoritos'],
              children: [
                _buildTitularidadeTab(),
                _buildListTab(
                  contactsProvider.contacts,
                  contactsProvider,
                  'Nenhum Contato',
                ),
                _buildListTab(
                  contactsProvider.favoriteContacts,
                  contactsProvider,
                  'Nenhum Contato Favorito',
                ),
              ],
            ),
            const Divider(height: 1, color: AppDesignTokens.colorNeutral),
            if (selectedValueType != null && selectedTitularidade == 1) ...[
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
            AppTextField(
              formFieldKey: _valueFieldKey,
              label: 'Valor a ser transferido',
              controller: _valueController,
              validator: validateMinTransferValueBRL,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              hintText: '0,00',
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                CurrencyBRLInputFormatter(),
              ],
              showRequiredIndicator: true,
            ),
            const SizedBox(height: 24),
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
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(
                      AppDesignTokens.borderRadiusDefault,
                    ),
                  ),
                  suffixIcon: const Icon(Icons.calendar_today),
                ),
                child: Text(
                  DateFormatter.formatDate(_selectedDate),
                  style: Theme.of(context).textTheme.bodyLarge,
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
            const SizedBox(height: 24),
            AppDropdownField<String>(
              label: 'Selecione a categoria',
              hintText: 'Selecione a categoria',
              value: selectedValueCategory,
              showRequiredIndicator: true,
              items: TransactionCategory.values.map((category) {
                return DropdownMenuItem<String>(
                  value: category.name,
                  child: Text(category.label),
                );
              }).toList(),
              onChanged: (newValue) =>
                  setState(() => selectedValueCategory = newValue),
              validator: (value) => value == null ? 'Campo obrigatório' : null,
            ),
            const SizedBox(height: 24),
            AppTextField(
              label: 'Descrição (opcional)',
              controller: _descriptionController,
              hintText: 'Ex: Almoço no restaurante',
              maxLines: 2,
            ),
            const SizedBox(height: 24),
            if (kDebugMode) ...[
              Row(
                children: [
                  Switch(
                    value: _debugCreatePending,
                    onChanged: (v) =>
                        setState(() => _debugCreatePending = v),
                  ),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      'Criar como pendente (apenas ambiente de teste)',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
            ],
            TextButton.icon(
              onPressed: _attachments.length >= AttachmentConstants.maxAttachments
                  ? null
                  : () async {
                      final result = await FilePicker.platform.pickFiles(
                        type: FileType.custom,
                        allowedExtensions:
                            AttachmentConstants.allowedExtensions,
                        withData: true,
                      );
                      if (result == null ||
                          result.files.isEmpty ||
                          !mounted) {
                        return;
                      }
                      final file = result.files.single;
                      final bytes = file.bytes;
                      final name = file.name;
                      if (bytes == null || name.isEmpty) return;
                      if (bytes.length > AttachmentConstants.maxFileSizeBytes) {
                        if (!context.mounted) return;
                        final maxMb = AttachmentConstants.maxFileSizeBytes /
                            (1024 * 1024);
                        AppSnackBar.error(
                          context,
                          'Arquivo excede o limite de ${maxMb.toStringAsFixed(0)}MB.',
                        );
                        return;
                      }
                      if (_attachments.length <
                          AttachmentConstants.maxAttachments) {
                        setState(() {
                          _attachments.add((bytes: bytes, name: name));
                        });
                      }
                    },
              icon: Icon(
                Icons.attach_file,
                size: 20,
                color: _attachments.length >=
                        AttachmentConstants.maxAttachments
                    ? AppDesignTokens.colorContentDisabled
                    : AppDesignTokens.colorPrimary,
              ),
              label: Text(
                'Anexar recibo',
                style: TextStyle(
                  color: _attachments.length >=
                          AttachmentConstants.maxAttachments
                      ? AppDesignTokens.colorContentDisabled
                      : AppDesignTokens.colorPrimary,
                ),
              ),
              style: TextButton.styleFrom(
                backgroundColor: Colors.transparent,
                foregroundColor: _attachments.length >=
                        AttachmentConstants.maxAttachments
                    ? AppDesignTokens.colorContentDisabled
                    : AppDesignTokens.colorPrimary,
              ),
            ),
            if (_attachments.length >= AttachmentConstants.maxAttachments)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  'Máximo de ${AttachmentConstants.maxAttachments} arquivos anexados.',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppDesignTokens.colorContentDisabled,
                  ),
                ),
              ),
            ...List.generate(_attachments.length, (i) {
              final a = _attachments[i];
              return Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Row(
                  children: [
                    Icon(
                      Icons.insert_drive_file,
                      size: 18,
                      color: AppDesignTokens.colorContentDisabled,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        a.name,
                        style: TextStyle(
                          fontSize: 14,
                          color: AppDesignTokens.colorContentDisabled,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, size: 20),
                      onPressed: () => setState(() => _attachments.removeAt(i)),
                    ),
                  ],
                ),
              );
            }),
            const SizedBox(height: 24),
            Consumer<TransactionsProvider>(
              builder: (context, txProvider, child) {
                final busy = _isSubmitting || txProvider.isLoading;
                final isScheduled =
                    TransactionDatePolicy.isStrictlyAfterToday(_selectedDate);
                return AppButton(
                  label: TransactionScheduleCopy.primaryButtonLabel(
                    isScheduled: isScheduled,
                  ),
                  loading: busy,
                  onPressed: busy
                      ? null
                      : () async {
                          if (!mounted) return;
                          if (!_validateFormAndShowFeedback()) return;

                          final scheduleFuture =
                              TransactionDatePolicy.isStrictlyAfterToday(
                            _selectedDate,
                          );
                          final confirmar = await showDialog<bool>(
                            context: context,
                            useRootNavigator: true,
                            builder: (ctx) => AlertDialog(
                              title: Text(
                                TransactionScheduleCopy.dialogTitle(
                                  isScheduled: scheduleFuture,
                                ),
                              ),
                              content: Text(
                                TransactionScheduleCopy.dialogMessage(
                                  _selectedDate,
                                  isScheduled: scheduleFuture,
                                ),
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(ctx, false),
                                  child: const Text('Cancelar'),
                                ),
                                TextButton(
                                  onPressed: () => Navigator.pop(ctx, true),
                                  child: Text(
                                    TransactionScheduleCopy.dialogConfirmLabel(
                                      isScheduled: scheduleFuture,
                                    ),
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );

                          if (confirmar == true && mounted) {
                            await _submitTransaction();
                          }
                        },
                );
              },
            ),
                ],
              ),
            ),
          ),
          if (_isSubmitting)
            Positioned.fill(
              child: Material(
                color: Colors.black.withValues(alpha: 0.12),
                child: Center(
                  child: Card(
                    elevation: 4,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 28,
                        vertical: 24,
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const SizedBox(
                            width: 36,
                            height: 36,
                            child: CircularProgressIndicator(strokeWidth: 3),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            TransactionScheduleCopy.loadingTitle(
                              isScheduled:
                                  TransactionDatePolicy.isStrictlyAfterToday(
                                _selectedDate,
                              ),
                            ),
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.titleSmall,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            TransactionScheduleCopy.loadingSubtitle(
                              isScheduled:
                                  TransactionDatePolicy.isStrictlyAfterToday(
                                _selectedDate,
                              ),
                            ),
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
