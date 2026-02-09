import 'dart:typed_data';

import '../entities/crypto_identity.dart';

/// Contract for cryptographic operations.
abstract class CryptoRepository {
  /// Generates a new Ed25519 keypair for the given role.
  Future<CryptoIdentity> generateIdentity(Role role);

  /// Signs a message with the given private key (Ed25519).
  ///
  /// Returns a Base64 encoded signature.
  Future<String> sign(Uint8List message, Uint8List privateKey);

  /// Verifies an Ed25519 signature against the message and public key.
  ///
  /// [signatureBase64] must be a Base64 encoded string.
  /// Returns true if valid, false otherwise.
  Future<bool> verify(Uint8List message, String signatureBase64, Uint8List publicKey);

  /// Computes the SHA-256 hash of a string input.
  ///
  /// Returns the hash as a hex string.
  String sha256Hash(String input);
}
