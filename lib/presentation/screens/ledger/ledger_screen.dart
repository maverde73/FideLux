
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:fidelux/l10n/generated/app_localizations.dart';
import 'package:fidelux/presentation/widgets/empty_state_view.dart';
import 'package:fidelux/theme/fidelux_colors.dart';
import 'package:fidelux/theme/fidelux_spacing.dart';
import 'package:fidelux/theme/fidelux_theme.dart';

import '../../../data/local_db/app_database.dart';
import '../../providers/accounting_providers.dart';

// Stream provider for transactions
final recentTransactionsProvider = StreamProvider<List<Transaction>>((ref) {
  final dao = ref.watch(transactionsDaoProvider);
  return dao.watchRecentTransactions();
});

class LedgerScreen extends ConsumerWidget {
  const LedgerScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = L.of(context)!;
    final transactionsAsync = ref.watch(recentTransactionsProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.ledgerTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () {
              // TODO: Open filters
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Filter Chips (Horizontal Scroll)
          SizedBox(
            height: 50,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: FideLuxSpacing.s4),
              children: [
                FilterChip(label: Text(l10n.ledgerFilterAll), onSelected: (val) {}, selected: true),
                const SizedBox(width: FideLuxSpacing.s2),
                FilterChip(label: Text(l10n.ledgerFilterAccount), onSelected: (val) {}),
                const SizedBox(width: FideLuxSpacing.s2),
                FilterChip(label: Text(l10n.ledgerFilterCategory), onSelected: (val) {}),
                const SizedBox(width: FideLuxSpacing.s2),
                FilterChip(label: Text(l10n.ledgerFilterPeriod), onSelected: (val) {}),
              ],
            ),
          ),
          const Divider(),
          Expanded(
            child: transactionsAsync.when(
              data: (transactions) {
                if (transactions.isEmpty) {
                  return EmptyStateView(
                    icon: Icons.receipt_long_outlined,
                    title: l10n.emptyLedgerTitle,
                    body: l10n.emptyLedgerBody,
                    ctaLabel: l10n.emptyLedgerCta,
                    onCtaPressed: () => GoRouter.of(context).go('/inbox'),
                  );
                }
                return ListView.separated(
                  itemCount: transactions.length,
                  separatorBuilder: (_, __) => Divider(
                    indent: FideLuxSpacing.s16,
                    height: 1,
                  ),
                  itemBuilder: (context, index) {
                    final tx = transactions[index];
                    final category = tx.category;
                    final isExpense = tx.amount < 0;
                    
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundColor: category.color.withValues(alpha: 0.15),
                        child: Icon(category.icon, color: category.color),
                      ),
                      title: Text(tx.merchant ?? tx.description),
                      subtitle: Text('${_formatDate(tx.date)} • ${category.localizedName}'),
                      trailing: Text(
                        '${isExpense ? '' : '+'}${(tx.amount / 100).toStringAsFixed(2)}',
                        style: FideLuxFinancialStyles.transactionAmount.copyWith(
                          color: isExpense
                              ? FideLuxColors.error
                              : FideLuxColors.success,
                        ),
                      ),
                      onTap: () {
                        context.push('/ledger/detail/${tx.id}');
                      },
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, stack) => Center(child: Text('Error: $err')),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(l10n.ledgerManualEntrySoon)),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
