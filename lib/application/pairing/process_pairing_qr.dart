import 'dart:convert';

import '../../domain/entities/crypto_identity.dart';
import '../../domain/entities/pairing_data.dart';
import '../../domain/repositories/key_storage_repository.dart';

/// Use case: Process scanned pairing data and save the peer's key.
class ProcessPairingQr {
  ProcessPairingQr(this.keyStorageRepository);

  final KeyStorageRepository keyStorageRepository;

  Future<void> call({
    required String qrData,
    required Role myRole,
  }) async {
    // 1. Parse QR Data
    final data = PairingData.fromQrString(qrData);

    // 2. Validate Role Compatibility
    if (data.role == myRole) {
      throw Exception('Cannot pair with same role (${data.role.name}).');
    }

    // 3. Extract Key
    final peerKey = base64Decode(data.publicKeyBase64);

    // 4. Save Peer Key
    await keyStorageRepository.savePeerPublicKey(data.role, peerKey);
    
    // TODO: Save email/contact info if present
  }
}
