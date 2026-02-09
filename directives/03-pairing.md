# Direttiva 03 — Pairing Sharer-Keeper

**Obiettivo:** Implementare il pairing crittografico tra Sharer e Keeper tramite scambio chiavi pubbliche via QR code in presenza fisica.

**Criticità:** 🟡 MEDIO

**Prerequisiti:** Direttiva 02 completata. Keypair Ed25519, firma/verifica e storage chiavi funzionanti.

---

## Input

- `FIDELUX.md` sezione 3.5 (Validazione dei Messaggi — scambio chiavi via QR code)
- `FIDELUX.md` sezione 2 (Attori e Ruoli)
- Librerie: `qr_flutter` (generazione QR), `mobile_scanner` (lettura QR)

## Output Atteso

1. Schermata "Setup Iniziale" che guida il Keeper nella configurazione
2. Generazione QR code con chiave pubblica del Keeper
3. Scansione QR code con chiave pubblica dello Sharer
4. Conferma pairing con verifica bidirezionale
5. Salvataggio identità Keeper + chiave pubblica Sharer in secure storage
6. Stato pairing persistente (paired/unpaired) accessibile via Riverpod
7. `flutter analyze` clean, app funzionante con flusso pairing

---

## Step 1 — Domain Entity

### lib/domain/entities/pairing_state.dart

```
enum PairingStatus { unpaired, keeperReady, paired }

class PairingState {
  final PairingStatus status;
  final CryptoIdentity? keeperIdentity;    // Keypair completo del Keeper
  final CryptoIdentity? sharerIdentity;    // Solo chiave pubblica dello Sharer
  final DateTime? pairedAt;
  final String? sharerLabel;               // Nome/etichetta opzionale dello Sharer

  bool get isPaired => status == PairingStatus.paired;
}
```

---

## Step 2 — Pairing Service

### lib/domain/repositories/pairing_repository.dart

```
abstract class PairingRepository {
  /// Inizializza il Keeper: genera keypair, salva, restituisce identità
  Future<CryptoIdentity> initializeKeeper();

  /// Genera il payload per il QR code del Keeper
  String generateKeeperQrPayload(CryptoIdentity keeperIdentity);

  /// Parsa il payload dal QR code dello Sharer
  CryptoIdentity? parseSharerQrPayload(String qrData);

  /// Completa il pairing: salva la chiave pubblica dello Sharer
  Future<PairingState> completePairing(CryptoIdentity sharerIdentity, {String? label});

  /// Carica lo stato di pairing dallo storage
  Future<PairingState> loadPairingState();

  /// Reset completo (unpair)
  Future<void> resetPairing();
}
```

### lib/data/pairing/pairing_service.dart

**Formato QR payload:**

```json
{
  "app": "fidelux",
  "version": 1,
  "role": "keeper",
  "publicKey": "<base64 Ed25519 public key>",
  "timestamp": "<ISO 8601 UTC>"
}
```

<rules>
1. Il QR payload è un JSON stringificato, compatto (no pretty print)
2. Il campo "app" e "version" permettono di validare che il QR sia di FideLux
3. Il campo "role" indica chi ha generato il QR (keeper o sharer)
4. Il timestamp serve per verificare che il QR non sia troppo vecchio (max 15 minuti)
5. parseSharerQrPayload() restituisce null se il JSON è malformato, non è di FideLux, o il ruolo è sbagliato
6. completePairing() salva la chiave pubblica dello Sharer in secure storage e aggiorna lo stato
7. loadPairingState() ricostruisce lo stato leggendo le chiavi dallo storage
</rules>

---

## Step 3 — Use Cases

### lib/application/initialize_keeper.dart

```
Input: nessuno
Output: CryptoIdentity del Keeper
Side effects: Genera keypair, salva in secure storage
Errore: Se già inizializzato → restituisce l'identità esistente (idempotente)
```

### lib/application/complete_pairing.dart

```
Input: String qrData (dal scanner)
Output: PairingState con status=paired
Side effects: Parsa il QR, valida, salva la chiave dello Sharer
Errori:
  - QR non valido → Failure("QR code non riconosciuto")
  - QR scaduto (>15min) → Failure("QR code scaduto, generane uno nuovo")
  - Ruolo sbagliato → Failure("Questo QR è di un Keeper, serve quello dello Sharer")
```

---

## Step 4 — UI Screens

### Flusso UX del Pairing

L'app al primo avvio mostra il flusso di pairing PRIMA della navigation shell:

