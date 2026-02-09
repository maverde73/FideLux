
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:drift/native.dart';
import 'package:fidelux/data/local_db/app_database.dart';
import 'package:fidelux/data/local_db/daos/accounts_dao.dart';
import 'package:fidelux/data/local_db/daos/chain_events_dao.dart';
import 'package:fidelux/data/local_db/daos/transactions_dao.dart';
import 'package:fidelux/data/chain/chain_service.dart';
import 'package:fidelux/application/accounting/create_account.dart';
import 'package:fidelux/domain/entities/crypto_identity.dart';
import 'package:fidelux/domain/repositories/crypto_repository.dart';
import 'package:fidelux/domain/repositories/key_storage_repository.dart';
import 'package:mockito/mockito.dart';

// Mock Crypto/KeyStorage
class MockCryptoRepository extends Mock implements CryptoRepository {
  @override
  Future<String> sign(List<int> data, List<int> privateKey) async => "mock_signature";
}

class MockKeyStorageRepository extends Mock implements KeyStorageRepository {
  @override
  Future<Uint8List?> loadPrivateKey(Role role) async => Uint8List.fromList([1, 2, 3]);
}

void main() {
  late AppDatabase database;
  late AccountsDao accountsDao;
  late ChainEventsDao chainDao;
  late TransactionsDao transactionsDao;
  late ChainService chainService;
  late MockCryptoRepository cryptoRepo;
  late MockKeyStorageRepository keyStorage;
  late CreateAccount createAccount;

  setUp(() {
    database = AppDatabase.forTesting(NativeDatabase.memory());
    accountsDao = AccountsDao(database);
    chainDao = ChainEventsDao(database);
    transactionsDao = TransactionsDao(database);
    cryptoRepo = MockCryptoRepository();
    keyStorage = MockKeyStorageRepository();
    
    chainService = ChainService(chainDao);
    createAccount = CreateAccount(
      accountsDao, 
      chainService, 
      transactionsDao, 
      keyStorage, 
      cryptoRepo
    );
  });

  tearDown(() async {
    await database.close();
  });

  test('CreateAccount should create account, genesis event, and initial transaction', () async {
    await createAccount(
      name: "Test Account",
      type: "checking",
      currency: "EUR",
      initialBalance: 10000, // 100.00
    );

    // Verify Account
    final accounts = await accountsDao.watchAllAccounts().first;
    expect(accounts.length, 1);
    expect(accounts.first.name, "Test Account");
    expect(accounts.first.currentBalance, 10000);

    // Verify Chain Event
    final event = await chainDao.getLastEvent();
    expect(event, isNotNull);
    expect(event!.sequence, 0); // First event
    expect(event.eventType, "genesis");
    
    // Verify Transaction
    final transactions = await transactionsDao.getTransactionsByAccount(accounts.first.id);
    expect(transactions.length, 1);
    expect(transactions.first.amount, 10000);
    expect(transactions.first.description, "Initial Balance"); // or logic in use case
  });
}
