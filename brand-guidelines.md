# FideLux — Brand Identity & Design System v1.0

**Nome:** FideLux (_Fides + Lux_ | Fiducia + Trasparenza)
**Tipo:** Personal Finance Accountability App
**Piattaforma:** Flutter (iOS + Android)
**Vibe:** Calda, affidabile, luminosa. Non un tool finanziario freddo — un compagno di percorso.

---

## 1. Tono e Voce

FideLux parla con empatia e chiarezza. Non giudica, non allarma inutilmente, non usa gergo finanziario. Il tono è quello di un amico fidato che ti aiuta a tenere ordine.

- **Empatico e Diretto:** "Hai documentato 28 su 31 giorni questo mese" — mai "Hai mancato 3 giorni"
- **Positivo-forward:** I messaggi enfatizzano il progresso, non le mancanze
- **Chiaro e Semplice:** Lo Sharer potrebbe essere in un momento di fragilità. Zero ambiguità.
- **Mai punitivo:** Gli alert informano, non accusano

---

## 2. Architettura Token a 3 Livelli

```
Primitivo (cosa È)  →  Semantico (cosa FA)  →  Componente (dove VA)
color.amber.500      →  --primary             →  button.default.bg
```

I componenti referenziano SOLO token semantici. Per aggiungere un tema dark, rimappa solo il livello semantico.

---

## 3. Livello 1 — Token Primitivi

### 3.1 Scale Colore

```json
{
  "color": {
    "neutral": {
      "0":    "#FFFFFF",
      "50":   "#FAFAF8",
      "100":  "#F5F3F0",
      "150":  "#ECEAE6",
      "200":  "#E0DDD8",
      "300":  "#C8C4BD",
      "400":  "#A8A49C",
      "500":  "#888379",
      "600":  "#6B6760",
      "700":  "#4A4740",
      "800":  "#333028",
      "900":  "#1C1A15",
      "1000": "#0D0C0A"
    },
    "amber": {
      "50":   "#FFF8E1",
      "100":  "#FFECB3",
      "200":  "#FFE082",
      "300":  "#FFD54F",
      "400":  "#FFCA28",
      "500":  "#D4A017",
      "600":  "#B8860B",
      "700":  "#996F0A",
      "800":  "#7A5908",
      "900":  "#5C4306"
    },
    "teal": {
      "50":   "#E0F2F1",
      "100":  "#B2DFDB",
      "300":  "#4DB6AC",
      "400":  "#26A69A",
      "500":  "#1A8A7E",
      "600":  "#147A6F",
      "700":  "#0E6B61"
    },
    "red": {
      "50":   "#FFF5F5",
      "100":  "#FFE0E0",
      "400":  "#E57373",
      "500":  "#D32F2F",
      "600":  "#C62828",
      "700":  "#B71C1C"
    },
    "green": {
      "50":   "#F1F8E9",
      "100":  "#DCEDC8",
      "400":  "#66BB6A",
      "500":  "#43A047",
      "600":  "#388E3C",
      "700":  "#2E7D32"
    },
    "blue": {
      "50":   "#E8F0FE",
      "100":  "#C5DCFA",
      "400":  "#5B9BD5",
      "500":  "#1976D2",
      "600":  "#1565C0"
    },
    "orange": {
      "400":  "#FF9800",
      "500":  "#F57C00",
      "600":  "#E65100"
    }
  }
}
```

### 3.2 Scale Spazio, Raggi, Dimensioni

```json
{
  "spacing": {
    "0": "0px",
    "1": "4px",
    "2": "8px",
    "3": "12px",
    "4": "16px",
    "5": "20px",
    "6": "24px",
    "8": "32px",
    "10": "40px",
    "12": "48px",
    "16": "64px"
  },
  "radius": {
    "none": "0px",
    "sm": "8px",
    "md": "12px",
    "lg": "16px",
    "xl": "24px",
    "full": "9999px"
  },
  "borderWidth": {
    "0": "0px",
    "1": "1px",
    "2": "2px"
  }
}
```

