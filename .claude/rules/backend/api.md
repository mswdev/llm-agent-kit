---
paths:
  - "api/**"
---

<!-- Adjust the `paths` above to your backend package directory (e.g. "packages/api/**"). -->
<!-- Replace placeholder service/file names with your project's actual implementations. -->

# API Package Rules

## API Standards
- **Validation schemas for all input** (Zod, Joi, or equivalent) — NEVER TRUST CLIENT INPUT
- **Route naming**: kebab-case paths, `[param]` for dynamic segments (e.g., `/merchants/[merchantId]/orders`)
- All route handlers must have corresponding validation schemas
- **ALL MONETARY VALUES ARE IN CENTS** (integers), never floating-point dollars

## Atomicity

Any handler or processor that writes to ≥ 2 tables in a single logical operation MUST wrap the writes in a database transaction (e.g., `database.withTransaction(async (tx) => { ... })`). Pass the transactional handle (`tx`) to every persistence method inside the closure so all writes participate in the same transaction.

- Idempotent side-effects on a different aggregate (e.g., a workflow step completion) belong **outside** the transaction.
- Calls to external services (auth provider, third-party APIs, object storage) belong **outside** the transaction — use the saga pattern for compensating cleanup.
- Single-table writes do not need a transaction.

**Example:**
```typescript
const order = await this.database.withTransaction(async (tx) => {
  const customer = await this.persistCustomerDetails(input, tx);
  return this.persistOrder(this.buildOrder(customer), tx);
});
```

## Concurrency & Idempotency

- **No check-then-act on shared state** — use `INSERT ... ON CONFLICT`, upsert, or `SELECT ... FOR UPDATE`. An `if (!exists) create()` is a race condition.
- **Webhook/queue handlers must be idempotent** — events can be delivered more than once. Use an idempotency service keyed on the event id.
- **Saga compensation must handle missing state** — never silently no-op if the state-write after an external call failed.

## Soft-Delete

If the project soft-deletes rows (stamped `deleted_at`) rather than physically removing them — e.g., to retain an offboarded subject for audit/DSR while removing it from active operations:

- **Stamp via a dedicated soft-delete method, never a bare `update`** — it should CAS-stamp `deleted_at` AND emit the lifecycle audit event in **one transaction** (idempotent on `deleted_at IS NULL`). A soft-delete must never be recorded without its audit trail.
- **Apply the `deleted_at IS NULL` read filter DELIBERATELY, not blanket.** Add it to the *active* lookups (auth, onboarding, linking) so a soft-deleted row cannot act. Leave **by-primary-key reads unfiltered** so admin/DSR/erasure paths can still load the offboarded row.
- **Children without their own `deleted_at`** (append-only version tables, external-id mappings) are excluded **transitively** through their soft-deleted parent — they are not stamped.

## Authorization (per-endpoint, deny-by-default)

Authentication is not authorization. **Every authenticated, user-facing route MUST carry a function-level permission gate** (e.g., CASL) in addition to session auth — a restricted role must be blocked at the *endpoint*, not just hidden from the page (OWASP API5 / BFLA).

- **Gates take an `(action, subject)` pair** resolved from a single source-of-truth resource→subject mapping. A tenant-isolation-only middleware is **never the sole gate on a data route**.
- **Tenant isolation (OWASP API1 / BOLA):** scope every query by the tenant id from the session, **never** client input. Cross-tenant ids return 404. Keep the tenant filter on by-id queries.
- **Object-level coverage is enforced, not just gate presence.** A permission gate proves *authorization exists* — not that the query is *owner-scoped*. Classify every route whose path takes an object-id param in a coverage registry: either `tenant-scoped` (with a BOLA test driving the route as owner A with owner B's id → asserting **404, never B's data**) or a reasoned exemption (`cross-tenant-by-design` for staff/admin, `deferred` with a ticket). A guard test fails CI on any unclassified object-id route — so a new `/:id` endpoint cannot ship with an unscoped query.
- **Exceptions** (public routes, webhook endpoints, API-key auth, auth-provider bootstrap) go in a public-route allowlist with a reason. A guard test fails CI if any authenticated route is neither gated nor allowlisted — so a new unguarded endpoint cannot ship.
- **Any frontend-facing abilities endpoint is nav-gating only — never a security boundary.** The API enforces all authorization; a malicious client calling the API directly must be stopped here.

## Logging
- Route handlers: use the request-scoped logger (e.g., `req.log` from pino-http)

## Linting

<!-- Configure per project. Examples: -->
<!-- Biome: check `biome.json` for config -->
<!-- ESLint + Prettier: run `npm run lint` -->

## Error Monitoring
- **All catch blocks in route handlers MUST capture to the error monitoring service** (e.g., `Sentry.captureException(err)`) before returning an error response — prefer a shared helper that attaches route context
- Set user/session context on the monitoring scope via middleware, not per-handler
- Never log secrets or PII to the monitoring service — scrub in a `beforeSend` hook

## Testing
- **Quality gate:**
  ```bash
  npm run typecheck && npm run test && npm run lint
  ```
