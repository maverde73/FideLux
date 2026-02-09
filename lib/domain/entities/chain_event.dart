import 'dart:convert';
import 'package:crypto/crypto.dart';

import 'event_type.dart';
import 'event_metadata.dart';

/// Represents a single immutable event in the append-only chain.
class ChainEvent {
  const ChainEvent({
    required this.sequence,
    required this.previousHash,
    required this.timestamp,
    required this.eventType,
    required this.payload,
    this.sharerSignature,
    required this.keeperSignature,
    required this.metadata,
    required this.hash,
  });

  /// The sequence number (0 for Genesis, incrementing).
  final int sequence;

  /// The SHA-256 hash of the previous event (64 hex chars).
  final String previousHash;

  /// Timestamp of the event (UTC).
  final DateTime timestamp;

  /// The type of event.
  final EventType eventType;

  /// The data associated with the event.
  final Map<String, dynamic> payload;

  /// Ed25519 signature from the Sharer (Base64), if applicable.
  final String? sharerSignature;

  /// Ed25519 signature from the Keeper (Base64). Always present.
  final String keeperSignature;

  /// Metadata (source, trust, AI).
  final EventMetadata metadata;

  /// The SHA-256 hash of this event (64 hex chars).
  final String hash;

  /// Computes the SHA-256 hash of the event's components.
  ///
  /// The hash is deterministic and includes:
  /// - sequence
  /// - previousHash
  /// - timestamp (ISO 8601 UTC)
  /// - eventType.name
  /// - jsonEncode(payload)
  /// - keeperSignature
  ///
  /// The `sharerSignature` is largely redundant if `keeperSignature` signs the payload,
  /// but including `keeperSignature` covers the entire integrity authorized by the Keeper.
  /// Note: The directive says: "$sequence|$previousHash|${timestamp.toIso8601String()}|${eventType.name}|${jsonEncode(payload)}|$keeperSignature"
  static String computeHash({
    required int sequence,
    required String previousHash,
    required DateTime timestamp,
    required EventType eventType,
    required Map<String, dynamic> payload,
    required String keeperSignature,
  }) {
    // Ensure payload JSON is deterministic (e.g., sort keys? Dart's jsonEncode isn't guaranteed sorted).
    // For MVP, we assume the payload map insertion order is preserved or simple enough.
    // In production, use a canonical JSON serializer.
    final payloadJson = jsonEncode(payload);

    final content =
        '$sequence|$previousHash|${timestamp.toIso8601String()}|${eventType.name}|$payloadJson|$keeperSignature';
    
    final bytes = utf8.encode(content);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  /// Verifies if the stored hash matches the computed hash.
  bool get isValid {
    final computed = computeHash(
      sequence: sequence,
      previousHash: previousHash,
      timestamp: timestamp,
      eventType: eventType,
      payload: payload,
      keeperSignature: keeperSignature,
    );
    return computed == hash;
  }
}
