# Direttiva 07 — Dashboard e Alert

**Obiettivo:** Implementare la dashboard del Keeper con KPI, indicatori di rischio, sistema alert base, e schermata Report con grafici essenziali. Questo completa l'MVP.

**Criticità:** 🟢 BASSO

**Prerequisiti:** Direttive 05 e 06 completate. Database con transazioni, conti e catena funzionanti.

---

## Input

- `FIDELUX.md` sezione 4.4 (FideLux Score)
- `FIDELUX.md` sezione 4.5 (Sistema di Alert — 4 livelli)
- `FIDELUX.md` sezione 8.4 (Dashboard Keeper: Pattern, Non Dati Grezzi)
- `brand-guidelines.md` sezione 5.4 (FideLux Score Widget)

## Output Atteso

1. Dashboard con KPI cards: saldo totale, spese mese, transazioni mese, tasso documentazione
2. FideLux Score widget (versione semplificata MVP)
3. Alert attivi con livello di gravità
4. Schermata Report con grafici base (spese per categoria, trend mensile)
5. Badge alert nella dashboard
6. `flutter analyze` clean, `flutter test` green

---

## Step 1 — Domain Entities

### lib/domain/entities/dashboard_data.dart

```
class DashboardData {
  final int totalBalance;                    // Centesimi, somma tutti i conti
  final int monthExpenses;                   // Centesimi, spese mese corrente
  final int monthIncome;                     // Centesimi, entrate mese corrente
  final int transactionCount;                // Transazioni mese corrente
  final double documentationRate;            // 0.0-1.0 (giorni con almeno 1 transazione / giorni trascorsi)
  final int fideluxScore;                    // 0-100
  final ScoreLevel scoreLevel;               // high, medium, low
  final ScoreTrend scoreTrend;               // up, down, stable
  final List<ActiveAlert> activeAlerts;
  final Map<TransactionCategory, int> categoryBreakdown;  // Centesimi per categoria
  final DateTime lastUpdated;
}

enum ScoreLevel { high, medium, low }
enum ScoreTrend { up, down, stable }

class ActiveAlert {
  final String id;
  final AlertLevel level;                    // normal, advisory, critical, sos
  final String title;
  final String description;
  final DateTime createdAt;
  final bool dismissed;
}

enum AlertLevel { normal, advisory, critical, sos }
```

---

## Step 2 — Dashboard Service

### lib/domain/repositories/dashboard_repository.dart

```
abstract class DashboardRepository {
  /// Calcola tutti i dati della dashboard per il mese corrente
  Future<DashboardData> getDashboardData();

  /// Calcola il FideLux Score (versione MVP semplificata)
  Future<int> calculateScore();

  /// Genera alert basati sui dati correnti
  Future<List<ActiveAlert>> generateAlerts();

  /// Dismissa un alert
  Future<void> dismissAlert(String alertId);
}
```

### lib/data/dashboard/dashboard_service.dart

<rules>
**FideLux Score MVP (semplificato):**

Il calcolo completo (5 componenti pesati) richiede storico. Per l'MVP, usa solo 2 componenti:

1. Tasso documentazione (50%): giorni con ≥1 transazione / giorni del mese trascorsi × 100
2. Regolarità (50%): se nessun gap > 3 giorni consecutivi = 100, altrimenti penalità progressiva

Score = (documentationRate × 50) + (regularityScore × 50)
Arrotondato a intero, clamp 0-100.

**Livelli:**
- 70-100 → ScoreLevel.high (verde)
- 40-69 → ScoreLevel.medium (amber)
- 0-39 → ScoreLevel.low (rosso)

**Trend:** Confronto con il mese precedente. Se differenza > +5 → up, < -5 → down, altrimenti stable.

**Alert generation:**
- Advisory (🟡): una categoria ha superato il 150% della media dei 2 mesi precedenti
- Advisory (🟡): nessuna transazione da 3+ giorni
- Critico (🔴): 3+ prelievi contanti in 24 ore
- Critico (🔴): categoria "gambling" presente
- SOS (🆘): evento SOS nella catena (generato dallo Sharer)

Per l'MVP, se non c'è abbastanza storico (primo mese), genera solo alert basati su regole statiche (gambling, prelievi multipli, gap documentazione).
</rules>

---

## Step 3 — Use Cases