### 3.3 Scale Tipografiche

```json
{
  "fontSize": {
    "xs": "11px",
    "sm": "12px",
    "base": "14px",
    "md": "16px",
    "lg": "20px",
    "xl": "24px",
    "2xl": "28px",
    "3xl": "34px",
    "4xl": "45px"
  },
  "fontWeight": {
    "regular": 400,
    "medium": 500,
    "semibold": 600,
    "bold": 700
  },
  "lineHeight": {
    "tight": 1.15,
    "snug": 1.25,
    "normal": 1.43,
    "relaxed": 1.6
  }
}
```

Le dimensioni seguono la scala tipografica Material 3 (Display, Headline, Title, Body, Label).

### 3.4 Scale Animazione

```json
{
  "duration": {
    "instant": "0ms",
    "fast": "150ms",
    "normal": "300ms",
    "slow": "500ms",
    "emphasis": "700ms"
  },
  "easing": {
    "standard": "cubic-bezier(0.2, 0, 0, 1)",
    "decelerate": "cubic-bezier(0, 0, 0, 1)",
    "accelerate": "cubic-bezier(0.3, 0, 1, 1)",
    "linear": "cubic-bezier(0, 0, 1, 1)"
  }
}
```

Le curve di easing seguono le specifiche Material 3 (Emphasized, Standard).

---

## 4. Livello 2 — Token Semantici

### 4.1 Tabella di Mapping per Tema

| Token Semantico | Light (attivo) | Dark (pianificato) |
|-----------------|----------------|--------------------|
| `--background` | neutral.0 | neutral.900 |
| `--on-background` | neutral.900 | neutral.100 |
| `--surface` | neutral.50 | neutral.800 |
| `--on-surface` | neutral.900 | neutral.100 |
| `--surface-variant` | neutral.150 | neutral.700 |
| `--on-surface-variant` | neutral.600 | neutral.400 |
| `--surface-container` | neutral.100 | neutral.800 |
| `--surface-container-high` | neutral.150 | neutral.700 |
| `--primary` | amber.500 | amber.300 |
| `--on-primary` | neutral.0 | neutral.900 |
| `--primary-container` | amber.100 | amber.800 |
| `--on-primary-container` | amber.900 | amber.100 |
| `--secondary` | teal.500 | teal.300 |
| `--on-secondary` | neutral.0 | neutral.900 |
| `--secondary-container` | teal.100 | teal.700 |
| `--on-secondary-container` | teal.700 | teal.100 |
| `--tertiary` | blue.500 | blue.400 |
| `--error` | red.500 | red.400 |
| `--on-error` | neutral.0 | neutral.900 |
| `--error-container` | red.100 | red.700 |
| `--success` | green.500 | green.400 |
| `--success-container` | green.100 | green.700 |
| `--warning` | orange.500 | orange.400 |
| `--outline` | neutral.300 | neutral.600 |
| `--outline-variant` | neutral.200 | neutral.700 |
| `--shadow` | neutral.1000 | neutral.1000 |
| `--scrim` | neutral.1000 | neutral.1000 |

### 4.2 Token Specifici FideLux

Oltre ai token Material 3, FideLux ha token semantici per le sue funzionalità uniche:

```json
{
  "fidelux": {
    "score": {
      "high": "{color.green.500}",
      "medium": "{color.orange.500}",
      "low": "{color.red.500}",
      "background": "{color.amber.50}"
    },
    "alert": {
      "normal": "{color.green.500}",
      "advisory": "{color.orange.400}",
      "critical": "{color.red.500}",
      "sos": "{color.red.700}"
    },
    "trust": {
      "maxima": "{color.green.600}",
      "buona": "{color.green.400}",
      "media": "{color.orange.400}",
      "condizionale": "{color.orange.500}",
      "bassa": "{color.red.400}",
      "zero": "{color.red.600}"
    },
    "chain": {
      "verified": "{color.green.500}",
      "pending": "{color.orange.400}",
      "broken": "{color.red.500}",
      "link-icon": "{color.amber.500}"
    },
    "inbox": {
      "unread": "{color.amber.500}",
      "processed": "{color.green.500}",
      "flagged": "{color.red.400}"
    }
  }
}
```

