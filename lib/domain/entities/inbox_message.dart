import 'dart:typed_data';

enum MessageStatus {
  received,
  verified,
  rejected,
  processed,
}

class InboxMessage {
  final String id;
  final String emailMessageId;
  final DateTime receivedAt;
  final String senderEmail;
  final String? subject;
  final String? bodyText;
  final List<MessageAttachment> attachments;
  final String? sharerSignature;
  final bool? signatureValid;
  final MessageStatus status;
  final String rawEmail; // verification audit

  const InboxMessage({
    required this.id,
    required this.emailMessageId,
    required this.receivedAt,
    required this.senderEmail,
    this.subject,
    this.bodyText,
    this.attachments = const [],
    this.sharerSignature,
    this.signatureValid,
    this.status = MessageStatus.received,
    required this.rawEmail,
  });

  InboxMessage copyWith({
    bool? signatureValid,
    MessageStatus? status,
  }) {
    return InboxMessage(
      id: id,
      emailMessageId: emailMessageId,
      receivedAt: receivedAt,
      senderEmail: senderEmail,
      subject: subject,
      bodyText: bodyText,
      attachments: attachments,
      sharerSignature: sharerSignature,
      signatureValid: signatureValid ?? this.signatureValid,
      status: status ?? this.status,
      rawEmail: rawEmail,
    );
  }
}

class MessageAttachment {
  final String filename;
  final String mimeType;
  final Uint8List data;
  final int sizeBytes;

  const MessageAttachment({
    required this.filename,
    required this.mimeType,
    required this.data,
    required this.sizeBytes,
  });
}
