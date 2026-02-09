
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/email_config.dart';
import '../../domain/entities/inbox_message.dart';
import '../../application/email/fetch_inbox.dart';
import 'crypto_providers.dart'; // for secure storage and crypto repo

// Repositories
import '../../domain/repositories/email_repository.dart';
import '../../data/email/email_service.dart';
import '../../data/email/message_validator.dart';

// --- DI ---

final messageValidatorProvider = Provider<MessageValidator>((ref) {
  return MessageValidator(
    ref.read(cryptoRepositoryProvider),
    ref.read(keyStorageProvider),
  );
});

final emailRepositoryProvider = Provider<EmailRepository>((ref) {
  // requires secure storage from crypto_providers or direct?
  // we can use the same package.
  // We need `FlutterSecureStorage` instance. 
  // `keyStorageProvider` returns `KeyStorageRepository`.
  // We should probably expose `secureStorageProvider` if shared, or instantiate anew.
  // `SecureKeyStorage` instantiates `const FlutterSecureStorage()`.
  // Here `EmailService` expects `FlutterSecureStorage`.
  // We can just instantiate it.
  
  // Wait, `EmailService` needs `FlutterSecureStorage`.
  // And `MessageValidator`.
  
  // Since we haven't exposed `secureStorage` as a raw provider, we'll import it.
  // But importing it directly in provider definition means we need the package.
  // Better to instantiate it inside `EmailService` or pass it.
  // `EmailService` constructor takes it.
  
  // Let's create a raw provider for it if needed, or just allow `EmailService` to create it?
  // `EmailService` constructor signature: `EmailService(this._secureStorage, this._validator);`
  // So we need to pass it.
  // Importing `flutter_secure_storage` here.
  
  // Wait, `crypto_providers.dart` handles crypto stuff.
  // I will just import the package here.
  return EmailService(
    const FlutterSecureStorage(), 
    ref.read(messageValidatorProvider),
  );
});

// --- Use Cases ---

final fetchInboxUseCaseProvider = Provider<FetchInbox>((ref) {
  return FetchInbox(ref.read(emailRepositoryProvider));
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
    data: (msgs) => msgs.where((m) => m.status == MessageStatus.verified).length, // Logic: verified = processed? Or unread?
    // Directive says: "Contatore messaggi non letti"
    // Usually "verified" means "ready to be processed".
    // "processed" means "accounted for".
    // So "verified" count is likely appropriate for unread/actionable items.
    orElse: () => 0,
  );
});
