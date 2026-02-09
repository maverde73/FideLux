
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/email_config.dart';
import '../../domain/entities/inbox_message.dart';
import '../../application/email/fetch_inbox.dart';
import 'core_providers.dart';
import 'accounting_providers.dart';

// Repositories
import '../../domain/repositories/email_repository.dart';
import '../../data/email/email_service.dart';
import '../../data/email/message_validator.dart';

// --- DI ---

final messageValidatorProvider = Provider<MessageValidator>((ref) {
  return MessageValidator(
    ref.read(cryptoRepositoryProvider),
    ref.read(keyStorageRepositoryProvider),
  );
});

final emailRepositoryProvider = Provider<EmailRepository>((ref) {
  return EmailService(
    const FlutterSecureStorage(),
    ref.read(messageValidatorProvider),
  );
});

// --- Use Cases ---

final fetchInboxUseCaseProvider = Provider<FetchInbox>((ref) {
  return FetchInbox(ref.read(emailRepositoryProvider), ref.read(inboxDaoProvider));
});

// --- Config State ---

final emailConfigProvider = FutureProvider<EmailConfig?>((ref) async {
  final repo = ref.read(emailRepositoryProvider);
  return await repo.loadConfig();
});

// --- Inbox State ---

final inboxMessagesProvider = FutureProvider<List<InboxMessage>>((ref) async {
  final fetch = ref.read(fetchInboxUseCaseProvider);
  return await fetch.call();
});

final unreadCountProvider = Provider<int>((ref) {
  return ref.watch(inboxMessagesProvider).maybeWhen(
    data: (msgs) => msgs.where((m) => m.status == MessageStatus.verified).length,
    orElse: () => 0,
  );
});
