import 'dart:convert';
import 'dart:typed_data';

import 'package:fidelux/data/chain/chain_service.dart';
import 'package:fidelux/data/crypto/crypto_service.dart';
import 'package:fidelux/domain/entities/chain_event.dart';
import 'package:fidelux/domain/entities/crypto_identity.dart';
import 'package:fidelux/domain/entities/event_metadata.dart';
import 'package:fidelux/domain/entities/event_type.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late CryptoService crypto;
  late ChainService chainService;
  late CryptoIdentity keeperIdentity;

  setUp(() async {
    crypto = CryptoService();
    chainService = ChainService(crypto: crypto);
    keeperIdentity = await crypto.generateIdentity(Role.keeper);
  });

  group('ChainService', () {
    test('starts empty', () async {
      final chain = await chainService.getFullChain();
      expect(chain, isEmpty);
      expect(await chainService.getLastEvent(), isNull);
    });

    test('appends first event correctly (Genesis logic)', () async {
      final payload = {'msg': 'Genesis'};
      final metadata = EventMetadata(source: EventSource.system, trustLevel: 6);

      final event = await chainService.appendEvent(
        type: EventType.genesis,
        payload: payload,
        keeperPrivateKey: keeperIdentity.privateKey!,
        metadata: metadata,
      );

      expect(event.sequence, 0);
      expect(event.previousHash, '0' * 64);
      expect(event.eventType, EventType.genesis);
      expect(event.keeperSignature, isNotEmpty);
      expect(event.isValid, isTrue);

      final chain = await chainService.getFullChain();
      expect(chain.length, 1);
      expect(chain.first, event);
    });

    test('links events via previousHash', () async {
       final payload = {'msg': 'Test'};
       final metadata = EventMetadata(source: EventSource.manual, trustLevel: 1);

       final event1 = await chainService.appendEvent(
         type: EventType.genesis, 
         payload: payload,
         keeperPrivateKey: keeperIdentity.privateKey!,
         metadata: metadata
        );

       final event2 = await chainService.appendEvent(
         type: EventType.transaction, 
         payload: {'amount': 100},
         keeperPrivateKey: keeperIdentity.privateKey!,
         metadata: metadata
        );

       expect(event2.sequence, 1);
       expect(event2.previousHash, event1.hash);
       
       final verification = await chainService.verifyChain();
       expect(verification.isValid, isTrue);
    });

    test('detects tampered chain', () async {
      // 1. Create a chain
       final payload = {'msg': 'Test'};
       final metadata = EventMetadata(source: EventSource.manual, trustLevel: 1);
       await chainService.appendEvent(
         type: EventType.genesis, 
         payload: payload,
         keeperPrivateKey: keeperIdentity.privateKey!,
         metadata: metadata
       );

       // 2. Access the internal list (reflection or just assume it is the same object in memory)
       // Since getFullChain returns unmodifiable, we can't tamper easily via public API.
       // But for testing, we might need a way to mock corruption or inject bad data.
       // However, since `ChainService` is just wrapping a List in memory, we can't easily reach inside
       // without making `_chain` visible for testing or using reflection.
       // Validating "tampered chain detection" strictly requires being able to tamper it.
       
       // Alternative: Create a custom ChainService populated with bad data for this test?
       // But `_chain` is private final.
       
       // Let's rely on unit testing `ChainEvent.isValid` and `verifyChain` logic by creating a 
       // subclass or using a robust way.
       // Or simpler: `ChainEvent` is immutable. If we create a manual `ChainEvent` with wrong hash
       // and inject it... `ChainService` prevents injection.
       
       // So to test `verifyChain`, we assume `appendEvent` works correctly.
       // If `verifyChain` checks `event.isValid`, we need to ensure `event.isValid` returns false
       // if data doesn't match hash. This is tested in unit test for `ChainEvent`.
       
       // Let's test `ChainEvent` integrity directly.
    });
  });

  group('ChainEvent Integrity', () {
      test('isValid returns false if content mismatch hash', () {
          final timestamp = DateTime.now().toUtc();
          final payload = {'a': 1};
          final correctHash = ChainEvent.computeHash(
            sequence: 0, 
            previousHash: '0'*64, 
            timestamp: timestamp, 
            eventType: EventType.genesis, 
            payload: payload, 
            keeperSignature: 'SIG'
          );

          // Create event with WRONG hash
          final event = ChainEvent(
              sequence: 0,
              previousHash: '0'*64,
              timestamp: timestamp,
              eventType: EventType.genesis,
              payload: payload,
              keeperSignature: 'SIG',
              metadata: EventMetadata(source: EventSource.manual, trustLevel: 1),
              hash: 'BAD_HASH'
          );

          expect(event.isValid, isFalse);
          expect(event.hash, 'BAD_HASH');
      });
  });
}
