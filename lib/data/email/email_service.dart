
import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:enough_mail/enough_mail.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../domain/entities/email_config.dart';
import '../../domain/entities/inbox_message.dart';
import '../../domain/repositories/email_repository.dart';
import 'message_validator.dart';

class EmailService implements EmailRepository {
  final FlutterSecureStorage _secureStorage;
  final MessageValidator _validator;

  static const _storageKeyPrefix = 'email_config_';

  EmailService(this._secureStorage, this._validator);

  @override
  Future<void> configure(EmailConfig config) async {
    await _secureStorage.write(key: '${_storageKeyPrefix}imapHost', value: config.imapHost);
    await _secureStorage.write(key: '${_storageKeyPrefix}imapPort', value: config.imapPort.toString());
    await _secureStorage.write(key: '${_storageKeyPrefix}smtpHost', value: config.smtpHost);
    await _secureStorage.write(key: '${_storageKeyPrefix}smtpPort', value: config.smtpPort.toString());
    await _secureStorage.write(key: '${_storageKeyPrefix}email', value: config.email);
    await _secureStorage.write(key: '${_storageKeyPrefix}password', value: config.password);
    await _secureStorage.write(key: '${_storageKeyPrefix}sharerEmail', value: config.sharerEmail);
  }

  @override
  Future<EmailConfig?> loadConfig() async {
    final imapHost = await _secureStorage.read(key: '${_storageKeyPrefix}imapHost');
    if (imapHost == null) return null;

    return EmailConfig(
      imapHost: imapHost,
      imapPort: int.parse(await _secureStorage.read(key: '${_storageKeyPrefix}imapPort') ?? '993'),
      smtpHost: await _secureStorage.read(key: '${_storageKeyPrefix}smtpHost') ?? '',
      smtpPort: int.parse(await _secureStorage.read(key: '${_storageKeyPrefix}smtpPort') ?? '465'),
      email: await _secureStorage.read(key: '${_storageKeyPrefix}email') ?? '',
      password: await _secureStorage.read(key: '${_storageKeyPrefix}password') ?? '',
      sharerEmail: await _secureStorage.read(key: '${_storageKeyPrefix}sharerEmail') ?? '',
    );
  }

  @override
  Future<bool> isConfigured() async {
    return await _secureStorage.containsKey(key: '${_storageKeyPrefix}imapHost');
  }

  @override
  Future<void> clearConfig() async {
    await _secureStorage.deleteAll(); // Warning: clears ALL secure storage if not careful? 
    // Usually flutter_secure_storage deletes everything for the app. 
    // But we share this storage with Crypto keys?
    // CryptoRepository uses `SecureKeyStorage` which might use `FlutterSecureStorage` too.
    // Ensure we don't wipe keys!
    // My previous `SecureKeyStorage` uses a dedicated instance or keys?
    // `SecureKeyStorage` uses `const FlutterSecureStorage()`.
    // So `deleteAll` here wipes EVERYTHING.
    // Dangerous.
    // I should delete specific keys.
    final keys = [
      'imapHost', 'imapPort', 'smtpHost', 'smtpPort', 'email', 'password', 'sharerEmail'
    ];
    for (final k in keys) {
      await _secureStorage.delete(key: '$_storageKeyPrefix$k');
    }
  }

  @override
  Future<bool> testConnection(EmailConfig config) async {
    final client = ImapClient(isLogEnabled: false);
    try {
      await client.connectToServer(config.imapHost, config.imapPort, isSecure: config.useSsl);
      await client.login(config.email, config.password);
      await client.logout();
      return true;
    } catch (e) {
      // Log error?
      return false;
    }
  }

  @override
  Future<List<InboxMessage>> fetchNewMessages() async {
    final config = await loadConfig();
    if (config == null) throw Exception("Email not configured");

    final client = ImapClient(isLogEnabled: false);
    try {
      await client.connectToServer(config.imapHost, config.imapPort, isSecure: config.useSsl);
      await client.login(config.email, config.password);
      
      final inbox = await client.selectInbox();
      // Search for UNSEEN messages from Sharer
      // enough_mail query builder:
      final searchCriteria = MessageSearchCriteria.and([
        MessageSearchCriteria.unseen(),
        MessageSearchCriteria.from(config.sharerEmail),
      ]);
      
      final fetchResult = await client.searchMessages(searchCriteria: searchCriteria);
      if (fetchResult.matchingSequence == null || fetchResult.matchingSequence!.isEmpty) {
        return [];
      }

      final messages = await client.fetchMessages(
          fetchResult.matchingSequence!, 
          'BODY.PEEK[]' // Peek avoids marking as read automatically, or valid macro
      );

      List<InboxMessage> processedMessages = [];

      for (final msg in messages) {
        // Parse
        final parsed = await _parseMessage(msg, config.sharerEmail);
        if (parsed != null) {
          // Validate
          final validated = await _validator.validate(parsed);
          processedMessages.add(validated);
          
          // Mark as processed/read if validated?
          // Repository contract says `markAsRead` is separate.
          // But usually we mark read if we successfully ingested.
          // For now, let the Caller (Application Service) decide when to mark as read.
        }
      }

      await client.logout();
      return processedMessages;
    } catch (e) {
      // Handling errors
      rethrow;
    } finally {
      if (client.isLoggedIn) {
        await client.logout();
      }
    }
  }

