**FideLux**

_Fides + Lux | Fiducia + Trasparenza_

Personal Finance Accountability App

**Documento di Progetto Esaustivo**

Versione 2.0 - Febbraio 2026

**CONFIDENZIALE**

# Indice

# 1\. Visione e Missione

## 1.1 Il Problema

La gestione delle finanze personali in contesti dove la fiducia tra partner deve essere ricostruita o mantenuta rappresenta una sfida complessa. Che si tratti di dipendenza dal gioco, spesa compulsiva, percorsi di riabilitazione finanziaria, o semplicemente della volontà di costruire trasparenza in una relazione, gli strumenti attuali non offrono un meccanismo credibile di accountability.

Le app di finanza personale esistenti si concentrano sul tracking individuale. Le app per coppie offrono visibilità condivisa, ma mai supervisione asimmetrica. Nessuna app sul mercato combina gestione finanziaria personale con un sistema di accountability crittograficamente verificabile e a prova di manomissione.

## 1.2 La Soluzione: FideLux

FideLux è un'applicazione mobile di gestione delle finanze personali con supervisione consapevole. Lo Sharer (la persona monitorata) invia semplicemente documentazione finanziaria - foto di scontrini, messaggi con operazioni, estratti conto - al Keeper (il partner di fiducia), che processa, valida e registra tutto in una contabilità immutabile e crittograficamente verificabile.

_Fides_ (fiducia) + _Lux_ (luce/trasparenza): FideLux è lo strumento che illumina il percorso verso la fiducia finanziaria reciproca.

## 1.3 Principi Fondamentali

- Fiducia, non controllo: il sistema supporta un percorso condiviso, non una sorveglianza unilaterale
- Trasparenza verificabile: ogni operazione è crittograficamente firmata e immutabile
- Privacy by design: nessun server centrale, dati solo sui dispositivi dei partecipanti
- Barriera d'ingresso minima per lo Sharer: inviare una foto è tutto ciò che serve
- Non-manipolabilità: nemmeno lo sviluppatore può alterare i dati consolidati
- Inclusività: multilingue, accessibile, utilizzabile su qualsiasi dispositivo

## 1.4 Differenziatori Unici

Dall'analisi di 34 applicazioni concorrenti in 5 categorie (finanza personale, finanza per coppie, recupero dipendenze, supervisione familiare, accountability), FideLux presenta cinque differenziatori che nessun concorrente possiede simultaneamente:

- Catena crittografica append-only per le transazioni finanziarie personali
- Architettura locale-first senza server centrale
- Dashboard Keeper con indicatori di rischio comportamentale
- OCR scontrini come input primario (validato dal Keeper)
- Non-manipolabilità da parte dello sviluppatore/azienda

# 2\. Attori e Ruoli

## 2.1 Sharer (Affidante)

Lo Sharer è la persona che condivide la propria vita finanziaria. Non utilizza direttamente l'app FideLux: invia semplicemente documentazione al Keeper attraverso un canale autenticato.

**Cosa fa lo Sharer:**

- Fotografa scontrini e li invia al Keeper
- Comunica operazioni finanziarie (spese, prelievi, bonifici) via messaggio
- Invia periodicamente gli estratti conto bancari (PDF/CSV)
- Può attivare il pulsante SOS per segnalare un momento di difficoltà

**Cosa NON fa lo Sharer:**

- Non categorizza le transazioni
- Non gestisce la contabilità
- Non ha accesso allo storico consolidato
- Non può modificare o cancellare ciò che ha già inviato

**Barriera d'ingresso:** Praticamente zero. Lo Sharer deve solo saper inviare una foto o un messaggio attraverso il canale scelto. Non deve installare un'app specifica, configurare chiavi, o imparare un'interfaccia.

## 2.2 Keeper (Custode)

Il Keeper è la persona di fiducia che custodisce la verità finanziaria. Utilizza l'app FideLux ed è responsabile dell'elaborazione e della validazione di tutto ciò che lo Sharer invia.

**Cosa fa il Keeper:**

- Riceve e valida i messaggi dello Sharer (verifica autenticità crittografica)
- Processa scontrini tramite OCR/LLM sul proprio dispositivo
- Categorizza e inserisce transazioni nella contabilità
- Monitora la dashboard con indicatori di rischio e trend
- Configura soglie e regole di alert
- Riconcilia la contabilità con gli estratti conto bancari
- Gestisce le richieste di chiarimento

**Responsabilità tecnica:** Tutta la complessità computazionale (OCR, LLM, categorizzazione, riconciliazione) risiede sul dispositivo del Keeper. Questo è intenzionale: il Keeper è la persona più motivata a mantenere il sistema funzionante e accurato.

## 2.3 Sviluppatore