---

## 5. Livello 3 — Token Componente

### 5.1 Button (Material 3)

FideLux usa i componenti Material 3 standard. I button seguono le varianti Material:

| Property | Filled | Tonal | Outlined | Text |
|----------|--------|-------|----------|------|
| bg | `--primary` | `--primary-container` | transparent | transparent |
| fg | `--on-primary` | `--on-primary-container` | `--primary` | `--primary` |
| hover | opacity 0.92 | opacity 0.92 | `--surface-variant` | `--surface-variant` |
| border | none | none | `--outline` | none |
| disabled-bg | `--on-surface` 12% | `--on-surface` 12% | transparent | transparent |
| disabled-fg | `--on-surface` 38% | `--on-surface` 38% | `--on-surface` 38% | `--on-surface` 38% |

| Size | Height | Padding H | Font | Radius |
|------|--------|-----------|------|--------|
| default | 40px | spacing.6 | Label Large (14px/500) | radius.full (pill) |
| large | 56px (FAB) | spacing.4 | Label Large | radius.lg |
| icon | 40px | 0 | — | radius.full |

### 5.2 Input / TextField (Material 3)

FideLux usa lo stile **Outlined** per tutti gli input (massima leggibilità per dati finanziari).

| State | Border | Label | Helper/Error | Fill |
|-------|--------|-------|--------------|------|
| default | `--outline` | `--on-surface-variant` | `--on-surface-variant` | transparent |
| hover | `--on-surface` | `--on-surface-variant` | `--on-surface-variant` | transparent |
| focus | `--primary` 2px | `--primary` | `--on-surface-variant` | transparent |
| error | `--error` 2px | `--error` | `--error` | transparent |
| disabled | `--on-surface` 12% | `--on-surface` 38% | — | `--on-surface` 4% |

- Label: floating (sopra il bordo quando focus/filled)
- Helper text: sotto il campo, `fontSize.sm`, `--on-surface-variant`
- Error text: sostituisce helper, `fontSize.sm`, `--error`
- Prefix/suffix: per valuta (€), percentuali, icone
- Radius: `radius.sm` (8px)
- Height: 56px (Material 3 default)

### 5.3 Card

| Property | Elevated | Filled | Outlined |
|----------|----------|--------|----------|
| bg | `--surface` | `--surface-variant` | `--surface` |
| fg | `--on-surface` | `--on-surface` | `--on-surface` |
| elevation | level1 (1dp) | level0 | level0 |
| border | none | none | `--outline-variant` |
| radius | `radius.md` (12px) | `radius.md` | `radius.md` |
| padding | `spacing.4` | `spacing.4` | `spacing.4` |

**Inbox Card (messaggio Sharer):**
| State | Indicatore | Background |
|-------|-----------|------------|
| Non letto | dot `--fidelux.inbox.unread` | `--surface` con tint `--primary-container` |
| Processato | check `--fidelux.inbox.processed` | `--surface` |
| Segnalato | flag `--fidelux.inbox.flagged` | `--error-container` leggero |

### 5.4 FideLux Score Widget

| Range | Colore | Label | Icona |
|-------|--------|-------|-------|
| 70-100 | `--fidelux.score.high` | Eccellente / Buono | Shield check |
| 40-69 | `--fidelux.score.medium` | Attenzione | Alert triangle |
| 0-39 | `--fidelux.score.low` | Critico | Alert circle |

- Background card: `--fidelux.score.background` (amber.50)
- Numero grande: `fontSize.4xl`, `fontWeight.bold`
- Trend arrow: ▲ verde se in salita, ▼ rosso se in discesa, ► neutro se stabile
- Barra di progresso: height 8px, radius.full, track `--surface-variant`, fill = colore del range

### 5.5 Toast / Snackbar (Material 3)

