import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:msal_auth/msal_auth.dart';

import '../../domain/entities/email_auth_method.dart';

class EmailAuthService {
  final FlutterSecureStorage _secureStorage;
  final GoogleSignIn _googleSignIn;
  MsalAuth? _msalClient;

  static const _keyPrefix = 'email_auth_';
  static const _keyAuthMethod = '${_keyPrefix}method';
  static const _keyAccessToken = '${_keyPrefix}access_token';
  static const _keyRefreshToken = '${_keyPrefix}refresh_token';
  static const _keyTokenExpiry = '${_keyPrefix}token_expiry';
  static const _keyPassword = '${_keyPrefix}password';

  // Google OAuth2 — handled natively by google_sign_in plugin
  static const _googleScopes = ['https://mail.google.com/'];

  // Microsoft OAuth2 — handled by msal_auth
  static const _microsoftClientId = '75b3f559-e24c-4a48-8b89-79c1a1556feb';
  static const _microsoftScopes = [
    'https://outlook.office365.com/IMAP.AccessAsUser.All',
    'https://outlook.office365.com/SMTP.Send',
    'offline_access',
  ];

  EmailAuthService({
    FlutterSecureStorage? secureStorage,
    GoogleSignIn? googleSignIn,
  })  : _secureStorage = secureStorage ?? const FlutterSecureStorage(),
        _googleSignIn = googleSignIn ??
            GoogleSignIn(scopes: _googleScopes);

  Future<MsalAuth> _getMsalClient() async {
    if (_msalClient != null) return _msalClient!;
    debugPrint('[MSAL] Creating MsalAuth public client...');
    _msalClient = await MsalAuth.createPublicClientApplication(
      clientId: _microsoftClientId,
      scopes: _microsoftScopes,
      androidConfig: AndroidConfig(
        configFilePath: 'assets/msal_config.json',
      ),
    );
    debugPrint('[MSAL] MsalAuth client created');
    return _msalClient!;
  }

  /// Authenticates via Google Sign-In (native Android SDK) and stores token.
  Future<String> authenticateGmail() async {
    debugPrint('[GMAIL-AUTH] Starting Google Sign-In flow');

    try {
      final account = await _googleSignIn.signIn();
      if (account == null) {
        debugPrint('[GMAIL-AUTH] Sign-in was cancelled by user');
        throw Exception('Google sign-in was cancelled');
      }

      debugPrint('[GMAIL-AUTH] Signed in as: ${account.email}');
      final auth = await account.authentication;
      final accessToken = auth.accessToken;
      if (accessToken == null) {
        debugPrint('[GMAIL-AUTH] ERROR: No access token received');
        throw Exception('Google OAuth2 authentication failed');
      }

      debugPrint('[GMAIL-AUTH] Access token received');
      await _storeTokens(
        accessToken: accessToken,
        method: EmailAuthMethod.oauth2Gmail,
      );
      debugPrint('[GMAIL-AUTH] Token stored successfully');

      return accessToken;
    } catch (e, stack) {
      debugPrint('[GMAIL-AUTH] ERROR: $e\n$stack');
      rethrow;
    }
  }

  /// Authenticates via Microsoft MSAL and stores tokens.
  Future<String> authenticateMicrosoft() async {
    debugPrint('[MS-AUTH] Starting MSAL authentication flow');
    debugPrint('[MS-AUTH] Client ID: $_microsoftClientId');
    debugPrint('[MS-AUTH] Scopes: $_microsoftScopes');

    try {
      final client = await _getMsalClient();
      debugPrint('[MS-AUTH] Calling acquireToken...');

      final result = await client.acquireToken();

      if (result == null) {
        debugPrint('[MS-AUTH] ERROR: acquireToken returned null');
        throw Exception('Microsoft authentication failed — no result');
      }

      debugPrint('[MS-AUTH] Token acquired for: ${result.username}');
      debugPrint('[MS-AUTH] Access token: ${result.accessToken.substring(0, 20)}...');

      await _storeTokens(
        accessToken: result.accessToken,
        method: EmailAuthMethod.oauth2Microsoft,
      );
      debugPrint('[MS-AUTH] Tokens stored successfully');

      return result.accessToken;
    } on MsalUserCanceledException {
      debugPrint('[MS-AUTH] User cancelled the sign-in');
      throw Exception('Microsoft sign-in was cancelled');
    } on MsalException catch (e) {
      debugPrint('[MS-AUTH] MSAL ERROR: ${e.errorMessage}');
      throw Exception('Microsoft authentication failed: ${e.errorMessage}');
    } catch (e, stack) {
      debugPrint('[MS-AUTH] ERROR: $e\n$stack');
      rethrow;
    }
  }

