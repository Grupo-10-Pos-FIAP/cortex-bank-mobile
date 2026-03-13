import 'package:cortex_bank_mobile/core/widgets/app_button.dart';
import 'package:cortex_bank_mobile/features/contacts/models/contact.dart';
import 'package:cortex_bank_mobile/features/contacts/presentation/widgets/add_contact_dialog_widget.dart';
import 'package:cortex_bank_mobile/features/contacts/presentation/widgets/contact_list_item.dart';
import 'package:cortex_bank_mobile/features/contacts/state/contacts_provider.dart'; // Importe o Provider
import 'package:cortex_bank_mobile/features/transaction/models/transaction.dart';
import 'package:cortex_bank_mobile/features/transaction/state/transactions_provider.dart';
import 'package:cortex_bank_mobile/shared/theme/app_design_tokens.dart';
import 'package:cortex_bank_mobile/core/utils/validators.dart';
import 'package:cortex_bank_mobile/core/widgets/app_card_container.dart';
import 'package:cortex_bank_mobile/core/widgets/app_dropdown_field.dart';
import 'package:cortex_bank_mobile/core/widgets/app_tabs.dart';
import 'package:cortex_bank_mobile/core/widgets/app_text_field.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AppNewTransactionCard extends StatefulWidget {
  const AppNewTransactionCard({super.key});

  @override
  State<AppNewTransactionCard> createState() => _AppNewTransactionCardState();
}

class _AppNewTransactionCardState extends State<AppNewTransactionCard> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _valueController = TextEditingController();

  String? selectedValue;
  int? selectedTitularidade;

  @override
  void initState() {
    super.initState();
    // Carrega os contatos via Provider após o build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ContactsProvider>().loadContacts();
    });
  }

  Future<void> _submitTransaction(BuildContext context) async {
    // 1. Valida o formulário (Dropdown e Valor)
    if (!_formKey.currentState!.validate()) return;

    final contactsProvider = context.read<ContactsProvider>();
    final txProvider = context.read<TransactionsProvider>();

    // 2. Identifica o destino selecionado
    Contact? selectedContact;
    try {
      selectedContact = contactsProvider.contacts.firstWhere(
        (c) => c.isSelected,
      );
    } catch (_) {
      selectedContact = null;
    }

    // 3. Validação de negócio: Se for transferência, exige um destino
    if (selectedValue == 'transferencia' &&
        selectedContact == null &&
        selectedTitularidade == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Selecione um destino para a transferência'),
        ),
      );
      return;
    }

    final transaction = Transaction(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      accountId: '',
      type: selectedValue == 'credito'
          ? TransactionType.credit
          : TransactionType.debit,
      value: double.tryParse(_valueController.text.replaceAll(',', '.')) ?? 0.0,
      date: DateTime.now(),
      to:
          selectedContact?.name ??
          (selectedTitularidade == 0
              ? 'Mesma Titularidade'
              : 'Outra Titularidade'),
      status: 'Completed',
    );

    final success = await txProvider.addTransaction(transaction);

    if (success && mounted) {
      _valueController.clear();
      setState(() {
        selectedValue = null;
        selectedTitularidade = null;
        for (var c in contactsProvider.contacts) {
          c.isSelected = false;
        }
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Transação realizada com sucesso!')),
      );
    }
  }

  @override
  void dispose() {
    _valueController.dispose();
    super.dispose();
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
              value: selectedValue,
              items: const [
                DropdownMenuItem(value: 'credito', child: Text('Crédito')),
                DropdownMenuItem(value: 'debito', child: Text('Débito')),
                DropdownMenuItem(
                  value: 'transferencia',
                  child: Text('Transferência'),
                ),
              ],
              onChanged: (newValue) => setState(() => selectedValue = newValue),
              showRequiredIndicator: true,
              validator: (value) => value == null ? 'Campo obrigatório' : null,
            ),

            AppTabs(
              height: 160,
              titles: const ['Nova conta', 'Contatos', 'Favoritos'],
              children: [
                // Aba 1: Nova Conta
                _buildTitularidadeTab(),

                // Aba 2: Contatos
                _buildListTab(
                  contactsProvider.contacts,
                  contactsProvider,
                  'Nenhum Contato',
                ),

                // Aba 3: Favoritos
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
              label: 'Valor a ser transferido',
              controller: _valueController,
              validator: requiredField,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              hintText: '0,00',
            ),

            const SizedBox(height: 24),
            Consumer<TransactionsProvider>(
              builder: (context, txProvider, child) {
                return AppButton(
                  label: 'Confirmar transferência',
                  onPressed: () => _submitTransaction(context),
                );
              },
            ),
          ],
        ),
      ),
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

  // Widget auxiliar para os itens de titularidade preservando seu estilo
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

  Widget _buildListTab(
    List<Contact> list,
    ContactsProvider provider,
    String textEmpty,
  ) {
    if (provider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

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
                                // 1. Desmarca TODOS os contatos da lista mestre do provider
                                for (var c in provider.contacts) {
                                  c.isSelected = false;
                                }
                                // 2. Marca apenas o atual
                                contact.isSelected = value ?? false;

                                // 3. Se marcou um contato, limpa a seleção de titularidade da Aba 1
                                if (contact.isSelected) {
                                  selectedTitularidade = null;
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
    ); // Removido o ); extra que causava erro
  }
}
