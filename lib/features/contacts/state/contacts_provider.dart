import 'package:flutter/material.dart';
import 'package:cortex_bank_mobile/core/cache/cache_manager.dart';
import '../data/repositories/i_contacts_repository.dart';
import '../models/contact.dart';

class ContactsProvider extends ChangeNotifier {
  static const _contactsCacheKey = 'contacts_provider.contacts';
  static const _contactsCacheTtl = Duration(minutes: 5);

  final IContactsRepository _repository;

  ContactsProvider(this._repository);

  List<Contact> _contacts = [];
  bool _isLoading = false;
  String? _errorMessage;

  // Getters
  List<Contact> get contacts => _contacts;
  List<Contact> get favoriteContacts =>
      _contacts.where((c) => c.isFavorite).toList();
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Carregar contatos
  Future<void> loadContacts({bool forceRefresh = false}) async {
    if (_isLoading) return;
    if (!forceRefresh) {
      final cachedContacts = CacheManager.get<List<Contact>>(_contactsCacheKey);
      if (cachedContacts != null) {
        if (_contacts.isEmpty) {
          _contacts = List<Contact>.from(cachedContacts);
          notifyListeners();
        }
        return;
      }

      if (_contacts.isNotEmpty) return;
    }

    _setLoading(true);
    _errorMessage = null;

    final result = await _repository.getAll();

    result.fold((success) {
      _contacts = success;
      CacheManager.set(
        _contactsCacheKey,
        List<Contact>.from(success),
        ttl: _contactsCacheTtl,
      );
    }, (failure) => _errorMessage = failure.message);

    _setLoading(false);
  }

  // Adicionar contato
  Future<void> addContact(String name) async {
    _setLoading(true);
    final result = await _repository.add(name);

    result.fold((id) {
      _contacts.add(Contact(id: id, name: name));
      CacheManager.set(
        _contactsCacheKey,
        List<Contact>.from(_contacts),
        ttl: _contactsCacheTtl,
      );
      notifyListeners();
    }, (failure) => _errorMessage = failure.message);
    _setLoading(false);
  }

  // Alternar favorito
  Future<void> toggleFavorite(Contact contact) async {
    final oldStatus = contact.isFavorite;
    final newStatus = !oldStatus;

    // Update otimista na UI
    contact.isFavorite = newStatus;
    notifyListeners();

    final result = await _repository.updateFavorite(contact.id, newStatus);

    result.fold(
      (_) => null, // Sucesso, mantém o estado
      (failure) {
        // Reverte em caso de erro
        contact.isFavorite = oldStatus;
        _errorMessage = failure.message;
        notifyListeners();
      },
    );

    CacheManager.set(
      _contactsCacheKey,
      List<Contact>.from(_contacts),
      ttl: _contactsCacheTtl,
    );
  }

  // Deletar contato
  Future<void> deleteContact(String id) async {
    final result = await _repository.delete(id);

    result.fold((_) {
      _contacts.removeWhere((c) => c.id == id);
      CacheManager.set(
        _contactsCacheKey,
        List<Contact>.from(_contacts),
        ttl: _contactsCacheTtl,
      );
      notifyListeners();
    }, (failure) => _errorMessage = failure.message);
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
