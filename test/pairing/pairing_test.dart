import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'package:fidelux/domain/entities/crypto_identity.dart';
import 'package:fidelux/domain/entities/pairing_data.dart';
import 'package:fidelux/domain/repositories/key_storage_repository.dart';
import 'package:fidelux/application/pairing/process_pairing_qr.dart';

import 'pairing_test.mocks.dart';

@GenerateMocks([KeyStorageRepository])
void main() {
  group('PairingData', () {
    test('serialization works', () {
      const data = PairingData(
        publicKeyBase64: 'abc',
        role: Role.keeper,
        email: 'test@example.com',
      );
      final jsonFn = data.toJson();
      expect(jsonFn['k'], 'abc');
      expect(jsonFn['r'], 'keeper');
      expect(jsonFn['e'], 'test@example.com');

      final qrString = data.toQrString();
      final decoded = PairingData.fromQrString(qrString);
      
      expect(decoded.publicKeyBase64, 'abc');
      expect(decoded.role, Role.keeper);
      expect(decoded.email, 'test@example.com');
    });

    test('serialization works without email', () {
      const data = PairingData(
        publicKeyBase64: 'xyz',
        role: Role.sharer,
      );
      final qrString = data.toQrString();
      final decoded = PairingData.fromQrString(qrString);
      
      expect(decoded.publicKeyBase64, 'xyz');
      expect(decoded.role, Role.sharer);
      expect(decoded.email, null);
    });
  });

  group('ProcessPairingQr', () {
    late MockKeyStorageRepository mockStorage;
    late ProcessPairingQr useCase;

    setUp(() {
      mockStorage = MockKeyStorageRepository();
      useCase = ProcessPairingQr(mockStorage);
    });

    test('successfully saves peer key when roles differ', () async {
      const qrData = '{"k":"c29tZWtleQ==","r":"sharer","e":"s@s.com"}'; // "somekey" base64
      
      await useCase.call(qrData: qrData, myRole: Role.keeper);

      verify(mockStorage.savePeerPublicKey(Role.sharer, any)).called(1);
    });

    test('throws exception when pairing with same role', () async {
      const qrData = '{"k":"key","r":"keeper"}';
      
      expect(
        () => useCase.call(qrData: qrData, myRole: Role.keeper),
        throwsException,
      );
      
      verifyNever(mockStorage.savePeerPublicKey(any, any));
    });

    test('throws FormatException on invalid QR', () async {
      expect(
        () => useCase.call(qrData: 'not json', myRole: Role.keeper),
        throwsException, // FormatException usually
      );
    });
  });
}
