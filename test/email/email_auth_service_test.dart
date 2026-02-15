import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'package:fidelux/data/email/email_auth_service.dart';
import 'package:fidelux/domain/entities/email_auth_method.dart';

@GenerateMocks([FlutterSecureStorage, GoogleSignIn])
import 'email_auth_service_test.mocks.dart';

void main() {
  late EmailAuthService service;
  late MockFlutterSecureStorage mockStorage;
  late MockGoogleSignIn mockGoogleSignIn;

  setUp(() {
    mockStorage = MockFlutterSecureStorage();
    mockGoogleSignIn = MockGoogleSignIn();
    service = EmailAuthService(
      secureStorage: mockStorage,
      googleSignIn: mockGoogleSignIn,
    );
  });

  group('hasCredentials', () {
    test('returns false when no auth method stored', () async {
      when(mockStorage.read(key: 'email_auth_method'))
          .thenAnswer((_) async => null);

      final result = await service.hasCredentials();
      expect(result, false);
    });

    test('returns true when auth method is stored', () async {
      when(mockStorage.read(key: 'email_auth_method'))
          .thenAnswer((_) async => 'password');

      final result = await service.hasCredentials();
      expect(result, true);
    });
  });

  group('storePassword', () {
    test('writes password and method to secure storage', () async {
      when(mockStorage.write(key: anyNamed('key'), value: anyNamed('value')))
          .thenAnswer((_) async {});

      await service.storePassword('myAppPassword123');

      verify(mockStorage.write(
        key: 'email_auth_password',
        value: 'myAppPassword123',
      )).called(1);
      verify(mockStorage.write(
        key: 'email_auth_method',
        value: 'password',
      )).called(1);
    });
  });

  group('getCredential', () {
    test('returns password when auth method is password', () async {
      when(mockStorage.read(key: 'email_auth_method'))
          .thenAnswer((_) async => 'password');
      when(mockStorage.read(key: 'email_auth_password'))
          .thenAnswer((_) async => 'storedPassword');

      final credential = await service.getCredential();
      expect(credential, 'storedPassword');
    });

    test('throws when no auth method configured', () async {
      when(mockStorage.read(key: 'email_auth_method'))
          .thenAnswer((_) async => null);

      expect(() => service.getCredential(), throwsException);
    });

    test('throws when password is null', () async {
      when(mockStorage.read(key: 'email_auth_method'))
          .thenAnswer((_) async => 'password');
      when(mockStorage.read(key: 'email_auth_password'))
          .thenAnswer((_) async => null);

      expect(() => service.getCredential(), throwsException);
    });
  });

  group('clearCredentials', () {
    test('deletes all credential keys and signs out of Google', () async {
      when(mockGoogleSignIn.signOut()).thenAnswer((_) async => null);
      when(mockStorage.delete(key: anyNamed('key')))
          .thenAnswer((_) async {});

      await service.clearCredentials();

      verify(mockGoogleSignIn.signOut()).called(1);
      verify(mockStorage.delete(key: 'email_auth_method')).called(1);
      verify(mockStorage.delete(key: 'email_auth_access_token')).called(1);
      verify(mockStorage.delete(key: 'email_auth_refresh_token')).called(1);
      verify(mockStorage.delete(key: 'email_auth_token_expiry')).called(1);
      verify(mockStorage.delete(key: 'email_auth_password')).called(1);
    });
  });

  group('getAuthMethod', () {
    test('returns null when nothing stored', () async {
      when(mockStorage.read(key: 'email_auth_method'))
          .thenAnswer((_) async => null);

      final method = await service.getAuthMethod();
      expect(method, isNull);
    });

    test('returns oauth2Gmail when stored', () async {
      when(mockStorage.read(key: 'email_auth_method'))
          .thenAnswer((_) async => 'oauth2Gmail');

      final method = await service.getAuthMethod();
      expect(method, EmailAuthMethod.oauth2Gmail);
    });

    test('returns password when stored', () async {
      when(mockStorage.read(key: 'email_auth_method'))
          .thenAnswer((_) async => 'password');

      final method = await service.getAuthMethod();
      expect(method, EmailAuthMethod.password);
    });
  });
}
