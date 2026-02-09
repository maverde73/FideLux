import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/chain/chain_service.dart';
import '../../data/crypto/crypto_service.dart';
import '../../data/crypto/secure_key_storage.dart';
import '../../domain/entities/crypto_identity.dart';
import '../../domain/repositories/chain_repository.dart';
import '../../domain/repositories/crypto_repository.dart';
import '../../domain/repositories/key_storage_repository.dart';

// --- Data Layer Providers ---

/// Provider for the singleton [CryptoRepository].
final cryptoRepositoryProvider = Provider<CryptoRepository>((ref) {
  return CryptoService();
});

/// Provider for the singleton [KeyStorageRepository].
final keyStorageProvider = Provider<KeyStorageRepository>((ref) {
  return SecureKeyStorage();
});

/// Provider for the singleton [ChainRepository].
final chainRepositoryProvider = Provider<ChainRepository>((ref) {
  return ChainService(crypto: ref.read(cryptoRepositoryProvider));
});

// --- Identity Providers ---

/// Provider that asynchronously loads the Keeper's identity from storage.
///
/// Returns null if no Keeper identity is stored.
final keeperIdentityProvider = FutureProvider<CryptoIdentity?>((ref) async {
  final storage = ref.read(keyStorageProvider);
  final privateKey = await storage.loadPrivateKey(Role.keeper);
  final publicKey = await storage.loadPublicKey(Role.keeper);

  if (privateKey == null || publicKey == null) return null;

  return CryptoIdentity.fromKeys(publicKey, privateKey, Role.keeper);
});

/// Provider that asynchronously loads the Sharer's identity (public key only usually) from storage.
///
/// WARNING: On the Keeper's device, this will likely only have the public key.
/// On the Sharer's device, it has both.
final sharerIdentityProvider = FutureProvider<CryptoIdentity?>((ref) async {
  final storage = ref.read(keyStorageProvider);
  final privateKey = await storage.loadPrivateKey(Role.sharer); // Null on Keeper device
  final publicKey = await storage.loadPublicKey(Role.sharer);

  if (publicKey == null) return null;

  return CryptoIdentity.fromKeys(publicKey, privateKey, Role.sharer);
});
