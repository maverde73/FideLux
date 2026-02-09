# Direttiva 05 — Contabilità Core

**Obiettivo:** Implementare la gestione conti, transazioni, database SQLite con Drift, persistenza della catena append-only, e la schermata Contabilità (Ledger) con timeline eventi.

**Criticità:** 🟡 MEDIO

**Prerequisiti:** Direttive 02 e 04 completate. Catena crittografica e inbox email funzionanti.

---

## Input

- `FIDELUX.md` sezione 4.2 (Elaborazione e Contabilità)
- `FIDELUX.md` sezione 4.3 (Gestione Conti)
- `FIDELUX.md` sezione 5.5 (Gerarchia di Fiducia delle Fonti)
- `FIDELUX.md` sezione 14 (Tipi di Evento)
- `FIDELUX.md` sezione 9.4 (Storage Locale)
- `brand-guidelines.md` sezione 5.8 (Lista Transazioni)
- Librerie: `drift`, `sqlite3_flutter_libs` (già in pubspec.yaml)

## Output Atteso

1. Database SQLite con tabelle: accounts, chain_events, transactions, inbox_messages
2. Migrazione della catena in-memory (modulo 02) verso SQLite persistente
3. CRUD per conti (create, read, update saldo)
4. Inserimento transazioni tramite catena append-only
5. Schermata Ledger con timeline eventi filtrabili
6. Schermata dettaglio transazione
7. Collegamento inbox → conferma → catena (flusso completo)
8. `flutter analyze` clean, `flutter test` green

---

## Step 1 — Database Schema (Drift)

### lib/data/local_db/app_database.dart

Definisci il database Drift con le seguenti tabelle:

#### Tabella: accounts

```
- id (text, primary key, UUID)
- name (text — es: "Conto UniCredit", "Carta Visa", "Contanti")
- type (text enum: checking, savings, credit_card, cash, other)
- currency (text, default "EUR")
- initialBalance (integer — centesimi, es: 150000 = €1500.00)
- currentBalance (integer — centesimi, ricalcolato)
- createdAt (dateTime)
- updatedAt (dateTime)
- isActive (boolean, default true)
```

#### Tabella: chain_events

```
- sequence (integer, primary key)
- previousHash (text, 64 chars hex)
- timestamp (dateTime, UTC)
- eventType (text enum)
- payload (text — JSON stringificato)
- sharerSignature (text, nullable)
- keeperSignature (text)
- metadataSource (text enum)
- metadataTrustLevel (integer, 1-6)
- metadataAiEngine (text, nullable)
- hash (text, 64 chars hex)
```

#### Tabella: transactions

```
- id (text, primary key, UUID)
- chainEventSequence (integer, foreign key → chain_events.sequence)
- accountId (text, foreign key → accounts.id)
- amount (integer — centesimi, negativo per spese, positivo per entrate)
- description (text)
- merchant (text, nullable)
- category (text enum)
- date (dateTime — data dell'operazione, non del processamento)
- notes (text, nullable)
- receiptImagePath (text, nullable — percorso locale immagine scontrino)
```

#### Tabella: inbox_messages (persistenza dei messaggi email)

```
- id (text, primary key, UUID)
- emailMessageId (text, unique)
- receivedAt (dateTime)
- senderEmail (text)
- subject (text, nullable)
- bodyText (text, nullable)
- sharerSignature (text, nullable)
- signatureValid (boolean, nullable)
- status (text enum: received, verified, rejected, processed)
- processedAt (dateTime, nullable)
- linkedChainEventSequence (integer, nullable — FK dopo processamento)
```

<rules>
1. Tutti gli importi sono in CENTESIMI (integer) per evitare errori floating point
2. Le conversioni €→centesimi e centesimi→€ avvengono solo nel layer Presentation
3. Le date sono sempre UTC nel database, convertite in locale solo nella UI
4. La tabella chain_events è append-only: nessun UPDATE o DELETE mai
5. Il currentBalance di un account è ricalcolato sommando tutte le transazioni
6. Le categorie sono un enum fisso nel codice (non configurabili dall'utente per l'MVP)
</rules>

---

## Step 2 — Categorie Transazioni

### lib/domain/entities/transaction_category.dart