Lo sviluppatore (che può coincidere con lo Sharer stesso) è esplicitamente privato di qualsiasi backdoor. Non ha accesso ai dati consolidati, non può alterare la catena eventi, e il codice è open-source per garantire verificabilità.

## 2.4 Terminologia Multilingue

I termini Sharer e Keeper sono gli identificatori universali nel codice. Nell'interfaccia utente vengono localizzati:

| **Termine** | **EN** | **IT** |
| --- | --- | --- |
| Sharer | Sharer | Affidante |
| Keeper | Keeper | Custode |
| FideLux Score | FideLux Score | Punteggio FideLux |
| Event Chain | Event Chain | Catena Eventi |
| SOS | SOS | SOS |

Il sistema di localizzazione utilizza Flutter intl/ARB (standard ufficiale), con supporto iniziale per Italiano e Inglese. L'architettura è predisposta per aggiungere lingue addizionali con minimo sforzo.

# 3\. Architettura del Sistema

## 3.1 Principio Architetturale: Local-First, Server-Zero

FideLux non ha backend centrale. Non ci sono server, database cloud, o endpoint esposti. Tutti i dati risiedono esclusivamente sui dispositivi dello Sharer e del Keeper. La comunicazione avviene attraverso un canale email dedicato.

**Vantaggi:**

- Nessun costo di infrastruttura server
- Nessun rischio di data breach centralizzato
- Nessun single point of failure
- Nessuna dipendenza da un'azienda (se FideLux cessasse di esistere, i dati restano sui dispositivi)
- Conformità GDPR intrinseca (nessun trasferimento dati a terzi)

## 3.2 Flusso dei Dati

Il flusso è unidirezionale nella direzione principale: Sharer invia, Keeper riceve e processa.

- Lo Sharer fotografa uno scontrino o scrive un messaggio con i dettagli di un'operazione
- Il messaggio viene firmato crittograficamente con la chiave privata dello Sharer
- Il messaggio viene inviato via email alla casella dedicata
- L'app del Keeper monitora la casella, riceve il messaggio
- Il Keeper verifica la firma crittografica (autenticità del mittente)
- Se il messaggio contiene un'immagine (scontrino), l'OCR/LLM locale estrae i dati
- Il Keeper rivede, categorizza e conferma l'inserimento nella contabilità
- La transazione viene aggiunta alla catena append-only con firma del Keeper

## 3.3 Catena Crittografica Append-Only

Ogni operazione registrata è un evento immutabile nella catena. La struttura è ispirata a protocolli validati come Secure Scuttlebutt (SSB) e Google Trillian (Certificate Transparency, RFC 6962).

**Struttura di un evento:**

- ID progressivo
- Hash dell'evento precedente (catena)
- Timestamp
- Tipo evento (TRANSACTION, RECONCILIATION, STATEMENT_UPLOAD, SOS, ecc.)
- Payload (dati della transazione)
- Firma crittografica dello Sharer (per eventi originati dallo Sharer)
- Firma crittografica del Keeper (per la validazione e inserimento)
- Metadati: sorgente (OCR, manuale, bank_sync), livello di fiducia, ai_engine utilizzato

**Proprietà garantite:**

- Append-only: nessuna cancellazione, solo eventi compensativi
- Integrità: qualsiasi alterazione rompe la catena di hash
- Non ripudiabilità: la firma dello Sharer prova che il messaggio originale proviene da lui
- Auditabilità: il Keeper (e potenzialmente un terzo verificatore) può ricostruire e verificare l'intera catena

**Implementazione crittografica:** Ed25519 per le firme digitali, SHA-256 per l'hashing della catena. Libreria Dart: pointycastle.

## 3.4 Canale di Comunicazione: Email

L'MVP utilizza email come canale di comunicazione. È stato scelto perché:

- Universalmente disponibile e gratuito
- Non richiede che lo Sharer installi un'app specifica
- Supporta allegati (foto scontrini, PDF estratti conto)
- Funziona in modo asincrono (lo Sharer invia quando vuole)
- L'app del Keeper monitora la casella via IMAP standard

**Sicurezza del canale:**

- Ogni messaggio è firmato digitalmente dallo Sharer
- Il contenuto può essere cifrato con la chiave pubblica del Keeper
- Verifica integrità e sequenza
- Solo messaggi con firma valida vengono processati; tutti gli altri sono scartati silenziosamente

## 3.5 Validazione dei Messaggi

La validazione crittografica garantisce che solo lo Sharer possa inviare messaggi validi al Keeper. Il processo:

- Al pairing iniziale, Sharer e Keeper si scambiano le chiavi pubbliche (via QR code in persona)
- Ogni messaggio dello Sharer include una firma Ed25519 creata con la sua chiave privata
- Il Keeper verifica la firma con la chiave pubblica dello Sharer già in suo possesso
- Messaggi non firmati o con firma non valida vengono rifiutati e loggati come anomalia