| Property | Value |
|----------|-------|
| position | bottom-center (Material 3 standard) |
| bg | `--on-surface` (inverse surface) |
| fg | `--surface` (inverse on-surface) |
| action | `--primary` (inverse primary) |
| radius | `radius.sm` (8px) |
| max-lines | 2 |
| duration | 4s (short), 10s (long), indefinite (con action) |
| enter | slide-up + fade, `duration.normal`, `easing.decelerate` |
| exit | fade-out, `duration.fast`, `easing.accelerate` |
| margin-bottom | spacing.4 (sopra la bottom nav) |

### 5.6 Dialog / Modal (Material 3)

| Property | Value |
|----------|-------|
| bg | `--surface-container-high` |
| fg | `--on-surface` |
| title | `fontSize.xl`, `fontWeight.semibold` |
| scrim | `--scrim` 32% opacity |
| radius | `radius.xl` (28px — Material 3) |
| padding | `spacing.6` |
| min-width | 280px |
| max-width | 560px |
| enter | scale 0.8→1, opacity 0→1, `duration.slow`, `easing.decelerate` |

**Confirm Dialog (operazioni critiche):**
- Titolo chiaro: "Inserire nella contabilità?"
- Corpo: riepilogo transazione
- Azioni: "Annulla" (Text button) + "Conferma" (Filled button)
- Animazione catena dopo conferma: icona link chain con pulse `--fidelux.chain.link-icon`

### 5.7 Bottom Navigation (5 Tab)

| Tab | Icona | Label IT | Label EN |
|-----|-------|----------|----------|
| Inbox | mail_outline / mail | Inbox | Inbox |
| Dashboard | dashboard_outlined / dashboard | Dashboard | Dashboard |
| Contabilità | receipt_long_outlined / receipt_long | Contabilità | Ledger |
| Report | bar_chart_outlined / bar_chart | Report | Reports |
| Impostazioni | settings_outlined / settings | Impostazioni | Settings |

| State | Icona | Label | Indicatore |
|-------|-------|-------|-----------|
| inactive | `--on-surface-variant` | `--on-surface-variant` | none |
| active | `--on-primary-container` | `--on-primary-container` | pill bg `--primary-container` |

- Height: 80px (Material 3)
- Badge su Inbox: contatore messaggi non letti, bg `--error`, fg `--on-error`
- Transizione: `duration.fast`, `easing.standard`

### 5.8 Data Table / Lista Transazioni

FideLux non usa tabelle desktop classiche. Su mobile, le transazioni sono una **lista di card/tile** scrollabile.

| Part | Spec |
|------|------|
| Tile height | min 72px (Material 3 three-line list) |
| Leading | Icona categoria 40px, bg `--primary-container`, radius.full |
| Title | Esercente/descrizione, `fontSize.base`, `--on-surface` |
| Subtitle | Data + categoria, `fontSize.sm`, `--on-surface-variant` |
| Trailing | Importo, `fontSize.base`, `fontWeight.semibold` |
| Trailing color | Negativo (spesa): `--error`. Positivo (entrata): `--success` |
| Divider | `--outline-variant`, 1px, indent a sinistra del leading |
| Swipe actions | (futuro) swipe-left per dettaglio, swipe-right per flag |

**Filtri:** Chip row in alto, scrollabile orizzontalmente. Chip stile Material 3 Filter Chip.

### 5.9 SOS Button

Il pulsante SOS è un elemento critico dell'app. Deve essere immediatamente visibile e accessibile.

| Property | Value |
|----------|-------|
| Type | Extended FAB |
| bg | `--fidelux.alert.sos` (red.700) |
| fg | neutral.0 (bianco) |
| icon | Warning / Emergency |
| label | "SOS" |
| radius | radius.lg |
| size | 56px height, min 80px width |
| position | Floating, bottom-right, sopra la bottom nav |
| elevation | level3 |
| haptic | Vibrazione lunga al tap |
| confirm | Dialog di conferma prima dell'invio |

### 5.10 Chain Event Animation

Quando una transazione viene confermata e aggiunta alla catena:

