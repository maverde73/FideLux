import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fidelux/l10n/generated/app_localizations.dart';
import 'package:fidelux/presentation/providers/dashboard_providers.dart';
import 'package:fidelux/domain/entities/dashboard_data.dart';
import 'package:fidelux/core/utils/currency_formatter.dart';
import 'package:fidelux/theme/fidelux_colors.dart';
import 'package:fidelux/theme/fidelux_spacing.dart';
import 'package:fidelux/theme/fidelux_radius.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dashboardAsync = ref.watch(dashboardDataProvider);
    final l10n = L.of(context)!;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.dashboardTitle)),
      body: dashboardAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text(e.toString())),
        data: (data) {
          if (data.transactionCount == 0 && data.totalBalance == 0) {
            return _buildEmptyState(context, l10n);
          }
          return RefreshIndicator(
            onRefresh: () async => ref.invalidate(dashboardDataProvider),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(FideLuxSpacing.s4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildScoreCard(context, l10n, data),
                  const SizedBox(height: FideLuxSpacing.s4),
                  if (data.activeAlerts.isNotEmpty) ...[
                    _buildAlertSection(context, ref, l10n, data.activeAlerts),
                    const SizedBox(height: FideLuxSpacing.s4),
                  ],
                  _buildKpiGrid(context, l10n, data),
                  const SizedBox(height: FideLuxSpacing.s4),
                  _buildDocumentationRate(context, l10n, data),
                  const SizedBox(height: FideLuxSpacing.s4),
                  if (data.categoryBreakdown.isNotEmpty)
                    _buildTopCategories(context, l10n, data),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, L l10n) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.dashboard_outlined,
            size: 64,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
          const SizedBox(height: FideLuxSpacing.s4),
          Text(
            l10n.dashboardNoData,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScoreCard(BuildContext context, L l10n, DashboardData data) {
    final scoreColor = _scoreColor(data.scoreLevel);
    final scoreLabel = _scoreLabel(l10n, data.scoreLevel);
    final trendWidget = _trendWidget(data.scoreTrend);

    return Card(
      color: FideLuxColors.scoreBackground,
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(FideLuxRadius.md),
      ),
      child: Padding(
        padding: const EdgeInsets.all(FideLuxSpacing.s4),
        child: Column(
          children: [
            Text(
              l10n.dashboardScore,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: FideLuxSpacing.s2),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  data.fideluxScore.toString(),
                  style: Theme.of(context).textTheme.displayMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: scoreColor,
                  ),
                ),
                const SizedBox(width: FideLuxSpacing.s2),
                trendWidget,
              ],
            ),
            const SizedBox(height: FideLuxSpacing.s1),
            Text(
              scoreLabel,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: scoreColor,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: FideLuxSpacing.s3),
            ClipRRect(
              borderRadius: BorderRadius.circular(FideLuxRadius.full),
              child: LinearProgressIndicator(
                value: data.fideluxScore / 100,
                minHeight: 8,
                backgroundColor: FideLuxColors.surfaceVariant,
                valueColor: AlwaysStoppedAnimation(scoreColor),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAlertSection(
    BuildContext context,
    WidgetRef ref,
    L l10n,
    List<ActiveAlert> alerts,
  ) {
    final visibleAlerts = alerts.where((a) => !a.dismissed).toList();
    if (visibleAlerts.isEmpty) return const SizedBox.shrink();

    final showAlerts = visibleAlerts.take(3).toList();
    final remaining = visibleAlerts.length - 3;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.dashboardAlerts,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: FideLuxSpacing.s2),
        ...showAlerts.map((alert) => Padding(
          padding: const EdgeInsets.only(bottom: FideLuxSpacing.s2),
          child: _buildAlertCard(context, ref, l10n, alert),
        )),
        if (remaining > 0)
          Center(
            child: TextButton(
              onPressed: () {}, // Expand to show all
              child: Text(l10n.dashboardShowMoreAlerts(remaining.toString())),
            ),
          ),
      ],
    );
  }

  Widget _buildAlertCard(
    BuildContext context,
    WidgetRef ref,
    L l10n,
    ActiveAlert alert,
  ) {
    final borderColor = _alertColor(alert.level);
    final icon = _alertIcon(alert.level);

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(FideLuxRadius.sm),
        side: const BorderSide(color: FideLuxColors.outlineVariant),
      ),
      child: Container(
        decoration: BoxDecoration(
          border: Border(left: BorderSide(color: borderColor, width: 4)),
          borderRadius: BorderRadius.circular(FideLuxRadius.sm),
        ),
        padding: const EdgeInsets.all(FideLuxSpacing.s3),
        child: Row(
          children: [
            Icon(icon, color: borderColor, size: 24),
            const SizedBox(width: FideLuxSpacing.s3),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _alertTitle(l10n, alert.level),
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _resolveAlertDescription(l10n, alert),
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
            if (alert.level == AlertLevel.advisory)
              IconButton(
                icon: const Icon(Icons.close, size: 18),
                onPressed: () {
                  ref.read(dashboardRepositoryProvider).dismissAlert(alert.id);
                  ref.invalidate(dashboardDataProvider);
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildKpiGrid(BuildContext context, L l10n, DashboardData data) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: FideLuxSpacing.s3,
      crossAxisSpacing: FideLuxSpacing.s3,
      childAspectRatio: 1.5,
      children: [
        _buildKpiCard(
          context,
          title: l10n.dashboardTotalBalance,
          value: CurrencyFormatter.format(data.totalBalance / 100),
          icon: Icons.account_balance,
          iconColor: Theme.of(context).colorScheme.primary,
        ),
        _buildKpiCard(
          context,
          title: l10n.dashboardMonthExpenses,
          value: CurrencyFormatter.format(data.monthExpenses / 100),
          icon: Icons.trending_down,
          iconColor: FideLuxColors.error,
        ),
        _buildKpiCard(
          context,
          title: l10n.dashboardMonthIncome,
          value: CurrencyFormatter.format(data.monthIncome / 100),
          icon: Icons.trending_up,
          iconColor: FideLuxColors.success,
        ),
        _buildKpiCard(
          context,
          title: l10n.dashboardTransactions,
          value: data.transactionCount.toString(),
          icon: Icons.receipt_long,
          iconColor: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
      ],
    );
  }

  Widget _buildKpiCard(
    BuildContext context, {
    required String title,
    required String value,
    required IconData icon,
    required Color iconColor,
  }) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(FideLuxRadius.md),
      ),
      child: Padding(
        padding: const EdgeInsets.all(FideLuxSpacing.s4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              children: [
                Icon(icon, size: 20, color: iconColor),
                const SizedBox(width: FideLuxSpacing.s2),
                Expanded(
                  child: Text(
                    title,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: FideLuxSpacing.s2),
            Text(
              value,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDocumentationRate(BuildContext context, L l10n, DashboardData data) {
    final rateColor = data.documentationRate > 0.7
        ? FideLuxColors.scoreHigh
        : (data.documentationRate > 0.4 ? FideLuxColors.scoreMedium : FideLuxColors.scoreLow);

    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(FideLuxRadius.md),
      ),
      child: Padding(
        padding: const EdgeInsets.all(FideLuxSpacing.s4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.dashboardDocumentationRate,
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: FideLuxSpacing.s1),
            Text(
              l10n.dashboardDocumentationDays(
                data.documentedDays.toString(),
                data.totalDays.toString(),
              ),
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: FideLuxSpacing.s2),
            ClipRRect(
              borderRadius: BorderRadius.circular(FideLuxRadius.full),
              child: LinearProgressIndicator(
                value: data.documentationRate,
                minHeight: 8,
                backgroundColor: FideLuxColors.surfaceVariant,
                valueColor: AlwaysStoppedAnimation(rateColor),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopCategories(BuildContext context, L l10n, DashboardData data) {
    final sorted = data.categoryBreakdown.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final top5 = sorted.take(5).toList();
    if (top5.isEmpty) return const SizedBox.shrink();

    final maxAmount = top5.first.value;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              l10n.dashboardTopCategories,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            TextButton(
              onPressed: () {}, // Navigate to Reports tab
              child: Text(l10n.dashboardViewAll),
            ),
          ],
        ),
        const SizedBox(height: FideLuxSpacing.s2),
        ...top5.map((entry) => Padding(
          padding: const EdgeInsets.only(bottom: FideLuxSpacing.s3),
          child: Row(
            children: [
              Icon(entry.key.icon, size: 20, color: entry.key.color),
              const SizedBox(width: FideLuxSpacing.s2),
              SizedBox(
                width: 80,
                child: Text(
                  entry.key.localizedName,
                  style: Theme.of(context).textTheme.bodySmall,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: FideLuxSpacing.s2),
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(FideLuxRadius.sm),
                  child: LinearProgressIndicator(
                    value: maxAmount > 0 ? entry.value / maxAmount : 0,
                    minHeight: 12,
                    backgroundColor: FideLuxColors.surfaceVariant,
                    valueColor: AlwaysStoppedAnimation(entry.key.color),
                  ),
                ),
              ),
              const SizedBox(width: FideLuxSpacing.s2),
              Text(
                CurrencyFormatter.format(entry.value / 100),
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        )),
      ],
    );
  }

  // ── Helpers ──

  Color _scoreColor(ScoreLevel level) {
    switch (level) {
      case ScoreLevel.high:
        return FideLuxColors.scoreHigh;
      case ScoreLevel.medium:
        return FideLuxColors.scoreMedium;
      case ScoreLevel.low:
        return FideLuxColors.scoreLow;
    }
  }

  String _scoreLabel(L l10n, ScoreLevel level) {
    switch (level) {
      case ScoreLevel.high:
        return l10n.dashboardScoreHigh;
      case ScoreLevel.medium:
        return l10n.dashboardScoreMedium;
      case ScoreLevel.low:
        return l10n.dashboardScoreLow;
    }
  }

  Widget _trendWidget(ScoreTrend trend) {
    switch (trend) {
      case ScoreTrend.up:
        return const Text('▲', style: TextStyle(color: FideLuxColors.scoreHigh, fontSize: 20));
      case ScoreTrend.down:
        return const Text('▼', style: TextStyle(color: FideLuxColors.scoreLow, fontSize: 20));
      case ScoreTrend.stable:
        return const Text('►', style: TextStyle(color: FideLuxColors.onSurfaceVariant, fontSize: 20));
    }
  }

  Color _alertColor(AlertLevel level) {
    switch (level) {
      case AlertLevel.normal:
        return FideLuxColors.success;
      case AlertLevel.advisory:
        return FideLuxColors.warning;
      case AlertLevel.critical:
        return FideLuxColors.error;
      case AlertLevel.sos:
        return FideLuxColors.alertSos;
    }
  }

  IconData _alertIcon(AlertLevel level) {
    switch (level) {
      case AlertLevel.normal:
        return Icons.check_circle_outline;
      case AlertLevel.advisory:
        return Icons.info_outline;
      case AlertLevel.critical:
        return Icons.warning_amber;
      case AlertLevel.sos:
        return Icons.sos;
    }
  }

  String _alertTitle(L l10n, AlertLevel level) {
    switch (level) {
      case AlertLevel.normal:
        return 'OK';
      case AlertLevel.advisory:
        return l10n.alertAdvisory;
      case AlertLevel.critical:
        return l10n.alertCritical;
      case AlertLevel.sos:
        return l10n.alertSos;
    }
  }

  String _resolveAlertDescription(L l10n, ActiveAlert alert) {
    switch (alert.descriptionKey) {
      case 'alertCategorySpike':
        return l10n.alertCategorySpike(
          alert.descriptionParams['category'] ?? '',
          alert.descriptionParams['percent'] ?? '',
        );
      case 'alertNoDocumentation':
        return l10n.alertNoDocumentation(
          alert.descriptionParams['days'] ?? '',
        );
      case 'alertMultipleCashWithdrawals':
        return l10n.alertMultipleCashWithdrawals(
          alert.descriptionParams['count'] ?? '',
        );
      case 'alertGamblingDetected':
        return l10n.alertGamblingDetected;
      case 'alertSosReceived':
        return l10n.alertSosReceived;
      default:
        return alert.descriptionKey;
    }
  }
}
