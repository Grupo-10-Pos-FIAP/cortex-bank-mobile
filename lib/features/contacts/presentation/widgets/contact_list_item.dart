import 'package:cortex_bank_mobile/shared/theme/app_design_tokens.dart';
import 'package:flutter/material.dart';
import '../../models/contact.dart';

class ContactListItem extends StatelessWidget {
  final Contact contact;

  final bool selected;
  final VoidCallback onToggleFavorite;
  final ValueChanged<bool?> onSelectChanged;

  const ContactListItem({
    super.key,
    required this.contact,
    required this.selected,
    required this.onToggleFavorite,
    required this.onSelectChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Checkbox(
          value: selected,
          onChanged: onSelectChanged,
          shape: const CircleBorder(),
        ),
        Expanded(
          child: Text(contact.name, style: const TextStyle(fontSize: 16)),
        ),
        IconButton(
          key: ValueKey<String>('contact-favorite-${contact.id}'),
          icon: Icon(
            contact.isFavorite ? Icons.favorite : Icons.favorite_border,
            color: contact.isFavorite
                ? AppDesignTokens.colorFeedbackFavorite
                : null,
          ),
          onPressed: onToggleFavorite,
        ),
      ],
    );
  }
}
