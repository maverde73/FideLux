
import 'dart:convert';
import 'package:drift/drift.dart';

import '../../domain/entities/chain_event.dart';
import '../../domain/entities/event_metadata.dart';
import '../../domain/entities/event_type.dart';
import '../../domain/repositories/chain_repository.dart';
import '../../domain/repositories/crypto_repository.dart';
import '../local_db/app_database.dart' as db;
import '../local_db/daos/chain_events_dao.dart';

class ChainService implements ChainRepository {
  final ChainEventsDao _dao;
  final CryptoRepository _cryptoRepository;

  ChainService(this._dao, this._cryptoRepository);

  @override
  Future<ChainEvent> appendEvent(ChainEvent event) async {
    // Normalize timestamp to second precision to match Drift's DB storage
    final unixSeconds = event.timestamp.millisecondsSinceEpoch ~/ 1000;
    final normalizedTs = DateTime.fromMillisecondsSinceEpoch(
      unixSeconds * 1000,
      isUtc: true,
    );

    // Recompute hash if timestamp precision changed
    final normalizedEvent = normalizedTs == event.timestamp
        ? event
        : ChainEvent(
            sequence: event.sequence,
            previousHash: event.previousHash,
            timestamp: normalizedTs,
            eventType: event.eventType,
            payload: event.payload,
            sharerSignature: event.sharerSignature,
            keeperSignature: event.keeperSignature,
            metadata: event.metadata,
            hash: ChainEvent.computeHash(
              sequence: event.sequence,
              previousHash: event.previousHash,
              timestamp: normalizedTs,
              eventType: event.eventType,
              payload: event.payload,
              keeperSignature: event.keeperSignature,
            ),
          );

    final entry = db.ChainEventsCompanion(
      sequence: Value(normalizedEvent.sequence),
      previousHash: Value(normalizedEvent.previousHash),
      timestamp: Value(normalizedEvent.timestamp),
      eventType: Value(normalizedEvent.eventType.name),
      payload: Value(jsonEncode(normalizedEvent.payload)),
      sharerSignature: Value(normalizedEvent.sharerSignature),
      keeperSignature: Value(normalizedEvent.keeperSignature),
      metadataSource: Value(normalizedEvent.metadata.source.name),
      metadataTrustLevel: Value(normalizedEvent.metadata.trustLevel),
      metadataAiEngine: Value(normalizedEvent.metadata.aiEngine),
      hash: Value(normalizedEvent.hash),
    );

    await _dao.insertEvent(entry);
    return normalizedEvent;
  }

  @override
  Future<ChainEvent?> getLastEvent() async {
    final row = await _dao.getLastEvent();
    if (row == null) return null;
    return _mapToDomain(row);
  }

  @override
  Future<List<ChainEvent>> getFullChain() async {
    final rows = await _dao.getAllEvents();
    return rows.map(_mapToDomain).toList();
  }

  @override
  Future<ChainVerificationResult> verifyChain() async {
    final history = await getFullChain();
    if (history.isEmpty) {
      return const ChainVerificationResult(isValid: true);
    }

    for (int i = 0; i < history.length; i++) {
      final current = history[i];

      if (!current.isValid) {
        return ChainVerificationResult(
          isValid: false,
          brokenAtSequence: current.sequence,
          errorMessage: 'Hash integrity check failed at sequence ${current.sequence}',
        );
      }

      if (i > 0) {
        final previous = history[i - 1];
        if (current.previousHash != previous.hash) {
          return ChainVerificationResult(
            isValid: false,
            brokenAtSequence: current.sequence,
            errorMessage: 'Previous hash mismatch at sequence ${current.sequence}',
          );
        }
        if (current.sequence != previous.sequence + 1) {
          return ChainVerificationResult(
            isValid: false,
            brokenAtSequence: current.sequence,
            errorMessage: 'Sequence gap at ${current.sequence}',
          );
        }
      } else {
        // First event in chain must reference the null hash
        if (current.previousHash != '0' * 64) {
          return ChainVerificationResult(
            isValid: false,
            brokenAtSequence: current.sequence,
            errorMessage: 'Genesis event has wrong previousHash',
          );
        }
      }
    }
    return const ChainVerificationResult(isValid: true);
  }

  ChainEvent _mapToDomain(db.ChainEvent row) {
    return ChainEvent(
      sequence: row.sequence,
      previousHash: row.previousHash,
      timestamp: row.timestamp.toUtc(),
      eventType: EventType.values.byName(row.eventType),
      payload: jsonDecode(row.payload) as Map<String, dynamic>,
      sharerSignature: row.sharerSignature,
      keeperSignature: row.keeperSignature,
      metadata: EventMetadata(
        source: EventSource.values.byName(row.metadataSource),
        trustLevel: row.metadataTrustLevel,
        aiEngine: row.metadataAiEngine,
      ),
      hash: row.hash,
    );
  }
}
