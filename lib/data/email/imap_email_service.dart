import 'dart:typed_data';

import 'package:enough_mail/enough_mail.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../domain/entities/email_auth_method.dart';
import '../../domain/entities/email_config.dart';
import '../../domain/entities/inbox_message.dart';
import '../../domain/repositories/email_repository.dart';
import 'email_auth_service.dart';
import 'message_validator.dart';

class ImapEmailService implements EmailRepository {
  final EmailAuthService _authService;
  final FlutterSecureStorage _secureStorage;
  final MessageValidator _validator;

  static const _storageKeyPrefix = 'email_config_';

  ImapEmailService(this._authService, this._secureStorage, this._validator);

  @override
  Future<void> configure(EmailConfig config) async {
    await _secureStorage.write(
        key: '${_storageKeyPrefix}email', value: config.email);
    await _secureStorage.write(
        key: '${_storageKeyPrefix}sharerEmail', value: config.sharerEmail);
    await _secureStorage.write(
        key: '${_storageKeyPrefix}imapHost', value: config.imapHost);
    await _secureStorage.write(
        key: '${_storageKeyPrefix}imapPort', value: config.imapPort.toString());
    await _secureStorage.write(
        key: '${_storageKeyPrefix}imapUseSsl',
        value: config.imapUseSsl.toString());
    await _secureStorage.write(
        key: '${_storageKeyPrefix}smtpHost', value: config.smtpHost);
    await _secureStorage.write(
        key: '${_storageKeyPrefix}smtpPort', value: config.smtpPort.toString());
    await _secureStorage.write(
        key: '${_storageKeyPrefix}smtpUseSsl',
        value: config.smtpUseSsl.toString());
    await _secureStorage.write(
        key: '${_storageKeyPrefix}authMethod', value: config.authMethod.name);
  }

  @override
  Future<EmailConfig?> loadConfig() async {
    final email = await _secureStorage.read(key: '${_storageKeyPrefix}email');
    if (email == null) return null;

    final sharerEmail =
        await _secureStorage.read(key: '${_storageKeyPrefix}sharerEmail') ?? '';
    final imapHost =
        await _secureStorage.read(key: '${_storageKeyPrefix}imapHost') ?? '';
    final imapPort =
        int.tryParse(
            await _secureStorage.read(key: '${_storageKeyPrefix}imapPort') ??
                '') ??
        993;
    final imapUseSsl =
        (await _secureStorage.read(key: '${_storageKeyPrefix}imapUseSsl')) ==
            'true';
    final smtpHost =
        await _secureStorage.read(key: '${_storageKeyPrefix}smtpHost') ?? '';
    final smtpPort =
        int.tryParse(
            await _secureStorage.read(key: '${_storageKeyPrefix}smtpPort') ??
                '') ??
        465;
    final smtpUseSsl =
        (await _secureStorage.read(key: '${_storageKeyPrefix}smtpUseSsl')) ==
            'true';
    final authMethodStr =
        await _secureStorage.read(key: '${_storageKeyPrefix}authMethod');
    final authMethod = authMethodStr != null
        ? EmailAuthMethod.values.byName(authMethodStr)
        : EmailAuthMethod.password;

    return EmailConfig(
      email: email,
      sharerEmail: sharerEmail,
      imapHost: imapHost,
      imapPort: imapPort,
      imapUseSsl: imapUseSsl,
      smtpHost: smtpHost,
      smtpPort: smtpPort,
      smtpUseSsl: smtpUseSsl,
      authMethod: authMethod,
    );
  }

  @override
  Future<bool> isConfigured() async {
    final hasEmail =
        await _secureStorage.containsKey(key: '${_storageKeyPrefix}email');
    if (!hasEmail) return false;
    return _authService.hasCredentials();
  }

  @override
  Future<void> clearConfig() async {
    final keys = [
      'email',
      'sharerEmail',
      'imapHost',
      'imapPort',
      'imapUseSsl',
      'smtpHost',
      'smtpPort',
      'smtpUseSsl',
      'authMethod',
    ];
    for (final k in keys) {
      await _secureStorage.delete(key: '$_storageKeyPrefix$k');
    }
    await _authService.clearCredentials();
  }

