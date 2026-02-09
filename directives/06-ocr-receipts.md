# Direttiva 06 — OCR Scontrini

**Obiettivo:** Implementare l'estrazione automatica dei dati dagli scontrini usando Google ML Kit Text Recognition on-device, con parsing intelligente e pre-compilazione del form di processamento.

**Criticità:** 🟢 BASSO

**Prerequisiti:** Direttiva 05 completata. Database, inbox e form processamento funzionanti.

---

## Input

- `FIDELUX.md` sezione 4.1 (Invio Documentazione — Foto Scontrino)
- `FIDELUX.md` sezione 6.1 (Requisiti Computazionali — task leggeri)
- `FIDELUX.md` sezione 6.5 (Parsing Estratto Conto — approccio ibrido)
- `FIDELUX.md` sezione 13 (Test AI sul Campo)
- Libreria: `google_mlkit_text_recognition` (già in pubspec.yaml)

## Output Atteso

1. Servizio OCR che estrae testo da immagini scontrini
2. Parser deterministico che identifica: totale, data, esercente, articoli
3. Pre-compilazione automatica del form di processamento (modulo 05)
4. Indicatore di confidenza per ogni campo estratto
5. Schermata review dove il Keeper verifica e corregge i dati OCR
6. `flutter analyze` clean, `flutter test` green

---

## Step 1 — OCR Service

### lib/domain/repositories/ocr_repository.dart

```
abstract class OcrRepository {
  /// Estrae testo grezzo da un'immagine
  Future<OcrResult> extractText(Uint8List imageBytes);

  /// Estrae testo da un file immagine locale
  Future<OcrResult> extractTextFromFile(String filePath);
}

class OcrResult {
  final String fullText;                    // Testo completo estratto
  final List<OcrTextBlock> blocks;          // Blocchi strutturati con posizione
  final Duration processingTime;            // Tempo di elaborazione
  final bool success;
  final String? errorMessage;
}

class OcrTextBlock {
  final String text;
  final Rect boundingBox;                   // Posizione nell'immagine
  final double confidence;                  // 0.0 - 1.0 (se disponibile)
  final List<OcrTextLine> lines;
}
```

### lib/data/ai/mlkit_ocr_service.dart

Implementazione con Google ML Kit:

<rules>
1. Usa TextRecognizer con script TextRecognitionScript.latin
2. Converti Uint8List → InputImage (via file temporaneo o InputImage.fromBytes)
3. Processa e mappa RecognizedText → OcrResult
4. Chiudi il recognizer dopo l'uso (dispose)
5. Misura il tempo di elaborazione con Stopwatch
6. Gestisci errori (immagine corrotta, formato non supportato) con Failure tipizzato
7. Tutto on-device, nessuna chiamata di rete
</rules>

---

## Step 2 — Receipt Parser (Deterministico)

### lib/data/ai/receipt_parser.dart

Parser rule-based che analizza il testo OCR per estrarre campi strutturati da scontrini italiani.

```
class ParsedReceipt {
  final String? merchant;             // Nome esercente
  final double? total;                // Importo totale in euro
  final DateTime? date;               // Data scontrino
  final String? vatNumber;            // Partita IVA
  final String? fiscalCode;           // Codice fiscale
  final List<ReceiptItem> items;      // Singoli articoli
  final Map<String, double> confidence; // Confidenza per campo (0.0-1.0)
  final String rawText;               // Testo grezzo per debug
}

class ReceiptItem {
  final String description;
  final double? price;
  final int? quantity;
}
```

<rules>
1. **Totale:** Cerca pattern: "TOTALE", "TOT.", "TOTALE EURO", "IMPORTO", "TOTALE COMPLESSIVO" seguito da un numero. Il numero più grande dopo queste keyword è probabilmente il totale. Formato: sia "47,32" che "47.32" che "€47,32" che "EUR 47,32".

2. **Data:** Cerca pattern data italiana: dd/mm/yyyy, dd-mm-yyyy, dd.mm.yyyy. Anche formati abbreviati: dd/mm/yy. Se multiple date presenti, prendi la prima (tipicamente in alto nello scontrino).

