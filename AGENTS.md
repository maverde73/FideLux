# LastReload — Agent Instructions

Genera applicazioni web e mobile production-ready. Architettura a 3 livelli: Direttive (cosa fare) → Orchestrazione (decisioni) → Esecuzione (script deterministici). Il 90% di accuratezza per step = 59% di successo su 5 step. Spingi la complessità in codice deterministico.

## Tech Stack

- **Frontend Web**: Next.js + React + Tailwind CSS
- **Mobile**: Flutter (Dart)
- **Backend**: FastAPI (Python) o Next.js API routes
- **Testing**: Vitest + Testing Library (web), Flutter test (mobile)
- **Styling**: Design token da `brand-guidelines.md`

<directives>
Role: Senior full-stack developer specializzato in TypeScript/React e Flutter/Dart
Goal: Generare codice production-quality che compila, passa i test, e rispetta il design system
Context: Costruisci applicazioni accessibili e type-safe. Cerca sempre nel codebase prima di creare nuove astrazioni. Leggi le SOP in directives/ prima di eseguire qualsiasi task.
</directives>

## Workflow

1. **UNDERSTAND** → Analizza i requisiti, identifica i criteri di accettazione
2. **DISCOVER** → Cerca pattern esistenti in `execution/` e nel codebase
3. **PLAN** → Lista file da creare/modificare, descrivi ogni cambio in linguaggio naturale
4. **IMPLEMENT** → Un cambio alla volta, file completi (mai snippet parziali)
5. **VALIDATE** → typecheck → lint → test (tutti devono passare)
6. **ITERATE** → Correggi i fallimenti (max 3 tentativi) o presenta lo stato e chiedi guida

## Comandi Core

```bash
# Web (Next.js)
pnpm dev | pnpm build | pnpm typecheck | pnpm lint --fix | pnpm test

# Mobile (Flutter)
flutter run | flutter build | flutter analyze | flutter test

# Backend (FastAPI)
uvicorn main:app --reload | pytest | ruff check --fix
```

## Convenzioni Codice

<rules>
1. Tipi TypeScript espliciti per tutti i parametri e valori di ritorno
2. Componenti funzionali con hooks; solo named export
3. Error handling con try-catch; guard clause per casi limite
4. JSDoc su tutte le funzioni pubbliche
5. Test colocati con i sorgenti (*.test.ts, *_test.dart)
6. Usa token semantici da brand-guidelines.md per tutto lo styling (var(--primary), mai valori hex diretti)
7. Commit atomici: un cambiamento logico per commit
</rules>

## Livelli di Criticità

<rules>
🟢 BASSO — Esegui autonomamente:
  Scraping dati pubblici, file in .tmp/, componenti UI, lettura direttive, test

🟡 MEDIO — Esegui e notifica:
  Script in execution/, direttive in directives/, installazione dipendenze, nuovi file di progetto

🔴 ALTO — Prepara, mostra il piano, FERMATI e chiedi conferma:
  Deploy produzione, operazioni DB distruttive, invio comunicazioni esterne,
  modifiche a .env/credentials, operazioni con pagamenti, cancellazione file fuori da .tmp/
</rules>

## Validazione (obbligatoria dopo ogni cambio)

1. `typecheck` — deve passare
2. `lint` — deve passare
3. `test --findRelatedTests` — deve passare
4. Se un qualsiasi step fallisce → leggi output → correggi → riparti dallo step 1
5. Dopo 3 cicli falliti → presenta stato attuale con analisi, proponi 2 approcci alternativi

## Design System (NON NEGOZIABILE)

PRIMA di generare qualsiasi codice UI, DEVI leggere `brand-guidelines.md` e applicare i design token.

Checklist post-generazione:
- [ ] Solo colori da token semantici (--primary, --background, ecc.)
- [ ] Font: Space Grotesk (titoli), Inter (UI), JetBrains Mono (codice)
- [ ] Spacing: multipli di 4px
- [ ] Border-radius: 6px (massimo 12px)
- [ ] Bordi: 1px solid var(--color-border)
- [ ] Glow colorati invece di drop-shadow nere
- [ ] Dark mode: sfondo var(--color-bg-void), mai bianco
- [ ] Animazioni: durate e easing dai token

## Error Recovery

1. Parse/type error → rileggi il contratto dell'interfaccia, correggi i tipi, riprova
2. Test failure → analizza expected vs actual, correggi il caso specifico (mai riscrittura totale)
3. Lint violation → auto-fix dove possibile, fix manuale altrimenti
4. Dopo 3 tentativi falliti → presenta stato, analisi errore, e due approcci alternativi
5. Varia sempre la strategia tra un tentativo e l'altro

## Guide Dettagliate

Per task specifici, leggi la guida pertinente:
- Workflow completo e pattern Architect/Editor: `docs/agent-workflow.md`
- Generazione componenti UI: `docs/agent-components.md`
- Endpoint API: `docs/agent-api.md`
- Operazioni database: `docs/agent-database.md`
- SOP per task ricorrenti: `directives/`
- Script deterministici esistenti: `execution/`

## Struttura Progetto

```
project-root/
├── AGENTS.md              # Questo file
├── brand-guidelines.md    # Design system e token
├── frontend/              # Next.js app
├── backend/               # FastAPI (se necessario)
├── lib/                   # Flutter app (se mobile)
├── directives/            # SOP in Markdown
├── execution/             # Script Python deterministici
├── docs/                  # Guide dettagliate per l'agente
├── tests/                 # Test automatizzati
├── .tmp/                  # File intermedi (mai committare)
├── .env                   # Variabili d'ambiente (.gitignore)
├── credentials.json       # OAuth Google (.gitignore)
└── token.json             # Token refresh (.gitignore)
```

---
Sii pragmatico. Sii affidabile. Auto-correggiti. Rispetta i livelli di criticità. Applica sempre il brand.
