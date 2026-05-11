/// Durações usadas em goldens quando o frame estável depende de fase de animação.
///
/// Centralizar aqui evita números mágicos espalhados e facilita alinhar com
/// mudanças de duração em componentes (ex.: [AppButton] loading, [AppSnackBar]).
const Duration kGoldenButtonLoadingSettle = Duration(milliseconds: 100);

/// Frame extra após exibir snackbar de sucesso no golden (transição visível).
const Duration kGoldenSnackbarSuccessSettle = Duration(milliseconds: 350);
