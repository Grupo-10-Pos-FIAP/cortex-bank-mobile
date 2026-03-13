import 'package:cortex_bank_mobile/core/widgets/app_button.dart';
import 'package:cortex_bank_mobile/features/contacts/models/contact.dart';
import 'package:cortex_bank_mobile/features/contacts/presentation/widgets/add_contact_dialog_widget.dart';
import 'package:cortex_bank_mobile/features/contacts/presentation/widgets/contact_list_item.dart';
import 'package:cortex_bank_mobile/features/contacts/state/contacts_provider.dart'; // Importe o Provider
import 'package:cortex_bank_mobile/shared/theme/app_design_tokens.dart';
import 'package:cortex_bank_mobile/core/utils/validators.dart';
import 'package:cortex_bank_mobile/core/widgets/app_card_container.dart';
import 'package:cortex_bank_mobile/core/widgets/app_dropdown_field.dart';
import 'package:cortex_bank_mobile/core/widgets/app_tabs.dart';
import 'package:cortex_bank_mobile/core/widgets/app_text_field.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // Adicionado

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

  @override
  void dispose() {
    _valueController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Escuta o provider de contatos
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

            const SizedBox(height: 32),

            AppButton(
              label: 'Concluir transação',
              onPressed: () {
                if (_formKey.currentState?.validate() ?? false) {
                  // formulário válido; prossiga com a ação (ex.: enviar à provider)
                }
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


  // Aba 2 e 3: Lista de Contatos/Favoritos
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
      // Botão sempre visível no topo da aba
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
      
      // Conteúdo condicional: Lista ou Mensagem de Vazio
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
                  children: list.map((contact) => ContactListItem(
                    contact: contact,
                    onToggleFavorite: () => provider.toggleFavorite(contact),
                    onSelectChanged: (value) {
                      setState(() => contact.isSelected = value ?? false);
                    },
                  )).toList(),
                ),
              ),
      ),
    ],
  );
}
}
