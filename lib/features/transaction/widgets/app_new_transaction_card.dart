import 'dart:async';

import 'package:cortex_bank_mobile/core/utils/currency_formatter.dart';
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
  Timer? _valueValidationTimer;

  String? selectedValueType;
  String? selectedValueCategory;
  int? selectedTitularidade;
  final List<({List<int> bytes, String name})> _attachments = [];
  bool _debugCreatePending = false;

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
      _valueFieldKey.currentState?.validate();
      setState(() {});
    });
  }

  @override
  void dispose() {
    _valueValidationTimer?.cancel();
    _valueController.removeListener(_validateValueAfterTyping);
    _valueController.dispose();
    super.dispose();
  }

  Future<void> _submitTransaction() async {
    if (!_formKey.currentState!.validate()) return;

    final contactsProvider = context.read<ContactsProvider>();
    final txProvider = context.read<TransactionsProvider>();

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

    if (selectedValueType == 'ted' &&
        selectedContact == null &&
        selectedTitularidade == null) {
      AppSnackBar.show(context, 'Selecione um destino para a transferência');
      return;
    }

    final titularName =
        context.read<AuthProvider>().user?.username ?? '';

    final transaction = Transaction(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      accountId: '',
      type: TransactionTypeExtension.fromString(selectedValueType!),
      category: TransactionCategoryExtension.fromString(selectedValueCategory!),
      value: valueToSave,
      date: DateTime.now(),
      from: titularName.isNotEmpty ? titularName : null,
      to:
          selectedContact?.name ??
          (selectedTitularidade == 0
              ? 'Mesma Titularidade'
              : 'Outra Titularidade'),
      status: kDebugMode && _debugCreatePending
          ? TransactionStatus.pending
          : TransactionStatus.completed,
    );

    final created = await txProvider.addTransaction(transaction);

    if (created != null && mounted) {
      _valueController.clear();
      setState(() {
        selectedValueType = null;
        selectedValueCategory = null;
        selectedTitularidade = null;
        _attachments.clear();
        for (var c in contactsProvider.contacts) {
          c.isSelected = false;
        }
      });

      AppSnackBar.success(context, 'Transação realizada com sucesso!');
    } else if (mounted) {
      AppSnackBar.error(
        context,
        txProvider.errorMessage ?? 'Erro desconhecido',
      );
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
      onTap: () => setState(() => selectedTitularidade = index),
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
              if (name != null && name.isNotEmpty)
                await provider.addContact(name);
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
                                if (contact.isSelected)
                                  selectedTitularidade = null;
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
      title: 'Nova transferência',
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppDropdownField<String>(
              label: 'Selecione o tipo de transação',
              hintText: 'Selecione o tipo de transação',
              value: selectedValueType,
              items: const [
                DropdownMenuItem(value: 'credito', child: Text('Crédito')),
                DropdownMenuItem(value: 'debito', child: Text('Débito')),
                DropdownMenuItem(value: 'ted', child: Text('TED/DOC')),
              ],
              onChanged: (newValue) =>
                  setState(() => selectedValueType = newValue),
            ),
            AppTabs(
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
            AppDropdownField<String>(
              label: 'Selecione a categoria',
              hintText: 'Selecione a categoria',
              value: selectedValueCategory,
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
                          !mounted) return;
                      final file = result.files.single;
                      final bytes = file.bytes;
                      final name = file.name;
                      if (bytes != null &&
                          name.isNotEmpty &&
                          _attachments.length <
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
                'Anexar arquivo',
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
                return AppButton(
                  label: 'Confirmar transferência',
                  loading: txProvider.isLoading,
                  onPressed: () async {
                    final confirmar = await showDialog<bool>(
                      context: context,
                      useRootNavigator: true,
                      builder: (ctx) => AlertDialog(
                        title: const Text('Confirmar Transação'),
                        content: const Text(
                          'Deseja realmente realizar esta transferência?',
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(ctx, false),
                            child: const Text('Cancelar'),
                          ),
                          TextButton(
                            onPressed: () => Navigator.pop(ctx, true),
                            child: const Text(
                              'Confirmar',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                    );

                    // Verificamos se o widget ainda está montado antes de realizar a ação
                    if (confirmar == true && mounted) {
                      // Chamamos a função sem passar o context por parâmetro,
                      // usando o context interno do State dentro do _submitTransaction
                      _submitTransaction();
                    }
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
