import 'dart:math';

import '../../domain/repositories/dashboard_repository.dart';
import '../../domain/entities/dashboard_data.dart';
import '../../domain/entities/report_data.dart';
import '../../domain/entities/transaction_category.dart';
import '../local_db/daos/transactions_dao.dart';
import '../local_db/daos/accounts_dao.dart';
import '../local_db/app_database.dart';

class DashboardService implements DashboardRepository {
  final TransactionsDao _transactionsDao;
  final AccountsDao _accountsDao;

  final Set<String> _dismissedAlertIds = {};

  DashboardService(this._transactionsDao, this._accountsDao);

  @override
  Future<DashboardData> getDashboardData() async {
    final now = DateTime.now().toUtc();
    final monthStart = DateTime.utc(now.year, now.month, 1);
    final nextMonthStart = DateTime.utc(now.year, now.month + 1, 1);

    final totalBalance = await _accountsDao.getTotalBalance();
    final monthTransactions = await _transactionsDao.getTransactionsByDateRange(monthStart, nextMonthStart);

    int monthExpenses = 0;
    int monthIncome = 0;
    final categoryBreakdown = <TransactionCategory, int>{};

    for (final t in monthTransactions) {
      if (t.amount < 0) {
        monthExpenses += t.amount.abs();
        categoryBreakdown.update(
          t.category,
          (v) => v + t.amount.abs(),
          ifAbsent: () => t.amount.abs(),
        );
      } else {
        monthIncome += t.amount;
      }
    }

    final daysElapsed = now.day;
    final documentedDays = await _transactionsDao.getDocumentedDaysCount(monthStart, nextMonthStart);
    final documentationRate = daysElapsed > 0 ? documentedDays / daysElapsed : 0.0;

    final regularityScore = _calculateRegularity(monthTransactions, monthStart, now);
    final docScore = (documentationRate * 100).clamp(0, 100);
    final currentScore = ((docScore * 0.5) + (regularityScore * 0.5)).round().clamp(0, 100);

    final prevMonthStart = DateTime.utc(now.year, now.month - 1, 1);
    final prevScore = await _calculateScoreForMonth(prevMonthStart, monthStart);

    final scoreTrend = prevScore == null
        ? ScoreTrend.stable
        : (currentScore - prevScore > 5
            ? ScoreTrend.up
            : (currentScore - prevScore < -5 ? ScoreTrend.down : ScoreTrend.stable));

    final scoreLevel = currentScore >= 70
        ? ScoreLevel.high
        : (currentScore >= 40 ? ScoreLevel.medium : ScoreLevel.low);

    final alerts = await _generateAlerts(monthTransactions, monthStart, now);

    return DashboardData(
      totalBalance: totalBalance,
      monthExpenses: monthExpenses,
      monthIncome: monthIncome,
      transactionCount: monthTransactions.length,
      documentationRate: documentationRate.clamp(0.0, 1.0),
      documentedDays: documentedDays,
      totalDays: daysElapsed,
      fideluxScore: currentScore,
      scoreLevel: scoreLevel,
      scoreTrend: scoreTrend,
      activeAlerts: alerts,
      categoryBreakdown: categoryBreakdown,
      lastUpdated: now,
    );
  }

  @override
  Future<ReportData> getReportData(DateRange dateRange) async {
    final transactions = await _transactionsDao.getTransactionsByDateRange(
      dateRange.start,
      dateRange.end,
    );

    final categoryBreakdown = <TransactionCategory, int>{};
    final dailyTotals = <DateTime, int>{};
    final merchantMap = <String, _MerchantAccumulator>{};
    int totalExpenses = 0;
    int totalIncome = 0;

    for (final t in transactions) {
      if (t.amount < 0) {
        totalExpenses += t.amount.abs();

        categoryBreakdown.update(
          t.category,
          (v) => v + t.amount.abs(),
          ifAbsent: () => t.amount.abs(),
        );

        final dayKey = DateTime.utc(t.date.year, t.date.month, t.date.day);
        dailyTotals.update(dayKey, (v) => v + t.amount.abs(), ifAbsent: () => t.amount.abs());

        if (t.merchant != null && t.merchant!.isNotEmpty) {
          merchantMap.update(
            t.merchant!,
            (v) {
              v.total += t.amount.abs();
              v.count += 1;
              return v;
            },
            ifAbsent: () => _MerchantAccumulator(t.amount.abs(), 1),
          );
        }
      } else {
        totalIncome += t.amount;
      }
    }

    final topMerchants = merchantMap.entries.toList()
      ..sort((a, b) => b.value.total.compareTo(a.value.total));

    final monthlyComparison = await _calculateMonthlyComparison(dateRange);

    return ReportData(
      dateRange: dateRange,
      categoryBreakdown: categoryBreakdown,
      dailyTotals: dailyTotals,
      monthlyComparison: monthlyComparison,
      topMerchants: topMerchants.take(5).map((e) => MerchantTotal(
        merchant: e.key,
        totalAmount: e.value.total,
        transactionCount: e.value.count,
      )).toList(),
      totalExpenses: totalExpenses,
      totalIncome: totalIncome,
    );
  }

