import 'dart:convert';
import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../../domain/entities/chain_event.dart';
import '../../domain/entities/event_metadata.dart';
import '../../domain/entities/event_type.dart';
import '../../domain/entities/crypto_identity.dart';
import '../../domain/repositories/chain_repository.dart';
import '../../domain/repositories/crypto_repository.dart';
import '../../domain/repositories/key_storage_repository.dart';
import '../../data/local_db/daos/accounts_dao.dart';

class DeleteAccount {
  final AccountsDao _accountsDao;
  final ChainRepository _chainRepository;
  final KeyStorageRepository _keyStorageRepository;
  final CryptoRepository _cryptoRepository;

  DeleteAccount(
    this._accountsDao,
    this._chainRepository,
    this._keyStorageRepository,
    this._cryptoRepository,
  );

  Future<void> call(String accountId) async {
    final account = await _accountsDao.getAccountById(accountId);
    if (account == null) throw Exception("Account not found");

    // 1. Soft Delete in DB
    await _accountsDao.deleteAccount(accountId);

    // 2. Record Event on Chain
    // We treat this as a config change or maybe a specific event type?
    // Using configChange for now as it modifies state configuration.
    
    final now = DateTime.now().toUtc();
    final previousEvent = await _chainRepository.getLastEvent();
    final sequence = (previousEvent?.sequence ?? -1) + 1;
    final previousHash = previousEvent?.hash ?? ('0' * 64);

    final payload = {
      'accountId': accountId,
      'action': 'delete_account',
      'reason': 'user_request',
    };

    // Sign with Keeper key (optional — pairing may not be done yet)
    final keeperKey = await _keyStorageRepository.loadPrivateKey(Role.keeper);

    if (keeperKey != null) {
      final payloadJson = jsonEncode(payload);
      final signableContent = '$sequence|$previousHash|${now.toIso8601String()}|${EventType.configChange.name}|$payloadJson';
      final signature = await _cryptoRepository.sign(utf8.encode(signableContent), keeperKey);

      final eventHash = ChainEvent.computeHash(
        sequence: sequence,
        previousHash: previousHash,
        timestamp: now,
        eventType: EventType.configChange,
        payload: payload,
        keeperSignature: signature,
      );

      final event = ChainEvent(
        sequence: sequence,
        previousHash: previousHash,
        timestamp: now,
        eventType: EventType.configChange,
        payload: payload,
        keeperSignature: signature,
        metadata: EventMetadata(
          source: EventSource.manual,
          trustLevel: 6,
          aiEngine: null,
        ),
        hash: eventHash,
      );

      await _chainRepository.appendEvent(event);
    }
  }
}
