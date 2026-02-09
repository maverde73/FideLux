import 'dart:typed_data';

import '../entities/chain_event.dart';
import '../entities/event_type.dart';
import '../entities/event_metadata.dart';

/// Result of a chain verification process.
class ChainVerificationResult {
  const ChainVerificationResult({
    required this.isValid,
    this.brokenAtSequence,
    this.errorMessage,
  });

  /// True if the chain is valid.
  final bool isValid;

  /// The sequence number where the chain broke (if invalid).
  final int? brokenAtSequence;

  /// Description of the error.
  final String? errorMessage;
}

/// Contract for managing the append-only chain.
abstract class ChainRepository {
  /// Appends a new event to the chain.
  ///
  /// - Fetches the last event to get `previousHash`.
  /// - Increments sequence.
  /// - Computes the new hash using [CryptoService.sha256Hash].
  /// - Verifies integrity before adding.
  Future<ChainEvent> appendEvent({
    required EventType type,
    required Map<String, dynamic> payload,
    required Uint8List keeperPrivateKey,
    String? sharerSignatureBase64,
    required EventMetadata metadata,
  });

  /// Returns the last event in the chain.
  Future<ChainEvent?> getLastEvent();

  /// Returns the full chain ordered by sequence.
  Future<List<ChainEvent>> getFullChain();

  /// Verifies the integrity of the entire chain.
  Future<ChainVerificationResult> verifyChain();
}
