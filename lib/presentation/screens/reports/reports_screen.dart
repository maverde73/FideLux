import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fidelux/l10n/generated/app_localizations.dart';
import 'package:fidelux/presentation/providers/report_providers.dart';
import 'package:fidelux/domain/entities/report_data.dart';
import 'package:fidelux/domain/entities/transaction_category.dart';
import 'package:fidelux/core/utils/currency_formatter.dart';
import 'package:fidelux/theme/fidelux_colors.dart';
import 'package:fidelux/theme/fidelux_spacing.dart';
import 'package:fidelux/theme/fidelux_radius.dart';

class ReportsScreen extends ConsumerWidget {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = L.of(context)!;
    final reportAsync = ref.watch(reportDataProvider);
    final selectedPeriod = ref.watch(selectedPeriodProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.reportsTitle)),
      body: Column(
        children: [
          _buildPeriodSelector(context, ref, selectedPeriod, l10n),
          Expanded(
            child: reportAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text(e.toString())),
              data: (data) {
                if (data.totalExpenses == 0 && data.totalIncome == 0) {
                  return _buildEmptyState(context, l10n);
                }
                return _buildReport(context, data, l10n);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPeriodSelector(
    BuildContext context,
    WidgetRef ref,
    ReportPeriod selected,
    L l10n,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: FideLuxSpacing.s3,
        vertical: FideLuxSpacing.s2,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _periodChip(context, ref, l10n.reportsPeriodMonth, ReportPeriod.month, selected),
          const SizedBox(width: FideLuxSpacing.s2),
          _periodChip(context, ref, l10n.reportsPeriodQuarter, ReportPeriod.quarter, selected),
          const SizedBox(width: FideLuxSpacing.s2),
          _periodChip(context, ref, l10n.reportsPeriodYear, ReportPeriod.year, selected),
        ],
      ),
    );
  }

  Widget _periodChip(
    BuildContext context,
    WidgetRef ref,
    String label,
    ReportPeriod period,
    ReportPeriod selected,
  ) {
    return ChoiceChip(
      label: Text(label),
      selected: period == selected,
      onSelected: (_) {
        ref.read(selectedPeriodProvider.notifier).state = period;
      },
    );
  }

  Widget _buildEmptyState(BuildContext context, L l10n) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.bar_chart_outlined,
            size: 64,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
          const SizedBox(height: FideLuxSpacing.s4),
          Text(
            l10n.reportsInsufficientData,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildReport(BuildContext context, ReportData data, L l10n) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(FideLuxSpacing.s4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (data.categoryBreakdown.isNotEmpty) ...[
            _buildDonutSection(context, l10n, data),
            const SizedBox(height: FideLuxSpacing.s6),
          ],
          if (data.dailyTotals.isNotEmpty) ...[
            _buildBarChartSection(context, l10n, data),
            const SizedBox(height: FideLuxSpacing.s6),
          ],
          if (data.monthlyComparison.length >= 2) ...[
            _buildMonthlyComparison(context, l10n, data),
            const SizedBox(height: FideLuxSpacing.s6),
          ],
          if (data.topMerchants.isNotEmpty) ...[
            _buildTopMerchants(context, l10n, data),
            const SizedBox(height: FideLuxSpacing.s6),
          ],
          _buildExportButton(context, l10n),
          const SizedBox(height: FideLuxSpacing.s8),
        ],
      ),
    );
  }

  // ── Donut Chart Section ──

  Widget _buildDonutSection(BuildContext context, L l10n, ReportData data) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n.reportsCategoryBreakdown, style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: FideLuxSpacing.s4),
        Center(
          child: SizedBox(
            width: 200,
            height: 200,
            child: Stack(
              alignment: Alignment.center,
              children: [
                CustomPaint(
                  size: const Size(200, 200),
                  painter: _DonutChartPainter(
                    categoryBreakdown: data.categoryBreakdown,
                    totalExpenses: data.totalExpenses,
                  ),
                ),
                Text(
                  CurrencyFormatter.format(data.totalExpenses / 100),
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: FideLuxSpacing.s4),
        _buildDonutLegend(context, data),
      ],
    );
  }

  Widget _buildDonutLegend(BuildContext context, ReportData data) {
    final sorted = data.categoryBreakdown.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Column(
      children: sorted.map((entry) {
        final pct = data.totalExpenses > 0
            ? (entry.value / data.totalExpenses * 100).round()
            : 0;
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 2),
          child: Row(
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: entry.key.color,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: FideLuxSpacing.s2),
              Expanded(
                child: Text(
                  entry.key.localizedName,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
              Text(
                CurrencyFormatter.format(entry.value / 100),
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(width: FideLuxSpacing.s2),
              SizedBox(
                width: 36,
                child: Text(
                  '$pct%',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                  textAlign: TextAlign.end,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  // ── Bar Chart Section ──

  Widget _buildBarChartSection(BuildContext context, L l10n, ReportData data) {
    final sortedDays = data.dailyTotals.keys.toList()..sort();
    final maxValue = data.dailyTotals.values.map((v) => v.abs()).reduce(max);
    final chartWidth = sortedDays.length * 12.0 + 50;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n.reportsDailyTrend, style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: FideLuxSpacing.s4),
        SizedBox(
          height: 200,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: SizedBox(
              width: max(chartWidth, MediaQuery.of(context).size.width - 32),
              height: 200,
              child: CustomPaint(
                painter: _BarChartPainter(
                  dailyTotals: data.dailyTotals,
                  maxValue: maxValue,
                  barColor: FideLuxColors.error,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ── Monthly Comparison ──

  Widget _buildMonthlyComparison(BuildContext context, L l10n, ReportData data) {
    final months = data.monthlyComparison;
    const monthNames = [
      '', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n.reportsMonthlyComparison, style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: FideLuxSpacing.s3),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: months.asMap().entries.map((mapEntry) {
              final i = mapEntry.key;
              final m = mapEntry.value;
              final prevExpenses = i + 1 < months.length ? months[i + 1].expenses : null;

              return Padding(
                padding: const EdgeInsets.only(right: FideLuxSpacing.s3),
                child: Card(
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
                          '${monthNames[m.month]} ${m.year}',
                          style: Theme.of(context).textTheme.titleSmall,
                        ),
                        const SizedBox(height: FideLuxSpacing.s2),
                        Row(
                          children: [
                            const Icon(Icons.trending_down, size: 14, color: FideLuxColors.error),
                            const SizedBox(width: 4),
                            Text(
                              CurrencyFormatter.format(m.expenses / 100),
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(Icons.trending_up, size: 14, color: FideLuxColors.success),
                            const SizedBox(width: 4),
                            Text(
                              CurrencyFormatter.format(m.income / 100),
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ],
                        ),
                        if (prevExpenses != null && prevExpenses > 0) ...[
                          const SizedBox(height: FideLuxSpacing.s2),
                          _buildVariation(context, m.expenses, prevExpenses),
                        ],
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildVariation(BuildContext context, int current, int previous) {
    final change = ((current - previous) / previous * 100).round();
    final isIncrease = change > 0;
    final color = isIncrease ? FideLuxColors.error : FideLuxColors.success;
    final arrow = isIncrease ? '▲' : '▼';

    return Text(
      '$arrow ${change.abs()}%',
      style: Theme.of(context).textTheme.bodySmall?.copyWith(
        color: color,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  // ── Top Merchants ──

  Widget _buildTopMerchants(BuildContext context, L l10n, ReportData data) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n.reportsTopMerchants, style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: FideLuxSpacing.s2),
        ...data.topMerchants.map((m) => ListTile(
          contentPadding: EdgeInsets.zero,
          leading: CircleAvatar(
            backgroundColor: FideLuxColors.primaryContainer,
            child: Text(
              m.merchant.isNotEmpty ? m.merchant[0].toUpperCase() : '?',
              style: const TextStyle(color: FideLuxColors.onPrimaryContainer),
            ),
          ),
          title: Text(m.merchant),
          subtitle: Text(l10n.reportsTransactions(m.transactionCount.toString())),
          trailing: Text(
            CurrencyFormatter.format(m.totalAmount / 100),
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        )),
      ],
    );
  }

  // ── Export Button ──

  Widget _buildExportButton(BuildContext context, L l10n) {
    return Center(
      child: FilledButton.tonal(
        onPressed: null, // Disabled
        child: Text(l10n.reportsExportComingSoon),
      ),
    );
  }
}

// ── CustomPainters ──

class _DonutChartPainter extends CustomPainter {
  final Map<TransactionCategory, int> categoryBreakdown;
  final int totalExpenses;

  _DonutChartPainter({required this.categoryBreakdown, required this.totalExpenses});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 15;
    const strokeWidth = 30.0;

    final rect = Rect.fromCircle(center: center, radius: radius);

    if (totalExpenses == 0) {
      final paint = Paint()
        ..color = Colors.grey.shade300
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth;
      canvas.drawArc(rect, 0, 2 * pi, false, paint);
      return;
    }

    double startAngle = -pi / 2;

    for (final entry in categoryBreakdown.entries) {
      final sweepAngle = (entry.value / totalExpenses) * 2 * pi;
      if (sweepAngle < 0.01) continue;

      final paint = Paint()
        ..color = entry.key.color
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.butt;
      canvas.drawArc(rect, startAngle, sweepAngle, false, paint);
      startAngle += sweepAngle;
    }
  }

  @override
  bool shouldRepaint(covariant _DonutChartPainter oldDelegate) {
    return oldDelegate.totalExpenses != totalExpenses ||
        oldDelegate.categoryBreakdown != categoryBreakdown;
  }
}

class _BarChartPainter extends CustomPainter {
  final Map<DateTime, int> dailyTotals;
  final int maxValue;
  final Color barColor;

  _BarChartPainter({
    required this.dailyTotals,
    required this.maxValue,
    required this.barColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (dailyTotals.isEmpty || maxValue == 0) return;

    const barWidth = 8.0;
    const gap = 4.0;
    const bottomPadding = 24.0;
    const leftPadding = 44.0;

    final chartHeight = size.height - bottomPadding;

    // Y-axis labels
    final yLabelPaint = TextPainter(textDirection: TextDirection.ltr);
    for (int i = 0; i <= 4; i++) {
      final value = (maxValue / 100 * (4 - i) / 4).round();
      final y = chartHeight * i / 4;
      yLabelPaint.text = TextSpan(
        text: '€$value',
        style: const TextStyle(fontSize: 9, color: Colors.grey),
      );
      yLabelPaint.layout();
      yLabelPaint.paint(canvas, Offset(0, y - 5));

      // Grid line
      final linePaint = Paint()
        ..color = Colors.grey.shade200
        ..strokeWidth = 0.5;
      canvas.drawLine(
        Offset(leftPadding, y),
        Offset(size.width, y),
        linePaint,
      );
    }

    // Bars
    final sortedDays = dailyTotals.keys.toList()..sort();
    for (int i = 0; i < sortedDays.length; i++) {
      final day = sortedDays[i];
      final value = dailyTotals[day]!.abs();
      final barHeight = (value / maxValue) * chartHeight;

      final x = leftPadding + i * (barWidth + gap);
      final y = chartHeight - barHeight;

      final paint = Paint()..color = barColor;
      canvas.drawRRect(
        RRect.fromRectAndCorners(
          Rect.fromLTWH(x, y, barWidth, barHeight),
          topLeft: const Radius.circular(2),
          topRight: const Radius.circular(2),
        ),
        paint,
      );

      // Day label
      if (day.day == 1 || day.day % 5 == 0) {
        final dayPaint = TextPainter(textDirection: TextDirection.ltr);
        dayPaint.text = TextSpan(
          text: day.day.toString(),
          style: const TextStyle(fontSize: 9, color: Colors.grey),
        );
        dayPaint.layout();
        dayPaint.paint(canvas, Offset(x + barWidth / 2 - dayPaint.width / 2, chartHeight + 4));
      }
    }
  }

  @override
  bool shouldRepaint(covariant _BarChartPainter oldDelegate) {
    return oldDelegate.dailyTotals != dailyTotals || oldDelegate.maxValue != maxValue;
  }
}
