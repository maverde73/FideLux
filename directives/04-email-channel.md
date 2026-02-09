# Direttiva 04 — Canale Email

**Obiettivo:** Implementare il canale di comunicazione Sharer→Keeper via email: monitoraggio IMAP della casella dedicata, invio SMTP di messaggi firmati, validazione firme crittografiche in ricezione.

**Criticità:** 🟡 MEDIO

**Prerequisiti:** Direttive 02 e 03 completate. Keypair Ed25519 e pairing funzionanti.

---

## Input

- `FIDELUX.md` sezione 3.4 (Canale di Comunicazione: Email)
- `FIDELUX.md` sezione 3.5 (Validazione dei Messaggi)
- `FIDELUX.md` sezione 4.1 (Invio Documentazione — 3 modalità)
- Libreria: `enough_mail` (già in pubspec.yaml)

## Output Atteso

1. Configurazione account email dedicato (IMAP + SMTP)
2. Servizio IMAP che monitora la casella e riceve nuovi messaggi
3. Parsing dei messaggi: estrae firma, payload (testo o immagine), metadata
4. Validazione firma Ed25519 su ogni messaggio ricevuto
5. Servizio SMTP per invio risposte (richieste di chiarimento)
6. Schermata Settings con configurazione email
7. `flutter analyze` clean, test funzionanti

---

## Step 1 — Domain Entities

### lib/domain/entities/inbox_message.dart

```
Campi:
- id (String, UUID generato alla ricezione)
- emailMessageId (String, Message-ID dell'email)
- receivedAt (DateTime, UTC)
- senderEmail (String)
- subject (String?)
- bodyText (String? — corpo testuale del messaggio)
- attachments (List<MessageAttachment> — foto scontrini, PDF)
- sharerSignature (String? — firma Ed25519 base64, estratta dall'header custom)
- signatureValid (bool? — null se non ancora verificata)
- status (enum: received, verified, rejected, processed)
- rawEmail (String — email originale per audit)

class MessageAttachment {
  final String filename;
  final String mimeType;    // image/jpeg, application/pdf, etc.
  final Uint8List data;
  final int sizeBytes;
}
```

### lib/domain/entities/email_config.dart

```
Campi:
- imapHost (String)
- imapPort (int, default 993)
- smtpHost (String)
- smtpPort (int, default 465)
- email (String)
- password (String)
- useSsl (bool, default true)
- pollingIntervalSeconds (int, default 300 — 5 minuti)
- sharerEmail (String — email dello Sharer, per filtrare)
```

---

## Step 2 — Email Repository

### lib/domain/repositories/email_repository.dart

```
abstract class EmailRepository {
  /// Configura la connessione email (salva credenziali)
  Future<void> configure(EmailConfig config);

  /// Testa la connessione IMAP
  Future<bool> testConnection();

  /// Recupera i nuovi messaggi dalla casella (dall'ultimo check)
  Future<List<InboxMessage>> fetchNewMessages();

  /// Segna un messaggio come letto sul server
  Future<void> markAsRead(String emailMessageId);

  /// Invia un messaggio (per richieste di chiarimento Keeper→Sharer)
  Future<void> sendMessage({
    required String to,
    required String subject,
    required String body,
    String? keeperSignature,
  });

  /// Verifica se la configurazione email esiste
  Future<bool> isConfigured();

  /// Cancella la configurazione
  Future<void> clearConfig();
}
```

### lib/data/email/email_service.dart

Implementazione con `enough_mail`:

<rules>
1. Connessione IMAP con SSL/TLS (porta 993 default)
2. Filtra solo messaggi dal sharerEmail configurato
3. La firma Ed25519 è nel custom header "X-FideLux-Signature"
4. Il payload firmato è: subject + body text (concatenati, no attachments)
5. Gli allegati sono estratti e salvati come MessageAttachment
6. fetchNewMessages() usa IMAP SEARCH per messaggi UNSEEN
7. Il polling è gestito da un timer esterno (non dentro il service)
8. Le credenziali email sono salvate in flutter_secure_storage (mai in plain text)
9. testConnection() tenta login IMAP e restituisce true/false
10. Gestisci timeout (30s) e errori di rete con Failure tipizzati
</rules>

**Formato email dallo Sharer:**

