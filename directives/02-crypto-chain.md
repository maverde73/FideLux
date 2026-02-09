# Direttiva 02 — Catena Crittografica

**Obiettivo:** Implementare il sistema crittografico core di FideLux: generazione keypair Ed25519, firma/verifica messaggi, catena append-only con hash SHA-256, storage sicuro delle chiavi.

**Criticità:** 🟡 MEDIO

**Prerequisiti:** Direttiva 01 completata. Il progetto compila e la struttura 4-layer esiste.

---

## Input

- `FIDELUX.md` sezione 3.3 (Catena Crittografica Append-Only)
- `FIDELUX.md` sezione 3.5 (Validazione dei Messaggi)
- `FIDELUX.md` sezione 14 (Appendice: Tipi di Evento)
- Libreria: `pointycastle` (già in pubspec.yaml)
- Storage chiavi: `flutter_secure_storage` (già in pubspec.yaml)

## Output Atteso

1. Entity `KeyPair` con generazione, export/import, storage sicuro
2. Entity `ChainEvent` con struttura completa (id, hash precedente, tipo, payload, firme)
3. Servizio firma/verifica Ed25519
4. Servizio catena append-only con verifica integrità
5. Unit test per: generazione chiavi, firma, verifica, catena valida, catena corrotta (detection)
6. `flutter analyze` clean, `flutter test` green

---

## Step 1 — Domain Entities

### lib/domain/entities/crypto_identity.dart

Rappresenta l'identità crittografica di un attore (Sharer o Keeper).

```
Campi:
- publicKey (Uint8List, 32 bytes Ed25519)
- privateKey (Uint8List, 64 bytes Ed25519) — nullable (il Keeper ha solo la pubblica dello Sharer)
- role (enum: sharer, keeper)
- createdAt (DateTime)

Metodi:
- factory CryptoIdentity.generate(Role role) — genera keypair Ed25519
- factory CryptoIdentity.fromPublicKey(Uint8List pubKey, Role role) — solo chiave pubblica
- String get publicKeyBase64 — export base64
- factory CryptoIdentity.fromBase64(String pubKeyB64, Role role) — import da base64
```

### lib/domain/entities/chain_event.dart

Rappresenta un singolo evento nella catena append-only.

```
Campi:
- sequence (int, progressivo partendo da 0)
- previousHash (String, SHA-256 hex dell'evento precedente — "0" × 64 per il GENESIS)
- timestamp (DateTime, UTC)
- eventType (enum EventType — tutti i tipi dalla sezione 14 di FIDELUX.md)
- payload (Map<String, dynamic> — dati della transazione, serializzati JSON)
- sharerSignature (String? — firma Ed25519 base64, presente se evento originato dallo Sharer)
- keeperSignature (String — firma Ed25519 base64, sempre presente)
- metadata (EventMetadata — sorgente, livello fiducia, ai_engine)
- hash (String — SHA-256 di questo evento, calcolato deterministicamente)

Metodo computeHash():
  SHA-256 di: "$sequence|$previousHash|${timestamp.toIso8601String()}|${eventType.name}|${jsonEncode(payload)}|$keeperSignature"
  Questo produce l'hash che verrà usato come previousHash dall'evento successivo.
```

### lib/domain/entities/event_type.dart

```dart
enum EventType {
  genesis,
  transaction,
  correction,
  receiptScan,
  reconciliation,
  statementUpload,
  statementMatched,
  statementNew,
  statementMismatch,
  recurringExpected,
  recurringConfirmed,
  sos,
  privacyLock,
  alert,
  clarificationRequest,
  clarificationResponse,
  bankSynced,
  configChange,
}
```

### lib/domain/entities/event_metadata.dart

```
Campi:
- source (enum: manual, ocr, bankSync, system, ai)
- trustLevel (int, 1-6 dalla gerarchia di fiducia sezione 5.5)
- aiEngine (String? — "mlkit", "gemma", "gemini", "byok", null se manuale)
```

---

## Step 2 — Crypto Service

### lib/domain/repositories/crypto_repository.dart

Interfaccia astratta (Layer Domain):

