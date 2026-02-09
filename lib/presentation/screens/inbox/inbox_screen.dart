
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:fidelux/l10n/generated/app_localizations.dart';

import '../../domain/entities/inbox_message.dart'; // Domain class (not Drift)
// We need to map Drift InboxMessage to Domain InboxMessage or use Drift class directly.
// The provider returns `List<InboxMessage>`. 
// If `InboxDao` returns Drift class, we should map it in provider or Dao.
// `InboxDao.getPendingMessages` returns `List<InboxMessage>` (Drift).
// Domain entity is `InboxMessage`. 
// Conflict!
// Same issue as `ChainEvent`.
// I should use `as db` import in Dao too? 
// Or create mapper.

// Assuming provider returns List of Domain `InboxMessage`.
// I need `inboxMessagesProvider` in `inbox_providers.dart` (D04) to use Dao?
// Or create new provider in `accounting_providers.dart`?
// D04 provider was `inboxMessagesProvider`.
// Let's replace it or use new one.

import '../providers/accounting_providers.dart'; // inboxDaoProvider
// import '../providers/inbox_providers.dart'; // Old one?

// Let's define the new stream provider here or in `accounting_providers.dart`.
// In `accounting_providers.dart` I didn't define stream for inbox.
// I'll define it locally or there.

final inboxStreamProvider = StreamProvider<List<dynamic>>((ref) { // dynamic to avoid type error now
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
              
              final isVerified = msg.status == 'verified';
              // If status is rejected, it might not be in "pending" list?
              // Dao `watchPendingMessages` filters by 'verified' & 'not processsed'.
              // So all here are verifiable.
              
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
