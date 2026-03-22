import 'package:firebase_core/firebase_core.dart';

String firebaseErrorUserMessage(
  Object error, {
  required String fallback,
}) {
  if (error is FirebaseException) {
    final code = error.code.toLowerCase();
    switch (code) {
      case 'permission-denied':
        return 'Acesso negado ao salvar dados. Confira se você está logado e as regras de segurança do Firebase.';
      case 'unauthenticated':
        return 'Sessão inválida ou expirada. Faça login novamente.';
      case 'unavailable':
      case 'deadline-exceeded':
        return 'Serviço temporariamente indisponível. Verifique sua internet e tente de novo.';
      case 'network-request-failed':
        return 'Sem conexão ou falha de rede. Verifique sua internet e tente novamente.';
      case 'cancelled':
        return 'Operação cancelada.';
      case 'quota-exceeded':
        return 'Limite do serviço foi atingido. Tente novamente mais tarde.';
      case 'storage/unauthorized':
      case 'unauthorized':
        return 'Sem permissão para enviar o arquivo. Faça login novamente.';
      case 'storage/canceled':
        return 'Envio do arquivo foi cancelado.';
      case 'storage/retry-limit-exceeded':
        return 'Não foi possível enviar o arquivo após várias tentativas. Tente de novo.';
      case 'storage/invalid-format':
        return 'Formato do arquivo não é aceito.';
      case 'storage/object-not-found':
        return 'Arquivo não encontrado no armazenamento.';
    }
    if (code.contains('storage/') && code.contains('unauthorized')) {
      return 'Sem permissão para enviar o arquivo. Faça login novamente.';
    }
    return fallback;
  }

  final s = error.toString();
  if (s.contains('Usuário não autenticado')) {
    return 'Você precisa estar logado para continuar.';
  }

  return fallback;
}
