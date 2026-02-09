import 'dart:typed_data';

import '../../domain/repositories/crypto_repository.dart';

/// Use case: Verify a signature against a public key.
class VerifySignature {
  VerifySignature(this.cryptoRepository);

  final CryptoRepository cryptoRepository;

  Future<bool> call(Uint8List message, String signatureBase64, Uint8List publicKey) async {
    return await cryptoRepository.verify(message, signatureBase64, publicKey);
  }
}
