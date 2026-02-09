# docs/agent-components.md — Generazione Componenti UI

Questa guida si applica ogni volta che generi componenti UI, pagine, layout o widget. Leggila INSIEME a `brand-guidelines.md`.

---

## Regola Zero

PRIMA di scrivere qualsiasi codice UI:
1. Leggi `brand-guidelines.md` e carica i design token
2. Verifica se esiste già un componente simile nel codebase
3. Se esiste, estendilo. Se non esiste, crealo seguendo i pattern sotto.

---

## Struttura Componente (Web — React/Next.js)

Ogni componente vive nella sua cartella con file colocati:

```
components/
├── Button/
│   ├── Button.tsx           # Componente
│   ├── Button.test.tsx      # Test
│   └── index.ts             # Re-export
├── DataTable/
│   ├── DataTable.tsx
│   ├── DataTable.test.tsx
│   ├── columns.tsx          # Definizioni colonne (se necessario)
│   └── index.ts
```

### Template Base

```tsx
// components/[Name]/[Name].tsx
import { type VariantProps, cva } from 'class-variance-authority'
import { cn } from '@/lib/utils'

const nameVariants = cva(
  'base-classes transition-colors duration-fast ease-default',
  {
    variants: {
      variant: {
        default: 'bg-primary text-void',
        ghost: 'border border-border-default text-text-primary hover:bg-hover-ghost',
        destructive: 'bg-error text-void',
      },
      size: {
        sm: 'h-8 px-sm text-xs rounded-[6px]',
        default: 'h-10 px-base py-sm rounded-[6px]',
        lg: 'h-12 px-xl text-base rounded-[6px]',
      },
    },
    defaultVariants: { variant: 'default', size: 'default' },
  }
)

interface NameProps extends VariantProps<typeof nameVariants> {
  // Props specifiche del componente
}

export function Name({ variant, size, ...props }: NameProps) {
  return <div className={cn(nameVariants({ variant, size }))} {...props} />
}
```

---

## Struttura Componente (Mobile — Flutter)

```
lib/
├── widgets/
│   ├── lr_button.dart        # Prefisso "lr_" per componenti LastReload
│   ├── lr_data_table.dart
│   └── lr_toast.dart
├── theme/
│   ├── app_colors.dart       # Token colori
│   ├── app_spacing.dart      # Token spacing
│   ├── app_typography.dart   # Token tipografia
│   └── app_theme.dart        # ThemeData completo
```

### Regole Flutter

<rules>
1. Usa i valori da theme/ — mai hardcodare colori, font o spacing
2. Ogni widget custom ha prefisso "lr_" (LastReload)
3. Usa const constructor dove possibile
4. Gestisci tutti gli stati: loading, empty, error, success
5. Responsive: usa LayoutBuilder o MediaQuery, mai dimensioni fisse
</rules>

---

## Specifiche Componenti Essenziali

### Form Fields (Input, Select, Textarea)

Cinque stati obbligatori per ogni form field:

| Stato | Bordo | Sfondo | Label | Helper text |
|-------|-------|--------|-------|-------------|
| Default | var(--color-border) | var(--color-bg-layer) | var(--color-text-muted) | var(--color-text-muted) |
| Hover | var(--color-text-muted) | var(--color-bg-layer) | var(--color-text-muted) | var(--color-text-muted) |
| Focus | var(--color-primary) | var(--color-bg-layer) | var(--color-primary) | var(--color-text-muted) |
| Error | var(--color-error) | var(--color-bg-layer) | var(--color-error) | var(--color-error) |
| Disabled | var(--color-border) 50% | var(--color-bg-void) | var(--color-text-muted) 50% | nascosto |

- Focus ring: `box-shadow: 0 0 0 2px var(--color-primary)` con opacità 0.3
- Label: sempre visibile sopra il campo (no placeholder-as-label)
- Helper text: sotto il campo, 12px, Inter
- Error message: sostituisce helper text, colore var(--color-error)
- Validazione: onBlur per singoli campi, onSubmit per il form completo

### Switch / Checkbox / Radio

- Switch: track 40×20px, thumb 16×16px, colore attivo var(--color-primary)
- Checkbox: 18×18px, bordo 1px, check icon stroke 1.5px, stato indeterminate con dash
- Radio: 18×18px, dot interno 8×8px quando selezionato

### Data Table

<rules>
1. Testo allineato a sinistra, numeri a destra, status come badge colorati, azioni come icon button
2. Header: font Inter 500 12px uppercase, colore var(--color-text-muted), bordo inferiore
3. Sorting: icona chevron su header cliccabili, stato attivo evidenziato
4. Filtri: chip sopra la tabella per filtri attivi, con "×" per rimuovere
5. Paginazione: in basso, mostra "X-Y di Z risultati", selettore righe per pagina
6. Selezione righe: checkbox a sinistra, barra azioni bulk in alto quando selezione > 0
7. Mobile (< 640px): scroll orizzontale con colonne prioritarie fisse a sinistra
</rules>

### Toast / Snackbar

- Posizione: top-right, stack verticale (max 3 visibili)
- Timing: success = 5s auto-dismiss, warning = 8s, error = persistente (richiede dismiss manuale)
- Animazione: slide-in da destra (var(--duration-normal)), fade-out (var(--duration-fast))
- Struttura: icona stato + messaggio + action opzionale + close button
- Colori: bordo sinistro 3px nel colore dello stato (success/warning/error)

### Modal / Dialog

- Tre size: sm (400px), md (560px), lg (720px)
- Overlay: var(--color-bg-void) con opacità 0.7, backdrop-filter: blur(4px)
- Focus trap: tab e shift+tab restano dentro il modale
- Chiusura: click overlay, Escape key, close button
- Alert Dialog (variante): richiede azione esplicita, overlay non cliccabile, no Escape

### Sidebar Navigation

- Tre stati: espansa (240px) → icon-only (64px) → nascosta (0px, drawer su mobile)
- Item: icona 20px + label 14px Inter, padding verticale var(--space-sm)
- Item attivo: sfondo var(--color-hover-ghost), bordo sinistro 2px var(--color-primary)
- Item hover: sfondo var(--color-hover-ghost)
- Nested items: indentazione var(--space-lg), collapsabili con chevron

### Tabs

- Bordo inferiore 1px var(--color-border) su tutta la larghezza
- Tab attiva: bordo inferiore 2px var(--color-primary), testo var(--color-text)
- Tab inattiva: testo var(--color-text-muted)
- Overflow (> larghezza disponibile): scroll orizzontale con frecce o dropdown "Altro"

### Progress / Loading

- **Skeleton**: sfondo var(--color-bg-layer), animazione pulse (var(--duration-slow) loop)
- **Spinner**: 20px, stroke 2px var(--color-primary), rotazione continua
- **Progress bar**: altezza 4px, track var(--color-bg-layer), fill var(--color-primary)
- **AI streaming**: testo carattere per carattere, cursore var(--color-primary) lampeggiante

---

## Checklist Finale Componente

Dopo aver generato un componente, verifica:

- [ ] Usa solo token semantici (mai valori hex o px arbitrari)
- [ ] Tutti gli stati interattivi gestiti (hover, focus, active, disabled)
- [ ] Accessibilità: aria-label su elementi interattivi, ruoli ARIA dove necessario
- [ ] Responsive: funziona su tutti i breakpoint definiti
- [ ] Animazioni: usano durate e easing dai token
- [ ] Test scritto e passato
- [ ] Export dal file index.ts della cartella componente