### lib/application/get_dashboard_data.dart

```
Input: nessuno (usa mese corrente)
Output: DashboardData completo
Side effects: Interroga DB per transazioni, conti, catena eventi
```

### lib/application/get_report_data.dart

```
Input: DateRange (mese, trimestre, o custom)
Output: ReportData {
  categoryBreakdown: Map<TransactionCategory, int>,
  dailyTotals: Map<DateTime, int>,
  monthlyComparison: List<MonthTotal>,
  topMerchants: List<MerchantTotal>,
}
```

---

## Step 4 — UI Dashboard Screen

### lib/presentation/screens/dashboard/dashboard_screen.dart

Sostituisce il placeholder della direttiva 01.

<rules>
1. **ScrollView verticale** con le seguenti sezioni:

2. **FideLux Score Card** (in alto, prominente)
   - Card con bg scoreBackground (amber.50)
   - Numero grande al centro (Display Medium, bold)
   - Colore numero: scoreHigh/scoreMedium/scoreLow dal tema
   - Label sotto: "Eccellente" / "Attenzione" / "Critico" (localizzato)
   - Freccia trend: ▲ verde / ▼ rosso / ► neutro
   - Progress bar sotto (8px, radius full, colore del livello)
   - Design: vedi brand-guidelines sezione 5.4

3. **Alert Banner** (se ci sono alert attivi)
   - Card con bordo sinistro colorato (come Toast, brand-guidelines sezione 5.5)
   - Icona + titolo + descrizione breve
   - Colore bordo: verde/amber/rosso/rosso scuro per livello
   - Tap → espande dettagli
   - Swipe o "X" per dismissare (solo advisory, non critical/sos)
   - Se multipli: lista verticale, max 3 visibili + "Mostra altri"

4. **KPI Row** (2×2 griglia o row scrollabile)
   - Card "Saldo Totale": importo grande, icona account_balance
   - Card "Spese Mese": importo, icona trending_down, colore error
   - Card "Entrate Mese": importo, icona trending_up, colore success
   - Card "Transazioni": conteggio, icona receipt_long
   - Ogni card: bg surface, radius md, padding spacing.4

5. **Tasso Documentazione** (barra con percentuale)
   - "Documentazione: 85% (26/31 giorni)"
   - Progress bar lineare, colore basato sul valore (verde >70, amber >40, rosso ≤40)

6. **Spese per Categoria** (top 5)
   - Lista con icona categoria, nome, barra proporzionale, importo
   - La barra più lunga = 100%, le altre proporzionali
   - Colori: primary per la categoria maggiore, sfumature per le altre
   - "Vedi tutte" → naviga a Report

7. **Tutte le card usano Elevated Card dal tema (elevation 1, radius 12)**
8. **Pull-to-refresh per ricaricare i dati**
9. **Loading state: skeleton shimmer su tutte le card**
10. **Empty state: se nessuna transazione, mostra messaggio incoraggiante**
</rules>

---

## Step 5 — UI Report Screen

### lib/presentation/screens/reports/reports_screen.dart

Sostituisce il placeholder della direttiva 01.

<rules>
1. **AppBar** con titolo localizzato e selettore periodo (chip: Mese, Trimestre, Anno)

