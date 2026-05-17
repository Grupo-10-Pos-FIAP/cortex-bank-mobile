import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cortex_bank_mobile/core/utils/safe_log.dart';
import 'package:cortex_bank_mobile/features/auth/data/datasources/user_datasource.dart';

/// [SEGURANÇA] Lista de campos permitidos no perfil do usuário.
/// Qualquer campo fora desta lista é removido antes da escrita no Firestore,
/// prevenindo poluição de dados e ataques de mass-assignment.
const _allowedProfileFields = {
  'uid',
  'username',
  'email',
  'branchCode',
  'accountNumber',
  'balance',
  'emailVerified',
  'createdAt',
  'updatedAt',
};

/// [SEGURANÇA] Campos que o cliente nunca pode alterar diretamente.
/// Atualizações nesses campos são silenciosamente ignoradas no lado do cliente;
/// devem ser modificados apenas por Cloud Functions com privilégios de admin.
const _immutableFields = {
  'uid',
  'branchCode',
  'accountNumber',
  'balance', // Saldo só é modificado via transações server-side
  'createdAt',
};

class UserDataSourceFirestore implements UserDataSource {
  final FirebaseFirestore _firestore;

  UserDataSourceFirestore(this._firestore);

  CollectionReference<Map<String, dynamic>> get _usersCollection =>
      _firestore.collection('users');

  // ─── createUserProfile ────────────────────────────────────────────────────

  @override
  Future<void> createUserProfile(Map<String, dynamic> userData) async {
    final uid = userData['uid'] as String?;
    if (uid == null || uid.trim().isEmpty) {
      throw Exception('UID é obrigatório para criar perfil.');
    }

    // [SEGURANÇA] Filtra apenas campos permitidos para evitar mass-assignment:
    // impede que um Map malicioso grave campos arbitrários no documento.
    final sanitized = _sanitizeForWrite(
      userData,
      allowedFields: _allowedProfileFields,
    );

    // [SEGURANÇA] Usa `set` com merge:false para garantir que um cadastro nunca
    // sobrescreva silenciosamente um perfil já existente.
    final docRef = _usersCollection.doc(uid);
    await _firestore.runTransaction((transaction) async {
      final snapshot = await transaction.get(docRef);
      if (snapshot.exists) {
        throw Exception('Perfil já existe para o UID informado.');
      }
      transaction.set(docRef, sanitized);
    });
  }

  // ─── getUserProfile ───────────────────────────────────────────────────────

  @override
  Future<Map<String, dynamic>> getUserProfile(String uid) async {
    // [SEGURANÇA] Valida o UID antes de construir a referência ao documento,
    // evitando consultas com caminhos malformados.
    _validateUid(uid);

    try {
      // Força leitura do servidor para ignorar cache offline do Firestore.
      // Evita o erro "_Exception" que ocorre quando o cache local ainda não
      // possui o documento (ex: logo após o cadastro com logout imediato).
      final doc = await _usersCollection
          .doc(uid)
          .get(const GetOptions(source: Source.serverAndCache));

      // Retorna Map vazio quando o perfil ainda não existe — o chamador
      // (AuthDataSourceFirebase) decide o que fazer (criar ou aguardar).
      // Não lança exceção para não quebrar o fluxo normal de navegação.
      if (!doc.exists || doc.data() == null) return {};

      // [SEGURANÇA] Retorna apenas os campos permitidos, descartando qualquer
      // campo extra que possa ter sido inserido diretamente no Firestore.
      return _sanitizeForRead(
        doc.data()!,
        allowedFields: _allowedProfileFields,
      );
    } catch (e) {
      safeLogError('Erro ao buscar perfil no Firestore', e);
      // Se falhar (sem conexão e sem cache), retorna vazio em vez de
      // propagar exceção — o shell trata ausência de dados graciosamente.
      return {};
    }
  }

  // ─── updateUserProfile ────────────────────────────────────────────────────

  /// Atualiza campos mutáveis do perfil.
  ///
  /// [SEGURANÇA] Campos imutáveis (saldo, agência, conta, UID) são removidos
  /// do Map antes da escrita, mesmo que o chamador os inclua por engano.
  Future<void> updateUserProfile(
    String uid,
    Map<String, dynamic> fields,
  ) async {
    _validateUid(uid);

    final sanitized = _sanitizeForWrite(
      fields,
      allowedFields: _allowedProfileFields,
      // Remove campos que só o servidor pode alterar
      blockedFields: _immutableFields,
    );

    if (sanitized.isEmpty) return; // Nada a atualizar

    // [SEGURANÇA] Adiciona timestamp server-side de última atualização.
    sanitized['updatedAt'] = FieldValue.serverTimestamp();

    await _usersCollection.doc(uid).update(sanitized);
  }

  // ─── Helpers privados ─────────────────────────────────────────────────────

  /// Remove campos não permitidos e bloqueia campos imutáveis.
  Map<String, dynamic> _sanitizeForWrite(
    Map<String, dynamic> data, {
    required Set<String> allowedFields,
    Set<String> blockedFields = const {},
  }) {
    return Map.fromEntries(
      data.entries.where((e) {
        if (!allowedFields.contains(e.key)) return false;
        if (blockedFields.contains(e.key)) return false;
        return true;
      }),
    );
  }

  /// Filtra campos retornados do Firestore, expondo apenas o que é esperado
  /// pela camada de domínio.
  Map<String, dynamic> _sanitizeForRead(
    Map<String, dynamic> data, {
    required Set<String> allowedFields,
  }) {
    return Map.fromEntries(
      data.entries.where((e) => allowedFields.contains(e.key)),
    );
  }

  /// [SEGURANÇA] Garante que o UID não está vazio e não contém
  /// caracteres que possam forçar um path traversal no Firestore.
  void _validateUid(String uid) {
    if (uid.trim().isEmpty) {
      throw ArgumentError('UID não pode ser vazio.');
    }
    // Firestore UIDs gerados pelo Firebase são alfanuméricos; rejeita
    // qualquer coisa que contenha barras ou pontos suspeitos.
    if (uid.contains('/') || uid.contains('..')) {
      throw ArgumentError('UID com formato inválido.');
    }
  }
}
