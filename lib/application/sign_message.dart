import 'dart:typed_data';

import '../../domain/entities/crypto_identity.dart';
import '../../domain/repositories/crypto_repository.dart';
import '../../domain/repositories/key_storage_repository.dart';

/// Use case: Sign a message using the stored private key.
class SignMessage {
  SignMessage(this.cryptoRepository, this.keyStorageRepository);

  final CryptoRepository cryptoRepository;
  final KeyStorageRepository keyStorageRepository;

  Future<String> call(Uint8List message, Role signerRole) async {
    // 1. Load private key
    final privateKey = await keyStorageRepository.loadPrivateKey(signerRole);
    if (privateKey == null) {
      // In a real app, use a typed Failure.
      throw Exception('Private key for $signerRole not found.');
    }

    // 2. Sign message
    return await cryptoRepository.sign(message, privateKey);
  }
}