```
From: sharer@email.com
To: fidelux-dedicated@email.com
Subject: [FideLux] Scontrino Esselunga
X-FideLux-Signature: <base64 Ed25519 signature of subject+body>
X-FideLux-Version: 1

Spesa Esselunga 47.32€, pagato contanti

[attachment: scontrino.jpg]
```

---

## Step 3 — Message Validation Service

### lib/data/email/message_validator.dart

<rules>
1. Per ogni messaggio ricevuto, verifica:
   a. Il mittente corrisponde a sharerEmail configurato
   b. L'header X-FideLux-Signature è presente
   c. La firma è valida rispetto alla chiave pubblica dello Sharer
2. Il payload da verificare è: subject + "\n" + bodyText (UTF-8 encoded)
3. Se la firma è valida → status = verified
4. Se la firma manca o è invalida → status = rejected (ma il messaggio viene comunque salvato per audit)
5. Se il mittente non corrisponde → messaggio scartato silenziosamente (log warning)
6. Messaggi senza header X-FideLux-Version vengono accettati con warning (backward compatibility)
</rules>

---

## Step 4 — Use Cases

### lib/application/fetch_inbox.dart

```
Input: nessuno
Output: List<InboxMessage> (nuovi messaggi, verificati)
Side effects: 
  - Connessione IMAP, fetch, validazione firma
  - Salva messaggi nel repository locale (per ora in memoria, DB nel modulo 05)
Errori:
  - Email non configurata → Failure("Configura la casella email nelle Impostazioni")
  - Connessione fallita → Failure("Impossibile connettersi al server email")
  - Timeout → Failure("Timeout connessione")
```

### lib/application/send_clarification.dart

```
Input: String recipientEmail, String subject, String body
Output: void
Side effects: Firma il messaggio con chiave Keeper, invia via SMTP
```

---

## Step 5 — Email Config UI

### lib/presentation/screens/settings/email_config_screen.dart

Accessibile da Settings → tap su "Configurazione Email".

<rules>
1. Form con campi: IMAP host, IMAP port, SMTP host, SMTP port, Email, Password, Email Sharer
2. Presets per provider comuni (bottoni): Gmail, Outlook, Yahoo, Custom
   - Gmail: imap.gmail.com:993, smtp.gmail.com:465
   - Outlook: outlook.office365.com:993, smtp.office365.com:587
3. Pulsante "Testa Connessione" → loading → risultato (successo/errore)
4. Pulsante "Salva" abilitato solo dopo test connessione riuscito
5. Password oscurata, salvata in secure storage
6. Mostra nota: "Per Gmail, usa una App Password (non la password del tuo account)"
7. Tutti i campi con validazione (email valida, porta numerica, host non vuoto)
8. Outlined TextField stile Material 3 (da brand-guidelines)
</rules>

### Aggiorna lib/presentation/screens/settings/settings_screen.dart

Aggiungi ListTile "Configurazione Email" con:
- Leading: icona mail_outline
- Subtitle: "Configurata" (verde) o "Non configurata" (grigio)
- onTap: naviga a email_config_screen

---

## Step 6 — Inbox Polling Provider

### lib/presentation/providers/inbox_providers.dart

```dart
// Config email (async, da secure storage)
final emailConfigProvider = FutureProvider<EmailConfig?>((ref) async {
  final repo = ref.read(emailRepositoryProvider);
  if (await repo.isConfigured()) {
    return repo.loadConfig();
  }
  return null;
});

// Lista messaggi inbox (refreshable)
final inboxMessagesProvider = FutureProvider<List<InboxMessage>>((ref) async {
  final fetchInbox = ref.read(fetchInboxUseCaseProvider);
  return fetchInbox.execute();
});

// Contatore messaggi non letti (per badge nella navigation)
final unreadCountProvider = Provider<int>((ref) {
  final messages = ref.watch(inboxMessagesProvider);
  return messages.whenOrNull(
    data: (msgs) => msgs.where((m) => m.status == MessageStatus.verified).length,
  ) ?? 0;
});
```

---

## Step 7 — Localizzazione

### Stringhe da aggiungere

