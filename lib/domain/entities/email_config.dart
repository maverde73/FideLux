import 'email_auth_method.dart';

class EmailConfig {
  final String email;
  final String sharerEmail;
  final int pollingIntervalSeconds;
  final String imapHost;
  final int imapPort;
  final bool imapUseSsl;
  final String smtpHost;
  final int smtpPort;
  final bool smtpUseSsl;
  final EmailAuthMethod authMethod;

  const EmailConfig({
    required this.email,
    required this.sharerEmail,
    this.pollingIntervalSeconds = 300,
    required this.imapHost,
    required this.imapPort,
    this.imapUseSsl = true,
    required this.smtpHost,
    required this.smtpPort,
    this.smtpUseSsl = true,
    required this.authMethod,
  });
}