Questo meccanismo impedisce a terzi (incluso lo sviluppatore) di iniettare messaggi falsi nel sistema.

# 4\. Funzionalità Core

## 4.1 Invio Documentazione (Sharer)

Lo Sharer ha tre modalità di invio, tutte estremamente semplici:

**A) Foto Scontrino:** Lo Sharer fotografa lo scontrino e lo invia al canale dedicato. È la modalità primaria e più affidabile. Il Keeper riceve l'immagine, l'OCR/LLM estrae automaticamente data, importo, esercente e articoli.

**B) Messaggio Testuale:** Per operazioni senza scontrino (prelievo ATM, bonifico, pagamento online), lo Sharer invia un messaggio di testo con i dettagli. Es: "Prelievo 200€ Bancomat UniCredit Via Roma".

**C) Estratto Conto:** Periodicamente (tipicamente mensile), lo Sharer scarica l'estratto conto dalla propria banca (PDF o CSV) e lo invia al Keeper per la riconciliazione.

## 4.2 Elaborazione e Contabilità (Keeper)

Il Keeper è il centro operativo del sistema. Dopo aver ricevuto e validato un messaggio:

- Per foto scontrino: l'OCR/LLM locale estrae i dati, il Keeper rivede e conferma
- Per messaggi testuali: l'LLM locale interpreta e struttura i dati, il Keeper verifica
- Per estratti conto: il parser estrae i movimenti, l'LLM effettua il fuzzy matching con le transazioni già registrate

Il Keeper categorizza ogni transazione e la inserisce nella catena append-only. Può anche aggiungere note, richiedere chiarimenti, o segnalare anomalie.

## 4.3 Gestione Conti

Il Keeper gestisce i conti dello Sharer nel sistema:

- Inserimento conti correnti, carte, portafogli contanti
- Saldo iniziale dichiarato (evento GENESIS firmato)
- Supporto multi-conto e multi-valuta
- Riconciliazione periodica con estratti conto reali

## 4.4 FideLux Score

Il FideLux Score è un indicatore composito 0-100 che sintetizza la salute finanziaria e comportamentale dello Sharer. Viene calcolato dal Keeper e mostrato nella dashboard.

**Componenti del punteggio:**

- Aderenza al budget (peso: 25%)
- Tasso di documentazione scontrini (peso: 25%)
- Stabilità pattern di spesa (peso: 20%)
- Progresso obiettivi di risparmio (peso: 15%)
- Tempestività nelle comunicazioni e riconciliazioni (peso: 15%)

**Visualizzazione:** Semaforo con trend. Verde (70-100): tutto bene. Giallo (40-69): attenzione. Rosso (0-39): criticità. Freccia trend indica la direzione rispetto al periodo precedente.

## 4.5 Sistema di Alert (4 Livelli)

| **Livello** | **Nome** | **Esempio** | **Azione** |
| --- | --- | --- | --- |
| 🟢  | Normale | Spese nella norma | Nessuna |
| 🟡  | Advisory | Entertainment +30% sopra baseline | Notifica Keeper |
| 🔴  | Critico | 3 prelievi contanti grandi in 24h | Alert immediato Keeper |
| 🆘  | SOS | Sharer attiva il bottone SOS | Alert urgente + cooling-off |

## 4.6 Meccanismo SOS e Cooling-Off

Lo Sharer può attivare un pulsante SOS in qualsiasi momento per segnalare un momento di difficoltà (tentazione di gioco, spesa compulsiva, crisi). L'attivazione:

- Notifica immediatamente il Keeper
- Può attivare un periodo di cooling-off opzionale (48 ore) prima di grandi acquisti discrezionali
- Viene registrata nella catena append-only come evento SOS
- Il Keeper può rispondere con supporto e suggerimenti

## 4.7 Privacy Lock con Audit Trail

Lo Sharer può temporaneamente limitare la visibilità del Keeper (es. per comprare un regalo a sorpresa). La restrizione stessa però viene registrata nella catena append-only: il Keeper non vede i dettagli, ma sa che esiste un periodo di privacy lock. Questo meccanismo bilancia privacy legittima e accountability.

# 5\. Riconciliazione Bancaria

## 5.1 Il Problema del Delta

Le transazioni non direttamente iniziate dallo Sharer (addebiti SEPA, stipendio, interessi bancari, rate mutuo, utenze domiciliate) creano un divario tra saldo reale e saldo tracciato in FideLux. Questo delta, se non gestito, mina la credibilità del sistema.

## 5.2 Soluzione: Upload Estratto Conto Mensile

