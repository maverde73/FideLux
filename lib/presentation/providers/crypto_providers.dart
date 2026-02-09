import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/chain/chain_service.dart';
import '../../domain/entities/crypto_identity.dart';
import '../../domain/repositories/chain_repository.dart';
import 'core_providers.dart';
import 'accounting_providers.dart';

// --- Chain Repository Provider ---

/// Provider for the singleton [ChainRepository].
final chainRepositoryProvider = Provider<ChainRepository>((ref) {
  return ChainService(ref.read(chainEventsDaoProvider));
});

// --- Role Provider ---

/// Determines the user's role by checking which identity has a private key.
final myRoleProvider = FutureProvider<Role?>((ref) async {
  final storage = ref.read(keyStorageRepositoryProvider);
  final keeperKey = await storage.loadPrivateKey(Role.keeper);
  if (keeperKey != null) return Role.keeper;
  final sharerKey = await storage.loadPrivateKey(Role.sharer);
  if (sharerKey != null) return Role.sharer;
  return null;
});

// --- Identity Providers ---

/// Provider that asynchronously loads the Keeper's identity from storage.
///
/// Returns null if no Keeper identity is stored.
final keeperIdentityProvider = FutureProvider<CryptoIdentity?>((ref) async {
  final storage = ref.read(keyStorageRepositoryProvider);
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
  final storage = ref.read(keyStorageRepositoryProvider);
  final privateKey = await storage.loadPrivateKey(Role.sharer);
  final publicKey = await storage.loadPublicKey(Role.sharer);

  if (publicKey == null) return null;

  return CryptoIdentity.fromKeys(publicKey, privateKey, Role.sharer);
});