  @override
  Future<bool> testConnection() async {
    final config = await loadConfig();
    if (config == null) {
      debugPrint('[IMAP-TEST] No config found');
      return false;
    }

    debugPrint('[IMAP-TEST] Testing connection to ${config.imapHost}:${config.imapPort} (SSL=${config.imapUseSsl})');
    debugPrint('[IMAP-TEST] Auth method: ${config.authMethod.name}, email: ${config.email}');

    final client = ImapClient(isLogEnabled: true);
    try {
      debugPrint('[IMAP-TEST] Connecting...');
      await client.connectToServer(
        config.imapHost,
        config.imapPort,
        isSecure: config.imapUseSsl,
      );
      debugPrint('[IMAP-TEST] Connected, authenticating...');

      await _authenticate(client, config);
      debugPrint('[IMAP-TEST] Authenticated successfully!');

      await client.logout();
      debugPrint('[IMAP-TEST] Logged out, test PASSED');
      return true;
    } catch (e, stack) {
      debugPrint('[IMAP-TEST] FAILED: $e\n$stack');
      return false;
    } finally {
      try {
        await client.disconnect();
      } catch (_) {
        // Ignore disconnect errors
      }
    }
  }

  @override
  Future<List<InboxMessage>> fetchNewMessages() async {
    final config = await loadConfig();
    if (config == null) throw Exception('Email not configured');

    final client = ImapClient(isLogEnabled: false);
    try {
      await client.connectToServer(
        config.imapHost,
        config.imapPort,
        isSecure: config.imapUseSsl,
      );

      await _authenticate(client, config);
      await client.selectInbox();

      // Search for unseen messages from the Sharer
      final searchResult = await client.searchMessages(
        searchCriteria: 'UNSEEN FROM "${config.sharerEmail}"',
      );

      if (searchResult.matchingSequence == null ||
          searchResult.matchingSequence!.isEmpty) {
        await client.logout();
        return [];
      }

      final fetchResult = await client.fetchMessages(
        searchResult.matchingSequence!,
        'BODY.PEEK[]',
      );

      final List<InboxMessage> processedMessages = [];

      for (final msgData in fetchResult.messages) {
        final parsed = _parseMimeMessage(msgData, config.sharerEmail);
        if (parsed != null) {
          final validated = await _validator.validate(parsed);
          processedMessages.add(validated);
        }
      }

      await client.logout();
      return processedMessages;
    } finally {
      try {
        await client.disconnect();
      } catch (_) {
        // Ignore disconnect errors
      }
    }
  }

  Future<void> _authenticate(ImapClient client, EmailConfig config) async {
    debugPrint('[IMAP-AUTH] Getting credential for method=${config.authMethod.name}');
    final credential = await _authService.getCredential();
    debugPrint('[IMAP-AUTH] Credential obtained (${credential.length} chars)');

    if (config.authMethod == EmailAuthMethod.password) {
      debugPrint('[IMAP-AUTH] Using LOGIN for ${config.email}');
      await client.login(config.email, credential);
    } else {
      debugPrint('[IMAP-AUTH] Using XOAUTH2 for ${config.email}');
      debugPrint('[IMAP-AUTH] Token preview: ${credential.substring(0, 20.clamp(0, credential.length))}...');
      try {
        await client.authenticateWithOAuth2(config.email, credential);
        debugPrint('[IMAP-AUTH] XOAUTH2 succeeded');
      } catch (e, stack) {
        debugPrint('[IMAP-AUTH] XOAUTH2 FAILED: $e\n$stack');
        rethrow;
      }
    }
  }

  InboxMessage? _parseMimeMessage(MimeMessage msg, String expectedSender) {
    final emailId = msg.getHeaderValue('Message-ID') ?? '';
    final subject = msg.decodeSubject() ?? '';
    final sender = msg.fromEmail ?? '';
    final date = msg.decodeDate() ?? DateTime.now().toUtc();
    final signature = msg.getHeaderValue('X-FideLux-Signature');
    final body = msg.decodeTextPlainPart() ?? '';

    // Extract attachments
    final attachments = <MessageAttachment>[];
    if (msg.hasAttachments()) {
      final contentInfos = msg.findContentInfo();
      for (final info in contentInfos) {
        final part = msg.getPart(info.fetchId);
        if (part != null) {
          final filename = info.fileName ?? 'attachment';
          final mimeType =
              info.mediaType?.text ?? 'application/octet-stream';
          final data = part.decodeContentBinary();
          if (data != null) {
            attachments.add(MessageAttachment(
              filename: filename,
              mimeType: mimeType,
              data: Uint8List.fromList(data),
              sizeBytes: data.length,
            ));
          }
        }
      }
    }

    return InboxMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      emailMessageId: emailId,
      receivedAt: date.toUtc(),
      senderEmail: sender,
      subject: subject,
      bodyText: body,
      attachments: attachments,
      sharerSignature: signature,
      rawEmail: msg.renderMessage(),
    );
  }
}
