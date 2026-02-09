
import 'package:drift/drift.dart';
import '../../domain/entities/transaction_category.dart';
import '../app_database.dart';

part 'transactions_dao.g.dart';

@DriftAccessor(tables: [Transactions])
class TransactionsDao extends DatabaseAccessor<AppDatabase> with _$TransactionsDaoMixin {
  TransactionsDao(AppDatabase db) : super(db);

  Future<void> insertTransaction(TransactionsCompanion transaction) => into(transactions).insert(transaction);

  Future<Transaction?> getTransactionById(String id) => (select(transactions)..where((t) => t.id.equals(id))).getSingleOrNull();

  Future<List<Transaction>> getTransactionsByAccount(String accountId) {
    return (select(transactions)
      ..where((t) => t.accountId.equals(accountId))
      ..orderBy([(t) => OrderingTerm(expression: t.date, mode: OrderingMode.desc)]))
    .get();
  }

  Future<List<Transaction>> getTransactionsByCategory(TransactionCategory category) {
    // Requires Converter logic to be working or manual check
    // Drift handles converters automatically in generated code
    return (select(transactions)
      ..where((t) => t.category.equals(category.name)) // Error? Converter applies to Dart side. 
      // If we query, we might need to pass the object if Drift supports it, or raw string if not.
      // With `TypeConverter`, we should pass the enum.
      // ..where((t) => t.category.equals(category))
    )
    .get();
  }
  
  // Correction: filtering with TypeConverter
  Future<List<Transaction>> getTransactionsByCategoryTyped(TransactionCategory category) {
      return (select(transactions)..where((t) => t.category.equals(category))).get();
  }

  Stream<List<Transaction>> watchRecentTransactions({int limit = 50}) {
    return (select(transactions)
      ..orderBy([(t) => OrderingTerm(expression: t.date, mode: OrderingMode.desc)])
      ..limit(limit))
    .watch();
  }
  
  Future<int> calculateBalance(String accountId) async {
    final amount = transactions.amount.sum();
    final query = selectOnly(transactions)
      ..addColumns([amount])
      ..where(transactions.accountId.equals(accountId));
      
    final result = await query.getSingle();
    return result.read(amount) ?? 0;
  }
}