Lo Sharer scarica l'estratto conto mensile dalla propria banca e lo invia al Keeper. L'AI locale del Keeper estrae i movimenti, li confronta con le transazioni già registrate, e produce un report di riconciliazione.

**Processo:**

- Promemoria in-app: "Il 5 del mese, invia l'estratto conto di gennaio"
- Lo Sharer scarica dalla banca (2 tap), invia al Keeper (1 tap)
- L'AI processa e compara (30 secondi)
- Il Keeper rivede i risultati (1 minuto)
- Se non fatto entro il 10 del mese, alert automatico al Keeper

**Tempo totale richiesto allo Sharer:** meno di 3 minuti al mese.

## 5.3 Categorie di Matching AI

L'AI del Keeper classifica ogni riga dell'estratto conto in una di tre categorie:

| **Categoria** | **Significato** | **Azione** |
| --- | --- | --- |
| Matched | Già presente in FideLux, importo corrispondente | Conferma automatica |
| Mismatch | Presente ma importo diverso | Revisione Keeper (sospetto) |
| Nuovo | Non tracciato in FideLux | Sharer deve categorizzare |

## 5.4 Catalogo Operazioni Ricorrenti

Il Keeper configura le operazioni ricorrenti attese (stipendio il 27, bolletta luce bimestrale, Netflix mensile, rata mutuo). FideLux auto-genera eventi RECURRING_EXPECTED alle date previste. Lo Sharer conferma o corregge l'importo effettivo. Se non confermato entro N giorni, alert al Keeper.

Questo meccanismo copre circa l'80% delle operazioni passive (che sono prevedibili e periodiche).

## 5.5 Gerarchia di Fiducia delle Fonti

| **Livello** | **Fonte** | **Fiducia** |
| --- | --- | --- |
| 1   | Transazione manuale con scontrino OCR | Massima |
| 2   | Transazione manuale senza scontrino | Media |
| 3   | Ricorrente confermata dallo Sharer | Buona |
| 4   | Ricorrente auto-generata non confermata | Condizionale |
| 5   | Transazione passiva dichiarata retroattivamente | Bassa |
| 6   | Delta non spiegato | Zero (alert) |

Il FideLux Score pesa diversamente ogni tipo. Un trend nel tempo (es. percentuale di transazioni livello 1-2 in calo) diventa un indicatore predittivo.

## 5.6 Tipi di Evento per la Riconciliazione

- STATEMENT_UPLOAD: contiene hash del file e periodo coperto
- STATEMENT_MATCHED: transazione già presente, confermata dalla banca
- STATEMENT_NEW: trovata nell'estratto ma non in FideLux
- STATEMENT_MISMATCH: importo diverso tra FideLux e banca
- RECONCILIATION: checkpoint periodico (saldo reale vs saldo FideLux)

Tutti firmati, tutti append-only, tutti visibili al Keeper.

## 5.7 Strategia Open Banking (V2+)

Con l'integrazione Open Banking (prevista per V2), le transazioni sincronizzate dalla banca diventano una nuova categoria con fiducia molto alta: BANK_SYNCED. Il delta dovrebbe tendere a zero. Qualsiasi transazione bancaria senza corrispondente evento FideLux viene segnalata automaticamente.

**Provider raccomandati per l'Italia:**

- Salt Edge: centinaia di connessioni a banche italiane, Partner Program (opera sotto la loro licenza AISP), già usato da Plannix e EasyPol in Italia
- Enable Banking: 2.500+ banche in 29 paesi europei, partnership recente con A-Tono per 26.000+ imprese italiane, documentazione specifica per Intesa, UniCredit, BPM, Poste
- Tink (Visa): 3.400+ banche in 18 mercati europei, orientato enterprise

**Nota:** GoCardless/Nordigen non accetta più nuove registrazioni dal luglio 2025. PSD3 (atteso 2026-2027) dovrebbe abbassare significativamente le barriere d'ingresso con API standardizzate.

# 6\. Strategia AI e LLM

## 6.1 Requisiti Computazionali

I task AI di FideLux sono leggeri: estrazione campi strutturati da scontrini, categorizzazione in 15-20 categorie predefinite, fuzzy matching tra testo bancario e transazioni. Si tratta di extraction/classification, non di reasoning complesso.

**Volume tipico mensile per utente:** 30-50 transazioni + 1 estratto conto = circa 50.000-80.000 token/mese = frazioni di centesimo con qualsiasi provider cloud.

## 6.2 Strategia a Due Tier (sul dispositivo del Keeper)

Poiché tutta l'elaborazione AI avviene sul dispositivo del Keeper, la strategia è adattata alle capacità hardware del Keeper.

**Dispositivo Keeper capace (>6GB RAM, chipset recente):** L'app propone il download del modello on-device come opzione primaria. I dati finanziari non escono mai dal telefono.

