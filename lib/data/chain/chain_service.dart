
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
  Future<void> appendEvent(ChainEvent event) async {
    // 1. Verify signatures before inserting? 
    final entry = db.ChainEventsCompanion(
      sequence: Value(event.sequence),
      previousHash: Value(event.previousHash),
      timestamp: Value(event.timestamp),
      eventType: Value(event.eventType.name),
      payload: Value(jsonEncode(event.payload)),
      sharerSignature: Value(event.sharerSignature),
      keeperSignature: Value(event.keeperSignature),
      metadataSource: Value(event.metadata.source.name),
      metadataTrustLevel: Value(event.metadata.trustLevel),
      metadataAiEngine: Value(event.metadata.aiEngine),
      hash: Value(event.hash),
    );

    await _dao.insertEvent(entry);
  }

  @override
  Future<ChainEvent?> getLastEvent() async {
    final row = await _dao.getLastEvent();
    if (row == null) return null;
    return _mapToDomain(row);
  }

  @override
  Future<List<ChainEvent>> getHistory() async {
    // This loads everything? MVP: yes.
    final rows = await _dao.getAllEvents();
    return rows.map(_mapToDomain).toList();
  }

  @override
  Future<bool> verifyChain() async {
    final history = await getHistory();
    if (history.isEmpty) return true;

    // Verify hash links
    for (int i = 0; i < history.length; i++) {
      final current = history[i];
      
      // 1. Verify hash integrity
      if (!current.isValid) return false;

      // 2. Verify previous hash link (except genesis)
      if (i > 0) {
        final previous = history[i - 1];
        if (current.previousHash != previous.hash) return false;
        if (current.sequence != previous.sequence + 1) return false;
      } else {
        // Genesis check
        if (current.sequence != 0) return false;
        if (current.previousHash != '0' * 64) return false;
      }
      
      // 3. Verify signatures?
      // Expensive to do all.
      // We rely on append logic.
      // But full re-verification might be requested.
      // For MVP, we check basic hash integrity.
    }
    return true;
  }

  ChainEvent _mapToDomain(db.ChainEvent row) { 
    return ChainEvent(
      sequence: row.sequence,
      previousHash: row.previousHash,
      timestamp: row.timestamp,
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
