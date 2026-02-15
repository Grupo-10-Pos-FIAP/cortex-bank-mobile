/// Represents a failure with an optional error code.
class Failure {
  const Failure({
    required this.message,
    this.code,
  });

  final String message;
  final String? code;
}