| Step | Durata | Descrizione |
|------|--------|-------------|
| 1 | `duration.fast` | Icona link chain appare con scale 0→1 |
| 2 | `duration.normal` | Pulse glow ambra attorno all'icona (2 cicli) |
| 3 | `duration.fast` | Check mark sovrapposto, colore `--success` |
| 4 | `duration.slow` | Fade verso la timeline, transazione visibile nella lista |

Colore glow: `color.amber.400` con opacità 0.3. Easing: `easing.decelerate`.

---

## 6. Tipografia

### Font Stack (Material 3 Default)

FideLux usa i font di default di Material 3 per massima compatibilità nativa:

| Ruolo | Android | iOS | Fallback |
|-------|---------|-----|----------|
| Display / Headline | Roboto | SF Pro Display | system-ui |
| Body / Label | Roboto | SF Pro Text | system-ui |
| Dati finanziari | Roboto Mono | SF Mono | monospace |

**Perché non font custom:** FideLux è un'app di finanza personale, non un prodotto creative/tech. I font di sistema garantiscono leggibilità massima, zero tempo di caricamento, e familiarità per l'utente. L'identità visiva si esprime nei colori e nella UX, non nei font.

### Scala Tipografica (Material 3)

| Token | Size | Weight | Line Height | Uso |
|-------|------|--------|-------------|-----|
| Display Large | 57px | 400 | 1.12 | — (non usato in app) |
| Display Medium | 45px | 400 | 1.16 | FideLux Score grande |
| Headline Large | 32px | 400 | 1.25 | Titoli sezione |
| Headline Medium | 28px | 400 | 1.29 | Sotto-titoli |
| Title Large | 22px | 500 | 1.27 | AppBar title |
| Title Medium | 16px | 500 | 1.5 | Card title |
| Body Large | 16px | 400 | 1.5 | Corpo testo primario |
| Body Medium | 14px | 400 | 1.43 | Corpo testo secondario |
| Body Small | 12px | 400 | 1.33 | Note, timestamp |
| Label Large | 14px | 500 | 1.43 | Button text |
| Label Medium | 12px | 500 | 1.33 | Tab label, chip |
| Label Small | 11px | 500 | 1.45 | Badge, caption |

### Importi Finanziari

Gli importi usano sempre font mono per allineamento colonnare:

| Contesto | Size | Weight | Formato |
|----------|------|--------|---------|
| Lista transazioni | 16px | 600 | €1.234,56 |
| Dettaglio transazione | 24px | 700 | €1.234,56 |
| Dashboard KPI | 34px | 700 | €12.345 |
| Saldo conto | 28px | 600 | €1.234,56 |

Formato locale: separatore migliaia `.`, decimale `,` per IT. Invertito per EN.

---

## 7. Layout e Responsive

### Breakpoints (Flutter)

| Token | Width | Layout | Uso |
|-------|-------|--------|-----|
| compact | < 600px | 1 colonna | Smartphone (primario) |
| medium | 600–840px | 2 colonne | Tablet portrait |
| expanded | > 840px | 3 colonne + nav rail | Tablet landscape |

### Specifiche Layout

- Safe area: rispettata su tutti i lati (notch, home indicator)
- Bottom nav: 80px height, sopra safe area
- AppBar: height standard Material 3 (64px)
- Content padding: `spacing.4` (16px) orizzontale
- Card gap: `spacing.3` (12px)
- Touch target minimo: 48×48dp (Material 3 accessibility)
- Scroll: physics BouncingScrollPhysics (iOS) / ClampingScrollPhysics (Android)

---

## 8. Iconografia

- **Libreria:** Material Symbols (Outlined, weight 400, grade 0, optical size 24)
- **Perché:** Nativa Flutter, zero dipendenze, coerente con Material 3
- **Dimensioni:** 24dp (standard), 20dp (dense), 40dp (illustrativo)
- **Colore:** segue il token del contesto (--on-surface, --on-primary, ecc.)

### Icone FideLux Specifiche