  /// Stores a password for IMAP authentication.
  Future<void> storePassword(String password) async {
    await _secureStorage.write(key: _keyPassword, value: password);
    await _secureStorage.write(
        key: _keyAuthMethod, value: EmailAuthMethod.password.name);
  }

  /// Returns a valid credential (OAuth2 token or password).
  Future<String> getCredential() async {
    final method = await getAuthMethod();
    debugPrint('[CRED] getCredential called, method=$method');
    if (method == null) throw Exception('No auth method configured');

    if (method == EmailAuthMethod.password) {
      final password = await _secureStorage.read(key: _keyPassword);
      if (password == null) throw Exception('No password stored');
      return password;
    }

    if (method == EmailAuthMethod.oauth2Gmail) {
      debugPrint('[CRED] Gmail: attempting silent sign-in for fresh token');
      final account = _googleSignIn.currentUser ??
          await _googleSignIn.signInSilently();
      if (account != null) {
        final auth = await account.authentication;
        if (auth.accessToken != null) {
          debugPrint('[CRED] Gmail: fresh token obtained');
          await _secureStorage.write(
              key: _keyAccessToken, value: auth.accessToken!);
          return auth.accessToken!;
        }
      }
      final token = await _secureStorage.read(key: _keyAccessToken);
      if (token == null) {
        throw Exception('No access token — re-authentication required');
      }
      return token;
    }

    // Microsoft — use MSAL silent token acquisition
    debugPrint('[CRED] Microsoft: attempting silent token acquisition');
    try {
      final client = await _getMsalClient();
      final result = await client.acquireTokenSilent();
      if (result != null) {
        debugPrint('[CRED] Microsoft: silent token acquired');
        await _secureStorage.write(
            key: _keyAccessToken, value: result.accessToken);
        return result.accessToken;
      }
    } on MsalUiRequiredException {
      debugPrint('[CRED] Microsoft: UI required, need interactive sign-in');
    } on MsalException catch (e) {
      debugPrint('[CRED] Microsoft: MSAL error: ${e.errorMessage}');
    }
    // Fall back to stored token
    final token = await _secureStorage.read(key: _keyAccessToken);
    if (token != null) return token;
    throw Exception('No access token — re-authentication required');
  }

  /// Returns the currently configured auth method.
  Future<EmailAuthMethod?> getAuthMethod() async {
    final methodStr = await _secureStorage.read(key: _keyAuthMethod);
    if (methodStr == null) return null;
    return EmailAuthMethod.values.byName(methodStr);
  }

  /// Checks if any credentials are stored.
  Future<bool> hasCredentials() async {
    final method = await _secureStorage.read(key: _keyAuthMethod);
    return method != null;
  }

  /// Clears all stored credentials and signs out.
  Future<void> clearCredentials() async {
    try {
      await _googleSignIn.signOut();
    } catch (_) {}
    try {
      final client = await _getMsalClient();
      await client.logout();
    } catch (_) {}
    for (final key in [
      _keyAuthMethod,
      _keyAccessToken,
      _keyRefreshToken,
      _keyTokenExpiry,
      _keyPassword,
    ]) {
      await _secureStorage.delete(key: key);
    }
  }

  Future<void> _storeTokens({
    required String accessToken,
    String? refreshToken,
    DateTime? expiresAt,
    required EmailAuthMethod method,
  }) async {
    await _secureStorage.write(key: _keyAccessToken, value: accessToken);
    await _secureStorage.write(key: _keyAuthMethod, value: method.name);
    if (refreshToken != null) {
      await _secureStorage.write(key: _keyRefreshToken, value: refreshToken);
    }
    if (expiresAt != null) {
      await _secureStorage.write(
          key: _keyTokenExpiry, value: expiresAt.toUtc().toIso8601String());
    }
  }
}
