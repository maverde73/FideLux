
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:fidelux/l10n/generated/app_localizations.dart';

import 'package:fidelux/data/local_db/app_database.dart' as db;
import '../../providers/accounting_providers.dart';

final inboxStreamProvider = StreamProvider<List<db.InboxMessage>>((ref) {
  final dao = ref.watch(inboxDaoProvider);
  return dao.watchPendingMessages();
});

class InboxScreen extends ConsumerWidget {
  const InboxScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = L.of(context)!;
    final messagesAsync = ref.watch(inboxStreamProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text('Inbox'), // Localize
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
               // Trigger FetchInbox use case manually?
               // ref.read(fetchInboxProvider).call();
            },
          ),
        ],
      ),
      body: messagesAsync.when(
        data: (messages) {
          if (messages.isEmpty) {
            return Center(child: Text(l10n.ledgerEmpty)); // Reuse "No transactions" or similar
          }
          return ListView.separated(
            itemCount: messages.length,
            separatorBuilder: (_, __) => const Divider(),
            itemBuilder: (context, index) {
              final msg = messages[index];
              // msg is Drift class `InboxMessage`.
              // It has fields: id, senderEmail, subject, status...
              
              return ListTile(
                leading: Icon(Icons.mark_email_read, color: Colors.green),
                title: Text(msg.subject ?? 'No Subject'),
                subtitle: Text(msg.senderEmail),
                trailing: Text(
                  _formatDate(msg.receivedAt), // Localize date
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                onTap: () {
                  // Navigate to ProcessMessageScreen
                  // Pass ID or Object. 
                  // GoRouter path: '/inbox/process/:id'
                  context.push('/inbox/process/${msg.id}');
                },
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
      ),
    );
  }
  
  String _formatDate(DateTime date) {
    return '${date.day}/${date.month} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }
}
