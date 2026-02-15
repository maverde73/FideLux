
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/local_db/app_database.dart';
import '../../data/local_db/daos/accounts_dao.dart';
import '../../data/local_db/daos/transactions_dao.dart';
import '../../data/local_db/daos/chain_events_dao.dart';
import '../../data/local_db/daos/inbox_dao.dart';
import '../../data/chain/chain_service.dart';
import '../../application/accounting/create_account.dart';
import '../../application/accounting/process_inbox_message.dart';
import '../../application/accounting/update_account.dart';
import '../../application/accounting/delete_account.dart';
import '../providers/core_providers.dart';

// We need access to repositories.
// Assuming we have a global DB provider.

final databaseProvider = Provider<AppDatabase>((ref) {
  return AppDatabase();
});

final accountsDaoProvider = Provider<AccountsDao>((ref) {
  return AccountsDao(ref.watch(databaseProvider));
});

final transactionsDaoProvider = Provider<TransactionsDao>((ref) {
  return TransactionsDao(ref.watch(databaseProvider));
});

final chainEventsDaoProvider = Provider<ChainEventsDao>((ref) {
  return ChainEventsDao(ref.watch(databaseProvider));
});

final inboxDaoProvider = Provider<InboxDao>((ref) {
  return InboxDao(ref.watch(databaseProvider));
});

// Import Repositories Providers from previous modules
// We need CryptoRepository and KeyStorageRepository.
// They are usually in `di_providers.dart` or similar.
// I'll define basic providers here if not globally available, or assume they are available.
// I used `cryptoRepositoryProvider` in `pairing_providers.dart`.
// I should look where `KeyStorageRepository` is provided. probably `core_providers.dart` or similar.

// Placeholder:
// final keyStorageRepositoryProvider = ...;
// final cryptoRepositoryProvider = ...;
// I'll use placeholders that throw if not overridden or link to real ones if I find them.

final accountsProvider = StreamProvider<List<Account>>((ref) {
  final dao = ref.watch(accountsDaoProvider);
  return dao.watchAllAccounts();
});

final createAccountProvider = Provider<CreateAccount>((ref) {
  final accountsDao = ref.watch(accountsDaoProvider);
  final transactionsDao = ref.watch(transactionsDaoProvider);
  // Chain Repository is needed. We should have a chainRepositoryProvider.
  // For now I construct ChainService here or assume it's provided.
  // Let's assume ChainService is provided by chainServiceProvider.
  // I need to find where ChainService is provided. 
  // It consumes Dao and CryptoRepo.
  
  // ChainService instantiation:
  final chainDao = ref.watch(chainEventsDaoProvider);
  final cryptoRepo = ref.watch(cryptoRepositoryProvider);

  final chainService = ChainService(chainDao);

  final keyStorage = ref.watch(keyStorageRepositoryProvider);

  return CreateAccount(
    accountsDao,
    chainService,
    transactionsDao,
    keyStorage,
    cryptoRepo,
  );
});

final processInboxMessageProvider = Provider<ProcessInboxMessage>((ref) {
    final chainDao = ref.watch(chainEventsDaoProvider);
    final cryptoRepo = ref.watch(cryptoRepositoryProvider);
    final chainService = ChainService(chainDao);
    
    return ProcessInboxMessage(
        chainService,
        ref.watch(transactionsDaoProvider),
        ref.watch(inboxDaoProvider),
        ref.watch(accountsDaoProvider),
        ref.watch(keyStorageRepositoryProvider),
        cryptoRepo,
    );
});

// We need to import pairing_providers.dart for crypto/key repos?
// Checked pairing_providers.dart: it has `peerIdentityProvider` etc. 
// It DOES NOT export `cryptoRepositoryProvider` or `keyStorageRepositoryProvider`.
// I need to find where they are. 
// They are likely in `lib/presentation/providers/core_providers.dart` or similar if they exist.
// If not, I should create `lib/presentation/providers/core_providers.dart` to hold singletons.

final updateAccountProvider = Provider<UpdateAccount>((ref) {
  final accountsDao = ref.watch(accountsDaoProvider);
  final transactionsDao = ref.watch(transactionsDaoProvider);
  final chainDao = ref.watch(chainEventsDaoProvider);
  final cryptoRepo = ref.watch(cryptoRepositoryProvider);
  final keyStorage = ref.watch(keyStorageRepositoryProvider);
  
  final chainService = ChainService(chainDao);

  return UpdateAccount(
    accountsDao,
    chainService,
    transactionsDao,
    keyStorage,
    cryptoRepo,
  );
});

final deleteAccountProvider = Provider<DeleteAccount>((ref) {
  final accountsDao = ref.watch(accountsDaoProvider);
  final chainDao = ref.watch(chainEventsDaoProvider);
  final cryptoRepo = ref.watch(cryptoRepositoryProvider);
  final keyStorage = ref.watch(keyStorageRepositoryProvider);
  
  final chainService = ChainService(chainDao);

  return DeleteAccount(
    accountsDao,
    chainService,
    keyStorage,
    cryptoRepo,
  );
});

