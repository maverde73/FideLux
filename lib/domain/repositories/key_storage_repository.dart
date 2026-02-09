import 'dart:typed_data';

import '../entities/crypto_identity.dart';

/// Contract for secure key storage.
abstract class KeyStorageRepository {
  /// Saves the private key for the given role.
  Future<void> savePrivateKey(Role role, Uint8List privateKey);

  /// Loads the private key for the given role.
  Future<Uint8List?> loadPrivateKey(Role role);

  /// Saves the public key for the given role.
  Future<void> savePublicKey(Role role, Uint8List publicKey);

  /// Loads the public key for the given role.
  Future<Uint8List?> loadPublicKey(Role role);

  /// Saves the peer's public key (e.g., Keeper saving Sharer's key).
  Future<void> savePeerPublicKey(Role peerRole, Uint8List publicKey);

  /// Loads the peer's public key.
  Future<Uint8List?> loadPeerPublicKey(Role peerRole);

  /// Deletes ALL keys (dangerous, for reset/debug).
  Future<void> deleteAll();
}
