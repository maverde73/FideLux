
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fidelux/l10n/generated/app_localizations.dart';

import '../../../data/local_db/app_database.dart';
import '../../providers/accounting_providers.dart';

class TransactionDetailData {
  final Transaction transaction;
  final ChainEvent? chainEvent; // Drift class
  
  TransactionDetailData(this.transaction, this.chainEvent);
}

final transactionDetailProvider = FutureProvider.family<TransactionDetailData?, String>((ref, id) async {
  final txDao = ref.watch(transactionsDaoProvider);
  final chainDao = ref.watch(chainEventsDaoProvider);
  
  final tx = await txDao.getTransactionById(id);
  if (tx == null) return null;
  
  final event = await chainDao.getEventBySequence(tx.chainEventSequence);
  
  return TransactionDetailData(tx, event);
});

class TransactionDetailScreen extends ConsumerWidget {
  final String transactionId;

  const TransactionDetailScreen({super.key, required this.transactionId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = L.of(context)!;
    final dataAsync = ref.watch(transactionDetailProvider(transactionId));

    return Scaffold(
      appBar: AppBar(title: Text(l10n.transactionDetailTitle)),
      body: dataAsync.when(
        data: (data) {
          if (data == null) return const Center(child: Text("Transaction not found"));
          final tx = data.transaction;
          final event = data.chainEvent;
          final category = tx.category;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Amount
                Center(
                  child: Text(
                    '${tx.amount < 0 ? '' : '+'}${(tx.amount/100).toStringAsFixed(2)} €', // Localize currency
                    style: Theme.of(context).textTheme.displayMedium?.copyWith(
                      color: tx.amount < 0 ? Colors.red : Colors.green,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Center(child: Text(tx.merchant ?? tx.description, style: Theme.of(context).textTheme.titleLarge)),
                const SizedBox(height: 32),
                
                // Details Card
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        _detailRow(context, l10n.processMessageDate, '${tx.date.day}/${tx.date.month}/${tx.date.year}'),
                        const Divider(),
                        _detailRow(context, l10n.processMessageCategory, category.localizedName),
                        const Divider(),
                        _detailRow(context, l10n.processMessageAccount, 'Account ID: ${tx.accountId.substring(0,8)}...'), // Should fetch name
                        if (tx.notes != null && tx.notes!.isNotEmpty) ...[
                           const Divider(),
                           _detailRow(context, l10n.processMessageNotes, tx.notes!),
                        ],
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                
                // Chain Info
                Text(l10n.transactionDetailChainInfo, style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 8),
                Card(
                  color: Theme.of(context).colorScheme.surfaceVariant,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (event != null) ...[
                          Row(
                            children: [
                              const Icon(Icons.link, size: 20),
                              const SizedBox(width: 8),
                              Text(l10n.transactionDetailSequence(event.sequence.toString()), style: const TextStyle(fontWeight: FontWeight.bold)),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text('Hash: ${event.hash.substring(0, 16)}...', style: const TextStyle(fontFamily: 'RobotoMono', fontSize: 12)),
                          const SizedBox(height: 8),
                          if (event.sharerSignature != null)
                            Row(
                              children: [
                                const Icon(Icons.verified_user, color: Colors.green, size: 20),
                                const SizedBox(width: 8),
                                Text(l10n.transactionDetailSignatureVerified, style: const TextStyle(color: Colors.green)),
                              ],
                            ),
                          const SizedBox(height: 8),
                          Text('Metadata: ${event.metadataSource} (Trust: ${event.metadataTrustLevel})', style: Theme.of(context).textTheme.bodySmall),
                        ] else
                          const Text("Event data unavailable"),
                      ],
                    ),
                  ),
                ),
                
                const SizedBox(height: 32),
                Center(
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.help_outline),
                    label: Text(l10n.transactionDetailRequestClarification),
                    onPressed: () {
                      // Navigate to logic D04
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Coming in later modules")));
                    },
                  ),
                ),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
      ),
    );
  }

  Widget _detailRow(BuildContext context, String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey[600])),
        Text(value, style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500)),
      ],
    );
  }
}
