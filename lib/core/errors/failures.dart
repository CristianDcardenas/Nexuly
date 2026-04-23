/// Errores de dominio de Nexuly.
/// Usarlos en los repositorios en lugar de propagar excepciones de Firebase
/// directamente permite manejar errores en la UI sin acoplarla a Firebase.
sealed class NexulyFailure implements Exception {
  const NexulyFailure(this.message, [this.cause]);
  final String message;
  final Object? cause;

  @override
  String toString() => '$runtimeType: $message';
}

class AuthFailure extends NexulyFailure {
  const AuthFailure(super.message, [super.cause]);
}

class NotFoundFailure extends NexulyFailure {
  const NotFoundFailure(super.message, [super.cause]);
}

class PermissionFailure extends NexulyFailure {
  const PermissionFailure(super.message, [super.cause]);
}

class ValidationFailure extends NexulyFailure {
  const ValidationFailure(super.message, [super.cause]);
}

class NetworkFailure extends NexulyFailure {
  const NetworkFailure(super.message, [super.cause]);
}

class UnknownFailure extends NexulyFailure {
  const UnknownFailure(super.message, [super.cause]);
}
