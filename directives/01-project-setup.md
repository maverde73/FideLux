# Direttiva 01 — Project Setup

**Obiettivo:** Creare la struttura base del progetto Flutter FideLux con tema, localizzazione, architettura a 4 layer e navigation shell.

**Criticità:** 🟡 MEDIO

**Prerequisiti:** Flutter SDK 3.x installato, Dart SDK compatibile.

---

## Input

- `brand-guidelines.md` (root del progetto) — token colori, spacing, raggi, tipografia
- `FIDELUX.md` sezione 9 (Stack Tecnologico) e sezione 8 (UI/UX)

## Output Atteso

Un progetto Flutter che:
1. Compila senza errori (`flutter analyze` clean)
2. Mostra una shell con bottom navigation a 5 tab (placeholder per ogni sezione)
3. Applica il tema FideLux (colori amber/oro, Material 3)
4. Supporta localizzazione IT + EN con switch funzionante
5. Ha la struttura Clean Architecture a 4 layer pronta per i moduli successivi

---

## Step 1 — Creazione Progetto

```bash
flutter create --org com.lastreload --project-name fidelux .
```

Se il progetto esiste già, salta questo step.

Verifica: `flutter analyze` deve passare.

---

## Step 2 — Dipendenze (pubspec.yaml)

Aggiungi queste dipendenze. Usa le versioni più recenti compatibili.

### Dipendenze Core (MVP)

```yaml
dependencies:
  flutter:
    sdk: flutter
  flutter_localizations:
    sdk: flutter

  # State Management
  flutter_riverpod: ^2.0.0
  riverpod_annotation: ^2.0.0

  # Routing
  go_router: ^14.0.0

  # Database locale
  drift: ^2.0.0
  sqlite3_flutter_libs: ^0.5.0

  # Crittografia
  pointycastle: ^3.0.0
  convert: ^3.0.0  # per base64

  # Email (IMAP/SMTP)
  enough_mail: ^3.0.0

  # AI / OCR
  google_mlkit_text_recognition: ^0.13.0

  # UI utilities
  intl: ^0.19.0
  cached_network_image: ^3.0.0
  flutter_svg: ^2.0.0

  # Storage sicuro chiavi
  flutter_secure_storage: ^9.0.0

  # QR Code (per pairing)
  qr_flutter: ^4.0.0
  mobile_scanner: ^5.0.0

  # Utilities
  uuid: ^4.0.0
  path_provider: ^2.0.0
  share_plus: ^9.0.0

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^4.0.0
  build_runner: ^2.0.0
  riverpod_generator: ^2.0.0
  drift_dev: ^2.0.0
  mockito: ^5.0.0
  build_verify: ^3.0.0
```

Verifica: `flutter pub get` deve completare senza errori.

---

## Step 3 — Struttura Directory

Crea questa struttura. Le cartelle vuote contengono un file `.gitkeep`.

