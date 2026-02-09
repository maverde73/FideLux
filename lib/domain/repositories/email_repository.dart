
import '../entities/email_config.dart';
import '../entities/inbox_message.dart';

abstract class EmailRepository {
  /// Configures the email connection (saving credentials securely).
  Future<void> configure(EmailConfig config);

  /// Tests the connection to IMAP and SMTP servers.
  Future<bool> testConnection(EmailConfig config);

  /// Fetches new messages from the inbox.
  Future<List<InboxMessage>> fetchNewMessages();

  /// Marks a message as read or processed on the server.
  Future<void> markAsRead(String emailMessageId);

  /// Sends a message (e.g., clarification request).
  Future<void> sendMessage({
    required String to,
    required String subject,
    required String body,
    String? keeperSignature,
  });

  /// Checks if email is configured.
  Future<bool> isConfigured();

  /// Loads the current configuration.
  Future<EmailConfig?> loadConfig();

  /// Clears the configuration.
  Future<void> clearConfig();
}
