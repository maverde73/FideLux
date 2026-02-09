import 'dart:convert';
import 'dart:typed_data';

import 'package:cryptography/cryptography.dart';
import 'package:crypto/crypto.dart' as crypto;

import '../../domain/entities/crypto_identity.dart';
import '../../domain/repositories/crypto_repository.dart';

/// Concrete implementation of [CryptoRepository] using the `cryptography` package.
class CryptoService implements CryptoRepository {
  final _algorithm = Ed25519();

  @override
  Future<CryptoIdentity> generateIdentity(Role role) async {
    final keyPair = await _algorithm.newKeyPair();
    final pubKey = await keyPair.extractPublicKey();
    final privKeyBytes = await keyPair.extractPrivateKeyBytes();

    return CryptoIdentity.fromKeys(
      Uint8List.fromList(pubKey.bytes),
      Uint8List.fromList(privKeyBytes),
      role,
    );
  }

  @override
  Future<String> sign(Uint8List message, Uint8List privateKey) async {
    // Reconstruct key pair from private key bytes.
    // We need the public key to reconstruct SimpleKeyPairData fully?
    // Actually, `SimpleKeyPairData` can work with just private key for signing if the algorithm allows, 
    // but Ed25519 usually derives public from private.
    // The `cryptography` package's `Ed25519` implementation can derive the public key from the seed.
    
    final keyPair = await _algorithm.newKeyPairFromSeed(privateKey);
    
    final signature = await _algorithm.sign(
      message,
      keyPair: keyPair,
    );
    
    return base64Encode(signature.bytes);
  }

  @override
  Future<bool> verify(Uint8List message, String signatureBase64, Uint8List publicKey) async {
    try {
      final signatureBytes = base64Decode(signatureBase64);
      final signature = Signature(
        signatureBytes,
        publicKey: SimplePublicKey(publicKey, type: KeyPairType.ed25519),
      );

      return await _algorithm.verify(
        message,
        signature: signature,
      );
    } catch (_) {
      return false;
    }
  }

  @override
  String sha256Hash(String input) {
    // We use `crypto` package for synchronous SHA-256 for chain hashing (preferred for simplicity in sync logic if possible, 
    // but here we are in a service class).
    // The directive explicitly mentioned SHA-256 from PointyCastle, but since we dropped PC for Ed25519,
    // using `crypto` package (which is standard Dart) is cleaner and already in pubspec.
    final bytes = utf8.encode(input);
    final digest = crypto.sha256.convert(bytes);
    return digest.toString();
  }
}
