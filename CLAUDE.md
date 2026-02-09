# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

FideLux ("Fides + Lux" — Trust + Transparency) is a Flutter mobile app for personal finance accountability. A **Keeper** (accountability partner) monitors a **Sharer**'s finances through a cryptographically-verified, append-only event chain. Communication happens via email (IMAP/SMTP) — no central server. All data lives on-device only.

## Commands

```bash
# Run the app
flutter run

# Static analysis (linting)
flutter analyze

# Run all tests
flutter test

# Run a single test file
flutter test test/crypto/crypto_service_test.dart

# Code generation (Drift DB + Riverpod, required after changing DB schema or providers)
flutter pub run build_runner build --delete-conflicting-outputs

# Regenerate localization files (after editing ARB files)
flutter gen-l10n

# Get dependencies
flutter pub get
```

## Architecture

Clean Architecture with 4 layers. Dependencies point inward: Presentation → Application → Domain ← Data.

```
lib/
├── domain/           # Pure Dart — entities, repository interfaces. ZERO Flutter imports.
├── data/             # Implements domain interfaces (Drift DB, crypto, email, secure storage)
├── application/      # Use cases orchestrating domain logic (one class per use case)
├── presentation/     # UI: screens, providers (Riverpod), router (GoRouter), shell
├── theme/            # Material 3 design tokens (colors, spacing, radius)
├── l10n/             # ARB files (EN/IT) + generated localizations
├── core/             # Shared utilities (CurrencyFormatter, extensions, error types)
├── main.dart         # Entry point — wraps app in ProviderScope
└── app.dart          # MaterialApp.router with theme + localization config
```

### Key patterns

- **State management**: Riverpod 2.0. Providers live in `lib/presentation/providers/`. Singletons via `Provider`, async loads via `FutureProvider`, reactive DB queries via `StreamProvider`.
- **Database**: Drift (type-safe SQLite). Schema in `lib/data/local_db/app_database.dart`, DAOs in `lib/data/local_db/daos/`. Generated file: `app_database.g.dart`. Run `build_runner` after schema changes.
- **Routing**: GoRouter with `StatefulShellRoute.indexedStack` (5 tabs: Inbox, Dashboard, Ledger, Reports, Settings). Config in `lib/presentation/router/app_router.dart`.
- **Localization**: ARB files in `lib/l10n/`, output class is `L` (usage: `L.of(context).keyName`). Config in `l10n.yaml`. Generated output goes to `lib/l10n/generated/`.

### Cryptographic chain (core invariant)

Every financial event is an immutable link in an append-only chain:
- **Genesis** event: `sequence=0`, `previousHash="0"×64`
- Each event's `hash` = SHA-256 of `sequence|previousHash|timestamp|eventType|payload|keeperSignature`
- Events carry Ed25519 signatures (Keeper required, Sharer optional)
- Chain integrity = each event's `previousHash` matches prior event's `hash`
- **Never update or delete** rows in the `chain_events` table — append-only is non-negotiable

### Domain rules

- All monetary amounts are **integers in cents** (centesimi). Conversion to display format happens only in Presentation layer via `CurrencyFormatter`.
- All `DateTime` values stored as **UTC**. Convert to local only in UI with `.toLocal()`.
- The `chain_events` table is strictly append-only. Corrections are new CORRECTION events, never edits.
- Trust levels 1-6 on event metadata (6=highest, manual with receipt; 1=lowest, pending clarification).

## Directive-driven development

Features are specified as SOPs in `directives/` (numbered sequentially). Before implementing a feature, read the relevant directive — it contains exact file lists, steps, validation criteria, and critical rules. Completed: 01–05. Pending: 06 (OCR receipts), 07 (Dashboard).

## Design system

Before writing any UI code, consult `brand-guidelines.md`. Key constraints:
- Primary color: Amber/Gold `#D4A017`. Theme tokens in `lib/theme/`.
- Spacing: multiples of 4px (use `FideLuxSpacing` constants).
- Border-radius: max 12px (use `FideLuxRadius` constants).
- Colored glows instead of black drop-shadows.
- Financial amounts use monospace styling via `FideLuxFinancialStyles`.

## Testing

Tests are in `test/` mirroring the source structure. Key test areas:
- `test/crypto/` — Ed25519 sign/verify, SHA-256 hashing, tamper detection
- `test/chain/` — genesis creation, hash linking, chain integrity verification
- `test/email/` — message signature validation
- `test/pairing/` — QR code generation/parsing
- `test/integration/` — end-to-end flows (account creation → transaction → balance)

Uses Mockito for mocking external dependencies. Domain entities are tested in isolation without Flutter.

## See also

- `AGENTS.md` — Agent workflow, criticality levels, validation checklist, error recovery
- `FIDELUX.md` — Full product specification (actors, threat model, roadmap, business model)
- `docs/` — Detailed guides (agent-workflow, agent-components, agent-api, agent-database)