3. **Esercente:** Tipicamente le prime 1-3 righe del testo. Ignora righe che contengono solo numeri, P.IVA, C.F., o sono molto corte (<3 caratteri). La prima riga significativa è probabilmente il nome.

4. **P.IVA:** Pattern: "P.IVA", "P.I.", "PARTITA IVA" seguito da 11 cifre.

5. **Codice Fiscale:** Pattern: "C.F.", "COD.FISC." seguito da 16 caratteri alfanumerici.

6. **Articoli:** Righe tra l'header e il totale che contengono un prezzo (numero con virgola/punto). Pattern: "DESCRIZIONE     PREZZO" o "DESCRIZIONE  QTÀxPREZZO".

7. **Confidenza:** Ogni campo ha una confidenza:
   - 0.9+ se trovato con keyword esatta e formato pulito
   - 0.6-0.8 se trovato con euristica (posizione, pattern parziale)
   - 0.3-0.5 se ambiguo (multiple candidate)
   - 0.0 se non trovato

8. Il parser è deterministico (no ML). Funziona offline e in <10ms.
9. Deve gestire scontrini ruotati/storti (il testo OCR potrebbe avere righe mescolate).
10. Non fare assunzioni sul formato: se un campo non è trovato con confidenza >0.5, lascialo null.
</rules>

---

## Step 3 — AI Adapter (Interfaccia per LLM futuro)

### lib/domain/repositories/ai_engine_repository.dart

Interfaccia astratta per preparare l'integrazione LLM (modulo V1.0, non MVP):

```
abstract class AiEngineRepository {
  /// Interpreta un testo OCR e restituisce un ParsedReceipt strutturato
  Future<ParsedReceipt> parseReceipt(String ocrText, {String locale = 'it'});

  /// Categorizza una transazione basata sulla descrizione
  Future<TransactionCategory> categorize(String description, String? merchant);

  /// Indica se l'engine è disponibile
  Future<bool> isAvailable();

  /// Nome dell'engine per metadata
  String get engineName;
}
```

### lib/data/ai/rule_based_engine.dart

Implementazione MVP che usa il ReceiptParser deterministico:

```
class RuleBasedEngine implements AiEngineRepository {
  @override String get engineName => 'rule_based';
  @override Future<bool> isAvailable() async => true; // sempre disponibile

  @override
  Future<ParsedReceipt> parseReceipt(String ocrText, {String locale = 'it'}) {
    return ReceiptParser(locale: locale).parse(ocrText);
  }

  @override
  Future<TransactionCategory> categorize(String description, String? merchant) {
    return ReceiptCategorizer().categorize(description, merchant);
  }
}
```

### lib/data/ai/receipt_categorizer.dart

Categorizzazione rule-based per keyword:

```
Mappatura keyword → categoria:
- "esselunga", "coop", "conad", "lidl", "eurospin", "supermercato" → groceries
- "ristorante", "pizzeria", "bar", "caffè", "mcdonald" → dining
- "trenitalia", "italo", "atm", "autostrada", "benzina", "eni", "q8" → transport
- "enel", "eni gas", "acea", "tim", "vodafone", "fastweb" → utilities
- "farmacia", "parafarmacia" → health
- "cinema", "teatro", "netflix", "spotify", "playstation" → entertainment
- "zara", "h&m", "ovs", "decathlon" → clothing
- "prelievo", "atm", "bancomat" → cash
- "snai", "sisal", "lottomatica", "bet365", "pokerstars" → gambling (⚠️ alert!)
- default → other
```

<rules>
1. Match case-insensitive
2. Cerca in description + merchant (se presente)
3. Se la categoria è "gambling" → imposta un flag alert=true nel risultato
4. Se nessun match → restituisci "other" con confidenza 0.3
5. Se match → confidenza 0.7-0.9 a seconda della specificità
</rules>

---

## Step 4 — Aggiorna il Flusso Inbox → Processamento

### Modifica lib/presentation/screens/inbox/process_message_screen.dart

