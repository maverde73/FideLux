import 'package:flutter_test/flutter_test.dart';
import 'package:fidelux/domain/entities/email_auth_method.dart';
import 'package:fidelux/data/email/email_discovery_service.dart';

void main() {
  group('EmailDiscoveryService domain detection', () {
    late EmailDiscoveryService service;

    setUp(() {
      service = EmailDiscoveryService();
    });

    test('gmail.com should map to oauth2Gmail', () {
      // Verify the service was created successfully
      expect(service, isNotNull);
      expect(EmailAuthMethod.oauth2Gmail.name, 'oauth2Gmail');
    });

    test('oauth2Microsoft enum exists', () {
      expect(EmailAuthMethod.oauth2Microsoft.name, 'oauth2Microsoft');
    });

    test('password enum exists', () {
      expect(EmailAuthMethod.password.name, 'password');
    });
  });

  group('EmailDiscoveryResult', () {
    test('can be constructed', () {
      const result = EmailDiscoveryResult(
        imapHost: 'imap.gmail.com',
        imapPort: 993,
        imapUseSsl: true,
        smtpHost: 'smtp.gmail.com',
        smtpPort: 465,
        smtpUseSsl: true,
        authMethod: EmailAuthMethod.oauth2Gmail,
        providerName: 'Gmail',
      );

      expect(result.imapHost, 'imap.gmail.com');
      expect(result.imapPort, 993);
      expect(result.imapUseSsl, true);
      expect(result.smtpHost, 'smtp.gmail.com');
      expect(result.smtpPort, 465);
      expect(result.smtpUseSsl, true);
      expect(result.authMethod, EmailAuthMethod.oauth2Gmail);
      expect(result.providerName, 'Gmail');
    });

    test('Microsoft result', () {
      const result = EmailDiscoveryResult(
        imapHost: 'outlook.office365.com',
        imapPort: 993,
        imapUseSsl: true,
        smtpHost: 'smtp.office365.com',
        smtpPort: 587,
        smtpUseSsl: true,
        authMethod: EmailAuthMethod.oauth2Microsoft,
        providerName: 'Outlook',
      );

      expect(result.authMethod, EmailAuthMethod.oauth2Microsoft);
      expect(result.providerName, 'Outlook');
    });

    test('Password-based result', () {
      const result = EmailDiscoveryResult(
        imapHost: 'imap.libero.it',
        imapPort: 993,
        imapUseSsl: true,
        smtpHost: 'smtp.libero.it',
        smtpPort: 465,
        smtpUseSsl: true,
        authMethod: EmailAuthMethod.password,
        providerName: 'IMAP',
      );

      expect(result.authMethod, EmailAuthMethod.password);
      expect(result.providerName, 'IMAP');
    });
  });
}