```
lib/
├── main.dart                          # Entry point
├── app.dart                           # MaterialApp + GoRouter + Providers
│
├── core/                              # Utilities trasversali
│   ├── constants/
│   │   └── app_constants.dart         # Costanti globali
│   ├── extensions/
│   │   └── context_extensions.dart    # Extension methods su BuildContext
│   ├── utils/
│   │   └── currency_formatter.dart    # Formattazione importi per locale
│   └── errors/
│       └── failures.dart              # Classi errore tipizzate
│
├── theme/                             # Design System (da brand-guidelines.md)
│   ├── fidelux_colors.dart            # Classe colori (da sezione 9 brand)
│   ├── fidelux_spacing.dart           # Classe spacing
│   ├── fidelux_radius.dart            # Classe raggi
│   └── fidelux_theme.dart             # ThemeData completo Material 3
│
├── l10n/                              # Localizzazione
│   ├── app_it.arb                     # Stringhe italiane
│   └── app_en.arb                     # Stringhe inglesi
│
├── domain/                            # Layer 3: Entities + Repository interfaces
│   ├── entities/
│   │   └── .gitkeep
│   └── repositories/
│       └── .gitkeep
│
├── application/                       # Layer 2: Use cases
│   └── .gitkeep
│
├── data/                              # Layer 4: Implementazioni concrete
│   ├── local_db/
│   │   └── .gitkeep
│   ├── email/
│   │   └── .gitkeep
│   └── ai/
│       └── .gitkeep
│
└── presentation/                      # Layer 1: UI
    ├── router/
    │   └── app_router.dart            # GoRouter config con 5 route
    ├── shell/
    │   └── main_shell.dart            # Scaffold + BottomNavigationBar
    ├── screens/
    │   ├── inbox/
    │   │   └── inbox_screen.dart      # Placeholder
    │   ├── dashboard/
    │   │   └── dashboard_screen.dart  # Placeholder
    │   ├── ledger/
    │   │   └── ledger_screen.dart     # Placeholder
    │   ├── reports/
    │   │   └── reports_screen.dart    # Placeholder
    │   └── settings/
    │       └── settings_screen.dart   # Placeholder con language switch
    ├── widgets/
    │   └── .gitkeep
    └── providers/
        └── .gitkeep
```

---

## Step 4 — Theme (da brand-guidelines.md)

Crea i file in `lib/theme/` copiando i valori dalla sezione 9 del brand-guidelines.md.

### fidelux_theme.dart

Questo file assembla il `ThemeData` completo usando `ColorScheme.fromSeed` o `ColorScheme` esplicito:

<rules>
1. Usa ColorScheme esplicito con TUTTI i valori da FideLuxColors (non fromSeed, per controllo totale)
2. useMaterial3: true
3. scaffoldBackgroundColor: FideLuxColors.background
4. Applica la scala tipografica Material 3 con font di sistema
5. Per gli importi finanziari, definisci un TextStyle dedicato con fontFeatures monospace
6. InputDecorationTheme: stile Outlined con i token dal brand
7. CardTheme: elevation 1, radius 12
8. NavigationBarTheme: height 80, indicatorColor primaryContainer
9. FloatingActionButtonTheme: per SOS button (rosso, elevation 3)
</rules>

---

## Step 5 — Localizzazione (IT + EN)

### Configurazione in pubspec.yaml

```yaml
flutter:
  generate: true
```

### l10n.yaml (root del progetto)

```yaml
arb-dir: lib/l10n
template-arb-file: app_en.arb
output-localization-file: app_localizations.dart
output-class: L
```

### app_en.arb (template)

```json
{
  "@@locale": "en",
  "appTitle": "FideLux",
  "tabInbox": "Inbox",
  "tabDashboard": "Dashboard",
  "tabLedger": "Ledger",
  "tabReports": "Reports",
  "tabSettings": "Settings",
  "sharer": "Sharer",
  "keeper": "Keeper",
  "fideluxScore": "FideLux Score",
  "eventChain": "Event Chain",
  "sos": "SOS",
  "settingsLanguage": "Language",
  "settingsLanguageIt": "Italiano",
  "settingsLanguageEn": "English",
  "placeholderScreenTitle": "{screenName} - Coming Soon",
  "@placeholderScreenTitle": {
    "placeholders": {
      "screenName": { "type": "String" }
    }
  },
  "currencyFormat": "€{amount}",
  "@currencyFormat": {
    "placeholders": {
      "amount": { "type": "String" }
    }
  }
}
```

### app_it.arb

```json
{
  "@@locale": "it",
  "appTitle": "FideLux",
  "tabInbox": "Inbox",
  "tabDashboard": "Dashboard",
  "tabLedger": "Contabilità",
  "tabReports": "Report",
  "tabSettings": "Impostazioni",
  "sharer": "Affidante",
  "keeper": "Custode",
  "fideluxScore": "Punteggio FideLux",
  "eventChain": "Catena Eventi",
  "sos": "SOS",
  "settingsLanguage": "Lingua",
  "settingsLanguageIt": "Italiano",
  "settingsLanguageEn": "English",
  "placeholderScreenTitle": "{screenName} - In arrivo",
  "currencyFormat": "€{amount}"
}
```

