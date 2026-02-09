
import 'dart:convert';
import 'package:uuid/uuid.dart';

import '../../domain/entities/chain_event.dart';
import '../../domain/entities/event_metadata.dart';
import '../../domain/entities/event_type.dart';
import '../../domain/entities/crypto_identity.dart';
import '../../domain/entities/inbox_message.dart';
import '../../domain/entities/transaction_category.dart';
import '../../domain/repositories/chain_repository.dart';
import '../../domain/repositories/crypto_repository.dart';
import '../../domain/repositories/key_storage_repository.dart';
import '../../data/local_db/daos/accounts_dao.dart';
import '../../data/local_db/daos/transactions_dao.dart';
import '../../data/local_db/daos/inbox_dao.dart';
import '../../data/local_db/app_database.dart'; 

class ProcessInboxMessage {
  final ChainRepository _chainRepository;
  final TransactionsDao _transactionsDao;
  final InboxDao _inboxDao;
  final AccountsDao _accountsDao;
  final KeyStorageRepository _keyStorageRepository;
  final CryptoRepository _cryptoRepository;
  final Uuid _uuid = const Uuid();

  ProcessInboxMessage(
    this._chainRepository,
    this._transactionsDao,
    this._inboxDao,
    this._accountsDao,
    this._keyStorageRepository,
    this._cryptoRepository,
  );

  Future<void> call({
    required InboxMessage message,
    required String accountId,
    required TransactionCategory category,
    required int amount, // cents (negative for expense)
    String? merchant,
    DateTime? date, // operation date
    String? notes,
  }) async {
    // 0. Validation
    if (message.status != MessageStatus.verified) {
      throw Exception("Cannot process unverified message");
    }

    final now = DateTime.now().toUtc();
    final opDate = date?.toUtc() ?? now;

    // 1. Create Chain Event
    final previousEvent = await _chainRepository.getLastEvent();
    final sequence = (previousEvent?.sequence ?? -1) + 1;
    final previousHash = previousEvent?.hash ?? ('0' * 64);

    // Event Type: receiptScan if attachment, or transaction if text only?
    // Using transaction type for generic expense logic. 
    // Or receiptScan if there is an image. 
    // D05 says: "Crea evento TRANSACTION (o RECEIPT_SCAN se ha allegato)"
    final eventType = message.attachments.isNotEmpty ? EventType.receiptScan : EventType.transaction;

    final payload = {
      'inboxMessageId': message.id, // Internal ID
      'emailMessageId': message.emailMessageId,
      'accountId': accountId,
      'amount': amount,
      'category': category.name,
      'merchant': merchant,
      'notes': notes,
      'sharerSignature': message.sharerSignature, // Preserve original sig reference
    };

    // Sign with Keeper key
    final keeperKey = await _keyStorageRepository.loadPrivateKey(Role.keeper);
    if (keeperKey == null) throw Exception("Keeper identity not found");

    final payloadJson = jsonEncode(payload);
    final signableContent = '$sequence|$previousHash|${now.toIso8601String()}|${eventType.name}|$payloadJson';
    final keeperSignature = await _cryptoRepository.sign(utf8.encode(signableContent), keeperKey);

    final eventHash = ChainEvent.computeHash(
      sequence: sequence,
      previousHash: previousHash,
      timestamp: now,
      eventType: eventType,
      payload: payload,
      keeperSignature: keeperSignature,
    );

    final event = ChainEvent(
      sequence: sequence,
      previousHash: previousHash,
      timestamp: now,
      eventType: eventType,
      payload: payload,
      keeperSignature: keeperSignature,
      // Pass Sharer Sig if available for storage in column? 
      // ChainEvents table has `sharerSignature` column.
      // Domain `ChainEvent` has `sharerSignature` field.
      sharerSignature: message.sharerSignature, 
      metadata: EventMetadata(
        source: EventSource.email,
        trustLevel: 5, // Verified email
        aiEngine: null,
      ),
      hash: eventHash,
    );

    await _chainRepository.appendEvent(event);

    // 2. Create Transaction
    await _transactionsDao.insertTransaction(
      TransactionsCompanion.insert(
        id: _uuid.v4(),
        chainEventSequence: sequence,
        accountId: accountId,
        amount: amount,
        description: merchant ?? message.subject ?? "Transaction",
        merchant: Value(merchant),
        category: category.name, // String
        date: opDate,
        notes: Value(notes),
        receiptImagePath: Value(null), // Handle attachment saving later (module 06 or separate)
      ),
    );

    // 3. Update Balance
    // We fetch current balance first? Or calculate?
    // accountsDao has updateBalance(id, int).
    // TransactionsDao has calculateBalance(id).
    final newBalance = await _transactionsDao.calculateBalance(accountId);
    // Wait, calculateBalance logic needs to account for Initial Balance?
    // If I created a transaction for initial balance, `calculateBalance` sums it up. 
    // So `newBalance` is correct.
    // If I didn't create transaction for initial balance, this sum is missing it.
    // In `CreateAccount`, I decided to INSERT a transaction for initial balance. 
    // So basic sum is correct.
    await _accountsDao.updateBalance(accountId, newBalance);

    // 4. Update Inbox Message
    await _inboxDao.markAsProcessed(message.id, sequence);
  }
}