```
1. Welcome Screen
   "Benvenuto su FideLux"
   "Sei il Custode della fiducia finanziaria"
   [Inizia configurazione] (Filled button)

2. Keeper Setup Screen
   → Genera keypair automaticamente (con loading indicator)
   → Mostra QR code con chiave pubblica del Keeper
   "Mostra questo QR code all'Affidante"
   "L'Affidante deve scansionarlo con la sua app"
   [L'Affidante ha scansionato → Prosegui]

3. Scan Sharer QR Screen
   → Camera scanner attiva
   "Ora scansiona il QR code dell'Affidante"
   → Al riconoscimento: mostra preview chiave + conferma
   [Conferma pairing] (Filled button)

4. Pairing Complete Screen
   → Animazione successo (chain link icon con glow amber)
   "Pairing completato!"
   "Ora puoi ricevere e validare i messaggi dell'Affidante"
   [Vai alla Home] → naviga alla main shell
```

### Implementazione Screens

#### lib/presentation/screens/pairing/welcome_screen.dart

<rules>
1. Layout centrato verticalmente
2. Logo/icona FideLux grande (placeholder: icona shield con luce)
3. Titolo: localizzato
4. Sottotitolo: localizzato, spiega il ruolo del Keeper
5. Un solo Filled Button primario
6. Sfondo: --background, colori dal tema FideLux
</rules>

#### lib/presentation/screens/pairing/keeper_qr_screen.dart

