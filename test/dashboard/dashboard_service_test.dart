import 'package:flutter_test/flutter_test.dart';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:fidelux/data/local_db/app_database.dart';
import 'package:fidelux/data/local_db/daos/transactions_dao.dart';
import 'package:fidelux/data/local_db/daos/accounts_dao.dart';
import 'package:fidelux/data/local_db/daos/chain_events_dao.dart';
import 'package:fidelux/data/dashboard/dashboard_service.dart';
import 'package:fidelux/domain/entities/dashboard_data.dart';
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

  /// Inserts a test account and returns its ID.
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

  /// Inserts a dummy chain event and returns its sequence number.
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

  /// Helper: insert a transaction on a given day of the current month.
  Future<void> insertTx({
    required String accountId,
    required int chainSeq,
    required int day,
    int amount = -1000,
    TransactionCategory category = TransactionCategory.groceries,
    String? merchant,
  }) async {
    final date = DateTime.utc(now.year, now.month, day, 12, 0, 0);
    await txDao.insertTransaction(TransactionsCompanion.insert(
      id: 'tx-${day.toString().padLeft(2, '0')}-${amount.abs()}-${category.name}',
      chainEventSequence: chainSeq,
      accountId: accountId,
      amount: amount,
      description: 'Test transaction',
      merchant: Value(merchant),
      category: category,
      date: date,
    ));
  }

  group('FideLux Score calculation', () {
    test('calculates score with full documentation', () async {
      final accountId = await insertAccount();
      final seq = await insertChainEvent();

      // Insert a transaction every day from day 1 to today
      for (int d = 1; d <= now.day; d++) {
        await insertTx(accountId: accountId, chainSeq: seq, day: d);
      }

      final data = await service.getDashboardData();

      expect(data.documentedDays, now.day);
      expect(data.documentationRate, closeTo(1.0, 0.01));
      expect(data.fideluxScore, greaterThanOrEqualTo(90));
      expect(data.scoreLevel, ScoreLevel.high);
    });

    test('calculates score with gaps', () async {
      final accountId = await insertAccount();
      final seq = await insertChainEvent();

      // Insert transactions on even days only, creating max gap of ~2 days
      // For a more medium score, let's create a gap of 4-5 days
      final daysToInsert = <int>[];
      for (int d = 1; d <= now.day; d++) {
        // Insert on days 1-5, skip 6-10, insert 11-15, skip 16-20, insert 21+
        if (d <= 5 || (d >= 11 && d <= 15) || d >= 21) {
          daysToInsert.add(d);
        }
      }

      for (final d in daysToInsert) {
        await insertTx(accountId: accountId, chainSeq: seq, day: d);
      }

      final data = await service.getDashboardData();

      // With 5-day gaps, regularity score = 70, doc rate varies
      expect(data.fideluxScore, greaterThanOrEqualTo(40));
      expect(data.fideluxScore, lessThan(90));
      expect(data.scoreLevel, anyOf(ScoreLevel.medium, ScoreLevel.high));
    });

    test('calculates score with poor documentation', () async {
      final accountId = await insertAccount();
      final seq = await insertChainEvent();

      // Only 2 transactions: day 1 and day 2
      await insertTx(accountId: accountId, chainSeq: seq, day: 1);
      if (now.day >= 2) {
        await insertTx(accountId: accountId, chainSeq: seq, day: 2);
      }

      final data = await service.getDashboardData();

      // If we're past day 10, gaps > 7 → regularity = 10
      // Doc rate = 2/N which will be very low
      if (now.day >= 10) {
        expect(data.fideluxScore, lessThan(40));
        expect(data.scoreLevel, ScoreLevel.low);
      }
    });

    test('detects trend up', () async {
      final accountId = await insertAccount();
      final seq = await insertChainEvent();

      // Previous month: only 1 transaction on day 1 (poor score)
      final prevMonth = DateTime.utc(now.year, now.month - 1, 1, 12, 0, 0);
      await txDao.insertTransaction(TransactionsCompanion.insert(
        id: 'tx-prev-01',
        chainEventSequence: seq,
        accountId: accountId,
        amount: -1000,
        description: 'Prev month tx',
        category: TransactionCategory.groceries,
        date: prevMonth,
      ));

      // Current month: transactions every day (high score)
      for (int d = 1; d <= now.day; d++) {
        await insertTx(accountId: accountId, chainSeq: seq, day: d);
      }

      final data = await service.getDashboardData();

      expect(data.scoreTrend, ScoreTrend.up);
    });
  });

  group('Alert generation', () {
    test('generates advisory alert for category spike', () async {
      final accountId = await insertAccount();
      final seq = await insertChainEvent();

      // 2 previous months: entertainment average of 5000 cents per month
      for (int m = 1; m <= 2; m++) {
        final date = DateTime.utc(now.year, now.month - m, 15, 12, 0, 0);
        await txDao.insertTransaction(TransactionsCompanion.insert(
          id: 'tx-prev-ent-$m',
          chainEventSequence: seq,
          accountId: accountId,
          amount: -5000,
          description: 'Entertainment prev $m',
          category: TransactionCategory.entertainment,
          date: date,
        ));
      }

      // Current month: entertainment 15000 (300% of average 5000 = way above 150%)
      await insertTx(
        accountId: accountId,
        chainSeq: seq,
        day: 1,
        amount: -15000,
        category: TransactionCategory.entertainment,
      );

      final data = await service.getDashboardData();

      final spikeAlerts = data.activeAlerts.where((a) =>
        a.level == AlertLevel.advisory &&
        a.descriptionKey == 'alertCategorySpike');
      expect(spikeAlerts, isNotEmpty);
    });

    test('generates critical alert for multiple cash withdrawals', () async {
      final accountId = await insertAccount();
      final seq = await insertChainEvent();

      // 3 cash withdrawals on the same day
      for (int i = 0; i < 3; i++) {
        final date = DateTime.utc(now.year, now.month, 1, 10 + i, 0, 0);
        await txDao.insertTransaction(TransactionsCompanion.insert(
          id: 'tx-cash-$i',
          chainEventSequence: seq,
          accountId: accountId,
          amount: -5000,
          description: 'Cash withdrawal $i',
          category: TransactionCategory.cash,
          date: date,
        ));
      }

      final data = await service.getDashboardData();

      final cashAlerts = data.activeAlerts.where((a) =>
        a.level == AlertLevel.critical &&
        a.descriptionKey == 'alertMultipleCashWithdrawals');
      expect(cashAlerts, isNotEmpty);
    });

    test('generates critical alert for gambling', () async {
      final accountId = await insertAccount();
      final seq = await insertChainEvent();

      await insertTx(
        accountId: accountId,
        chainSeq: seq,
        day: 1,
        amount: -2000,
        category: TransactionCategory.gambling,
      );

      final data = await service.getDashboardData();

      final gamblingAlerts = data.activeAlerts.where((a) =>
        a.level == AlertLevel.critical &&
        a.descriptionKey == 'alertGamblingDetected');
      expect(gamblingAlerts, isNotEmpty);
    });

    test('no alerts when everything normal', () async {
      final accountId = await insertAccount();
      final seq = await insertChainEvent();

      // Regular groceries transactions, one per day, recent enough
      final startDay = (now.day - 2).clamp(1, 28);
      for (int d = startDay; d <= now.day; d++) {
        await insertTx(
          accountId: accountId,
          chainSeq: seq,
          day: d,
          amount: -2000,
          category: TransactionCategory.groceries,
        );
      }

      final data = await service.getDashboardData();

      final significantAlerts = data.activeAlerts.where(
        (a) => a.level == AlertLevel.critical || a.level == AlertLevel.sos);
      expect(significantAlerts, isEmpty);
    });
  });
}
