import 'transaction_category.dart';

enum ScoreLevel { high, medium, low }

enum ScoreTrend { up, down, stable }

enum AlertLevel { normal, advisory, critical, sos }

class DashboardData {
  final int totalBalance;
  final int monthExpenses;
  final int monthIncome;
  final int transactionCount;
  final double documentationRate;
  final int documentedDays;
  final int totalDays;
  final int fideluxScore;
  final ScoreLevel scoreLevel;
  final ScoreTrend scoreTrend;
  final List<ActiveAlert> activeAlerts;
  final Map<TransactionCategory, int> categoryBreakdown;
  final DateTime lastUpdated;

  const DashboardData({
    required this.totalBalance,
    required this.monthExpenses,
    required this.monthIncome,
    required this.transactionCount,
    required this.documentationRate,
    required this.documentedDays,
    required this.totalDays,
    required this.fideluxScore,
    required this.scoreLevel,
    required this.scoreTrend,
    required this.activeAlerts,
    required this.categoryBreakdown,
    required this.lastUpdated,
  });
}

class ActiveAlert {
  final String id;
  final AlertLevel level;
  final String titleKey;
  final String descriptionKey;
  final Map<String, String> descriptionParams;
  final DateTime createdAt;
  final bool dismissed;

  const ActiveAlert({
    required this.id,
    required this.level,
    required this.titleKey,
    required this.descriptionKey,
    this.descriptionParams = const {},
    required this.createdAt,
    this.dismissed = false,
  });

  ActiveAlert copyWith({bool? dismissed}) {
    return ActiveAlert(
      id: id,
      level: level,
      titleKey: titleKey,
      descriptionKey: descriptionKey,
      descriptionParams: descriptionParams,
      createdAt: createdAt,
      dismissed: dismissed ?? this.dismissed,
    );
  }
}
