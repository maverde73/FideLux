
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'package:fidelux/domain/entities/inbox_message.dart';
import 'package:fidelux/domain/entities/crypto_identity.dart';
import 'package:fidelux/domain/repositories/crypto_repository.dart';
import 'package:fidelux/domain/repositories/key_storage_repository.dart';
import 'package:fidelux/data/email/message_validator.dart';

import 'message_validator_test.mocks.dart';

@GenerateMocks([CryptoRepository, KeyStorageRepository])
void main() {
  late MockCryptoRepository mockCrypto;
  late MockKeyStorageRepository mockStorage;
  late MessageValidator validator;

  setUp(() {
    mockCrypto = MockCryptoRepository();
    mockStorage = MockKeyStorageRepository();
    validator = MessageValidator(mockCrypto, mockStorage);
  });

  final msg = InboxMessage(
    id: '1',
    emailMessageId: 'msg1',
    receivedAt: DateTime.now(),
    senderEmail: 'sharer@test.com',
    subject: 'Subject',
    bodyText: 'Body',
    rawEmail: '',
    sharerSignature: 'simulated_signature',
  );

  test('returns rejected if no signature present', () async {
    final noSig = InboxMessage(
        id: '1',
        emailMessageId: 'msg1',
        receivedAt: DateTime.now(),
        senderEmail: 'sharer@test.com',
        subject: 'Subject',
        bodyText: 'Body',
        rawEmail: '',
        sharerSignature: null,
    );

    final result = await validator.validate(noSig);
    expect(result.status, MessageStatus.rejected);
    expect(result.signatureValid, false);
  });

  test('returns verified if crypto check passes', () async {
    final peerKey = Uint8List.fromList([1, 2, 3]);
    when(mockStorage.loadPeerPublicKey(Role.sharer)).thenAnswer((_) async => peerKey);
    
    when(mockCrypto.verify(any, 'simulated_signature', peerKey)).thenAnswer((_) async => true);

    final result = await validator.validate(msg);

    expect(result.status, MessageStatus.verified);
    expect(result.signatureValid, true);
    verify(mockCrypto.verify(any, 'simulated_signature', peerKey)).called(1);
  });

  test('returns rejected if crypto check fails', () async {
    final peerKey = Uint8List.fromList([1, 2, 3]);
    when(mockStorage.loadPeerPublicKey(Role.sharer)).thenAnswer((_) async => peerKey);
    
    when(mockCrypto.verify(any, 'simulated_signature', peerKey)).thenAnswer((_) async => false);

    final result = await validator.validate(msg);

    expect(result.status, MessageStatus.rejected);
    expect(result.signatureValid, false);
  });

  test('returns rejected if peer key not found', () async {
    when(mockStorage.loadPeerPublicKey(Role.sharer)).thenAnswer((_) async => null);

    final result = await validator.validate(msg);

    expect(result.status, MessageStatus.rejected);
    expect(result.signatureValid, false);
  });
}