**EN:**
```json
{
  "emailConfigTitle": "Email Configuration",
  "emailConfigImapHost": "IMAP Server",
  "emailConfigImapPort": "IMAP Port",
  "emailConfigSmtpHost": "SMTP Server",
  "emailConfigSmtpPort": "SMTP Port",
  "emailConfigEmail": "Email Address",
  "emailConfigPassword": "Password",
  "emailConfigSharerEmail": "Sharer's Email Address",
  "emailConfigTestConnection": "Test Connection",
  "emailConfigTestSuccess": "Connection successful!",
  "emailConfigTestFailed": "Connection failed: {error}",
  "emailConfigSave": "Save",
  "emailConfigGmailNote": "For Gmail, use an App Password (not your account password)",
  "emailConfigPresetGmail": "Gmail",
  "emailConfigPresetOutlook": "Outlook",
  "emailConfigPresetCustom": "Custom",
  "emailConfigured": "Configured",
  "emailNotConfigured": "Not configured",
  "inboxSignatureVerified": "Signature verified",
  "inboxSignatureRejected": "Invalid signature — message rejected",
  "inboxSignatureMissing": "No signature — treat with caution"
}
```

**IT:**
```json
{
  "emailConfigTitle": "Configurazione Email",
  "emailConfigImapHost": "Server IMAP",
  "emailConfigImapPort": "Porta IMAP",
  "emailConfigSmtpHost": "Server SMTP",
  "emailConfigSmtpPort": "Porta SMTP",
  "emailConfigEmail": "Indirizzo Email",
  "emailConfigPassword": "Password",
  "emailConfigSharerEmail": "Email dell'Affidante",
  "emailConfigTestConnection": "Testa Connessione",
  "emailConfigTestSuccess": "Connessione riuscita!",
  "emailConfigTestFailed": "Connessione fallita: {error}",
  "emailConfigSave": "Salva",
  "emailConfigGmailNote": "Per Gmail, usa una App Password (non la password del tuo account)",
  "emailConfigPresetGmail": "Gmail",
  "emailConfigPresetOutlook": "Outlook",
  "emailConfigPresetCustom": "Personalizzato",
  "emailConfigured": "Configurata",
  "emailNotConfigured": "Non configurata",
  "inboxSignatureVerified": "Firma verificata",
  "inboxSignatureRejected": "Firma non valida — messaggio rifiutato",
  "inboxSignatureMissing": "Nessuna firma — trattare con cautela"
}
```

---

## Step 8 — Test

### test/email/email_service_test.dart

Usa mock per `enough_mail` (non serve connessione reale nei test).

```
Test da implementare:
1. "parses valid FideLux email with signature" — estrae firma, body, attachments
2. "validates correct signature" — messaggio firmato correttamente → verified
3. "rejects tampered message" — body modificato dopo firma → rejected
4. "rejects missing signature" — no header X-FideLux-Signature → rejected con warning
5. "filters by sender email" — messaggi da altri mittenti → scartati
6. "extracts image attachments" — allegato JPEG estratto con dimensione corretta
7. "handles connection timeout gracefully" — timeout → Failure, non crash
8. "saves and loads email config from secure storage" — round-trip config
```

---

## Validazione Finale

```bash
flutter analyze
flutter test test/email/
flutter run
```

Checklist:
- [ ] Settings mostra "Configurazione Email" con stato
- [ ] Form email con presets Gmail/Outlook funzionanti
- [ ] "Testa Connessione" dà feedback chiaro (successo/errore)
- [ ] Salvataggio credenziali in secure storage
- [ ] (Con account email reale) Fetch messaggi dalla casella funziona

---

## Casi Limite Noti

- Gmail richiede "App Password" (non la password dell'account) se 2FA è attivo. L'app deve indicarlo chiaramente.
- `enough_mail` potrebbe avere conflitti di versione. Se fallisce, alternative: `mailer` per SMTP + `imap_client` per IMAP (due package separati).
- Alcuni provider email (Outlook, Yahoo) richiedono OAuth2 invece di password. Per l'MVP usiamo password/app-password. OAuth2 è un miglioramento futuro.
- Gli allegati grandi (>5MB) possono causare problemi di memoria. Limita la dimensione in fase di fetch e mostra warning.
- Il polling in background su iOS è limitato. Per l'MVP, il fetch avviene solo quando l'app è in foreground.

---

## Prossimo Modulo

Completato il canale email, procedi con `directives/05-accounting-core.md` (gestione conti, transazioni, database SQLite).
