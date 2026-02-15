import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'package:fidelux/data/email/email_auth_service.dart';
import 'package:fidelux/data/email/imap_email_service.dart';
import 'package:fidelux/data/email/message_validator.dart';
import 'package:fidelux/domain/entities/email_auth_method.dart';
import 'package:fidelux/domain/entities/email_config.dart';

@GenerateMocks([EmailAuthService, FlutterSecureStorage, MessageValidator])
import 'imap_email_service_test.mocks.dart';

void main() {
  late ImapEmailService service;
  late MockEmailAuthService mockAuthService;
  late MockFlutterSecureStorage mockStorage;
  late MockMessageValidator mockValidator;

  setUp(() {
    mockAuthService = MockEmailAuthService();
    mockStorage = MockFlutterSecureStorage();
    mockValidator = MockMessageValidator();
    service = ImapEmailService(mockAuthService, mockStorage, mockValidator);
  });

  group('isConfigured', () {
    test('returns false when no email in storage', () async {
      when(mockStorage.containsKey(key: 'email_config_email'))
          .thenAnswer((_) async => false);

      final result = await service.isConfigured();
      expect(result, false);
    });

    test('returns false when email exists but no credentials', () async {
      when(mockStorage.containsKey(key: 'email_config_email'))
          .thenAnswer((_) async => true);
      when(mockAuthService.hasCredentials())
          .thenAnswer((_) async => false);

      final result = await service.isConfigured();
      expect(result, false);
    });

    test('returns true when email and credentials exist', () async {
      when(mockStorage.containsKey(key: 'email_config_email'))
          .thenAnswer((_) async => true);
      when(mockAuthService.hasCredentials())
          .thenAnswer((_) async => true);

      final result = await service.isConfigured();
      expect(result, true);
    });
  });

  group('configure', () {
    test('stores all 9 config keys', () async {
      when(mockStorage.write(key: anyNamed('key'), value: anyNamed('value')))
          .thenAnswer((_) async {});

      const config = EmailConfig(
        email: 'test@gmail.com',
        sharerEmail: 'sharer@example.com',
        imapHost: 'imap.gmail.com',
        imapPort: 993,
        imapUseSsl: true,
        smtpHost: 'smtp.gmail.com',
        smtpPort: 465,
        smtpUseSsl: true,
        authMethod: EmailAuthMethod.oauth2Gmail,
      );

      await service.configure(config);

      verify(mockStorage.write(key: 'email_config_email', value: 'test@gmail.com')).called(1);
      verify(mockStorage.write(key: 'email_config_sharerEmail', value: 'sharer@example.com')).called(1);
      verify(mockStorage.write(key: 'email_config_imapHost', value: 'imap.gmail.com')).called(1);
      verify(mockStorage.write(key: 'email_config_imapPort', value: '993')).called(1);
      verify(mockStorage.write(key: 'email_config_imapUseSsl', value: 'true')).called(1);
      verify(mockStorage.write(key: 'email_config_smtpHost', value: 'smtp.gmail.com')).called(1);
      verify(mockStorage.write(key: 'email_config_smtpPort', value: '465')).called(1);
      verify(mockStorage.write(key: 'email_config_smtpUseSsl', value: 'true')).called(1);
      verify(mockStorage.write(key: 'email_config_authMethod', value: 'oauth2Gmail')).called(1);
    });
  });

  group('loadConfig', () {
    test('returns null when email is not stored', () async {
      when(mockStorage.read(key: 'email_config_email'))
          .thenAnswer((_) async => null);

      final config = await service.loadConfig();
      expect(config, isNull);
    });

    test('returns full config when all keys stored', () async {
      when(mockStorage.read(key: 'email_config_email'))
          .thenAnswer((_) async => 'test@libero.it');
      when(mockStorage.read(key: 'email_config_sharerEmail'))
          .thenAnswer((_) async => 'sharer@example.com');
      when(mockStorage.read(key: 'email_config_imapHost'))
          .thenAnswer((_) async => 'imap.libero.it');
      when(mockStorage.read(key: 'email_config_imapPort'))
          .thenAnswer((_) async => '993');
      when(mockStorage.read(key: 'email_config_imapUseSsl'))
          .thenAnswer((_) async => 'true');
      when(mockStorage.read(key: 'email_config_smtpHost'))
          .thenAnswer((_) async => 'smtp.libero.it');
      when(mockStorage.read(key: 'email_config_smtpPort'))
          .thenAnswer((_) async => '465');
      when(mockStorage.read(key: 'email_config_smtpUseSsl'))
          .thenAnswer((_) async => 'true');
      when(mockStorage.read(key: 'email_config_authMethod'))
          .thenAnswer((_) async => 'password');

      final config = await service.loadConfig();

      expect(config, isNotNull);
      expect(config!.email, 'test@libero.it');
      expect(config.sharerEmail, 'sharer@example.com');
      expect(config.imapHost, 'imap.libero.it');
      expect(config.imapPort, 993);
      expect(config.imapUseSsl, true);
      expect(config.smtpHost, 'smtp.libero.it');
      expect(config.smtpPort, 465);
      expect(config.smtpUseSsl, true);
      expect(config.authMethod, EmailAuthMethod.password);
    });
  });

  group('clearConfig', () {
    test('deletes all config keys and credentials', () async {
      when(mockStorage.delete(key: anyNamed('key')))
          .thenAnswer((_) async {});
      when(mockAuthService.clearCredentials())
          .thenAnswer((_) async {});

      await service.clearConfig();

      verify(mockStorage.delete(key: 'email_config_email')).called(1);
      verify(mockStorage.delete(key: 'email_config_sharerEmail')).called(1);
      verify(mockStorage.delete(key: 'email_config_imapHost')).called(1);
      verify(mockStorage.delete(key: 'email_config_imapPort')).called(1);
      verify(mockStorage.delete(key: 'email_config_imapUseSsl')).called(1);
      verify(mockStorage.delete(key: 'email_config_smtpHost')).called(1);
      verify(mockStorage.delete(key: 'email_config_smtpPort')).called(1);
      verify(mockStorage.delete(key: 'email_config_smtpUseSsl')).called(1);
      verify(mockStorage.delete(key: 'email_config_authMethod')).called(1);
      verify(mockAuthService.clearCredentials()).called(1);
    });
  });

  group('testConnection', () {
    test('returns false when no config', () async {
      when(mockStorage.read(key: 'email_config_email'))
          .thenAnswer((_) async => null);

      final result = await service.testConnection();
      expect(result, false);
    });
  });
}
