# docs/agent-workflow.md — Workflow Dettagliato

Questa guida espande il workflow a 6 step definito in `AGENTS.md`. Leggila quando affronti task complessi, multi-file, o quando un task semplice fallisce al primo tentativo.

---

## Pattern Architect / Editor

Ogni task di generazione codice si divide in due fasi distinte. Eseguile sempre in sequenza.

### Fase 1 — Architect (pianifica)

Prima di scrivere codice:
1. Analizza il requisito e identifica le acceptance criteria
2. Cerca nel codebase file correlati, pattern riutilizzabili, tipi esistenti
3. Lista ogni file da creare o modificare
4. Per ogni file, descrivi il cambio in linguaggio naturale (1-2 frasi)
5. Identifica rischi, dipendenze, e casi limite
6. Se il task è 🔴 ALTO → presenta il piano e attendi conferma

### Fase 2 — Editor (implementa)

Dopo la pianificazione:
1. Implementa un file alla volta, nell'ordine definito dal piano
2. Genera file completi con import, tipi, error handling (mai snippet parziali)
3. Dopo ogni file, esegui la validazione (typecheck → lint → test)
4. Se la validazione fallisce, correggi prima di passare al file successivo
5. A implementazione completa, esegui la suite di test completa

---

## Loop di Esecuzione (ReAct)

Per ogni singolo cambio all'interno della Fase Editor:

```
THINK  → Dichiara cosa cambierai e perché
READ   → Esamina il codice esistente nei file coinvolti
ACT    → Applica il cambio specifico
VERIFY → Esegui la validazione pertinente
REFLECT → Se fallisce, analizza il PERCHÉ prima di ritentare
```

Questo loop previene l'errore più comune: ritentare lo stesso approccio sperando in un risultato diverso.

---

## Protocollo di Testing

Prima di dichiarare uno script o componente "funzionante":

1. **Happy path** — Input validi producono output atteso
2. **Input malformato** — Errori gestiti con messaggi leggibili (no crash)
3. **Casi limite** — Valori vuoti, liste con 1 elemento, stringhe con caratteri speciali, undefined/null
4. **Idempotenza** — Due esecuzioni consecutive producono risultati coerenti

Per script che usano API a pagamento o con rate limit: prepara il test, mostralo, chiedi conferma prima di eseguire.

---

## Gestione del Contesto

### Chunking del lavoro
- Spezza task grandi in sotto-task indipendenti, completabili in una singola sessione
- Ogni sotto-task ha input e output chiari, documentati nella direttiva
- Completa un sotto-task, verifica, poi procedi al successivo

### Ripresa di sessione
- All'inizio di ogni sessione, leggi la direttiva corrente e lo stato dei file
- Identifica cosa è completato e cosa resta
- Verifica sempre lo stato dei file — non assumere di ricordare sessioni precedenti

### Coerenza cross-file
- Quando modifichi un file importato da altri, verifica le dipendenze
- Mantieni naming coerente tra file, variabili, componenti
- Se rinomini qualcosa, cerca tutte le occorrenze nel progetto

---

## Loop di Auto-Correzione

Quando qualcosa si rompe:

1. Leggi l'errore e identifica la causa root
2. Correggi lo script
3. Testa con un caso minimo che riproduce l'errore originale
4. Aggiorna la direttiva pertinente per documentare il caso limite
5. Verifica che il fix non abbia rotto funzionalità preesistenti

Il sistema ora è più forte. Ogni ciclo errore-correzione migliora codice E documentazione.

---

## Disciplina delle Direttive

Le direttive in `directives/` sono documenti vivi. Aggiornale quando scopri vincoli API, approcci migliori, errori comuni, o aspettative di timing.

<rules>
1. Ogni direttiva resta focalizzata su un singolo task o dominio
2. Se una direttiva supera ~200 righe, spezzala in sotto-direttive con riferimenti incrociati
3. Aggiorna le direttive esistenti — non crearne o sovrascriverne senza chiedere
4. Usa il formato: Obiettivo → Input → Step → Output → Casi limite noti
</rules>

---

## Limiti di Contesto per Modello

| Modello | Istruzioni affidabili | Strategia |
|---------|----------------------|-----------|
| Claude Opus/Sonnet | ~150-200 | AGENTS.md slim + file referenziati |
| GPT-4o | ~150-200 | Stesso approccio, evita istruzioni annidate profonde |
| Gemini Pro | ~100-150 | Istruzioni assertive e esplicite, evita linguaggio suggestivo |
| Modelli open-source | ~50-80 | Solo regole essenziali, massima semplicità |

Regola generale: mantieni AGENTS.md sotto le 100 righe. Tutto il resto va nei file `docs/`.
