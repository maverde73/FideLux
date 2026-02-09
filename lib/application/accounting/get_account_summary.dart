
import '../../data/local_db/daos/accounts_dao.dart';
import '../../data/local_db/daos/transactions_dao.dart';
import '../../data/local_db/app_database.dart';

class AccountSummary {
  final Account account;
  final int currentBalance; // cents
  final int income; // cents
  final int expenses; // cents (positive value)
  final int transactionCount;
  final List<Transaction> recentTransactions;

  AccountSummary({
    required this.account,
    required this.currentBalance,
    required this.income,
    required this.expenses,
    required this.transactionCount,
    required this.recentTransactions,
  });
}

class GetAccountSummary {
  final AccountsDao _accountsDao;
  final TransactionsDao _transactionsDao;

  GetAccountSummary(this._accountsDao, this._transactionsDao);

  Future<AccountSummary?> call(String accountId) async {
    final account = await _accountsDao.getAccountById(accountId);
    if (account == null) return null;

    final transactions = await _transactionsDao.getTransactionsByAccount(accountId);
    
    int income = 0;
    int expenses = 0;

    for (var t in transactions) {
      if (t.amount > 0) {
        income += t.amount;
      } else {
        expenses += t.amount.abs();
      }
    }

    // currentBalance is already in Account (updated by ProcessInboxMessage/CreateAccount)
    // But we might want to verify against transactions sum + initialBalance?
    // For MVP, trust the stored value which is updated by logic.
    
    return AccountSummary(
      account: account,
      currentBalance: account.currentBalance,
      income: income,
      expenses: expenses,
      transactionCount: transactions.length,
      recentTransactions: transactions.take(5).toList(), // Top 5
    );
  }
}
