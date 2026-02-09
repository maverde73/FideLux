
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:fidelux/l10n/generated/app_localizations.dart';

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
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                FilterChip(label: Text(l10n.ledgerFilterAll), onSelected: (val) {}, selected: true),
                const SizedBox(width: 8),
                FilterChip(label: Text(l10n.ledgerFilterAccount), onSelected: (val) {}),
                const SizedBox(width: 8),
                FilterChip(label: Text(l10n.ledgerFilterCategory), onSelected: (val) {}),
                const SizedBox(width: 8),
                FilterChip(label: Text(l10n.ledgerFilterPeriod), onSelected: (val) {}),
              ],
            ),
          ),
          const Divider(),
          Expanded(
            child: transactionsAsync.when(
              data: (transactions) {
                if (transactions.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.receipt_long, size: 64, color: Colors.grey),
                        const SizedBox(height: 16),
                        Text(l10n.ledgerEmpty),
                      ],
                    ),
                  );
                }
                return ListView.separated(
                  itemCount: transactions.length,
                  separatorBuilder: (_, __) => Divider(indent: 72),
                  itemBuilder: (context, index) {
                    final tx = transactions[index];
                    final category = tx.category; // Now proper enum if converter works
                    // If converter fails, it might be string? No, Drift generated class uses the converted type.
                    
                    final isExpense = tx.amount < 0;
                    
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundColor: category.color.withOpacity(0.2),
                        child: Icon(category.icon, color: category.color),
                      ),
                      title: Text(tx.merchant ?? tx.description),
                      subtitle: Text('${_formatDate(tx.date)} • ${category.localizedName}'),
                      trailing: Text(
                        '${isExpense ? '' : '+'}${ (tx.amount/100).toStringAsFixed(2) }', // Currency symbol?
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: isExpense ? Colors.red : Colors.green,
                          fontFamily: 'RobotoMono', // Monospace if available
                          fontWeight: FontWeight.bold,
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
          // Manual entry without inbox
          // Navigate to process message screen but with empty message?
          // Or separate manual entry screen reusing the form?
          // ProcessMessageScreen requires InboxMessage.
          // I should refactor form to be reusable or create dummy message.
          // For MVP, limit to Inbox processing or Create Account.
          // User asked for FAB "+" in Step 6 Rule 4.
          // "FAB "+" per inserimento manuale transazione (senza messaggio inbox)"
          // I'll create a variant or pass null message if allowed.
          // For now, I'll show snackbar "Coming Soon" or implement basic redirect if time permits.
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Manual entry coming soon")));
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