```
abstract class CryptoRepository {
  /// Genera un nuovo keypair Ed25519
  CryptoIdentity generateIdentity(Role role);

  /// Firma un messaggio con la chiave privata
  String sign(Uint8List message, Uint8List privateKey);

  /// Verifica una firma con la chiave pubblica
  bool verify(Uint8List message, String signatureBase64, Uint8List publicKey);

  /// Calcola SHA-256 di una stringa
  String sha256Hash(String input);
}
```

### lib/data/crypto/crypto_service.dart

Implementazione concreta (Layer Data) usando `pointycastle`:

<rules>
1. Usa Ed25519 da pointycastle per firma/verifica
2. Usa SHA-256 da pointycastle per hashing catena
3. Le firme sono encode/decode base64
4. Le chiavi sono Uint8List (32 bytes pubblica, 64 bytes privata)
5. Il metodo sign() prende il messaggio come bytes e restituisce la firma in base64
6. Il metodo verify() restituisce true/false, mai eccezione
7. Gestisci errori con try-catch e restituisci false su verifica fallita
</rules>

---

## Step 3 — Key Storage Service

### lib/domain/repositories/key_storage_repository.dart

```
abstract class KeyStorageRepository {
  Future<void> savePrivateKey(Role role, Uint8List privateKey);
  Future<Uint8List?> loadPrivateKey(Role role);
  Future<void> savePublicKey(Role role, Uint8List publicKey);
  Future<Uint8List?> loadPublicKey(Role role);
  Future<void> savePeerPublicKey(Uint8List publicKey);
  Future<Uint8List?> loadPeerPublicKey();
  Future<void> deleteAll();
}
```

### lib/data/crypto/secure_key_storage.dart

Implementazione usando `flutter_secure_storage`:

<rules>
1. Le chiavi sono salvate come stringhe base64 in flutter_secure_storage
2. Naming keys: "fidelux_private_{role}", "fidelux_public_{role}", "fidelux_peer_public"
3. Android: usa EncryptedSharedPreferences (default di flutter_secure_storage)
4. iOS: usa Keychain con kSecAttrAccessibleWhenUnlockedThisDeviceOnly
5. Il metodo deleteAll() cancella TUTTE le chiavi FideLux (per reset/debug)
</rules>

---

## Step 4 — Chain Service

### lib/domain/repositories/chain_repository.dart

```
abstract class ChainRepository {
  /// Aggiunge un evento alla catena. Calcola hash e verifica integrità.
  Future<ChainEvent> appendEvent({
    required EventType type,
    required Map<String, dynamic> payload,
    required Uint8List keeperPrivateKey,
    String? sharerSignatureBase64,
    required EventMetadata metadata,
  });

  /// Restituisce l'ultimo evento della catena (per il previousHash)
  Future<ChainEvent?> getLastEvent();

  /// Restituisce l'intera catena ordinata per sequence
  Future<List<ChainEvent>> getFullChain();

  /// Verifica l'integrità dell'intera catena
  Future<ChainVerificationResult> verifyChain();
}
```

### lib/data/chain/chain_service.dart

<rules>
1. appendEvent() recupera l'ultimo evento, calcola previousHash, incrementa sequence
2. L'evento GENESIS ha sequence=0 e previousHash="0" × 64
3. L'hash è calcolato DOPO la firma del Keeper (la firma è parte dell'input hash)
4. verifyChain() ricalcola ogni hash e verifica la catena completa
5. ChainVerificationResult contiene: isValid (bool), brokenAtSequence (int?), errorMessage (String?)
6. Per ora lo storage è in memoria (List<ChainEvent>). Il database SQLite sarà nel modulo 05.
</rules>

---

## Step 5 — Use Cases (Layer Application)

### lib/application/generate_identity.dart

```
Input: Role (sharer o keeper)
Output: CryptoIdentity con chiavi salvate in secure storage
Side effect: Salva le chiavi nel KeyStorageRepository
```

### lib/application/sign_message.dart

```
Input: String message, Role signerRole
Output: String (firma base64)
Side effect: Legge la chiave privata dal KeyStorageRepository
Errore: Se chiave privata non trovata → Failure specifico
```