  @override
  Future<void> dismissAlert(String alertId) async {
    _dismissedAlertIds.add(alertId);
  }

  double _calculateRegularity(List<Transaction> transactions, DateTime start, DateTime end) {
    if (transactions.isEmpty) return 0;

    final days = transactions
        .map((t) => DateTime.utc(t.date.year, t.date.month, t.date.day))
        .toSet()
        .toList()
      ..sort();

    if (days.isEmpty) return 0;

    int maxGap = days.first.difference(start).inDays;

    for (int i = 1; i < days.length; i++) {
      final gap = days[i].difference(days[i - 1]).inDays;
      maxGap = max(maxGap, gap);
    }

    final trailingGap = end.difference(days.last).inDays;
    maxGap = max(maxGap, trailingGap);

    if (maxGap <= 3) return 100;
    if (maxGap <= 5) return 70;
    if (maxGap <= 7) return 40;
    return 10;
  }

  Future<int?> _calculateScoreForMonth(DateTime monthStart, DateTime monthEnd) async {
    final transactions = await _transactionsDao.getTransactionsByDateRange(monthStart, monthEnd);
    if (transactions.isEmpty) return null;

    final daysInMonth = monthEnd.difference(monthStart).inDays;
    final documentedDays = transactions
        .map((t) => DateTime.utc(t.date.year, t.date.month, t.date.day))
        .toSet()
        .length;

    final docRate = daysInMonth > 0 ? documentedDays / daysInMonth : 0.0;
    final docScore = (docRate * 100).clamp(0, 100);
    final regScore = _calculateRegularity(transactions, monthStart, monthEnd);

    return ((docScore * 0.5) + (regScore * 0.5)).round().clamp(0, 100);
  }

