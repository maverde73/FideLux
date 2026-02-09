import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../domain/entities/crypto_identity.dart';
import '../../domain/repositories/key_storage_repository.dart';

/// Secure storage implementation using [FlutterSecureStorage].
class SecureKeyStorage implements KeyStorageRepository {
  // Use recommended options for highest security
  final _storage = const FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
    ),
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.passcode,
    ),
  );

  static String _privKeyKey(Role role) => 'fidelux_private_${role.name}';
  static String _pubKeyKey(Role role) => 'fidelux_public_${role.name}';
  static const String _peerPubKeyKey = 'fidelux_peer_public';

  @override
  Future<void> savePrivateKey(Role role, Uint8List privateKey) async {
    await _storage.write(
      key: _privKeyKey(role),
      value: base64Encode(privateKey),
    );
  }

  @override
  Future<Uint8List?> loadPrivateKey(Role role) async {
    final val = await _storage.read(key: _privKeyKey(role));
    return val != null ? base64Decode(val) : null;
  }

  @override
  Future<void> savePublicKey(Role role, Uint8List publicKey) async {
    await _storage.write(
      key: _pubKeyKey(role),
      value: base64Encode(publicKey),
    );
  }

  @override
  Future<Uint8List?> loadPublicKey(Role role) async {
    final val = await _storage.read(key: _pubKeyKey(role));
    return val != null ? base64Decode(val) : null;
  }

  @override
  Future<void> savePeerPublicKey(Role peerRole, Uint8List publicKey) async {
    // We append the role to the key to allow multiple peers (one per role)
    // e.g. fidelux_peer_public_sharer
    final key = '${_peerPubKeyKey}_${peerRole.name}';
    await _storage.write(
      key: key,
      value: base64Encode(publicKey),
    );
  }

  @override
  Future<Uint8List?> loadPeerPublicKey(Role peerRole) async {
    final key = '${_peerPubKeyKey}_${peerRole.name}';
    final val = await _storage.read(key: key);
    return val != null ? base64Decode(val) : null;
  }

  @override
  Future<void> deleteAll() async {
    await _storage.deleteAll();
  }
}
