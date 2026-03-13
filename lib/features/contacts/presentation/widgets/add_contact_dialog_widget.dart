import 'package:flutter/material.dart';
import '../../../../core/widgets/app_text_field.dart';

class AddContactDialogWidget extends StatefulWidget {
  const AddContactDialogWidget({super.key});

  @override
  State<AddContactDialogWidget> createState() => _AddContactDialogWidgetState();
}

class _AddContactDialogWidgetState extends State<AddContactDialogWidget> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Novo contato'),
      content: AppTextField(
        label: 'Nome do contato',
        controller: _controller,
        hintText: 'Digite o nome',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, _controller.text),
          child: const Text('Salvar'),
        ),
      ],
    );
  }
}
