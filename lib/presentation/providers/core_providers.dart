
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/repositories/crypto_repository.dart';
import '../../domain/repositories/key_storage_repository.dart';
import '../../data/crypto/crypto_service.dart';
import '../../data/crypto/secure_key_storage.dart';

// Singletons for core repositories

final keyStorageRepositoryProvider = Provider<KeyStorageRepository>((ref) {
  return SecureKeyStorage();
});

final cryptoRepositoryProvider = Provider<CryptoRepository>((ref) {
  return CryptoService();
});
