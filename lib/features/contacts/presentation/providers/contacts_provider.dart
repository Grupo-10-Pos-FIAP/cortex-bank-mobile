import 'package:flutter/material.dart';
import 'package:cortex_bank_mobile/core/cache/cache_serializers.dart';
import 'package:cortex_bank_mobile/core/cache/sensitive_cache_manager.dart';
import 'package:cortex_bank_mobile/features/contacts/domain/entities/contact.dart';
import 'package:cortex_bank_mobile/features/contacts/domain/repositories/i_contacts_repository.dart';

class ContactsProvider extends ChangeNotifier {
  static const _contactsCacheKey = 'contacts_provider.contacts';
  static const _contactsCacheTtl = Duration(minutes: 5);

  final IContactsRepository _repository;

  ContactsProvider(this._repository);

  List<Contact> _contacts = [];
  bool _isLoading = false;
  String? _errorMessage;
  String? _selectedContactId;

  // Getters
  List<Contact> get contacts => _contacts;
  List<Contact> get favoriteContacts =>
      _contacts.where((c) => c.isFavorite).toList();
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  String? get selectedContactId => _selectedContactId;

  /// Contato marcado na lista (checkbox); seleção fica no provider, não no modelo.
  Contact? get selectedContact {
    final id = _selectedContactId;
    if (id == null || id.isEmpty) return null;
    for (final c in _contacts) {
      if (c.id == id) return c;
    }
    return null;
  }

  void setSelectedContactId(String? id) {
    if (_selectedContactId == id) return;
    _selectedContactId = id;
    notifyListeners();
  }

  void _dropSelectionIfContactMissing() {
    final id = _selectedContactId;
    if (id == null) return;
    if (!_contacts.any((c) => c.id == id)) {
      _selectedContactId = null;
    }
  }

  String? _boundUserId;

  /// Alinha o cache em memória ao usuário autenticado (troca de conta / logout).
  void syncAuthUserId(String? userId) {
    if (_boundUserId == userId) return;
    _boundUserId = userId;
    _contacts = [];
    _selectedContactId = null;
    _errorMessage = null;
    _isLoading = false;
    SensitiveCacheManager.remove(_contactsCacheKey);
    notifyListeners();
  }

  // Carregar contatos
  Future<void> loadContacts({bool forceRefresh = false}) async {
    if (_isLoading) return;
    if (!forceRefresh) {
      final cachedContacts = SensitiveCacheManager.getJson<List<Contact>>(
        _contactsCacheKey,
        (json) => CacheSerializers.contactsFromJson(json! as List<dynamic>),
      );
      if (cachedContacts != null) {
        if (_contacts.isEmpty) {
          _contacts = List<Contact>.from(cachedContacts);
          _dropSelectionIfContactMissing();
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
      _contacts = List<Contact>.from(success);
      _dropSelectionIfContactMissing();
      SensitiveCacheManager.setJson(
        _contactsCacheKey,
        CacheSerializers.contactsToJson(success),
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
      SensitiveCacheManager.setJson(
        _contactsCacheKey,
        CacheSerializers.contactsToJson(_contacts),
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

    SensitiveCacheManager.setJson(
      _contactsCacheKey,
      CacheSerializers.contactsToJson(_contacts),
      ttl: _contactsCacheTtl,
    );
  }

  // Deletar contato
  Future<void> deleteContact(String id) async {
    final result = await _repository.delete(id);

    result.fold(
      (_) {
        _contacts.removeWhere((c) => c.id == id);
        if (_selectedContactId == id) {
          _selectedContactId = null;
        }
        SensitiveCacheManager.setJson(
          _contactsCacheKey,
          CacheSerializers.contactsToJson(_contacts),
          ttl: _contactsCacheTtl,
        );
        notifyListeners();
      },
      (failure) {
        _errorMessage = failure.message;
        notifyListeners();
      },
    );
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
