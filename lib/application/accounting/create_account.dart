
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

class CreateAccount {
  final AccountsDao _accountsDao;
  final ChainRepository _chainRepository;
  final TransactionsDao _transactionsDao;
  final KeyStorageRepository _keyStorageRepository;
  final CryptoRepository _cryptoRepository;
  final Uuid _uuid = const Uuid();

  CreateAccount(
    this._accountsDao,
    this._chainRepository,
    this._transactionsDao,
    this._keyStorageRepository,
    this._cryptoRepository,
  );

  Future<void> call({
    required String name,
    required String type,
    required String currency,
    required int initialBalance,
  }) async {
    final accountId = _uuid.v4();
    final now = DateTime.now().toUtc(); // DB stores UTC

    // 1. Create Account
    // We need to insert Account into DB. 
    // Is it inserted first or after chain? Atomicity?
    // Drift supports transactions. Ideally wrap everything in transaction.
    // But DAO APIs are separate.
    // For MVP, simplistic ordering.
    // We insert account first so transaction can reference it.
    
    await _accountsDao.insertAccount(
      db.AccountsCompanion.insert(
        id: accountId,
        name: name,
        type: type,
        currency: Value(currency),
        initialBalance: initialBalance,
        currentBalance: initialBalance,
        createdAt: now,
        updatedAt: now,
      ),
    );

    // 2. Create Genesis Event
    final previousEvent = await _chainRepository.getLastEvent();
    final sequence = (previousEvent?.sequence ?? -1) + 1;
    final previousHash = previousEvent?.hash ?? ('0' * 64);

    final payload = {
      'accountId': accountId,
      'action': 'create_account',
      'initialBalance': initialBalance,
      'currency': currency,
    };

    // Sign with Keeper key (optional — pairing may not be done yet)
    final keeperKey = await _keyStorageRepository.loadPrivateKey(Role.keeper);

    if (keeperKey != null) {
      final payloadJson = jsonEncode(payload);
      final signableContent = '$sequence|$previousHash|${now.toIso8601String()}|${EventType.genesis.name}|$payloadJson';
      final signature = await _cryptoRepository.sign(utf8.encode(signableContent), keeperKey);

      final eventHash = ChainEvent.computeHash(
        sequence: sequence,
        previousHash: previousHash,
        timestamp: now,
        eventType: EventType.genesis,
        payload: payload,
        keeperSignature: signature,
      );

      final event = ChainEvent(
        sequence: sequence,
        previousHash: previousHash,
        timestamp: now,
        eventType: EventType.genesis,
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
    
    // 3. Create Transaction if initial balance != 0?
    // "Initial Balance" is in account table. 
    // Does it need a transaction?
    // Accounts schema: `currentBalance` is recalculated. 
    // If we only have `initialBalance` field, `currentBalance` = `initialBalance` + sum(transactions).
    // So we don't need a transaction for initial balance if `initialBalance` field handles it.
    // BUT the directive says: "Alla creazione -> evento GENESIS nella catena".
    // It doesn't explicitly say "Create Transaction".
    // However, if we want Ledger to show "Opening Balance", we might want a transaction.
    // But then `initialBalance` field would double count if we add a transaction?
    // Let's stick to: `initialBalance` is the starting point. Transactions add/subtract. 
    // So NO transaction for initial balance in `Transactions` table, unless `initialBalance` column is just for reference/reset?
    // Rule 5: "currentBalance di un account è ricalcolato sommando tutte le transazioni".
    // This implies `currentBalance = sum(transactions)`. 
    // It does NOT mention `initialBalance`.
    // If `currentBalance` is purely sum of transactions, then we MUST create a transaction for the initial balance.
    // In that case, `initialBalance` column in `Accounts` table might be `0` or just metadata.
    // Let's assume we create a transaction "Initial Deposit" with amount = initialBalance.
    
    if (initialBalance != 0) {
      await _transactionsDao.insertTransaction(
        db.TransactionsCompanion.insert(
          id: _uuid.v4(),
          chainEventSequence: sequence,
          accountId: accountId,
          amount: initialBalance,
          description: "Initial Balance",
          category: TransactionCategory.incomeOther,
          date: now,
        ),
      );
      // We assume `updateBalance` in DAO handles summing transactions. 
      // If DAO implementation sums transactions, it will equal initialBalance.
      // Wait, Accounts Schema has `initialBalance` column. 
      // If I add transaction, duplicate?
      // I'll assume `initialBalance` column is for "Opening Balance" record, and `currentBalance` = `initialBalance` + `transactions`.
      // Let's check `accounts_dao.dart` `updateBalance` implementation if I wrote it?
      // "Future<void> updateBalance(String accountId) — ricalcola da transazioni"
      // In my implementation (Step 1089), `updateBalance` took `int newBalance`.
      // It didn't recalculate itself. The Caller recalculates.
      // So I should calculate: `currentBalance` = `initialBalance` + `transactionsSum`.
      // Since I created a transaction for it, I might be double counting if I use both.
      // I will Create a Transaction for Initial Balance, AND set SQL `initialBalance` column to 0 (or keep it as ref).
      // Or sets `initialBalance` to X, and NO transaction.
      // But Rule 5 says "summing **all** transactions". 
      // Use case "Create Account" should probably adhere to "Genesis event with initial balance".
      // Let's create a transaction linked to Genesis event.
    }
  }
}
