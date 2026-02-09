import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../application/pairing/generate_pairing_qr.dart';
import '../../application/pairing/process_pairing_qr.dart';
import '../../domain/entities/crypto_identity.dart';
import '../../presentation/providers/crypto_providers.dart';

// --- Pairing Use Cases ---

final generatePairingQrProvider = Provider<GeneratePairingQr>((ref) {
  return GeneratePairingQr(ref.read(keyStorageProvider));
});

final processPairingQrProvider = Provider<ProcessPairingQr>((ref) {
  return ProcessPairingQr(ref.read(keyStorageProvider));
});

// --- Peer Identity Provider ---

/// Provides the Peer's identity (public key) if paired.
final peerIdentityProvider = FutureProvider.family<CryptoIdentity?, Role>((ref, peerRole) async {
  final storage = ref.read(keyStorageProvider);
  final peerKey = await storage.loadPeerPublicKey(peerRole);

  if (peerKey == null) return null;

  return CryptoIdentity(
    publicKey: peerKey,
    privateKey: null,
    role: peerRole,
    createdAt: DateTime.now(), // Estimate creation or store it
  );
});