<rules>
1. Quando la schermata si apre e il messaggio ha un allegato immagine:
   a. Mostra l'immagine in alto
   b. Avvia OCR automaticamente con loading indicator ("Analisi scontrino...")
   c. Mostra il testo OCR grezzo in un area espandibile (collapsed di default)
   d. Pre-compila i campi del form con i dati estratti:
      - Importo: dal totale OCR (se confidenza > 0.5)
      - Merchant: dall'esercente OCR (se confidenza > 0.5)
      - Data: dalla data OCR (se confidenza > 0.5)
      - Categoria: dalla categorizzazione automatica
   e. Ogni campo pre-compilato mostra un indicatore di confidenza:
      - ≥0.8: chip verde "Alta"
      - 0.5-0.7: chip amber "Media"
      - <0.5: chip rosso "Bassa" o campo lasciato vuoto
   f. Il Keeper può modificare qualsiasi campo (l'OCR è un suggerimento, non una verità)
2. Se il messaggio è solo testo (no allegato):
   - Usa la categorizzazione automatica per suggerire la categoria
   - Gli altri campi restano vuoti (compilazione manuale)
3. Il metadata dell'evento registra: source=ocr, aiEngine="mlkit+rule_based"
</rules>

---

## Step 5 — Riverpod Providers

### lib/presentation/providers/ocr_providers.dart

```dart
final ocrRepositoryProvider = Provider<OcrRepository>((ref) {
  return MlkitOcrService();
});

final aiEngineProvider = Provider<AiEngineRepository>((ref) {
  return RuleBasedEngine();
});

// Provider per il risultato OCR di un messaggio specifico
final receiptParseProvider = FutureProvider.family<ParsedReceipt?, String>((ref, messageId) async {
  // Recupera il messaggio, estrai immagine, OCR, parse
  final message = await ref.read(inboxDaoProvider).getMessageById(messageId);
  if (message == null || message.attachments.isEmpty) return null;

  final ocr = ref.read(ocrRepositoryProvider);
  final engine = ref.read(aiEngineProvider);

  final ocrResult = await ocr.extractText(message.attachments.first.data);
  if (!ocrResult.success) return null;

  return engine.parseReceipt(ocrResult.fullText);
});
```

---

## Step 6 — Localizzazione

### Stringhe da aggiungere

**EN:**
```json
{
  "ocrProcessing": "Analyzing receipt...",
  "ocrComplete": "Analysis complete",
  "ocrFailed": "Could not read the receipt. Enter data manually.",
  "ocrRawText": "Raw OCR Text",
  "ocrConfidenceHigh": "High",
  "ocrConfidenceMedium": "Medium",
  "ocrConfidenceLow": "Low",
  "ocrSuggested": "Suggested by AI",
  "categoryGroceries": "Groceries",
  "categoryDining": "Dining",
  "categoryTransport": "Transport",
  "categoryUtilities": "Utilities",
  "categoryHousing": "Housing",
  "categoryHealth": "Health",
  "categoryEntertainment": "Entertainment",
  "categoryClothing": "Clothing",
  "categoryEducation": "Education",
  "categoryPersonalCare": "Personal Care",
  "categoryGifts": "Gifts",
  "categorySubscriptions": "Subscriptions",
  "categoryGambling": "Gambling",
  "categoryCash": "Cash Withdrawal",
  "categoryOther": "Other",
  "categorySalary": "Salary",
  "categoryRefund": "Refund",
  "categoryTransfer": "Transfer",
  "categoryIncomeOther": "Other Income",
  "gamblingAlert": "⚠️ Gambling category detected"
}
```

**IT:**
```json
{
  "ocrProcessing": "Analisi scontrino in corso...",
  "ocrComplete": "Analisi completata",
  "ocrFailed": "Impossibile leggere lo scontrino. Inserisci i dati manualmente.",
  "ocrRawText": "Testo OCR grezzo",
  "ocrConfidenceHigh": "Alta",
  "ocrConfidenceMedium": "Media",
  "ocrConfidenceLow": "Bassa",
  "ocrSuggested": "Suggerito dall'AI",
  "categoryGroceries": "Alimentari",
  "categoryDining": "Ristoranti / Bar",
  "categoryTransport": "Trasporti",
  "categoryUtilities": "Utenze",
  "categoryHousing": "Affitto / Mutuo",
  "categoryHealth": "Salute / Farmacia",
  "categoryEntertainment": "Svago",
  "categoryClothing": "Abbigliamento",
  "categoryEducation": "Istruzione",
  "categoryPersonalCare": "Cura personale",
  "categoryGifts": "Regali",
  "categorySubscriptions": "Abbonamenti",
  "categoryGambling": "Gioco d'azzardo",
  "categoryCash": "Prelievo contanti",
  "categoryOther": "Altro",
  "categorySalary": "Stipendio",
  "categoryRefund": "Rimborso",
  "categoryTransfer": "Giroconto",
  "categoryIncomeOther": "Altre entrate",
  "gamblingAlert": "⚠️ Rilevata categoria gioco d'azzardo"
}
```

---

## Step 7 — Test

### test/ai/receipt_parser_test.dart

```
Test con scontrini reali italiani (testo OCR simulato):

1. "extracts total from standard Italian receipt"
   Input: "ESSELUNGA\nVia Roma 15\n...\nTOTALE EURO  47,32\n..."
   Expected: total=47.32, confidence≥0.9

2. "extracts date in dd/mm/yyyy format"
   Input: "...12/01/2026..."
   Expected: date=2026-01-12

3. "extracts merchant from first lines"
   Input: "COOP LOMBARDIA\nViale Monza 23\nMilano\nP.IVA 01234567890"
   Expected: merchant="COOP LOMBARDIA"

4. "extracts P.IVA"
   Input: "P.IVA 01234567890"
   Expected: vatNumber="01234567890"

5. "handles messy OCR with low confidence"
   Input: "xXx TOTALE 47 32 xXx" (OCR parzialmente illeggibile)
   Expected: total=47.32, confidence < 0.7

6. "returns null fields when nothing found"
   Input: "illeggibile completamente"
   Expected: total=null, merchant=null, date=null

7. "parses receipt with multiple amounts and picks largest after TOTALE"
   Input: "PANE  2,50\nLATTE  1,80\nTOTALE  4,30"
   Expected: total=4.30 (not 2.50 or 1.80)
```

### test/ai/receipt_categorizer_test.dart

```
1. "categorizes Esselunga as groceries"
2. "categorizes prelievo bancomat as cash"
3. "categorizes SNAI as gambling with alert flag"
4. "returns other for unknown merchant"
5. "case insensitive matching"
```

---

## Validazione Finale

```bash
flutter analyze
flutter test test/ai/
flutter run
```

Checklist:
- [ ] Messaggio con allegato immagine → OCR automatico con loading
- [ ] Campi form pre-compilati con dati estratti
- [ ] Indicatori di confidenza visibili (chip colorati)
- [ ] Testo OCR grezzo visualizzabile in sezione espandibile
- [ ] Keeper può modificare tutti i campi suggeriti
- [ ] Messaggio senza allegato → form vuoto con solo categoria suggerita
- [ ] Categoria gambling → alert visivo
- [ ] Performance: OCR completo in <2 secondi su dispositivo medio

---

## Casi Limite Noti

- ML Kit richiede minSdkVersion 21 su Android. Verifica `android/app/build.gradle`.
- La qualità OCR dipende dalla foto: scontrini sgualciti, scuri o sfocati avranno confidenza bassa.
- Il parser deterministico funziona bene per scontrini italiani standard. Formati esotici (es. scontrini cinesi, ricevute hotel) non saranno parsati correttamente → il Keeper compila manualmente.
- ML Kit scarica il modello al primo uso (~10MB). Gestisci il caso in cui non sia ancora disponibile offline.
- Su emulatore senza camera, non puoi testare la foto. Usa immagini di test precaricate.

---

## Prossimo Modulo

Completato l'OCR, procedi con `directives/07-dashboard.md` (dashboard KPI e alert).
