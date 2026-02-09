
import 'dart:convert';
import 'dart:typed_data';

import '../../domain/entities/crypto_identity.dart';
import '../../domain/entities/inbox_message.dart';
import '../../domain/repositories/crypto_repository.dart';
import '../../domain/repositories/key_storage_repository.dart';

class MessageValidator {
  final CryptoRepository cryptoRepository;
  final KeyStorageRepository keyStorageRepository;

  MessageValidator(this.cryptoRepository, this.keyStorageRepository);

  /// Validates the message signature against the stored Sharer public key.
  /// Returns a copy of the message with updated [status] and [signatureValid].
  Future<InboxMessage> validate(InboxMessage message) async {
    // 1. Check if signature exists
    if (message.sharerSignature == null) {
      return message.copyWith(
        signatureValid: false,
        status: MessageStatus.rejected, // Or warning? Directive rule 4: rejected (audit)
      );
    }

    // 2. Load Sharer Public Key
    // We assume the sender is the Sharer.
    // Ideally we match senderEmail to configured Sharer email, but here we just check signature validity
    // against the stored "Peer" key (which is the Sharer for a Keeper).
    final peerKey = await keyStorageRepository.loadPeerPublicKey(Role.sharer);
    
    if (peerKey == null) {
      // We don't have a peer key to verify against.
      // Cannot verify. Status? Maybe received but unverified?
      // Rule 4 says "signature missing OR invalid -> rejected".
      // Missing key effectively makes it unverifiable -> invalid -> rejected.
      return message.copyWith(
        signatureValid: false,
        status: MessageStatus.rejected,
      );
    }

    // 3. Construct Payload
    // Rule 2: subject + "\n" + bodyText (UTF-8)
    // Handle nulls gracefully (though email usually has body)
    final subject = message.subject ?? '';
    final body = message.bodyText ?? '';
    final payloadString = '$subject\n$body';
    final payloadBytes = utf8.encode(payloadString);

    // 4. Verify
    final isValid = await cryptoRepository.verify(
      Uint8List.fromList(payloadBytes),
      message.sharerSignature!,
      peerKey,
    );

    // 5. Update Status
    return message.copyWith(
      signatureValid: isValid,
      status: isValid ? MessageStatus.verified : MessageStatus.rejected,
    );
  }
}