<rules>
1. Genera il keypair al didChangeDependencies (una volta)
2. Mostra loading mentre genera
3. QR code centrato, dimensione 280×280
4. QR code generato con qr_flutter, colore foreground --on-surface, background --surface
5. Sotto il QR: istruzioni localizzate
6. Pulsante "Prosegui" abilitato sempre (l'app non può verificare che lo Sharer abbia scansionato)
</rules>

#### lib/presentation/screens/pairing/scan_sharer_screen.dart

<rules>
1. Camera fullscreen con MobileScanner
2. Overlay con bordi arrotondati (finder) al centro
3. Testo istruzioni sopra il finder
4. Al riconoscimento QR valido: vibrazione haptic + navigazione automatica alla conferma
5. Se QR non valido: SnackBar errore (localizzato) e continua a scansionare
6. Permessi camera: richiesti automaticamente. Se negati: mostra messaggio con link alle impostazioni
</rules>

#### lib/presentation/screens/pairing/pairing_complete_screen.dart

<rules>
1. Animazione catena (vedi brand-guidelines sezione 5.10 Chain Event Animation)
2. Messaggio di successo localizzato
3. Mostra il nome/label dello Sharer se fornito
4. Filled Button "Vai alla Home"
5. Al tap: naviga alla main shell e impedisci il back (replace route)
</rules>

---

## Step 5 — Router Update

### Aggiorna lib/presentation/router/app_router.dart

<rules>
1. Aggiungi le 4 route di pairing: /welcome, /pairing/keeper-qr, /pairing/scan-sharer, /pairing/complete
2. Aggiungi un redirect guard: se PairingState.isPaired == false → redirect a /welcome
3. Se isPaired == true → redirect a /inbox (skip pairing)
4. Le route di pairing sono FUORI dalla ShellRoute (no bottom navigation)
</rules>

---

## Step 6 — Riverpod Providers

### lib/presentation/providers/pairing_providers.dart

```dart
final pairingRepositoryProvider = Provider<PairingRepository>((ref) {
  return PairingService(
    crypto: ref.read(cryptoRepositoryProvider),
    keyStorage: ref.read(keyStorageProvider),
  );
});

// Stato corrente del pairing (async, caricato dallo storage)
final pairingStateProvider = FutureProvider<PairingState>((ref) async {
  final repo = ref.read(pairingRepositoryProvider);
  return repo.loadPairingState();
});

// Notifier per aggiornare lo stato durante il flusso di pairing
final pairingNotifierProvider = StateNotifierProvider<PairingNotifier, AsyncValue<PairingState>>((ref) {
  return PairingNotifier(ref.read(pairingRepositoryProvider));
});
```

---

## Step 7 — Localizzazione

Aggiungi le stringhe ai file ARB:

### Stringhe EN da aggiungere

```json
{
  "welcomeTitle": "Welcome to FideLux",
  "welcomeSubtitle": "You are the Keeper of financial trust",
  "welcomeButton": "Start Setup",
  "keeperQrTitle": "Your Keeper QR Code",
  "keeperQrInstruction": "Show this QR code to the Sharer.\nThey need to scan it with their app.",
  "keeperQrContinue": "The Sharer has scanned it",
  "scanSharerTitle": "Scan Sharer's QR Code",
  "scanSharerInstruction": "Point the camera at the Sharer's QR code",
  "scanSharerInvalidQr": "Unrecognized QR code. Make sure it's a FideLux code.",
  "scanSharerExpiredQr": "This QR code has expired. Ask the Sharer to generate a new one.",
  "scanSharerWrongRole": "This is a Keeper's QR code. You need the Sharer's code.",
  "pairingCompleteTitle": "Pairing Complete!",
  "pairingCompleteSubtitle": "You can now receive and validate the Sharer's messages",
  "pairingCompleteButton": "Go to Home",
  "cameraPermissionDenied": "Camera permission is required to scan QR codes"
}
```

### Stringhe IT corrispondenti

```json
{
  "welcomeTitle": "Benvenuto su FideLux",
  "welcomeSubtitle": "Sei il Custode della fiducia finanziaria",
  "welcomeButton": "Inizia configurazione",
  "keeperQrTitle": "Il tuo QR Code Custode",
  "keeperQrInstruction": "Mostra questo QR code all'Affidante.\nDeve scansionarlo con la sua app.",
  "keeperQrContinue": "L'Affidante ha scansionato",
  "scanSharerTitle": "Scansiona il QR dell'Affidante",
  "scanSharerInstruction": "Inquadra il QR code dell'Affidante",
  "scanSharerInvalidQr": "QR code non riconosciuto. Assicurati che sia un codice FideLux.",
  "scanSharerExpiredQr": "Questo QR code è scaduto. Chiedi all'Affidante di generarne uno nuovo.",
  "scanSharerWrongRole": "Questo è il QR di un Custode. Serve quello dell'Affidante.",
  "pairingCompleteTitle": "Pairing completato!",
  "pairingCompleteSubtitle": "Ora puoi ricevere e validare i messaggi dell'Affidante",
  "pairingCompleteButton": "Vai alla Home",
  "cameraPermissionDenied": "Serve il permesso alla fotocamera per scansionare i QR code"
}
```

Dopo aver aggiornato i file ARB: `flutter gen-l10n`

---

## Step 8 — Test

### test/pairing/pairing_service_test.dart

```
Test da implementare:
1. "initializes keeper with valid keypair" — genera e salva correttamente
2. "generates valid QR payload" — payload JSON contiene app, version, role, publicKey
3. "parses valid sharer QR payload" — restituisce CryptoIdentity con chiave corretta
4. "rejects malformed QR data" — JSON invalido → restituisce null
5. "rejects non-FideLux QR" — campo app diverso → null
6. "rejects expired QR" — timestamp > 15 minuti fa → null
7. "rejects wrong role QR" — role=keeper quando si aspetta sharer → null
8. "completes pairing and persists state" — dopo completePairing, loadPairingState restituisce paired
9. "resetPairing clears all keys" — dopo reset, loadPairingState restituisce unpaired
```

---

## Validazione Finale

```bash
flutter analyze
flutter test test/pairing/
flutter run          # L'app mostra il flusso di pairing al primo avvio
```

Checklist:
- [ ] Al primo avvio → Welcome screen
- [ ] "Inizia configurazione" → QR code del Keeper visibile
- [ ] "Prosegui" → Camera scanner si apre
- [ ] Scansione QR valido → Pairing complete con animazione
- [ ] "Vai alla Home" → Navigation shell con 5 tab
- [ ] Al riavvio dell'app → va diretto alla Home (pairing già fatto)
- [ ] QR non valido → SnackBar errore, scanner resta attivo

---

## Casi Limite Noti

- `mobile_scanner` richiede permesso camera. Su Android aggiungilo in AndroidManifest.xml. Su iOS in Info.plist (`NSCameraUsageDescription`).
- L'emulatore non ha camera: per testare il parsing QR, aggiungi un pulsante debug "Simula Pairing" che chiama completePairing con una chiave di test. Wrappalo in `kDebugMode`.
- Il QR code ha un limite di capacità (~4KB per alphanumeric). La chiave pubblica Ed25519 in base64 è ~44 caratteri, il payload totale è ~200 bytes — abbondantemente nel limite.

---

## Prossimo Modulo

Completato il pairing, procedi con `directives/04-email-channel.md` (IMAP/SMTP per comunicazione Sharer→Keeper).
