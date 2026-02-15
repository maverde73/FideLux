import 'email_auth_method.dart';

enum EmailAuthStatus { disconnected, connecting, connected, error }

class EmailAuthState {
  final EmailAuthStatus status;
  final String? email;
  final String? providerName; // "Gmail", "Outlook", "IMAP"
  final EmailAuthMethod? authMethod;
  final String? errorMessage;

  const EmailAuthState({
    required this.status,
    this.email,
    this.providerName,
    this.authMethod,
    this.errorMessage,
  });
}