- Modello: Gemma 3n 2B-IT quantizzato 4-bit (~1.5 GB)
- OCR: Google ML Kit on-device (testo puro, ~140ms, 18MB, offline)
- LLM: interpretazione intelligente del testo OCR estratto
- Performance: 8-13 secondi per il parsing di uno scontrino su telefono mid-range
- Aggiornamento modello: scaricabile in background come aggiornamento dati, senza aggiornare l'app

**Dispositivo Keeper limitato (<6GB RAM, chipset datato):** L'app propone direttamente il collegamento a Google Gemini via OAuth, senza menzionare dettagli tecnici.

- Flusso: Google Sign-In OAuth (single tap sull'account già presente) per collegare Gemini
- Tier gratuito Gemini Flash: limiti di rate più che sufficienti per un singolo utente
- I dati vengono inviati a Google per l'elaborazione (l'utente viene informato chiaramente)

## 6.3 UX della Configurazione AI

L'utente non vede mai "on-device vs cloud". Vede tre opzioni comprensibili nelle impostazioni:

| **Modalità** | **Descrizione** | **Requisiti** |
| --- | --- | --- |
| Modalità Privata | I dati non escono dal telefono. Download 1.5 GB. | \>6GB RAM, spazio disco |
| Modalità Cloud | Più veloce. Richiede account Google. | Connessione internet |
| Modalità Avanzata (BYOK) | Usa il tuo provider AI preferito. | API key del provider |

L'app sceglie automaticamente la modalità migliore in base al dispositivo. L'utente può sempre sovrascrivere la scelta nelle impostazioni.

## 6.4 Prompt AI Localizzati

Poiché i formati di scontrini e estratti conto variano per paese (IVA vs MwSt vs TVA, formati data, valute, formati fiscali), i prompt AI sono template localizzati:

- Template IT: scontrino fiscale italiano, codice fiscale, partita IVA, format dd/mm/yyyy
- Template EN: receipt, VAT number, format mm/dd/yyyy o dd/mm/yyyy
- Ogni template include few-shot examples specifici per il paese

L'aggiunta di nuove lingue/paesi richiede la creazione di nuovi template prompt, oltre alla localizzazione UI.

## 6.5 Parsing Estratto Conto: Approccio Ibrido

Per l'estratto conto mensile, si usa un approccio a due step per ridurre il consumo di token:

- Parser strutturale deterministico (on-device): template per i formati CSV/XLS delle principali banche italiane (Intesa, UniCredit, Poste, N26, Revolut). Pochi formati, stabili, parsabili con regex.
- LLM solo per edge case: PDF non strutturati e fuzzy matching intelligente (es. "PAGO BANCOMAT 15/01 ESSELUNGA MI" = "Spesa Esselunga 47.32€").

Questo riduce drasticamente il consumo di token e permette di restare nel tier gratuito quasi indefinitamente.

# 7\. Analisi di Mercato

## 7.1 Panorama Competitivo

Dall'analisi di 34 applicazioni in 5 categorie, non esiste un concorrente diretto. I competitor più vicini coprono solo un sottoinsieme delle funzionalità di FideLux:

| **App** | **Categoria** | **Vicinanza a FideLux** | **Gap** |
| --- | --- | --- | --- |
| Carefull (\$12.99/mese) | Elder care finance | Alta | Solo anziani, richiede bank API |
| Folded | Gambling recovery | Alta | Solo gioco, early-stage |
| Monarch Money (\$9.99/mese) | Finanza coppie | Media | No supervisione gerarchica |
| Greenlight/FamZoo | Supervisione genitori | Media | Solo minori, richiede carta dedicata |
| StickK | Accountability | Media-bassa | No finanza, solo goal generici |
| Honeydue | Finanza coppie | Bassa | Qualità in declino, nessuna accountability |

**Gap critico nel mercato:** Nessuna app combina finanza personale + dashboard Keeper con accountability + supporto recupero dipendenze + catena crittografica a prova di manomissione.

## 7.2 Dimensione del Mercato

**Globale:** Financial Wellness Software è un mercato da \$3.8B nel 2024, proiettato a \$10.2B entro il 2034 (CAGR 10.4%). Europa: ~\$325-475M.

**Italia come mercato di lancio strategico:**

- Crisi gioco d'azzardo: €157.4B di volume di gioco (2024), 1.5M giocatori problematici (solo 5.4% cerca aiuto), più alta prevalenza di gioco tra teenager in Europa
- Mercato PFM sottosviluppato: i fintech italiani (Satispay, Hype) si concentrano su pagamenti, non budgeting
- Economia del contante: l'OCR degli scontrini è particolarmente prezioso perché il contante non lascia traccia digitale
- Fit culturale: l'"amministratore di sostegno" è un ruolo legale riconosciuto - il modello Keeper è culturalmente intuitivo

