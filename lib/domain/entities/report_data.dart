import 'transaction_category.dart';

enum ReportPeriod { month, quarter, year }

class DateRange {
  final DateTime start;
  final DateTime end;

  const DateRange({required this.start, required this.end});

  factory DateRange.currentMonth() {
    final now = DateTime.now().toUtc();
    return DateRange(
      start: DateTime.utc(now.year, now.month, 1),
      end: now,
    );
  }

  factory DateRange.fromPeriod(ReportPeriod period) {
    final now = DateTime.now().toUtc();
    switch (period) {
      case ReportPeriod.month:
        return DateRange(
          start: DateTime.utc(now.year, now.month, 1),
          end: now,
        );
      case ReportPeriod.quarter:
        return DateRange(
          start: DateTime.utc(now.year, now.month - 2, 1),
          end: now,
        );
      case ReportPeriod.year:
        return DateRange(
          start: DateTime.utc(now.year - 1, now.month, now.day),
          end: now,
        );
    }
  }
}

class ReportData {
  final DateRange dateRange;
  final Map<TransactionCategory, int> categoryBreakdown;
  final Map<DateTime, int> dailyTotals;
  final List<MonthTotal> monthlyComparison;
  final List<MerchantTotal> topMerchants;
  final int totalExpenses;
  final int totalIncome;

  const ReportData({
    required this.dateRange,
    required this.categoryBreakdown,
    required this.dailyTotals,
    required this.monthlyComparison,
    required this.topMerchants,
    required this.totalExpenses,
    required this.totalIncome,
  });
}

class MonthTotal {
  final int year;
  final int month;
  final int expenses;
  final int income;

  const MonthTotal({
    required this.year,
    required this.month,
    required this.expenses,
    required this.income,
  });
}

class MerchantTotal {
  final String merchant;
  final int totalAmount;
  final int transactionCount;

  const MerchantTotal({
    required this.merchant,
    required this.totalAmount,
    required this.transactionCount,
  });
}
