import 'dart:convert';
import 'dart:typed_data';



/// The role of a user in the FideLux system.
enum Role {
  sharer,
  keeper,
}

/// Represents a cryptographic identity (Ed25519 KeyPair) for a FideLux user.
class CryptoIdentity {
  const CryptoIdentity({
    required this.publicKey,
    this.privateKey,
    required this.role,
    required this.createdAt,
  });

  /// The public key (32 bytes).
  final Uint8List publicKey;

  /// The private key (64 bytes). Nullable because the Keeper only holds
  /// the Sharer's public key, not their private key.
  final Uint8List? privateKey;

  /// The role associated with this identity.
  final Role role;

  /// Creation timestamp.
  final DateTime createdAt;

  /// Creates an identity from raw key bytes.
  factory CryptoIdentity.fromKeys(
    Uint8List publicKey,
    Uint8List? privateKey,
    Role role, {
    DateTime? createdAt,
  }) {
    return CryptoIdentity(
      publicKey: publicKey,
      privateKey: privateKey,
      role: role,
      createdAt: createdAt ?? DateTime.now().toUtc(),
    );
  }

  /// Creates an identity from Base64 encoded keys.
  factory CryptoIdentity.fromBase64({
    required String publicKey,
    String? privateKey,
    required Role role,
    DateTime? createdAt,
  }) {
    return CryptoIdentity(
      publicKey: base64Decode(publicKey),
      privateKey: privateKey != null ? base64Decode(privateKey) : null,
      role: role,
      createdAt: createdAt ?? DateTime.now().toUtc(),
    );
  }

  /// Returns the public key as a Base64 string.
  String get publicKeyBase64 => base64Encode(publicKey);

  /// Returns the private key as a Base64 string (or null if not present).
  String? get privateKeyBase64 =>
      privateKey != null ? base64Encode(privateKey!) : null;

  /// Generates a new Ed25519 keypair.
  ///
  /// Deprecated: Use [CryptoRepository.generateIdentity] instead.
  static Future<CryptoIdentity> generate(Role role) {
    throw UnimplementedError('Use CryptoRepository.generateIdentity() instead.');
  }
}