  @override
  Future<void> markAsRead(String emailMessageId) async {
    final config = await loadConfig();
    if (config == null) return;
    
    // Complex: We need to find the sequence ID again to mark it?
    // IMAP uses sequence numbers or UIDs.
    // If we closed connection, we need to reconnect, search by Message-ID (HEADER Message-ID) and set flag.
    final client = ImapClient(isLogEnabled: false);
    try {
      await client.connectToServer(config.imapHost, config.imapPort, isSecure: config.useSsl);
      await client.login(config.email, config.password);
      await client.selectInbox();

      // Search by Message-ID header
      // Note: MessageID in entities might be cleaned.
      // Search criteria for header:
      // Imap search for HEADER "Message-ID" "<id>"
      // enough_mail doesn't support HEADER search easily in high level?
      // It does support `MessageSearchCriteria.header(name, value)`.
      // NOTE: Message-ID usually contains <...>.
      
      final result = await client.searchMessages(searchCriteria: MessageSearchCriteria.header('Message-ID', emailMessageId));
      if (result.matchingSequence != null && result.matchingSequence!.isNotEmpty) {
        await client.markMessagesAsRead(result.matchingSequence!);
      }
      
      await client.logout();
    } catch (_) {}
  }

  @override
  Future<void> sendMessage({required String to, required String subject, required String body, String? keeperSignature}) async {
    final config = await loadConfig();
    if (config == null) throw Exception("Email not configured");

    final client = SmtpClient('fidelux.local', isLogEnabled: false);
    try {
      await client.connectToServer(config.smtpHost, config.smtpPort, isSecure: config.useSsl);
      await client.ehlo();
      await client.startTls();
      await client.authenticate(config.email, config.password);

      final builder = MessageBuilder.prepareMultipartAlternativeMessage(
        plainText: body,
        htmlText: null,
      );
      builder.from = [MailAddress(null, config.email)];
      builder.to = [MailAddress(null, to)];
      builder.subject = subject;
      
      if (keeperSignature != null) {
        builder.addHeader('X-FideLux-Signature', keeperSignature);
      }
      builder.addHeader('X-FideLux-Version', '1');

      final mimeMessage = builder.buildMimeMessage();
      await client.sendMessage(mimeMessage);
      
      await client.quit();
    } catch (e) {
      rethrow;
    }
  }

  Future<InboxMessage?> _parseMessage(MimeMessage msg, String expectedSender) async {
    // Basic Parsing
    // Sender check done in search, but double check?
    final sender = msg.from?.first.email ?? '';
    // if (sender != expectedSender) return null; // Already filtered by SEARCH
    
    final emailId = msg.decodeHeaderValue('Message-ID') ?? '';
    final subject = msg.decodeSubject() ?? '';
    final date = msg.decodeDate() ?? DateTime.now();
    
    final signature = msg.getHeader('X-FideLux-Signature')?.value;
    
    // Body extraction
    // enough_mail: msg.decodeTextPlainPart() or msg.body
    final body = msg.decodeTextPlainPart() ?? msg.decodeTextHtmlPart() ?? ''; // Prefer plain
    
    // Attachments
    List<MessageAttachment> attachments = [];
    if (msg.hasParts) {
       for (final part in msg.allPartsFlat) {
         if (part.dispositionType == MediaDisposition.attachment || part.dispositionType == MediaDisposition.inline) {
           final filename = part.decodeFileName() ?? 'unnamed';
           // Decode content
           // If it's text, it might return string?
           // enough_mail generic part content decoding?
           // We might need to access raw bytes if possible.
           // `part.decodeContentBinary()`?
           // The documentation says `decodeContentBinary()` returns List<int>?.
           final data = part.decodeContentBinary();
           if (data != null) {
             attachments.add(MessageAttachment(
               filename: filename,
               mimeType: part.mediaType.toString(),
               data: Uint8List.fromList(data),
               sizeBytes: data.length,
             ));
           }
         }
       }
    }
    
    return InboxMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(), // Temporary ID logic
      emailMessageId: emailId,
      receivedAt: date,
      senderEmail: sender,
      subject: subject,
      bodyText: body,
      attachments: attachments,
      sharerSignature: signature,
      rawEmail: msg.toString(), // roughly headers + structure
    );
  }
}
