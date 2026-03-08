import 'package:cortex_bank_mobile/shared/theme/app_design_tokens.dart';
import 'package:cortex_bank_mobile/core/utils/validators.dart';
import 'package:cortex_bank_mobile/core/widgets/app_button.dart';
import 'package:cortex_bank_mobile/core/widgets/app_card_container.dart';
import 'package:cortex_bank_mobile/core/widgets/app_dropdown_field.dart';
import 'package:cortex_bank_mobile/core/widgets/app_tabs.dart';
import 'package:cortex_bank_mobile/core/widgets/app_text_field.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as fa;

class AppNewTransactionCard extends StatefulWidget {
  const AppNewTransactionCard({super.key});

  @override
  State<AppNewTransactionCard> createState() => _AppNewTransactionCardState();
}

class Contact {
  final String name;
  bool isFavorite;
  bool isSelected;
  Contact({
    required this.name,
    this.isFavorite = false,
    this.isSelected = false,
  });
}

class _AppNewTransactionCardState extends State<AppNewTransactionCard> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _valueController = TextEditingController();

  String? selectedValue;
  int? selectedTitularidade;

  List<Contact> contacts = [];

  @override
  void initState() {
    super.initState();
    _loadContacts();
  }

  Future<void> _loadContacts() async {
    final user = fa.FirebaseAuth.instance.currentUser;
    if (user == null) return;
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection(user.uid)
          .doc('contacts')
          .collection('list')
          .get();
      final fetched = snapshot.docs.map((d) {
        final data = d.data();
        return Contact(
          name: data['name'] as String? ?? '',
          isFavorite: data['isFavorite'] as bool? ?? false,
          isSelected: false,
        );
      }).toList();
      if (mounted) {
        setState(() {
          contacts = fetched;
        });
      }
    } catch (e) {
      // ignore errors for now or log them
      // SafeLog or similar could be used here
    }
  }

  @override
  void dispose() {
    _valueController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
              onChanged: (newValue) {
                setState(() {
                  selectedValue = newValue;
                });
              },
              showRequiredIndicator: true,
              validator: (value) => value == null ? 'Campo obrigatório' : null,
            ),

            AppTabs(
              height: 120,
              titles: const ['Nova conta', 'Contatos', 'Favoritos'],
              children: [
                Column(
                  children: [
                    ListTile(
                      title: const Text('Mesma titularidade'),
                      trailing: const Icon(Icons.chevron_right),
                      tileColor: selectedTitularidade == 0
                          ? AppDesignTokens.colorPrimary.withOpacity(0.1)
                          : null,
                      selected: selectedTitularidade == 0,
                      selectedTileColor: AppDesignTokens.colorPrimary
                          .withOpacity(0.15),
                      onTap: () {
                        setState(() {
                          selectedTitularidade = 0;
                        });
                      },
                    ),
                    ListTile(
                      title: const Text('Outra titularidade'),
                      trailing: const Icon(Icons.chevron_right),
                      tileColor: selectedTitularidade == 1
                          ? AppDesignTokens.colorPrimary.withOpacity(0.1)
                          : null,
                      selected: selectedTitularidade == 1,
                      selectedTileColor: AppDesignTokens.colorPrimary
                          .withOpacity(0.15),
                      onTap: () {
                        setState(() {
                          selectedTitularidade = 1;
                        });
                      },
                    ),
                  ],
                ),
                SingleChildScrollView(
                  child: Column(
                    children: contacts
                        .map(
                          (contact) => Row(
                            children: [
                              Checkbox(
                                value: contact.isSelected,
                                onChanged: (bool? value) {
                                  setState(
                                    () => contact.isSelected = value ?? false,
                                  );
                                },
                                shape: const CircleBorder(),
                              ),
                              Expanded(child: Text(contact.name)),
                              IconButton(
                                icon: Icon(
                                  contact.isFavorite
                                      ? Icons.favorite
                                      : Icons.favorite_border,
                                  color: contact.isFavorite
                                      ? AppDesignTokens.colorFeedbackFavorite
                                      : null,
                                ),
                                onPressed: () {
                                  setState(() {
                                    contact.isFavorite = !contact.isFavorite;
                                  });
                                },
                              ),
                            ],
                          ),
                        )
                        .toList(),
                  ),
                ),
                SingleChildScrollView(
                  child: Column(
                    children: contacts.where((c) => c.isFavorite).isEmpty
                        ? [const Center(child: Text('Nenhum favorito'))]
                        : contacts
                              .where((c) => c.isFavorite)
                              .map(
                                (contact) => Row(
                                  children: [
                                    Checkbox(
                                      value: contact.isSelected,
                                      onChanged: (bool? value) {
                                        setState(
                                          () => contact.isSelected =
                                              value ?? false,
                                        );
                                      },
                                      shape: const CircleBorder(),
                                    ),
                                    Expanded(child: Text(contact.name)),
                                    IconButton(
                                      icon: Icon(
                                        contact.isFavorite
                                            ? Icons.favorite
                                            : Icons.favorite_border,
                                        color: contact.isFavorite
                                            ? AppDesignTokens
                                                  .colorFeedbackFavorite
                                            : null,
                                      ),
                                      onPressed: () {
                                        setState(() {
                                          contact.isFavorite =
                                              !contact.isFavorite;
                                        });
                                      },
                                    ),
                                  ],
                                ),
                              )
                              .toList(),
                  ),
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
}
