class EmailConfig {
  final String imapHost;
  final int imapPort;
  final String smtpHost;
  final int smtpPort;
  final String email;
  final String password; // Should be handled securely
  final bool useSsl;
  final int pollingIntervalSeconds;
  final String sharerEmail;

  const EmailConfig({
    required this.imapHost,
    this.imapPort = 993,
    required this.smtpHost,
    this.smtpPort = 465,
    required this.email,
    required this.password,
    this.useSsl = true,
    this.pollingIntervalSeconds = 300,
    required this.sharerEmail,
  });
}