## 7.3 Segmenti Target (Italia)

| **Segmento** | **Dimensione stimata** | **Priorità** |
| --- | --- | --- |
| Coppie con frizione finanziaria | 2-3M (da 12M nuclei familiari) | Alta |
| Recupero dipendenza gioco | 1.5M giocatori problematici | Alta |
| Famiglie con membri finanziariamente dipendenti | 14M over 65, 5.5M giovani adulti, 3.1M disabili | Media |
| Disturbo da spesa compulsiva | 3.4M italiani (5.8% adulti) | Media |
| Terapeuti/consulenti finanziari (B2B) | Licenze a €20-50/mese | Futura |

**Mercato indirizzabile de-duplicato:** 5-8M utenti in Italia, 40-70M in Europa, 300-500M globalmente.

# 8\. Interfaccia Utente e UX

## 8.1 Principi di Design

- Moderna, semplice, leggibile: pochi elementi per schermata, CTA chiare
- Mobile-first, tablet-friendly: layout reattivo con breakpoints
- Material 3 (Android) + adattamenti Cupertino (iOS) con coerenza visiva
- Accessibilità: font scalabile, contrasto adeguato, target touch min 44px
- Tema Lux: colori neutri caldi + accento ambra/oro (tema luce)

## 8.2 App Keeper - Navigazione Principale

Il Keeper è l'unico utente con l'app completa. La navigazione principale:

| **Tab** | **Funzione** | **Contenuto Principale** |
| --- | --- | --- |
| Inbox | Messaggi in arrivo dallo Sharer | Lista messaggi da processare, validazione, preview OCR |
| Dashboard | Panoramica salute finanziaria | FideLux Score, KPI, alert attivi, trend |
| Contabilità | Timeline eventi e transazioni | Lista append-only, filtri, dettaglio evento |
| Report | Analisi e grafici | Spese per categoria, trend, confronto periodi |
| Impostazioni | Configurazione | Soglie alert, conti, sicurezza, AI engine |

## 8.3 Flusso di Lavoro Keeper: Ricezione e Processamento

Quando lo Sharer invia uno scontrino, il Keeper vede nell'Inbox:

- Card con preview immagine, timestamp, stato firma (verificata/non verificata)
- Tap sulla card: view espansa con immagine e dati estratti dall'OCR
- Dati presentati in forma editabile: totale, esercente, data, articoli, categoria suggerita
- Keeper conferma, corregge se necessario, seleziona conto
- "Inserisci nella contabilità" → transazione aggiunta alla catena
- Animazione catena (link chain) come conferma visiva dell'immutabilità

## 8.4 Dashboard Keeper: Pattern, Non Dati Grezzi

La dashboard non mostra ogni transazione, ma pattern e anomalie (modello Bark/Aura):

- FideLux Score (0-100) con semaforo e freccia trend
- Indicatori per categoria con colore (verde/giallo/rosso)
- "Tasso di documentazione" questo mese vs media
- Alert attivi con gravità
- Digest settimanale automatico via email

## 8.5 Sharer: Interfaccia Minimale (Opzionale)

Lo Sharer non ha bisogno di un'app per usare FideLux. Tuttavia, un'app minimale opzionale può offrire:

- Pulsante SOS ben visibile
- Camera ottimizzata per scontrini (guida bordo, flash automatico)
- Stato: "Ultimo messaggio inviato: 2h fa, ricevuto dal Keeper"
- Inbox richieste di chiarimento dal Keeper
- Streak di giorni consecutivi di documentazione
- FideLux Score personale (se il Keeper lo condivide)

L'alternativa è semplicemente usare email/messenger come canale.

# 9\. Stack Tecnologico

## 9.1 Framework e Linguaggio

| **Componente** | **Tecnologia** | **Motivazione** |
| --- | --- | --- |
| Framework | Flutter 3.x | Cross-platform (iOS + Android) da singolo codebase |
| Linguaggio | Dart | Nativo Flutter, type-safe, ottime performance |
| State Management | Riverpod | Reattivo, testabile, supporto async nativo |
| Routing | go_router | Declarativo, route guards per auth e ruoli |
| Localizzazione | Flutter intl/ARB | Standard ufficiale, type-safe, zero dipendenze |

## 9.2 Sicurezza e Crittografia

| **Componente** | **Tecnologia** | **Uso** |
| --- | --- | --- |
| Firme digitali | Ed25519 (pointycastle) | Firma eventi, verifica autenticità |
| Hashing catena | SHA-256 (pointycastle) | Integrità catena append-only |
| Storage chiavi | Android Keystore / iOS Keychain | Chiavi private, API keys |
| Comunicazione | IMAP/SMTP (Dart) | Canale email per sync Sharer→Keeper |

