import 'package:flutter_test/flutter_test.dart';
import 'package:drift/native.dart';
import 'package:fidelux/data/local_db/app_database.dart';
import 'package:fidelux/data/local_db/daos/transactions_dao.dart';
import 'package:fidelux/data/local_db/daos/accounts_dao.dart';
import 'package:fidelux/data/local_db/daos/chain_events_dao.dart';
import 'package:fidelux/data/dashboard/dashboard_service.dart';
import 'package:fidelux/domain/entities/report_data.dart';
import 'package:fidelux/domain/entities/transaction_category.dart';

void main() {
  late AppDatabase db;
  late TransactionsDao txDao;
  late AccountsDao accDao;
  late ChainEventsDao chainDao;
  late DashboardService service;

  final now = DateTime.now().toUtc();

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    txDao = TransactionsDao(db);
    accDao = AccountsDao(db);
    chainDao = ChainEventsDao(db);
    service = DashboardService(txDao, accDao);
  });

  tearDown(() async => await db.close());

  Future<String> insertAccount() async {
    const id = 'test-account-1';
    await accDao.insertAccount(AccountsCompanion.insert(
      id: id,
      name: 'Test',
      type: 'checking',
      initialBalance: 100000,
      currentBalance: 100000,
      createdAt: now,
      updatedAt: now,
    ));
    return id;
  }

  Future<int> insertChainEvent() async {
    return await chainDao.insertEvent(ChainEventsCompanion.insert(
      previousHash: '0' * 64,
      timestamp: now,
      eventType: 'transaction',
      payload: '{}',
      keeperSignature: 'mock_sig',
      metadataSource: 'test',
      metadataTrustLevel: 6,
      hash: 'a' * 64,
    ));
  }

  test('calculates category breakdown correctly', () async {
    final accountId = await insertAccount();
    final seq = await insertChainEvent();

    // 3 groceries transactions totaling 5000
    for (int i = 0; i < 3; i++) {
      await txDao.insertTransaction(TransactionsCompanion.insert(
        id: 'tx-groc-$i',
        chainEventSequence: seq,
        accountId: accountId,
        amount: -(1000 + i * 500), // -1000, -1500, -2000 = -4500
        description: 'Groceries $i',
        category: TransactionCategory.groceries,
        date: DateTime.utc(now.year, now.month, 1, 10 + i),
      ));
    }

    // 2 dining transactions totaling 3000
    for (int i = 0; i < 2; i++) {
      await txDao.insertTransaction(TransactionsCompanion.insert(
        id: 'tx-din-$i',
        chainEventSequence: seq,
        accountId: accountId,
        amount: -1500,
        description: 'Dining $i',
        category: TransactionCategory.dining,
        date: DateTime.utc(now.year, now.month, 2, 10 + i),
      ));
    }

    // 1 transport transaction
    await txDao.insertTransaction(TransactionsCompanion.insert(
      id: 'tx-trans-0',
      chainEventSequence: seq,
      accountId: accountId,
      amount: -1000,
      description: 'Transport',
      category: TransactionCategory.transport,
      date: DateTime.utc(now.year, now.month, 3, 10),
    ));

    final report = await service.getReportData(DateRange.currentMonth());

    expect(report.categoryBreakdown[TransactionCategory.groceries], 4500);
    expect(report.categoryBreakdown[TransactionCategory.dining], 3000);
    expect(report.categoryBreakdown[TransactionCategory.transport], 1000);
    expect(report.totalExpenses, 8500);
  });

  test('calculates daily totals', () async {
    final accountId = await insertAccount();
    final seq = await insertChainEvent();

    // Day 1: 2000 in expenses
    await txDao.insertTransaction(TransactionsCompanion.insert(
      id: 'tx-d1',
      chainEventSequence: seq,
      accountId: accountId,
      amount: -2000,
      description: 'Day 1',
      category: TransactionCategory.groceries,
      date: DateTime.utc(now.year, now.month, 1, 12),
    ));

    // Day 2: 3000 in expenses
    await txDao.insertTransaction(TransactionsCompanion.insert(
      id: 'tx-d2',
      chainEventSequence: seq,
      accountId: accountId,
      amount: -3000,
      description: 'Day 2',
      category: TransactionCategory.dining,
      date: DateTime.utc(now.year, now.month, 2, 14),
    ));

    // Day 3: 1500 in expenses
    await txDao.insertTransaction(TransactionsCompanion.insert(
      id: 'tx-d3',
      chainEventSequence: seq,
      accountId: accountId,
      amount: -1500,
      description: 'Day 3',
      category: TransactionCategory.transport,
      date: DateTime.utc(now.year, now.month, 3, 16),
    ));

    final report = await service.getReportData(DateRange.currentMonth());

    expect(report.dailyTotals.length, 3);

    final day1 = DateTime.utc(now.year, now.month, 1);
    final day2 = DateTime.utc(now.year, now.month, 2);
    final day3 = DateTime.utc(now.year, now.month, 3);

    expect(report.dailyTotals[day1], 2000);
    expect(report.dailyTotals[day2], 3000);
    expect(report.dailyTotals[day3], 1500);
  });

  test('handles empty month gracefully', () async {
    await insertAccount();

    final report = await service.getReportData(DateRange.currentMonth());

    expect(report.categoryBreakdown, isEmpty);
    expect(report.dailyTotals, isEmpty);
    expect(report.totalExpenses, 0);
    expect(report.totalIncome, 0);
    expect(report.topMerchants, isEmpty);
  });
}
