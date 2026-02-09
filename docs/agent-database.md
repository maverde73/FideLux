# docs/agent-database.md — Operazioni Database

Questa guida si applica quando crei, modifichi, o interagisci con database. Le operazioni DB sono tra le più critiche — segui i livelli di criticità con rigore.

---

## Criticità per Tipo di Operazione

| Operazione | Livello | Comportamento |
|------------|---------|---------------|
| SELECT / READ | 🟢 Basso | Esegui autonomamente |
| CREATE TABLE / INDEX | 🟡 Medio | Esegui e notifica |
| INSERT (batch piccolo) | 🟡 Medio | Esegui e notifica |
| ALTER TABLE | 🔴 Alto | Piano + conferma |
| UPDATE senza WHERE specifico | 🔴 Alto | Piano + conferma |
| DELETE / DROP | 🔴 Alto | Piano + conferma |
| Migration in produzione | 🔴 Alto | Piano + conferma |
| Seed / import dati massivo | 🔴 Alto | Piano + conferma |

---

## Convenzioni Schema

<rules>
1. Naming: snake_case per tabelle e colonne, plurale per tabelle (users, orders)
2. Ogni tabella ha: id (UUID o auto-increment), created_at, updated_at
3. Foreign key esplicite con ON DELETE appropriato (CASCADE, SET NULL, RESTRICT)
4. Index su ogni foreign key e su colonne usate frequentemente in WHERE/ORDER BY
5. Soft delete (deleted_at timestamp) preferito a DELETE fisico per dati utente
6. Commenti SQL su ogni tabella e colonna non ovvia
7. Migration numerate e idempotenti (IF NOT EXISTS)
</rules>

---

## Struttura Migration

```sql
-- migrations/001_create_users.sql
-- Descrizione: Crea la tabella utenti base
-- Criticità: 🟡 MEDIO (CREATE)
-- Reversibile: SI (DROP TABLE users)

CREATE TABLE IF NOT EXISTS users (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    email VARCHAR(255) NOT NULL UNIQUE,
    display_name VARCHAR(100) NOT NULL,
    role VARCHAR(20) NOT NULL DEFAULT 'user' CHECK (role IN ('admin', 'user', 'viewer')),
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    deleted_at TIMESTAMPTZ
);

CREATE INDEX IF NOT EXISTS idx_users_email ON users(email);
CREATE INDEX IF NOT EXISTS idx_users_role ON users(role);

-- Trigger per updated_at automatico
CREATE OR REPLACE FUNCTION update_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_users_updated_at
    BEFORE UPDATE ON users
    FOR EACH ROW EXECUTE FUNCTION update_updated_at();
```

---

## Protocollo per Operazioni Distruttive

Per qualsiasi operazione 🔴 ALTO:

1. **Mostra il piano** — Query esatta che verrà eseguita
2. **Mostra l'impatto** — Quante righe saranno coinvolte (esegui prima un COUNT/SELECT)
3. **Mostra il rollback** — Come annullare l'operazione
4. **Attendi conferma esplicita** — Non procedere senza "sì" dall'utente

Esempio:
```
PIANO: ALTER TABLE orders ADD COLUMN status VARCHAR(20) DEFAULT 'pending';
IMPATTO: 15,234 righe esistenti riceveranno status = 'pending'
ROLLBACK: ALTER TABLE orders DROP COLUMN status;
Procedo? [attendi conferma]
```

---

## ORM e Query Builder

### Python (SQLAlchemy / Prisma)
- Usa sempre parametri preparati (mai string interpolation nelle query)
- Transazioni esplicite per operazioni multi-step
- Connection pooling configurato (min 2, max 10 per default)

### TypeScript (Prisma / Drizzle)
- Schema Prisma come single source of truth per i tipi
- Genera i tipi client dopo ogni modifica allo schema
- Usa `$transaction` per operazioni atomiche

---

## Backup e Safety

<rules>
1. Prima di ALTER/DELETE in produzione: verifica che esista un backup recente
2. Esegui operazioni distruttive prima in ambiente di staging
3. Migration con rollback: ogni migration UP ha la corrispettiva DOWN
4. Seed data: script idempotente e separato dalle migration
5. Credenziali DB: solo in .env, mai nel codice o nelle migration
</rules>
