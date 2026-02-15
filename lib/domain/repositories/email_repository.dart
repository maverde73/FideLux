
import '../entities/email_config.dart';
import '../entities/inbox_message.dart';

abstract class EmailRepository {
  /// Configures the email connection (saving config securely).
  Future<void> configure(EmailConfig config);

  /// Fetches new messages from the inbox.
  Future<List<InboxMessage>> fetchNewMessages();

  /// Checks if email is configured.
  Future<bool> isConfigured();

  /// Loads the current configuration.
  Future<EmailConfig?> loadConfig();

  /// Clears the configuration.
  Future<void> clearConfig();

  /// Tests the IMAP connection with current credentials.
  Future<bool> testConnection();
}