  Future<List<ActiveAlert>> _generateAlerts(
    List<Transaction> monthTransactions,
    DateTime monthStart,
    DateTime now,
  ) async {
    final alerts = <ActiveAlert>[];
    final monthKey = '${now.year}_${now.month.toString().padLeft(2, '0')}';

    // Critical: gambling detected
    final hasGambling = monthTransactions.any((t) => t.category == TransactionCategory.gambling);
    if (hasGambling) {
      alerts.add(ActiveAlert(
        id: 'gambling_$monthKey',
        level: AlertLevel.critical,
        titleKey: 'alertCritical',
        descriptionKey: 'alertGamblingDetected',
        createdAt: now,
      ));
    }

    // Critical: 3+ cash withdrawals in 24 hours
    final cashTxns = monthTransactions
        .where((t) => t.category == TransactionCategory.cash)
        .toList()
      ..sort((a, b) => a.date.compareTo(b.date));

    for (int i = 0; i <= cashTxns.length - 3; i++) {
      final windowEnd = cashTxns[i].date.add(const Duration(hours: 24));
      final inWindow = cashTxns.where((t) =>
        t.date.isAfter(cashTxns[i].date.subtract(const Duration(seconds: 1))) &&
        t.date.isBefore(windowEnd)).length;
      if (inWindow >= 3) {
        final dayKey = '${cashTxns[i].date.year}_${cashTxns[i].date.month.toString().padLeft(2, '0')}_${cashTxns[i].date.day.toString().padLeft(2, '0')}';
        alerts.add(ActiveAlert(
          id: 'cash_spike_$dayKey',
          level: AlertLevel.critical,
          titleKey: 'alertCritical',
          descriptionKey: 'alertMultipleCashWithdrawals',
          descriptionParams: {'count': inWindow.toString()},
          createdAt: now,
        ));
        break;
      }
    }

    // Advisory: no transactions for 3+ days
    if (monthTransactions.isNotEmpty) {
      final lastTxnDate = monthTransactions
          .map((t) => t.date)
          .reduce((a, b) => a.isAfter(b) ? a : b);
      final daysSinceLastTxn = now.difference(lastTxnDate).inDays;
      if (daysSinceLastTxn >= 3) {
        alerts.add(ActiveAlert(
          id: 'gap_3d_$monthKey',
          level: AlertLevel.advisory,
          titleKey: 'alertAdvisory',
          descriptionKey: 'alertNoDocumentation',
          descriptionParams: {'days': daysSinceLastTxn.toString()},
          createdAt: now,
        ));
      }
    } else {
      // No transactions at all this month
      final daysSinceMonthStart = now.difference(monthStart).inDays;
      if (daysSinceMonthStart >= 3) {
        alerts.add(ActiveAlert(
          id: 'gap_3d_$monthKey',
          level: AlertLevel.advisory,
          titleKey: 'alertAdvisory',
          descriptionKey: 'alertNoDocumentation',
          descriptionParams: {'days': daysSinceMonthStart.toString()},
          createdAt: now,
        ));
      }
    }

    // Advisory: category spike (150% of 2-month average)
    final prevMonthStart = DateTime.utc(now.year, now.month - 2, 1);
    final currentMonthStart = DateTime.utc(now.year, now.month, 1);
    final prevTransactions = await _transactionsDao.getTransactionsByDateRange(prevMonthStart, currentMonthStart);

    if (prevTransactions.isNotEmpty) {
      final prevCategoryTotals = <TransactionCategory, int>{};
      for (final t in prevTransactions) {
        if (t.amount < 0) {
          prevCategoryTotals.update(
            t.category,
            (v) => v + t.amount.abs(),
            ifAbsent: () => t.amount.abs(),
          );
        }
      }

      // Average over 2 months
      final prevAvg = prevCategoryTotals.map((k, v) => MapEntry(k, v ~/ 2));

      final currentCategoryTotals = <TransactionCategory, int>{};
      for (final t in monthTransactions) {
        if (t.amount < 0) {
          currentCategoryTotals.update(
            t.category,
            (v) => v + t.amount.abs(),
            ifAbsent: () => t.amount.abs(),
          );
        }
      }

      for (final entry in currentCategoryTotals.entries) {
        final avg = prevAvg[entry.key];
        if (avg != null && avg > 0 && entry.value > avg * 1.5) {
          final percent = ((entry.value / avg - 1) * 100).round();
          alerts.add(ActiveAlert(
            id: 'spike_${entry.key.name}_$monthKey',
            level: AlertLevel.advisory,
            titleKey: 'alertAdvisory',
            descriptionKey: 'alertCategorySpike',
            descriptionParams: {
              'category': entry.key.localizedName,
              'percent': percent.toString(),
            },
            createdAt: now,
          ));
        }
      }
    }

    // Filter out dismissed alerts
    return alerts.where((a) => !_dismissedAlertIds.contains(a.id)).toList();
  }

  Future<List<MonthTotal>> _calculateMonthlyComparison(DateRange dateRange) async {
    final now = DateTime.now().toUtc();
    final months = <MonthTotal>[];

    for (int i = 0; i < 3; i++) {
      final mStart = DateTime.utc(now.year, now.month - i, 1);
      final mEnd = DateTime.utc(now.year, now.month - i + 1, 1);
      final txns = await _transactionsDao.getTransactionsByDateRange(mStart, mEnd);

      int expenses = 0;
      int income = 0;
      for (final t in txns) {
        if (t.amount < 0) {
          expenses += t.amount.abs();
        } else {
          income += t.amount;
        }
      }

      if (txns.isNotEmpty || i == 0) {
        months.add(MonthTotal(
          year: mStart.year,
          month: mStart.month,
          expenses: expenses,
          income: income,
        ));
      }
    }

    return months;
  }
}

class _MerchantAccumulator {
  int total;
  int count;
  _MerchantAccumulator(this.total, this.count);
}