Dopo aver creato i file ARB:
```bash
flutter gen-l10n
```

---

## Step 6 — Router (GoRouter + Shell)

### app_router.dart

<rules>
1. Usa ShellRoute per wrappare le 5 tab nella MainShell
2. Ogni tab è una route con path: /inbox, /dashboard, /ledger, /reports, /settings
3. initialLocation: '/inbox' (il Keeper apre sull'inbox)
4. Usa StatefulShellRoute.indexedStack per preservare lo stato di ogni tab
5. Nessun guard auth per ora (sarà aggiunto nel modulo pairing)
</rules>

### main_shell.dart

<rules>
1. Scaffold con body = child (dalla route)
2. NavigationBar Material 3 con 5 destinazioni (icone e label da brand-guidelines sezione 5.7)
3. Badge su Inbox tab (placeholder, valore hardcoded 0 per ora)
4. Nessun FAB per ora (SOS button sarà aggiunto dopo)
5. Rispetta SafeArea
</rules>

---

## Step 7 — Schermate Placeholder

Ogni schermata placeholder ha:
- AppBar con titolo localizzato
- Body centrato con icona grande (64dp) + testo "Coming Soon" localizzato
- Colori dal tema

La schermata Settings ha IN PIÙ:
- ListTile per cambio lingua con DropdownButton (IT/EN)
- Il cambio lingua aggiorna il locale dell'app in tempo reale
- Usa un Riverpod StateProvider per il locale corrente

---

## Step 8 — Entry Point

### main.dart

```dart
void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ProviderScope(child: FideLuxApp()));
}
```

### app.dart

<rules>
1. FideLuxApp è un ConsumerWidget
2. Legge il locale dal Riverpod provider
3. MaterialApp.router con:
   - theme: fideluxTheme (da fidelux_theme.dart)
   - localizationsDelegates: da flutter_localizations + generated L
   - supportedLocales: [Locale('en'), Locale('it')]
   - locale: dal provider
   - routerConfig: dal GoRouter
</rules>

---

## Validazione Finale

Dopo aver completato tutti gli step, verifica:

```bash
flutter analyze          # Zero errori, zero warning
flutter test             # (nessun test ancora, ma deve non crashare)
flutter run              # L'app si avvia, mostra 5 tab, switch lingua funziona
```

Checklist visiva:
- [ ] Bottom navigation con 5 tab, icone Material 3
- [ ] Tab attiva evidenziata con pill amber
- [ ] Sfondo caldo (bianco caldo, non bianco puro) — verificare #FAFAF8
- [ ] Testo leggibile, contrasto adeguato
- [ ] Switch lingua in Settings cambia le label in tempo reale
- [ ] Safe area rispettata (no contenuto sotto notch o home indicator)

---

## Casi Limite Noti

- `enough_mail` potrebbe avere conflitti di versione con alcune dipendenze. Se fallisce `pub get`, commenta la riga e prosegui — il canale email è il modulo 4.
- `google_mlkit_text_recognition` richiede minSdkVersion 21 su Android. Verifica in `android/app/build.gradle`.
- Su iOS, `mobile_scanner` richiede permessi camera in `Info.plist`. Aggiungi `NSCameraUsageDescription`.
- Se `flutter gen-l10n` fallisce, verifica che `l10n.yaml` sia nella root del progetto e che `generate: true` sia in `pubspec.yaml`.

---

## Prossimo Modulo

Completato il setup, procedi con `directives/02-crypto-chain.md` (keypair Ed25519, firma/verifica, catena append-only).
