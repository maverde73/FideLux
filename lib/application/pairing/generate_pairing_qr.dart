import 'dart:convert';

import '../../domain/entities/crypto_identity.dart';
import '../../domain/entities/pairing_data.dart';
import '../../domain/repositories/key_storage_repository.dart';

/// Use case: Generate the pairing QR code data for the current user.
class GeneratePairingQr {
  GeneratePairingQr(this.keyStorageRepository);

  final KeyStorageRepository keyStorageRepository;

  Future<PairingData?> call(Role myRole) async {
    // 1. Load my public key
    final publicKey = await keyStorageRepository.loadPublicKey(myRole);
    if (publicKey == null) return null;

    // 2. Create PairingData
    // Note: Email could be stored in preferences or secure storage separate from keys.
    // For MVP, we might prompt for it, or assume it's stored.
    // Let's assume for now email is null or fetched from a SettingsRepository (not yet creating one just for this).
    // We'll leave email optional/null for now.
    
    return PairingData(
      publicKeyBase64: base64Encode(publicKey),
      role: myRole,
      email: null, // TODO: Fetch from settings if available
    );
  }
}
