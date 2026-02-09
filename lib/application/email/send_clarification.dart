
import 'dart:convert';
import 'dart:typed_data';

import '../../domain/entities/crypto_identity.dart';
import '../../domain/repositories/email_repository.dart';
import '../../domain/repositories/crypto_repository.dart';
import '../../domain/repositories/key_storage_repository.dart';

class SendClarification {
  final EmailRepository _emailRepository;
  final CryptoRepository _cryptoRepository;
  final KeyStorageRepository _keyStorageRepository;

  SendClarification(
    this._emailRepository,
    this._cryptoRepository,
    this._keyStorageRepository,
  );

  Future<void> call({
    required String recipientEmail,
    required String subject,
    required String body,
  }) async {
    // 1. Sign message with Keeper identity (if available)
    String? signature;
    final privateKey = await _keyStorageRepository.loadPrivateKey(Role.keeper);
    
    if (privateKey != null) {
      // We sign subject + body
      final payload = '$subject\n$body';
      signature = await _cryptoRepository.sign(
        Uint8List.fromList(utf8.encode(payload)), 
        privateKey
      );
    }

    // 2. Send email
    await _emailRepository.sendMessage(
      to: recipientEmail,
      subject: subject,
      body: body,
      keeperSignature: signature,
    );
  }
}