```dart
enum TransactionCategory {
  // Spese
  groceries,        // Alimentari
  dining,           // Ristoranti / Bar
  transport,        // Trasporti
  utilities,        // Utenze (luce, gas, acqua, internet)
  housing,          // Affitto / Mutuo
  health,           // Salute / Farmacia
  entertainment,    // Svago / Intrattenimento
  clothing,         // Abbigliamento
  education,        // Istruzione
  personalCare,     // Cura personale
  gifts,            // Regali
  subscriptions,    // Abbonamenti
  gambling,         // Gioco d'azzardo (categoria critica — alert automatico)
  cash,             // Prelievo contanti
  other,            // Altro

  // Entrate
  salary,           // Stipendio
  refund,           // Rimborso
  transfer,         // Giroconto
  incomeOther,      // Altre entrate
}
```

Ogni categoria ha un'icona Material associata e un colore (definiti in un helper).

---

## Step 3 — DAOs (Data Access Objects)

### lib/data/local_db/daos/accounts_dao.dart

```
Metodi:
- Future<void> insertAccount(Account)
- Future<List<Account>> getAllAccounts()
- Future<Account?> getAccountById(String id)
- Future<void> updateBalance(String accountId) — ricalcola da transazioni
- Stream<List<Account>> watchAllAccounts() — stream reattivo
```

### lib/data/local_db/daos/chain_events_dao.dart

```
Metodi:
- Future<void> insertEvent(ChainEvent) — append only
- Future<ChainEvent?> getLastEvent()
- Future<List<ChainEvent>> getAllEvents({int? limit, int? offset})
- Future<List<ChainEvent>> getEventsByType(EventType type)
- Stream<List<ChainEvent>> watchRecentEvents({int limit = 50})
- Future<int> getEventCount()
```

### lib/data/local_db/daos/transactions_dao.dart

```
Metodi:
- Future<void> insertTransaction(Transaction)
- Future<List<Transaction>> getTransactionsByAccount(String accountId, {DateRange? range})
- Future<List<Transaction>> getTransactionsByCategory(TransactionCategory, {DateRange? range})
- Stream<List<Transaction>> watchRecentTransactions({int limit = 50})
- Future<Map<TransactionCategory, int>> getCategoryTotals({required DateRange range})
```

### lib/data/local_db/daos/inbox_dao.dart

```
Metodi:
- Future<void> insertMessage(InboxMessage)
- Future<void> updateMessageStatus(String id, MessageStatus, {int? linkedEventSequence})
- Future<List<InboxMessage>> getPendingMessages() — status = verified, non ancora processati
- Stream<List<InboxMessage>> watchPendingMessages()
- Future<int> getPendingCount()
```

---

## Step 4 — Aggiorna Chain Service per SQLite

### Modifica lib/data/chain/chain_service.dart

Sostituisci lo storage in-memoria con il DAO SQLite:

<rules>
1. appendEvent() ora usa chainEventsDao.insertEvent()
2. getLastEvent() ora usa chainEventsDao.getLastEvent()
3. verifyChain() ora carica tutti gli eventi dal DB e verifica sequenzialmente
4. Dopo ogni appendEvent(), inserisci anche la Transaction collegata nel TransactionsDao
5. Dopo ogni Transaction, aggiorna il balance dell'account con accountsDao.updateBalance()
6. Tutto in una transazione SQLite (drift transaction) per atomicità
</rules>

---

## Step 5 — Use Cases

### lib/application/create_account.dart

```
Input: name, type, currency, initialBalance (in centesimi)
Output: Account creato
Side effects:
  1. Inserisce account nel DB
  2. Crea evento GENESIS nella catena con saldo iniziale
  3. Firma con chiave Keeper
```

### lib/application/process_inbox_message.dart

```
Input: InboxMessage (verificato), accountId, category, amount?, merchant?, date?, notes?
Output: ChainEvent + Transaction
Side effects:
  1. Crea evento TRANSACTION (o RECEIPT_SCAN se ha allegato)
  2. Inserisce nella catena con firma Keeper + firma Sharer originale
  3. Crea Transaction collegata all'evento
  4. Aggiorna balance account
  5. Aggiorna status messaggio inbox → processed
```

### lib/application/get_account_summary.dart

```
Input: accountId, DateRange
Output: AccountSummary {
  account, currentBalance, periodIncome, periodExpenses,
  transactionCount, topCategories
}
```

---

## Step 6 — UI Schermata Ledger

### lib/presentation/screens/ledger/ledger_screen.dart

Sostituisce il placeholder della direttiva 01.

