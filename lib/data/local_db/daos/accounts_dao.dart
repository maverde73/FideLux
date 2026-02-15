
import 'package:drift/drift.dart';
import '../app_database.dart';

part 'accounts_dao.g.dart';

@DriftAccessor(tables: [Accounts])
class AccountsDao extends DatabaseAccessor<AppDatabase> with _$AccountsDaoMixin {
  AccountsDao(AppDatabase db) : super(db);

  Future<void> insertAccount(AccountsCompanion account) => into(accounts).insert(account);

  Future<List<Account>> getAllAccounts() => select(accounts).get();

  Future<Account?> getAccountById(String id) => (select(accounts)..where((t) => t.id.equals(id))).getSingleOrNull();

  Future<void> updateBalance(String accountId, int newBalance) {
    return (update(accounts)..where((t) => t.id.equals(accountId))).write(
      AccountsCompanion(
        currentBalance: Value(newBalance),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }
  
  Stream<List<Account>> watchAllAccounts() => select(accounts).watch();

  Future<int> getTotalBalance() async {
    final total = accounts.currentBalance.sum();
    final query = selectOnly(accounts)
      ..addColumns([total])
      ..where(accounts.isActive.equals(true));
    final result = await query.getSingle();
    return result.read(total) ?? 0;
  }
  Future<void> updateAccount(AccountsCompanion account) => update(accounts).replace(account);

  Future<void> deleteAccount(String id) => (update(accounts)..where((t) => t.id.equals(id))).write(
    const AccountsCompanion(isActive: Value(false)),
  );
}