## 9.3 AI e Machine Learning

| **Componente** | **Tecnologia** | **Uso** |
| --- | --- | --- |
| OCR | Google ML Kit Text Recognition | Estrazione testo da scontrini (on-device) |
| LLM on-device | flutter_gemma / Cactus SDK | Interpretazione testo, categorizzazione |
| LLM cloud | Google Gemini API (OAuth) | Fallback per dispositivi limitati |
| LLM avanzato | BYOK (OpenAI, Anthropic, ecc.) | Utenti esperti con proprie API key |

## 9.4 Storage Locale

- Database locale: SQLite via drift (Dart) o Isar per la catena eventi
- File system: scontrini e allegati cifrati nel filesystem locale
- Backup: esportazione cifrata della catena eventi (opzionale, gestita dal Keeper)

## 9.5 Architettura Software

Clean Architecture leggera a 4 layer:

- Presentation: UI (Widget, schermate)
- Application: use case (logica di business)
- Domain: entities, regole di validazione, modelli
- Data: storage locale, email provider, AI engine adapter

L'AI engine è dietro un'interfaccia astratta (adapter pattern), così il passaggio tra on-device, Gemini e BYOK è trasparente per il resto dell'app.

# 10\. Roadmap

## 10.1 MVP (Fase 1) - 3-4 mesi

Obiettivo: validare il flusso core Sharer → Keeper con utenti reali.

- Pairing crittografico Sharer-Keeper (QR code)
- Canale email: invio firmato e ricezione con verifica
- Keeper: inbox messaggi, validazione firma, inserimento manuale transazioni
- Keeper: gestione conti e catena append-only
- Keeper: dashboard base con KPI essenziali
- OCR scontrini via Google ML Kit (on-device)
- Localizzazione IT + EN

## 10.2 V1.0 (Fase 2) - +2-3 mesi

Obiettivo: aggiungere intelligenza e automazione.

- Integrazione LLM on-device (Gemma) per interpretazione scontrini
- Gemini OAuth come fallback per dispositivi limitati
- FideLux Score composito
- Sistema alert a 4 livelli
- Meccanismo SOS e cooling-off
- Upload e parsing estratto conto mensile
- Catalogo operazioni ricorrenti
- Weekly digest automatico via email al Keeper

## 10.3 V2.0 (Fase 3) - +3-4 mesi

Obiettivo: integrazione bancaria e scalabilità.

- Integrazione Open Banking (Salt Edge o Enable Banking) via Partner Program
- Riconciliazione automatica bank-synced vs FideLux
- Report avanzati con export PDF/CSV
- Template budget (recupero, studente, famiglia, debito)
- Privacy lock con audit trail
- App Sharer minimale opzionale

## 10.4 V3.0 (Fase 4) - Futuro

- Supporto PSD3 (API bancarie standardizzate, atteso 2026-2027)
- Modalità terapeuta/supervisore esterno (B2B)
- Modello ML predittivo per pattern di rischio
- Lingue addizionali (ES, FR, DE, PT)
- Community e marketplace template

# 11\. Sicurezza e Threat Model

## 11.1 Principi di Sicurezza

- Zero trust verso lo Sharer: ogni messaggio deve essere crittograficamente verificato
- Zero trust verso lo sviluppatore: nessuna backdoor, codice open-source
- Keeper come unica fonte di verità: il database canonico è sul suo dispositivo
- Defense in depth: firma + hash + catena + validazione

## 11.2 Vettori di Attacco e Mitigazioni

| **Minaccia** | **Scenario** | **Mitigazione** |
| --- | --- | --- |
| Sharer invia dati falsi | Scontrino fotografato per un'altra persona | Il Keeper verifica manualmente; FideLux Score penalizza inconsistenze nel tempo |
| Terzo invia messaggi falsi | Qualcuno impersona lo Sharer via email | Firma crittografica Ed25519: solo chi possiede la chiave privata può firmare |
| Sharer modifica la catena | Tentativo di alterare transazioni passate | La catena è sul dispositivo del Keeper; lo Sharer non vi ha accesso |
| Sviluppatore inserisce backdoor | Versione app con codice malevolo | Codice open-source, build riproducibili, la catena esistente è verificabile indipendentemente |
| Compromissione dispositivo Keeper | Malware sul telefono del Keeper | Catena esportabile e verificabile da terzi; backup cifrato; PIN/biometria |
| Falsificazione estratto conto | Sharer modifica CSV prima di inviarlo | Hash del file nell'evento; con Open Banking (V2), i dati bancari diretti diventano "verità" |

## 11.3 Separazione dei Poteri

