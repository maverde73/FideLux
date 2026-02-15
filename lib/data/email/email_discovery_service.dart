import 'package:enough_mail_discovery/enough_mail_discovery.dart';
import 'package:flutter/foundation.dart';

import '../../domain/entities/email_auth_method.dart';

class EmailDiscoveryResult {
  final String imapHost;
  final int imapPort;
  final bool imapUseSsl;
  final String smtpHost;
  final int smtpPort;
  final bool smtpUseSsl;
  final EmailAuthMethod authMethod;
  final String providerName;

  const EmailDiscoveryResult({
    required this.imapHost,
    required this.imapPort,
    required this.imapUseSsl,
    required this.smtpHost,
    required this.smtpPort,
    required this.smtpUseSsl,
    required this.authMethod,
    required this.providerName,
  });
}

class EmailDiscoveryService {
  static const _gmailDomains = {'gmail.com', 'googlemail.com'};
  static const _microsoftDomains = {
    'outlook.com',
    'hotmail.com',
    'live.com',
    'outlook.it',
    'hotmail.it',
    'live.it',
  };

  /// Discovers IMAP/SMTP server configuration for the given email address.
  Future<EmailDiscoveryResult> discover(String email) async {
    final domain = email.split('@').last.toLowerCase();
    final authMethod = _detectAuthMethod(domain);
    final providerName = _detectProviderName(domain);

    debugPrint('[DISCOVERY] Discovering for email=$email, domain=$domain');
    debugPrint('[DISCOVERY] Detected: provider=$providerName, authMethod=${authMethod.name}');

    final config = await Discover.discover(email, forceSslConnection: true);
    if (config == null) {
      debugPrint('[DISCOVERY] FAILED: No config discovered for $domain');
      throw Exception(
        'Could not discover email settings for $domain. '
        'Manual configuration is not yet supported.',
      );
    }

    final imapServer = config.preferredIncomingImapServer;
    final smtpServer = config.preferredOutgoingSmtpServer;

    debugPrint('[DISCOVERY] IMAP: ${imapServer?.hostname}:${imapServer?.port} (SSL=${imapServer?.isSecureSocket})');
    debugPrint('[DISCOVERY] SMTP: ${smtpServer?.hostname}:${smtpServer?.port} (SSL=${smtpServer?.isSecureSocket})');

    if (imapServer == null || smtpServer == null) {
      debugPrint('[DISCOVERY] FAILED: Missing IMAP or SMTP server');
      throw Exception(
        'No IMAP/SMTP server found for $domain.',
      );
    }

    final result = EmailDiscoveryResult(
      imapHost: imapServer.hostname ?? '',
      imapPort: imapServer.port ?? 993,
      imapUseSsl: imapServer.isSecureSocket,
      smtpHost: smtpServer.hostname ?? '',
      smtpPort: smtpServer.port ?? 465,
      smtpUseSsl: smtpServer.isSecureSocket,
      authMethod: authMethod,
      providerName: providerName,
    );
    debugPrint('[DISCOVERY] SUCCESS: ${result.imapHost}:${result.imapPort}');
    return result;
  }

  EmailAuthMethod _detectAuthMethod(String domain) {
    if (_gmailDomains.contains(domain)) return EmailAuthMethod.oauth2Gmail;
    // Microsoft personal accounts don't support IMAP OAuth2 via custom apps.
    // Use app password instead.
    return EmailAuthMethod.password;
  }

  String _detectProviderName(String domain) {
    if (_gmailDomains.contains(domain)) return 'Gmail';
    if (_microsoftDomains.contains(domain)) return 'Outlook';
    return 'IMAP';
  }
}