| Concetto | Icona Material | Uso |
|----------|----------------|-----|
| Catena verificata | link + verified | Evento confermato |
| Firma valida | shield + check | Messaggio autenticato |
| Firma invalida | shield + warning | Messaggio rifiutato |
| Score alto | emoji_events | Dashboard |
| Score medio | trending_flat | Dashboard |
| Score basso | warning | Dashboard |
| SOS | emergency | Pulsante SOS |
| OCR scan | document_scanner | Inbox processing |
| Riconciliazione | compare_arrows | Statement matching |

---

## 9. Cross-Platform — Flutter ThemeData

```dart
// theme/fidelux_colors.dart
import 'package:flutter/material.dart';

class FideLuxColors {
  // Surfaces
  static const background = Color(0xFFFFFFFF);
  static const onBackground = Color(0xFF1C1A15);
  static const surface = Color(0xFFFAFAF8);
  static const onSurface = Color(0xFF1C1A15);
  static const surfaceVariant = Color(0xFFECEAE6);
  static const onSurfaceVariant = Color(0xFF6B6760);
  static const surfaceContainer = Color(0xFFF5F3F0);
  static const surfaceContainerHigh = Color(0xFFECEAE6);

  // Primary (Amber/Gold)
  static const primary = Color(0xFFD4A017);
  static const onPrimary = Color(0xFFFFFFFF);
  static const primaryContainer = Color(0xFFFFECB3);
  static const onPrimaryContainer = Color(0xFF5C4306);

  // Secondary (Teal)
  static const secondary = Color(0xFF1A8A7E);
  static const onSecondary = Color(0xFFFFFFFF);
  static const secondaryContainer = Color(0xFFB2DFDB);
  static const onSecondaryContainer = Color(0xFF0E6B61);

  // Tertiary (Blue — link, info)
  static const tertiary = Color(0xFF1976D2);

  // Error
  static const error = Color(0xFFD32F2F);
  static const onError = Color(0xFFFFFFFF);
  static const errorContainer = Color(0xFFFFE0E0);

  // Status
  static const success = Color(0xFF43A047);
  static const successContainer = Color(0xFFDCEDC8);
  static const warning = Color(0xFFF57C00);

  // Outline
  static const outline = Color(0xFFC8C4BD);
  static const outlineVariant = Color(0xFFE0DDD8);

  // FideLux-specific
  static const scoreHigh = Color(0xFF43A047);
  static const scoreMedium = Color(0xFFF57C00);
  static const scoreLow = Color(0xFFD32F2F);
  static const scoreBackground = Color(0xFFFFF8E1);
  static const alertSos = Color(0xFFB71C1C);
  static const chainVerified = Color(0xFF43A047);
  static const chainPending = Color(0xFFFF9800);
  static const chainLinkIcon = Color(0xFFD4A017);
  static const inboxUnread = Color(0xFFD4A017);
}

// theme/fidelux_spacing.dart
class FideLuxSpacing {
  static const double s0 = 0;
  static const double s1 = 4;
  static const double s2 = 8;
  static const double s3 = 12;
  static const double s4 = 16;
  static const double s5 = 20;
  static const double s6 = 24;
  static const double s8 = 32;
  static const double s10 = 40;
  static const double s12 = 48;
  static const double s16 = 64;
}

// theme/fidelux_radius.dart
class FideLuxRadius {
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 24;
  static const double full = 9999;
}
```

---

## Changelog

### v1.0
- Versione iniziale
- Palette calda amber/oro con neutrali caldi
- Token a 3 livelli (Primitivi → Semantici → Componente)
- Naming Material 3 (surface, on-surface, container, ecc.)
- Font di sistema (Roboto / SF Pro) per massima leggibilità
- 10 componenti specificati (Button, Input, Card, Score, Toast, Dialog, BottomNav, TransactionList, SOS, ChainAnimation)
- Token specifici FideLux (score, alert, trust, chain, inbox)
- Tabella mapping per tema dark (pianificato)
- Flutter ThemeData con colori, spacing, raggi
