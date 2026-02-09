import 'dart:convert';
import 'dart:typed_data';

import 'crypto_identity.dart';

/// Data exchanged via QR code during pairing.
class PairingData {
  const PairingData({
    required this.publicKeyBase64,
    required this.role,
    this.email,
  });

  final String publicKeyBase64;
  final Role role;
  final String? email;

  /// Creates PairingData from JSON map.
  factory PairingData.fromJson(Map<String, dynamic> json) {
    return PairingData(
      publicKeyBase64: json['k'] as String,
      role: Role.values.firstWhere((e) => e.name == json['r']),
      email: json['e'] as String?,
    );
  }

  /// Converts to compact JSON map for QR code.
  Map<String, dynamic> toJson() {
    return {
      'k': publicKeyBase64,
      'r': role.name,
      if (email != null) 'e': email,
    };
  }

  /// Returns the JSON string representation.
  String toQrString() => jsonEncode(toJson());

  /// Parses a QR string into PairingData.
  static PairingData fromQrString(String qrString) {
    try {
      final json = jsonDecode(qrString) as Map<String, dynamic>;
      return PairingData.fromJson(json);
    } catch (e) {
      throw FormatException('Invalid QR data format');
    }
  }
}