<rules>
1. AppBar con titolo localizzato "Contabilità" / "Ledger"
2. Sotto l'AppBar: chip row scrollabile orizzontalmente per filtri
   - Filtri: Tutti, per Conto (dropdown), per Categoria, per Periodo
   - Chip stile Material 3 Filter Chip
3. Body: lista transazioni scrollabile (design da brand-guidelines sezione 5.8)
   - Leading: icona categoria, bg primaryContainer, radius full
   - Title: merchant o descrizione
   - Subtitle: data + categoria
   - Trailing: importo (rosso se spesa, verde se entrata) in font mono
   - Divider con indent
4. FAB "+" per inserimento manuale transazione (senza messaggio inbox)
5. Tap su transazione → navigazione a dettaglio
6. Empty state: illustrazione + "Nessuna transazione ancora" se lista vuota
7. Pull-to-refresh per ricaricare
</rules>

### lib/presentation/screens/ledger/transaction_detail_screen.dart

<rules>
1. Card con tutti i dettagli: importo grande, merchant, data, categoria, conto, note
2. Se ha scontrino: immagine visualizzabile (tap per zoom)
3. Sezione "Catena": hash evento, sequence, firma Sharer (verified badge), firma Keeper
4. Se l'evento ha sharerSignature: mostra icona shield+check verde
5. Pulsante "Richiedi Chiarimento" → crea evento CLARIFICATION_REQUEST
6. Non-editabile (append-only: per correggere, si crea un CORRECTION event)
</rules>

---

## Step 7 — UI Schermata Inbox (aggiornamento)

### Aggiorna lib/presentation/screens/inbox/inbox_screen.dart

Sostituisce il placeholder. Ora mostra i messaggi reali dall'email.

<rules>
1. Lista di InboxMessage cards (design da brand-guidelines sezione 5.3 Inbox Card)
2. Indicatore firma: shield+check verde (verificata), shield+warning rosso (rifiutata)
3. Preview: subject + prime righe del body + thumbnail allegato se presente
4. Tap su messaggio verificato → schermata processamento
5. Messaggi rifiutati: visibili ma non processabili, con banner rosso
6. Pull-to-refresh → chiama fetchInbox
7. Empty state se nessun messaggio
8. Badge nella bottom nav aggiornato con contatore pending
</rules>

### lib/presentation/screens/inbox/process_message_screen.dart

<rules>
1. Mostra: immagine scontrino (se presente) + testo messaggio
2. Form per processamento:
   - Importo (pre-compilato se estratto da OCR — per ora manuale, OCR nel modulo 06)
   - Merchant / Descrizione
   - Data operazione (default: oggi)
   - Categoria (dropdown con icone)
   - Conto destinazione (dropdown con saldo attuale)
   - Note (opzionale)
3. Pulsante "Inserisci nella Contabilità" (Filled button)
4. Dialog di conferma con riepilogo
5. Dopo conferma: animazione catena (brand-guidelines sezione 5.10)
6. Naviga automaticamente al Ledger dopo l'animazione
</rules>

---

## Step 8 — Aggiunta Conto (da Settings)

### lib/presentation/screens/settings/accounts_screen.dart

Accessibile da Settings → "Gestione Conti".

<rules>
1. Lista conti attivi con saldo
2. FAB "+" per aggiungere conto
3. Dialog/screen per nuovo conto: nome, tipo (dropdown), valuta, saldo iniziale
4. Saldo iniziale in formato €1.234,56 (con formattazione locale)
5. Alla creazione → evento GENESIS nella catena
</rules>

---

## Step 9 — Localizzazione

### Stringhe da aggiungere

**EN:**
```json
{
  "ledgerTitle": "Ledger",
  "ledgerEmpty": "No transactions yet",
  "ledgerFilterAll": "All",
  "ledgerFilterAccount": "Account",
  "ledgerFilterCategory": "Category",
  "ledgerFilterPeriod": "Period",
  "transactionDetailTitle": "Transaction Detail",
  "transactionDetailChainInfo": "Chain Info",
  "transactionDetailSequence": "Sequence #{sequence}",
  "transactionDetailSignatureVerified": "Sharer signature verified",
  "transactionDetailRequestClarification": "Request Clarification",
  "processMessageTitle": "Process Message",
  "processMessageAmount": "Amount",
  "processMessageMerchant": "Merchant / Description",
  "processMessageDate": "Transaction Date",
  "processMessageCategory": "Category",
  "processMessageAccount": "Account",
  "processMessageNotes": "Notes (optional)",
  "processMessageConfirm": "Add to Ledger",
  "processMessageConfirmDialog": "Add this transaction to the ledger?",
  "accountsTitle": "Accounts",
  "accountsAdd": "Add Account",
  "accountsName": "Account Name",
  "accountsType": "Account Type",
  "accountsInitialBalance": "Initial Balance",
  "accountTypeChecking": "Checking Account",
  "accountTypeSavings": "Savings Account",
  "accountTypeCreditCard": "Credit Card",
  "accountTypeCash": "Cash",
  "accountTypeOther": "Other"
}
```