| **Azione** | **Sharer** | **Keeper** | **Sviluppatore** |
| --- | --- | --- | --- |
| Inviare documentazione | Sì  | No  | No  |
| Inserire transazioni nella catena | No  | Sì  | No  |
| Leggere lo storico completo | No  | Sì  | No  |
| Modificare eventi passati | No  | No  | No  |
| Configurare soglie e alert | No  | Sì  | No  |
| Verificare integrità catena | No  | Sì  | Sì (open-source) |

# 12\. Modello di Business

## 12.1 Strategia Pricing

FideLux può seguire un modello freemium con le seguenti tier:

| **Tier** | **Prezzo** | **Include** |
| --- | --- | --- |
| Free | €0  | Flusso core completo, 1 coppia Sharer-Keeper, AI on-device, alert base |
| Premium | €4.99/mese | Report avanzati, template budget, weekly digest, multi-conto illimitato |
| Pro (B2B) | €20-50/mese | Modalità terapeuta/supervisore professionale, multi-client, export certificato |

**Vantaggi del modello:**

- Nessun costo AI per l'utente free (on-device o Gemini free tier)
- Nessun costo infrastruttura server per lo sviluppatore
- Il tier B2B giustifica il prezzo più alto per professionisti

## 12.2 Canali di Distribuzione

- Google Play Store + Apple App Store (primario)
- Sito web con landing page dedicata per ogni segmento target
- Partnership con associazioni anti-gioco (es. ALEA, Giocatori Anonimi)
- Partnership con terapeuti finanziari e consulenti
- Content marketing: blog su financial wellness, testimonianze anonime

# 13\. Test AI sul Campo (Pre-Sviluppo)

Prima di scrivere codice, è possibile validare l'efficacia dell'AI on-device per i task FideLux utilizzando app gratuite già disponibili.

## 13.1 Google AI Edge Gallery

App sperimentale di Google, disponibile su Play Store (US) o come APK da GitHub per altri paesi. Supporta Gemma 3n con modalità Ask Image (carica immagine e fai domande) e Prompt Lab (prompt testuali).

**Test 1 - Parsing Scontrino:** Fotografare 10-15 scontrini italiani reali, caricarli in Ask Image con Gemma 3n, e chiedere di estrarre data, importo, esercente, articoli in formato JSON. Annotare accuratezza e tempi.

## 13.2 SmolChat

App open-source su Play Store. Esegue modelli GGUF localmente con interfaccia chat. Supporta system prompt personalizzabili.

**Test 2 - Categorizzazione:** Impostare un system prompt con le categorie FideLux e inviare descrizioni di transazioni bancarie. Verificare accuratezza della categorizzazione.

**Test 3 - Fuzzy Matching:** Incollare righe di estratto conto e transazioni FideLux, chiedere al modello di matchare. Verificare la qualità del matching.

Questi test forniscono dati reali di performance sul proprio hardware prima di investire tempo nello sviluppo.

# 14\. Appendice: Tipi di Evento

Lista completa dei tipi di evento nella catena append-only:

| **Tipo Evento** | **Origine** | **Descrizione** |
| --- | --- | --- |
| GENESIS | Keeper | Creazione conto con saldo iniziale |
| TRANSACTION | Keeper (da Sharer) | Transazione standard (spesa, entrata, bonifico, prelievo) |
| CORRECTION | Keeper | Evento compensativo per correggere una transazione precedente |
| RECEIPT_SCAN | Keeper (da Sharer) | Scontrino processato via OCR/LLM |
| RECONCILIATION | Keeper | Checkpoint: saldo reale vs saldo FideLux |
| STATEMENT_UPLOAD | Keeper (da Sharer) | Upload estratto conto con hash file |
| STATEMENT_MATCHED | Keeper (AI) | Transazione confermata dall'estratto conto |
| STATEMENT_NEW | Keeper (AI) | Movimento bancario non tracciato in FideLux |
| STATEMENT_MISMATCH | Keeper (AI) | Discrepanza importo tra FideLux e banca |
| RECURRING_EXPECTED | Keeper (auto) | Operazione ricorrente attesa |
| RECURRING_CONFIRMED | Keeper (da Sharer) | Operazione ricorrente confermata |
| SOS | Sharer | Segnalazione momento di difficoltà |
| PRIVACY_LOCK | Sharer | Attivazione/disattivazione restrizione visibilità |
| ALERT | Keeper (auto) | Alert generato dal sistema |
| CLARIFICATION_REQUEST | Keeper | Richiesta chiarimento allo Sharer |
| CLARIFICATION_RESPONSE | Sharer | Risposta a richiesta chiarimento |
| BANK_SYNCED | Keeper (API) | Transazione sincronizzata via Open Banking (V2+) |
| CONFIG_CHANGE | Keeper | Modifica configurazione (soglie, categorie, conti) |
