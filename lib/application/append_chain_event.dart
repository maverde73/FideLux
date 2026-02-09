import 'dart:typed_data';

import '../../domain/entities/chain_event.dart';
import '../../domain/entities/event_metadata.dart';
import '../../domain/entities/event_type.dart';
import '../../domain/repositories/chain_repository.dart';

/// Use case: Append a new event to the secure chain.
class AppendChainEvent {
  AppendChainEvent(this.chainRepository);

  final ChainRepository chainRepository;

  Future<ChainEvent> call({
    required EventType type,
    required Map<String, dynamic> payload,
    required Uint8List keeperPrivateKey,
    String? sharerSignatureBase64,
    required EventMetadata metadata,
  }) {
    return chainRepository.appendEvent(
      type: type,
      payload: payload,
      keeperPrivateKey: keeperPrivateKey,
      sharerSignatureBase64: sharerSignatureBase64,
      metadata: metadata,
    );
  }
}
