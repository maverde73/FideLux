import 'dart:convert';

import 'package:drift/native.dart';
import 'package:fidelux/data/chain/chain_service.dart';
import 'package:fidelux/data/crypto/crypto_service.dart';
import 'package:fidelux/data/local_db/app_database.dart' hide ChainEvent;
import 'package:fidelux/data/local_db/daos/chain_events_dao.dart';
import 'package:fidelux/domain/entities/chain_event.dart';
import 'package:fidelux/domain/entities/crypto_identity.dart';
import 'package:fidelux/domain/entities/event_metadata.dart';
import 'package:fidelux/domain/entities/event_type.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late CryptoService crypto;
  late ChainService chainService;
  late CryptoIdentity keeperIdentity;
  late AppDatabase database;
  late ChainEventsDao chainDao;

  setUp(() async {
    database = AppDatabase.forTesting(NativeDatabase.memory());
    chainDao = ChainEventsDao(database);
    crypto = CryptoService();
    chainService = ChainService(chainDao);
    keeperIdentity = await crypto.generateIdentity(Role.keeper);
  });

  tearDown(() async {
    await database.close();
  });

  /// Helper to build and append a chain event.
  Future<ChainEvent> appendTestEvent({
    required EventType type,
    required Map<String, dynamic> payload,
    required EventMetadata metadata,
  }) async {
    final previousEvent = await chainService.getLastEvent();
    final sequence = (previousEvent?.sequence ?? -1) + 1;
    final previousHash = previousEvent?.hash ?? ('0' * 64);
    // Normalize to second precision to match Drift's DB storage
    final unixSeconds = DateTime.now().toUtc().millisecondsSinceEpoch ~/ 1000;
    final now = DateTime.fromMillisecondsSinceEpoch(
      unixSeconds * 1000,
      isUtc: true,
    );

    final payloadJson = jsonEncode(payload);
    final signableContent =
        '$sequence|$previousHash|${now.toIso8601String()}|${type.name}|$payloadJson';
    final signature = await crypto.sign(
      utf8.encode(signableContent),
      keeperIdentity.privateKey!,
    );

    final hash = ChainEvent.computeHash(
      sequence: sequence,
      previousHash: previousHash,
      timestamp: now,
      eventType: type,
      payload: payload,
      keeperSignature: signature,
    );

    final event = ChainEvent(
      sequence: sequence,
      previousHash: previousHash,
      timestamp: now,
      eventType: type,
      payload: payload,
      keeperSignature: signature,
      metadata: metadata,
      hash: hash,
    );

    return chainService.appendEvent(event);
  }

  group('ChainService', () {
    test('starts empty', () async {
      final chain = await chainService.getFullChain();
      expect(chain, isEmpty);
      expect(await chainService.getLastEvent(), isNull);
    });

    test('appends first event correctly (Genesis logic)', () async {
      final payload = {'msg': 'Genesis'};
      final metadata = const EventMetadata(source: EventSource.system, trustLevel: 6);

      final event = await appendTestEvent(
        type: EventType.genesis,
        payload: payload,
        metadata: metadata,
      );

      expect(event.sequence, 0);
      expect(event.previousHash, '0' * 64);
      expect(event.eventType, EventType.genesis);
      expect(event.keeperSignature, isNotEmpty);
      expect(event.isValid, isTrue);

      final chain = await chainService.getFullChain();
      expect(chain.length, 1);
    });

    test('links events via previousHash', () async {
      final metadata = const EventMetadata(source: EventSource.manual, trustLevel: 1);

      final event1 = await appendTestEvent(
        type: EventType.genesis,
        payload: {'msg': 'Test'},
        metadata: metadata,
      );

      final event2 = await appendTestEvent(
        type: EventType.transaction,
        payload: {'amount': 100},
        metadata: metadata,
      );

      expect(event2.sequence, 1);
      expect(event2.previousHash, event1.hash);

      // Verify events round-trip correctly through DB
      final chain = await chainService.getFullChain();
      for (final e in chain) {
        final recomputed = ChainEvent.computeHash(
          sequence: e.sequence,
          previousHash: e.previousHash,
          timestamp: e.timestamp,
          eventType: e.eventType,
          payload: e.payload,
          keeperSignature: e.keeperSignature,
        );
        expect(recomputed, e.hash, reason: 'Hash mismatch for sequence ${e.sequence}');
      }

      final verification = await chainService.verifyChain();
      expect(verification.isValid, isTrue, reason: verification.errorMessage ?? 'no error');
    });

    test('detects tampered chain via ChainEvent.isValid', () async {
      // ChainEvent with wrong hash should fail isValid check
      final timestamp = DateTime.now().toUtc();
      final payload = {'a': 1};

      final event = ChainEvent(
        sequence: 0,
        previousHash: '0' * 64,
        timestamp: timestamp,
        eventType: EventType.genesis,
        payload: payload,
        keeperSignature: 'SIG',
        metadata: const EventMetadata(source: EventSource.manual, trustLevel: 1),
        hash: 'BAD_HASH',
      );

      expect(event.isValid, isFalse);
      expect(event.hash, 'BAD_HASH');
    });
  });

  group('ChainEvent Integrity', () {
    test('isValid returns false if content mismatch hash', () {
      final timestamp = DateTime.now().toUtc();
      final payload = {'a': 1};

      final event = ChainEvent(
        sequence: 0,
        previousHash: '0' * 64,
        timestamp: timestamp,
        eventType: EventType.genesis,
        payload: payload,
        keeperSignature: 'SIG',
        metadata: const EventMetadata(source: EventSource.manual, trustLevel: 1),
        hash: 'BAD_HASH',
      );

      expect(event.isValid, isFalse);
      expect(event.hash, 'BAD_HASH');
    });
  });
}
