
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:fidelux/l10n/generated/app_localizations.dart';
import 'package:fidelux/presentation/widgets/empty_state_view.dart';
import 'package:fidelux/theme/fidelux_colors.dart';
import 'package:fidelux/theme/fidelux_spacing.dart';

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
        title: Text(l10n.tabInbox),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
               // Trigger FetchInbox use case manually
            },
          ),
        ],
      ),
      body: messagesAsync.when(
        data: (messages) {
          if (messages.isEmpty) {
            return EmptyStateView(
              icon: Icons.mail_outline,
              title: l10n.emptyInboxTitle,
              body: l10n.emptyInboxBody,
              ctaLabel: l10n.emptyInboxCta,
              onCtaPressed: () =>
                  GoRouter.of(context).go('/settings/email-config'),
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.symmetric(vertical: FideLuxSpacing.s2),
            itemCount: messages.length,
            separatorBuilder: (_, __) => const Divider(
              indent: FideLuxSpacing.s16,
              height: 1,
            ),
            itemBuilder: (context, index) {
              final msg = messages[index];

              return ListTile(
                leading: Icon(
                  Icons.mark_email_read,
                  color: FideLuxColors.inboxProcessed,
                ),
                title: Text(msg.subject ?? 'No Subject'),
                subtitle: Text(msg.senderEmail),
                trailing: Text(
                  _formatDate(msg.receivedAt),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
                onTap: () {
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
