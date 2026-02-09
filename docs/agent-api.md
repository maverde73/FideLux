# docs/agent-api.md — Generazione Endpoint API

Questa guida si applica quando generi endpoint API (FastAPI o Next.js API routes).

---

## Struttura Directory

### FastAPI (Python)

```
backend/
├── main.py              # App FastAPI, CORS, startup
├── routers/
│   ├── auth.py          # Endpoint autenticazione
│   ├── users.py         # CRUD utenti
│   └── [domain].py      # Un router per dominio
├── models/
│   ├── user.py          # Pydantic models (request/response)
│   └── [domain].py
├── services/
│   ├── user_service.py  # Business logic
│   └── [domain]_service.py
├── db/
│   ├── database.py      # Connessione DB
│   └── migrations/
├── tests/
│   ├── test_auth.py
│   └── test_users.py
├── requirements.txt
└── .env
```

### Next.js API Routes

```
frontend/
├── app/
│   └── api/
│       ├── auth/
│       │   └── route.ts       # POST /api/auth
│       ├── users/
│       │   ├── route.ts       # GET, POST /api/users
│       │   └── [id]/
│       │       └── route.ts   # GET, PUT, DELETE /api/users/:id
│       └── [domain]/
│           └── route.ts
├── lib/
│   ├── api-client.ts          # Fetch wrapper tipizzato
│   ├── validations/
│   │   └── user.ts            # Zod schemas
│   └── types/
│       └── api.ts             # Tipi request/response condivisi
```

---

## Convenzioni API

<rules>
1. Ogni endpoint ha validazione input (Pydantic per FastAPI, Zod per Next.js)
2. Response tipizzate: sempre un tipo esplicito per il body di risposta
3. Error handling uniforme: { error: string, code: string, details?: object }
4. HTTP status coerenti: 200 success, 201 created, 400 bad request, 401 unauthorized, 403 forbidden, 404 not found, 500 internal error
5. Paginazione: { data: T[], total: number, page: number, pageSize: number }
6. Logging: log strutturato su ogni errore 4xx/5xx con request ID
7. Rate limiting: specifica limiti nei commenti dell'endpoint
8. CORS: configurato esplicitamente in main.py o next.config.js
</rules>

---

## Template FastAPI

```python
# routers/[domain].py
from fastapi import APIRouter, HTTPException, Depends
from models.[domain] import CreateItemRequest, ItemResponse
from services.[domain]_service import DomainService

router = APIRouter(prefix="/[domain]", tags=["[Domain]"])

@router.post("/", response_model=ItemResponse, status_code=201)
async def create_item(
    request: CreateItemRequest,
    service: DomainService = Depends()
) -> ItemResponse:
    """Crea un nuovo item. Rate limit: 100/min."""
    try:
        item = await service.create(request)
        return ItemResponse.model_validate(item)
    except ValueError as e:
        raise HTTPException(status_code=400, detail=str(e))
```

## Template Next.js API Route

```typescript
// app/api/[domain]/route.ts
import { NextRequest, NextResponse } from 'next/server'
import { createItemSchema } from '@/lib/validations/[domain]'
import { DomainService } from '@/lib/services/[domain]'

export async function POST(request: NextRequest) {
  try {
    const body = await request.json()
    const validated = createItemSchema.parse(body)
    const item = await DomainService.create(validated)
    return NextResponse.json(item, { status: 201 })
  } catch (error) {
    if (error instanceof z.ZodError) {
      return NextResponse.json(
        { error: 'Validation failed', code: 'VALIDATION_ERROR', details: error.errors },
        { status: 400 }
      )
    }
    return NextResponse.json(
      { error: 'Internal server error', code: 'INTERNAL_ERROR' },
      { status: 500 }
    )
  }
}
```

---

## Autenticazione

<rules>
1. JWT con refresh token per app web/mobile
2. Token di accesso: durata breve (15min), in memoria (mai localStorage)
3. Refresh token: durata lunga (7-30 giorni), httpOnly cookie
4. Middleware di autenticazione separato e riutilizzabile
5. Ruoli e permessi: verifica a livello di endpoint, mai solo lato client
</rules>

---

## Testing API

Ogni endpoint ha almeno questi test:

1. **Happy path** — Request valida → response attesa con status corretto
2. **Validazione** — Request con campo mancante/invalido → 400 con messaggio chiaro
3. **Auth** — Request senza token → 401; token scaduto → 401; ruolo sbagliato → 403
4. **Not found** — ID inesistente → 404
5. **Idempotenza** — POST duplicato gestito (upsert o errore 409)