### lib/application/verify_signature.dart

```
Input: String message, String signatureBase64, Uint8List publicKey
Output: bool
Side effect: Nessuno
```

### lib/application/append_chain_event.dart

```
Input: EventType, Map<String, dynamic> payload, EventMetadata, String? sharerSignature
Output: ChainEvent (l'evento appena aggiunto)
Side effect: Aggiunge alla catena, calcola hash
Errore: Se catena corrotta → Failure, rifiuta l'inserimento
```

---

## Step 6 — Riverpod Providers

### lib/presentation/providers/crypto_providers.dart

```dart
// Provider per CryptoRepository (singleton)
final cryptoRepositoryProvider = Provider<CryptoRepository>((ref) {
  return CryptoService();
});

// Provider per KeyStorageRepository (singleton)
final keyStorageProvider = Provider<KeyStorageRepository>((ref) {
  return SecureKeyStorage();
});

// Provider per ChainRepository (singleton)
final chainRepositoryProvider = Provider<ChainRepository>((ref) {
  return ChainService(crypto: ref.read(cryptoRepositoryProvider));
});

// Provider per l'identità del Keeper (async, caricata dallo storage)
final keeperIdentityProvider = FutureProvider<CryptoIdentity?>((ref) async {
  final storage = ref.read(keyStorageProvider);
  final privateKey = await storage.loadPrivateKey(Role.keeper);
  final publicKey = await storage.loadPublicKey(Role.keeper);
  if (privateKey == null || publicKey == null) return null;
  return CryptoIdentity.fromKeys(publicKey, privateKey, Role.keeper);
});
```

---

## Step 7 — Test

### test/crypto/crypto_service_test.dart

```
Test da implementare:
1. "generates valid Ed25519 keypair" — keypair ha dimensioni corrette (32+64 bytes)
2. "signs and verifies message correctly" — firma valida restituisce true
3. "rejects tampered message" — messaggio modificato dopo firma restituisce false
4. "rejects wrong public key" — verifica con altra chiave restituisce false
5. "produces consistent SHA-256 hashes" — stesso input → stesso hash
6. "produces different hashes for different inputs" — input diversi → hash diversi
```

### test/chain/chain_service_test.dart

```
Test da implementare:
1. "creates GENESIS event with sequence 0" — primo evento ha sequence 0 e previousHash "000...0"
2. "appends events with correct sequence" — sequence incrementa di 1
3. "links events via previousHash" — evento N+1.previousHash == evento N.hash
4. "verifies valid chain" — verifyChain() su catena valida restituisce isValid=true
5. "detects tampered event" — modifica manuale del payload → verifyChain() rileva la rottura
6. "detects missing event" — rimozione evento dal mezzo → catena invalida
7. "includes keeper signature in hash computation" — stesso payload con firma diversa → hash diverso
```

### Esecuzione

```bash
flutter test test/crypto/
flutter test test/chain/
```

---

## Validazione Finale

```bash
flutter analyze          # Zero errori
flutter test             # Tutti i test green
```

Checklist:
- [ ] Ed25519 keypair si genera correttamente
- [ ] Firma e verifica funzionano (positivo e negativo)
- [ ] Catena append-only mantiene integrità
- [ ] Manomissione di un evento viene rilevata
- [ ] Chiavi salvate/caricate correttamente da secure storage
- [ ] Tutti i 13+ test passano

---

## Casi Limite Noti

- `pointycastle` potrebbe richiedere un setup specifico per Ed25519. Se l'import diretto non funziona, usa `pointycastle/export.dart` e `pointycastle/api.dart`.
- Su iOS simulator, `flutter_secure_storage` potrebbe richiedere il setup del Keychain Access Group in Xcode.
- L'hash deve essere calcolato in modo deterministico: assicurati che `jsonEncode(payload)` produca lo stesso output per lo stesso Map (ordina le chiavi se necessario).
- `DateTime` deve essere sempre UTC per evitare problemi di timezone nell'hash.

---

## Prossimo Modulo

Completata la crittografia, procedi con `directives/03-pairing.md` (scambio chiavi via QR code).
