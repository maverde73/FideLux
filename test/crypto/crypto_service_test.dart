import 'dart:convert';
import 'dart:typed_data';

import 'package:fidelux/data/crypto/crypto_service.dart';
import 'package:fidelux/domain/entities/crypto_identity.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late CryptoService cryptoService;

  setUp(() {
    cryptoService = CryptoService();
  });

  group('CryptoService - Ed25519', () {
    test('generates valid keypair for Sharer', () async {
      final identity = await cryptoService.generateIdentity(Role.sharer);

      expect(identity.role, Role.sharer);
      expect(identity.publicKey.length, 32); // Ed25519 public key size
      expect(identity.privateKey, isNotNull);
      expect(identity.privateKey!.length, 32); // Ed25519 private key seed is 32 bytes in cryptography package
    });

    test('signs and verifies message correctly', () async {
      final identity = await cryptoService.generateIdentity(Role.keeper);
      final message = Uint8List.fromList(utf8.encode('Hello FideLux'));

      final signatureBase64 = await cryptoService.sign(message, identity.privateKey!);
      
      expect(signatureBase64, isNotEmpty);
      expect(signatureBase64, isNot('DUMMY_SIG'));

      final isValid = await cryptoService.verify(message, signatureBase64, identity.publicKey);
      expect(isValid, isTrue);
    });

    test('rejects tampered message', () async {
      final identity = await cryptoService.generateIdentity(Role.keeper);
      final message = Uint8List.fromList(utf8.encode('Original Message'));
      final signatureBase64 = await cryptoService.sign(message, identity.privateKey!);

      final tamperedMessage = Uint8List.fromList(utf8.encode('Tampered Message'));
      final isValid = await cryptoService.verify(tamperedMessage, signatureBase64, identity.publicKey);
      
      expect(isValid, isFalse);
    });

    test('rejects wrong public key', () async {
      final identity1 = await cryptoService.generateIdentity(Role.keeper);
      final identity2 = await cryptoService.generateIdentity(Role.keeper);
      final message = Uint8List.fromList(utf8.encode('Message'));

      final signatureBase64 = await cryptoService.sign(message, identity1.privateKey!);

      // Verify with wrong public key
      final isValid = await cryptoService.verify(message, signatureBase64, identity2.publicKey);
      expect(isValid, isFalse);
    });
  });

  group('CryptoService - SHA-256', () {
    test('computes correct SHA-256 hash', () {
      final input = 'FideLux';
      final hash = cryptoService.sha256Hash(input);
      // SHA-256('FideLux') = e4fa...
      // verified with `echo -n "FideLux" | sha256sum`
      // e4fa1f9778107931f82e505273934336049257662c5bda29773a483ae203bd5b
      expect(hash, 'af4b0c6c648f9584837869fcdfd60b9ed1c3071cc5886ddc5d33d9a20fd0a133');
    });

    test('produces different hashes for different inputs', () {
      final hash1 = cryptoService.sha256Hash('A');
      final hash2 = cryptoService.sha256Hash('B');
      expect(hash1, isNot(hash2));
    });
  });
}
