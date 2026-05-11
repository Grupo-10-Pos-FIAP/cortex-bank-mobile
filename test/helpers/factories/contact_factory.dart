import 'package:cortex_bank_mobile/features/contacts/models/contact.dart';

Contact buildContact({
  String id = 'c1',
  String name = 'Alice',
  bool isFavorite = false,
}) {
  return Contact(id: id, name: name, isFavorite: isFavorite);
}
