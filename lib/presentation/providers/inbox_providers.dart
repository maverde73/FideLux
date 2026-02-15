
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/email_auth_method.dart';
import '../../domain/entities/email_config.dart';
import '../../domain/entities/email_auth_state.dart';
import '../../domain/entities/inbox_message.dart';
import '../../application/email/fetch_inbox.dart';
import 'core_providers.dart';
import 'accounting_providers.dart';

// Repositories
import '../../domain/repositories/email_repository.dart';
import '../../data/email/email_auth_service.dart';
import '../../data/email/email_discovery_service.dart';
import '../../data/email/imap_email_service.dart';
import '../../data/email/message_validator.dart';

// --- DI ---

final messageValidatorProvider = Provider<MessageValidator>((ref) {
  return MessageValidator(
    ref.read(cryptoRepositoryProvider),
    ref.read(keyStorageRepositoryProvider),
  );
});

final emailAuthServiceProvider = Provider<EmailAuthService>((ref) {
  return EmailAuthService();
});

final emailDiscoveryServiceProvider = Provider<EmailDiscoveryService>((ref) {
  return EmailDiscoveryService();
});

final emailRepositoryProvider = Provider<EmailRepository>((ref) {
  return ImapEmailService(
    ref.read(emailAuthServiceProvider),
    const FlutterSecureStorage(),
    ref.read(messageValidatorProvider),
  );
});

// --- Email Auth State ---

final emailAuthStateProvider = FutureProvider<EmailAuthState>((ref) async {
  final authService = ref.read(emailAuthServiceProvider);
  final repo = ref.read(emailRepositoryProvider);

  final hasCredentials = await authService.hasCredentials();
  if (!hasCredentials) {
    return const EmailAuthState(status: EmailAuthStatus.disconnected);
  }

  final config = await repo.loadConfig();
  if (config == null) {
    return const EmailAuthState(status: EmailAuthStatus.disconnected);
  }

  final method = await authService.getAuthMethod();
  String providerName;
  switch (method) {
    case EmailAuthMethod.oauth2Gmail:
      providerName = 'Gmail';
      break;
    case EmailAuthMethod.oauth2Microsoft:
      providerName = 'Outlook';
      break;
    default:
      providerName = 'IMAP';
  }

  return EmailAuthState(
    status: EmailAuthStatus.connected,
    email: config.email,
    providerName: providerName,
    authMethod: method,
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
