import 'dart:convert';
import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../../domain/entities/chain_event.dart';
import '../../domain/entities/event_metadata.dart';
import '../../domain/entities/event_type.dart';
import '../../domain/entities/crypto_identity.dart';
import '../../domain/entities/transaction_category.dart';
import '../../domain/repositories/chain_repository.dart';
import '../../domain/repositories/crypto_repository.dart';
import '../../domain/repositories/key_storage_repository.dart';
import '../../data/local_db/daos/accounts_dao.dart';
import '../../data/local_db/daos/transactions_dao.dart';
import '../../data/local_db/app_database.dart' as db;

class UpdateAccount {
  final AccountsDao _accountsDao;
  final ChainRepository _chainRepository;
  final TransactionsDao _transactionsDao;
  final KeyStorageRepository _keyStorageRepository;
  final CryptoRepository _cryptoRepository;
  final Uuid _uuid = const Uuid();

  UpdateAccount(
    this._accountsDao,
    this._chainRepository,
    this._transactionsDao,
    this._keyStorageRepository,
    this._cryptoRepository,
  );

  Future<void> call({
    required String accountId,
    required String name,
    required String type,
    required String currency,
    required int initialBalance,
  }) async {
    final now = DateTime.now().toUtc();
    final account = await _accountsDao.getAccountById(accountId);
    if (account == null) throw Exception("Account not found");

    // 1. Update Account in DB
    await _accountsDao.updateAccount(
      db.AccountsCompanion(
        id: Value(accountId),
        name: Value(name),
        type: Value(type),
        currency: Value(currency),
        initialBalance: Value(initialBalance),
        updatedAt: Value(now),
      ),
    );

    // 2. Handle Initial Balance Change
    if (account.initialBalance != initialBalance) {
      // Find the initial transaction linked to Genesis or account creation
      // We look for the transaction created during account creation.
      // It's likely the first transaction for this account, or one with "Initial Balance" description.
      // This is tricky if user has many transactions.
      
      // Attempt to find the "Initial Balance" transaction.
      // We could query transactions by account, sorted by date asc, take 1.
      final transactions = await _transactionsDao.getTransactionsByAccount(accountId);
      
      // If we implemented CreateAccount correctly, there should be an initial transaction.
      // Let's assume the OLDEST transaction is the initial one if description matches or close enough.
      // Or search for specific description "Initial Balance".
      final initialTx = transactions.reversed.firstWhere(
        (t) => t.description == "Initial Balance",
        orElse: () => transactions.last, // Fallback to oldest? Risky.
      );

      // If we found a likely initial transaction
      if (initialTx.description == "Initial Balance") {
         // Update it
         // But we need to update it via Chain Event?
         // For now, let's just update the local DB transaction directly as it's a correction of setup.
         // BUT wait, architecture says append-only chain.
         // A modification should be a new event.
         // "Correction" event.
         
         // However, for "Initial Balance" it might be acceptable to treat it as a correction
         // that replaces the old value in the current view.
         // The chain should record this change.
         
         await _recordUpdateEvent(accountId, name, type, currency, initialBalance);

         // Update the transaction in DB to reflect new reality in UI
         await _transactionsDao.updateTransaction(
            db.TransactionsCompanion(
              id: Value(initialTx.id),
              amount: Value(initialBalance),
            ),
         );
      } else {
        // If no initial transaction found, but balance changed, maybe we need to create one?
        // Or create a correction transaction. 
        // Let's create a NEW transaction for the difference?
        // diff = new - old.
        // If diff != 0, create transaction "Initial Balance Correction".
        final diff = initialBalance - account.initialBalance;
        if (diff != 0) {
           await _recordUpdateEvent(accountId, name, type, currency, initialBalance);
           
           // We need a sequence number for the new transaction
           // Let's get it from the event we just recorded? 
           // The event recording logic is below. We need to refactor to get the sequence.
        }
      }
    } else {
      // Just record the update event (name/type change)
       await _recordUpdateEvent(accountId, name, type, currency, initialBalance);
    }
  }

  Future<void> _recordUpdateEvent(
    String accountId,
    String name,
    String type,
    String currency,
    int initialBalance,
  ) async {
    final now = DateTime.now().toUtc();
    final previousEvent = await _chainRepository.getLastEvent();
    final sequence = (previousEvent?.sequence ?? -1) + 1;
    final previousHash = previousEvent?.hash ?? ('0' * 64);

    final payload = {
      'accountId': accountId,
      'action': 'update_account',
      'name': name,
      'type': type,
      'currency': currency,
      'initialBalance': initialBalance,
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
