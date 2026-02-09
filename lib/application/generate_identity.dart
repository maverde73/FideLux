import '../../domain/entities/crypto_identity.dart';
import '../../domain/repositories/crypto_repository.dart';
import '../../domain/repositories/key_storage_repository.dart';

/// Use case: Generate a new crypto identity and securely store keys.
class GenerateIdentity {
  GenerateIdentity(this.cryptoRepository, this.keyStorageRepository);

  final CryptoRepository cryptoRepository;
  final KeyStorageRepository keyStorageRepository;

  Future<CryptoIdentity> call(Role role) async {
    // 1. Generate keys
    final identity = await cryptoRepository.generateIdentity(role);

    // 2. Save private key (if present)
    if (identity.privateKey != null) {
      await keyStorageRepository.savePrivateKey(role, identity.privateKey!);
    }

    // 3. Save public key
    await keyStorageRepository.savePublicKey(role, identity.publicKey);

    return identity;
  }
}