2. **Grafico Torta / Donut — Spese per Categoria**
   - Usa CustomPainter (nessuna libreria esterna per l'MVP)
   - Colori: palette derivata dai token semantici (primary, secondary, tertiary, error, success + varianti)
   - Legenda sotto: lista con colore dot + nome categoria + importo + percentuale
   - Tap su spicchio: evidenzia e mostra tooltip

3. **Grafico a Barre — Trend Giornaliero**
   - Asse X: giorni del mese
   - Asse Y: importo in euro
   - Barre: rosso per spese
   - Usa CustomPainter
   - Scrollabile orizzontalmente se troppe barre

4. **Confronto Mensile** (se c'è abbastanza storico)
   - 2-3 mesi affiancati: totale spese + totale entrate
   - Semplice row di card con importi e freccia percentuale variazione

5. **Top Esercenti**
   - Lista top 5 merchant per importo speso
   - Icona + nome + importo + numero transazioni

6. **Export** (futuro — per l'MVP mostra solo un pulsante disabilitato "Export PDF/CSV — Coming Soon")

7. **Se dati insufficienti: mostra messaggio "Serve almeno un mese di dati per i report completi"**
</rules>

---

## Step 6 — Aggiorna Navigation Badge

### Modifica lib/presentation/shell/main_shell.dart

<rules>
1. Il badge sulla tab Inbox mostra il conteggio messaggi non processati (da unreadCountProvider)
2. Aggiungi un secondo badge sulla tab Dashboard se ci sono alert critici o SOS non dismissati
3. Il badge Dashboard: solo se alertLevel >= critical
</rules>

---

## Step 7 — Riverpod Providers

### lib/presentation/providers/dashboard_providers.dart

```dart
final dashboardDataProvider = FutureProvider<DashboardData>((ref) async {
  final repo = ref.read(dashboardRepositoryProvider);
  return repo.getDashboardData();
});

final activeAlertsProvider = FutureProvider<List<ActiveAlert>>((ref) async {
  final repo = ref.read(dashboardRepositoryProvider);
  return repo.generateAlerts();
});

final criticalAlertCountProvider = Provider<int>((ref) {
  final alerts = ref.watch(activeAlertsProvider);
  return alerts.whenOrNull(
    data: (list) => list.where((a) =>
      !a.dismissed && (a.level == AlertLevel.critical || a.level == AlertLevel.sos)
    ).length,
  ) ?? 0;
});
```

### lib/presentation/providers/report_providers.dart

```dart
final selectedPeriodProvider = StateProvider<ReportPeriod>((ref) => ReportPeriod.month);

final reportDataProvider = FutureProvider<ReportData>((ref) async {
  final period = ref.watch(selectedPeriodProvider);
  final useCase = ref.read(getReportDataUseCaseProvider);
  return useCase.execute(period.toDateRange());
});
```

---

## Step 8 — Localizzazione

### Stringhe da aggiungere

**EN:**
```json
{
  "dashboardTitle": "Dashboard",
  "dashboardScore": "FideLux Score",
  "dashboardScoreHigh": "Excellent",
  "dashboardScoreMedium": "Attention",
  "dashboardScoreLow": "Critical",
  "dashboardTotalBalance": "Total Balance",
  "dashboardMonthExpenses": "Month Expenses",
  "dashboardMonthIncome": "Month Income",
  "dashboardTransactions": "Transactions",
  "dashboardDocumentationRate": "Documentation Rate",
  "dashboardDocumentationDays": "{documented}/{total} days",
  "dashboardTopCategories": "Top Categories",
  "dashboardViewAll": "View All",
  "dashboardNoData": "Start tracking to see your dashboard",
  "dashboardAlerts": "Active Alerts",
  "dashboardShowMoreAlerts": "Show {count} more",
  "alertAdvisory": "Advisory",
  "alertCritical": "Critical",
  "alertSos": "SOS",
  "alertCategorySpike": "{category} is {percent}% above average",
  "alertNoDocumentation": "No transactions documented for {days} days",
  "alertMultipleCashWithdrawals": "{count} cash withdrawals in 24 hours",
  "alertGamblingDetected": "Gambling transaction detected",
  "alertSosReceived": "SOS signal received from Sharer",
  "reportsTitle": "Reports",
  "reportsPeriodMonth": "Month",
  "reportsPeriodQuarter": "Quarter",
  "reportsPeriodYear": "Year",
  "reportsCategoryBreakdown": "Expenses by Category",
  "reportsDailyTrend": "Daily Trend",
  "reportsMonthlyComparison": "Monthly Comparison",
  "reportsTopMerchants": "Top Merchants",
  "reportsExportComingSoon": "Export PDF/CSV — Coming Soon",
  "reportsInsufficientData": "At least one month of data needed for full reports"
}
```

**IT:**
```json
{
  "dashboardTitle": "Dashboard",
  "dashboardScore": "Punteggio FideLux",
  "dashboardScoreHigh": "Eccellente",
  "dashboardScoreMedium": "Attenzione",
  "dashboardScoreLow": "Critico",
  "dashboardTotalBalance": "Saldo Totale",
  "dashboardMonthExpenses": "Spese del Mese",
  "dashboardMonthIncome": "Entrate del Mese",
  "dashboardTransactions": "Transazioni",
  "dashboardDocumentationRate": "Tasso Documentazione",
  "dashboardDocumentationDays": "{documented}/{total} giorni",
  "dashboardTopCategories": "Categorie Principali",
  "dashboardViewAll": "Vedi tutte",
  "dashboardNoData": "Inizia a tracciare per vedere la dashboard",
  "dashboardAlerts": "Alert Attivi",
  "dashboardShowMoreAlerts": "Mostra altri {count}",
  "alertAdvisory": "Avviso",
  "alertCritical": "Critico",
  "alertSos": "SOS",
  "alertCategorySpike": "{category} è {percent}% sopra la media",
  "alertNoDocumentation": "Nessuna transazione documentata da {days} giorni",
  "alertMultipleCashWithdrawals": "{count} prelievi contanti in 24 ore",
  "alertGamblingDetected": "Rilevata transazione gioco d'azzardo",
  "alertSosReceived": "Segnale SOS ricevuto dall'Affidante",
  "reportsTitle": "Report",
  "reportsPeriodMonth": "Mese",
  "reportsPeriodQuarter": "Trimestre",
  "reportsPeriodYear": "Anno",
  "reportsCategoryBreakdown": "Spese per Categoria",
  "reportsDailyTrend": "Trend Giornaliero",
  "reportsMonthlyComparison": "Confronto Mensile",
  "reportsTopMerchants": "Esercenti Principali",
  "reportsExportComingSoon": "Export PDF/CSV — In arrivo",
  "reportsInsufficientData": "Serve almeno un mese di dati per i report completi"
}
```

---

## Step 9 — Test

### test/dashboard/dashboard_service_test.dart

```
1. "calculates score with full documentation" — 31/31 giorni → score alto
2. "calculates score with gaps" — 20/31 giorni → score medio
3. "calculates score with poor documentation" — 5/31 giorni → score basso
4. "detects trend up" — mese corrente > mese precedente +5 → trend up
5. "generates advisory alert for category spike" — entertainment 200% → alert advisory
6. "generates critical alert for multiple cash withdrawals" — 3 prelievi in 24h → alert critical
7. "generates critical alert for gambling" — categoria gambling presente → alert critical
8. "no alerts when everything normal" — spese regolari → lista alert vuota
```

### test/reports/report_data_test.dart

```
1. "calculates category breakdown correctly" — totali per categoria corrispondono
2. "calculates daily totals" — importi giornalieri corretti
3. "handles empty month gracefully" — nessuna transazione → tutti zeri, no crash
```

---

## Validazione Finale

```bash
flutter analyze
flutter test
flutter run
```

Checklist:
- [ ] Dashboard mostra FideLux Score con colore e trend
- [ ] KPI cards con saldo, spese, entrate, transazioni
- [ ] Tasso documentazione con barra di progresso
- [ ] Top 5 categorie con barre proporzionali
- [ ] Alert banner visibile se presenti alert (advisory/critical)
- [ ] Report mostra grafico torta spese per categoria
- [ ] Report mostra trend giornaliero a barre
- [ ] Selettore periodo (Mese/Trimestre/Anno) funziona
- [ ] Pull-to-refresh su dashboard e report
- [ ] Empty state corretto se nessun dato
- [ ] Badge su tab Dashboard per alert critici

---

## 🎉 MVP Completato

Con questa direttiva, tutte le funzionalità MVP sono implementate:

| Modulo | Direttiva | Funzionalità |
|--------|-----------|--------------|
| 01 | Project Setup | Struttura, tema, localizzazione, navigation |
| 02 | Crypto Chain | Ed25519, SHA-256, catena append-only |
| 03 | Pairing | QR code, scambio chiavi, handshake |
| 04 | Email Channel | IMAP/SMTP, messaggi firmati, validazione |
| 05 | Accounting Core | Conti, transazioni, database SQLite, ledger UI |
| 06 | OCR Receipts | ML Kit, parsing scontrini, pre-compilazione form |
| 07 | Dashboard | KPI, score, alert, report grafici |

**Prossimi passi (V1.0 — directives future):**
- Integrazione LLM on-device (Gemma 3n) per parsing intelligente scontrini
- Gemini OAuth come fallback
- FideLux Score completo (5 componenti pesati)
- Upload e parsing estratto conto mensile
- Meccanismo SOS completo con cooling-off
- Weekly digest email automatico
