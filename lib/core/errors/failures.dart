/// Base class for typed application failures.
///
/// Use concrete subclasses to distinguish between failure types
/// without relying on exception strings.
sealed class Failure {
  const Failure({required this.message, this.stackTrace});

  /// Human-readable description of the failure.
  final String message;

  /// Optional stack trace for debugging.
  final StackTrace? stackTrace;

  @override
  String toString() => '$runtimeType: $message';
}

/// A failure originating from the local database layer.
class DatabaseFailure extends Failure {
  const DatabaseFailure({required super.message, super.stackTrace});
}

/// A failure originating from network / email operations.
class NetworkFailure extends Failure {
  const NetworkFailure({required super.message, super.stackTrace});
}

/// A failure originating from cryptographic operations.
class CryptoFailure extends Failure {
  const CryptoFailure({required super.message, super.stackTrace});
}

/// A failure originating from AI/OCR processing.
class AIFailure extends Failure {
  const AIFailure({required super.message, super.stackTrace});
}

/// A generic, unexpected failure.
class UnexpectedFailure extends Failure {
  const UnexpectedFailure({required super.message, super.stackTrace});
}