**IT:** (traduzioni corrispondenti)
```json
{
  "ledgerTitle": "Contabilità",
  "ledgerEmpty": "Nessuna transazione ancora",
  "ledgerFilterAll": "Tutti",
  "ledgerFilterAccount": "Conto",
  "ledgerFilterCategory": "Categoria",
  "ledgerFilterPeriod": "Periodo",
  "transactionDetailTitle": "Dettaglio Transazione",
  "transactionDetailChainInfo": "Info Catena",
  "transactionDetailSequence": "Sequenza #{sequence}",
  "transactionDetailSignatureVerified": "Firma Affidante verificata",
  "transactionDetailRequestClarification": "Richiedi Chiarimento",
  "processMessageTitle": "Processa Messaggio",
  "processMessageAmount": "Importo",
  "processMessageMerchant": "Esercente / Descrizione",
  "processMessageDate": "Data Operazione",
  "processMessageCategory": "Categoria",
  "processMessageAccount": "Conto",
  "processMessageNotes": "Note (opzionale)",
  "processMessageConfirm": "Inserisci nella Contabilità",
  "processMessageConfirmDialog": "Inserire questa transazione nella contabilità?",
  "accountsTitle": "Conti",
  "accountsAdd": "Aggiungi Conto",
  "accountsName": "Nome Conto",
  "accountsType": "Tipo Conto",
  "accountsInitialBalance": "Saldo Iniziale",
  "accountTypeChecking": "Conto Corrente",
  "accountTypeSavings": "Conto Risparmio",
  "accountTypeCreditCard": "Carta di Credito",
  "accountTypeCash": "Contanti",
  "accountTypeOther": "Altro"
}
```

---

## Step 10 — Test

### test/local_db/database_test.dart

```
1. "inserts and retrieves account" — round trip
2. "creates GENESIS event on account creation" — chain event con tipo genesis
3. "inserts transaction and updates balance" — balance ricalcolato correttamente
4. "maintains chain integrity across multiple transactions" — hash chain valida
5. "atomic: rolls back on failure" — se la transaction inserisce ma il chain fallisce → niente salvato
6. "filters transactions by account and date range"
7. "calculates category totals for period"
```

### test/application/process_inbox_message_test.dart

```
1. "creates TRANSACTION event from text message"
2. "creates RECEIPT_SCAN event from message with attachment"
3. "updates inbox message status to processed"
4. "links inbox message to chain event sequence"
5. "rejects processing of unverified message"
```

---

## Validazione Finale

```bash
flutter analyze
flutter test
flutter run
```

Checklist:
- [ ] Creazione conto da Settings con evento GENESIS
- [ ] Inbox mostra messaggi (con badge contatore)
- [ ] Tap su messaggio → form processamento con tutti i campi
- [ ] "Inserisci nella Contabilità" → animazione catena → transazione nel Ledger
- [ ] Ledger mostra timeline con importi colorati (rosso/verde)
- [ ] Dettaglio transazione mostra info catena con firma verificata
- [ ] Filtri funzionano (per conto, categoria)
- [ ] Saldo conto si aggiorna dopo ogni transazione
- [ ] Importi formattati correttamente (€1.234,56 in IT)

---

## Casi Limite Noti

- Drift richiede `build_runner` per generare il codice: `flutter pub run build_runner build`
- Il primo `build_runner` può essere lento (1-2 minuti). I successivi sono incrementali.
- Gli importi in centesimi: assicurati che il form accetti input con virgola (IT) o punto (EN) e converta correttamente.
- Il ricalcolo del balance deve gestire il saldo iniziale + somma di tutte le transazioni del conto.
- Se il DB cresce molto, le query sulla chain diventano lente. Per l'MVP va bene, per V2+ aggiungere indici e paginazione.

---

## Prossimo Modulo

Completata la contabilità, procedi con `directives/06-ocr-receipts.md` (OCR scontrini con Google ML Kit).
