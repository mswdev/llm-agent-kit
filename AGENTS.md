# AGENTS.md — AI Development Instructions

> **Owner:** [Your Name / Org]
> **Product:** [Brief product description]
> **Repo:** [Repo name and structure]

> **Companion file:** This file mirrors the `.claude/` directory so that Codex (and other LLM agents) have the same project context as Claude Code. See `README.md` for project overview and `package.json` for available commands.

---

## 1. Project Overview

<!-- Replace this section with your project's domain context -->
<!-- Include: what the product does, key user flows, revenue model -->

<!-- Example domain terms table:
| Term | Definition |
|------|-----------|
| **Widget** | A configurable UI element that customers embed on their site |
-->

---

## 2. Core Engineering Philosophy

1. **KISS** — Keep It Simple, Stupid. The simplest solution that works is the best solution.
2. **Clarity over cleverness** — No tricks, no golf, no "elegant" one-liners that require a comment to explain.
3. **Functional decomposition** — Break problems into small, named, single-purpose functions.
4. **Object-Oriented Design** — Model the domain with clear objects, well-defined boundaries, and explicit contracts.
5. **Test what matters** — Unit tests are not optional. If logic makes a decision, it gets a test. ALWAYS WRITE TESTS.
6. **SOLID Principles** — Follow SOLID programming principles.

---

## 3. Code Style

### Method Size & Complexity

These are **hard limits**, not guidelines:
- **MAXIMUM 25 lines per method** (excluding blank lines and closing braces).
- **MAXIMUM 2 levels of control flow nesting** per method. If you need a third level, extract a method.
- **MAXIMUM 3 parameters** per method. Beyond that, introduce a parameter object or rethink the design.

### YOU MUST USE EARLY RETURNS OVER DEEP NESTING

Guard clauses go at the top. The happy path reads straight down.

### Naming Conventions

Names should be **descriptive and unambiguous**. A reader should never have to look at a method body to understand what it does. Avoid abbreviations.

- **Classes/Interfaces**: PascalCase — nouns (`DatabaseSDK`, `InvoiceCalculator`, `RequestValidator`)
- **Enums**: PascalCase with UPPER_SNAKE values (`Status.IN_REVIEW`)
- **Methods/Functions**: camelCase — verbs (`getUserById`, `approveRequest`, `calculateTotal`)
- **Booleans**: prefix with `is`, `has`, `can`, `should` (`isEligible`, `hasAccess`)
- **Collections**: pluralize (`users`, `activeOrders`, `pendingItems`)
- **Constants**: UPPER_SNAKE_CASE (`ALGORITHM`, `KEY_LENGTH`, `MAX_RETRY_COUNT`)
- **Files**: PascalCase for classes (`UserService.tsx`), camelCase for utils (`format-date.ts`)

### General Rules

- **DO NOT EVER USE `any` types** — Use proper typing or `unknown` with type guards.
- **ALWAYS USE `async/await`** over raw Promises.
- **One export per file** for classes/processors; named exports for utils/types.
- **ALL MONETARY VALUES ARE IN CENTS** (integers), never floating-point dollars.
- **NO MAGIC NUMBERS EVER** — ALWAYS EXTRACT TO A NAMED CONSTANT.

### Code Documentation & Comments

All code must include clear, human-readable documentation. Comments should be written so that a junior-level developer or higher can understand what is being done and why.

**JSDoc/TSDoc is required on all exported functions, methods, classes, and interfaces.** IDEs parse these for tooltips and autocomplete, and they support future automated API documentation generation (TypeDoc, API Extractor, etc.).

**Required JSDoc tags:**
- `@param` — every parameter with its purpose and constraints
- `@returns` — what the function returns and under what conditions
- `@throws` — any exceptions the function may throw
- `@example` — usage example for non-trivial functions
- `@see` — cross-reference related functions or docs
- `@deprecated` — mark deprecated code with migration path

**Inline comments** should explain "why," not "what." Comment business logic, workarounds, edge cases, and non-obvious decisions — not obvious code.

### Linting

<!-- Configure per project. Examples: -->
<!-- Biome: check `biome.json` for config -->
<!-- ESLint + Prettier: run `npm run lint` -->

---

## 4. Testing

### Philosophy

Tests are **documentation** that happens to be executable. A test should read like a specification of behavior.

### Structure: Arrange -> Act -> Assert

Separate the three phases with blank lines:

```typescript
describe('OrderProcessor', () => {
  describe('submit', () => {
    it('creates an order for a valid request', async () => {
      const request = RequestFixture.valid();
      const processor = buildOrderProcessor();

      const order = await processor.submit(request);

      expect(order.status).toBe(OrderStatus.PENDING);
      expect(order.requestId).toBe(request.id);
    });

    it('rejects invalid requests', async () => {
      const request = RequestFixture.invalid();
      const processor = buildOrderProcessor();

      await expect(processor.submit(request)).rejects.toThrow(InvalidRequestError);
    });
  });
});
```

### What to Test

- **Processors and business logic** — Always. This is the core of the system.
- **Utility/helper functions** — Always. They're pure and easy to test.
- **Financial calculations** — Always. Money math must be bulletproof.
- **API route handlers** — Integration tests for the happy path and key error cases.
- **React components** — Test behavior (user interactions, conditional rendering), not implementation.
- **Complex hooks** — Test with `renderHook` when they contain meaningful logic.

### What NOT to Test

- Simple getters/setters or data classes with no logic.
- Framework boilerplate (middleware wiring, route config, loader setup).
- Third-party library behavior.

### Test Doubles

Prefer **hand-written fakes** over mocking libraries. Fakes are simpler, more readable, and catch interface drift at compile time.

### Quality Gates

**Before committing, ALWAYS run:**
```bash
npm run build && npm run test && npm run lint
```

<!-- Add per-package gates as needed -->

---

## 5. Security

### No-Touch Zones

These files require **explicit approval** before any modification:

<!-- Customize per project. Examples: -->
<!-- - `src/crypto/Cryptographer.ts` — Encryption logic -->
<!-- - `src/billing/Calculator.ts` — Financial math -->

- Any `.env*` files, deployment configs, or CI/CD workflows
- Database migration files
- Authentication/authorization configuration
- Cryptography or encryption modules
- Financial calculation modules

### Security Rules

- **NEVER hardcode secrets in source code**
- **NEVER run destructive DB operations** (DROP, TRUNCATE, DELETE without WHERE)
- **Validate all API input** — NEVER TRUST CLIENT INPUT (use Joi, Zod, or equivalent)
- **Flag security concerns proactively** — exposed secrets, SQL injection, missing auth, XSS, CSRF, etc.
- **ALL MONETARY VALUES ARE IN CENTS** (integers), never floating-point dollars — prevents rounding vulnerabilities

---

## 6. Code Review Checklist

Before approving any PR, verify:
- [ ] **Can I understand every method without reading its callees?** If no, the names need work.
- [ ] **There are NO MAGIC NUMBERS**
- [ ] **Is every method <= 25 lines?** NO EXCEPTIONS.
- [ ] **Is nesting <= 2 levels deep?** Extract if not.
- [ ] **Does each class have a single, obvious responsibility?**
- [ ] **Are there tests for every decision point in the logic?**
- [ ] **Is there any cleverness that should be replaced with clarity?**
- [ ] **Would a new teammate understand this in 5 minutes?**
- [ ] **Do new API endpoints have input validation schemas?**
- [ ] **Do all exported functions/methods/classes have JSDoc documentation?**
- [ ] **Do route handlers and service methods log their outcomes?**
- [ ] **Do all catch blocks capture errors to the error monitoring service?**

---

## 7. File Organization

### Directory Size Limits

These are **hard limits**, not guidelines:
- **MAXIMUM 10 source files per directory.** Count only source files (`.ts`, `.tsx`) — colocated `.test.` and `.stories.` files do NOT count toward the cap. If a directory has 10 source files, the next file MUST go in a subdirectory. No exceptions.
- **Colocate test and story files with their source files.** `Button.tsx`, `Button.test.tsx`, and `Button.stories.tsx` belong together in the same directory.

When a directory approaches the cap, group related files into subdirectories by **domain**, **feature**, or **concern** — not by file type.

### Directory Grouping

Group by **domain or feature**, not by file type. Keep related code together.

**Exception:** Top-level `src/` directories MAY be organized by architectural layer (e.g., `api/`, `db/`, `event/`) when they represent distinct system boundaries. Within those layers, group by domain.

### Dependency Direction

Imports flow **downward and inward**, never upward or sideways across features.

- **Parent directories MUST NOT import from child route/feature directories.** Shared code lives at the nearest common ancestor.
- **Sibling feature directories MUST NOT import from each other.** Extract shared code to their common parent or a `_shared/` directory.

### DO NOT MIMIC EXISTING BAD PATTERNS

- **NEVER add files to a directory that already exceeds the 10-file cap.** Flag it and propose a restructuring.
- **When creating new files, follow these rules from scratch** — do not pattern-match against poorly organized directories.

---

## 8. Infrastructure & Services

<!-- Replace with your project's infrastructure -->
<!-- Example:
| Service | Purpose | Status |
|---------|---------|--------|
| PostgreSQL | Primary database | Active |
| Redis | Caching & sessions | Active |
| Clerk | Authentication | Active |
| Sentry | Error monitoring | Active |
-->

---

## 9. Git Workflow

**Branch naming:** `feature/{ticket}-{short-description}` (e.g., `feature/123-user-auth`)
**Commit messages:** Reference ticket (e.g., `#123: Implement user auth flow`)
**Always use feature branches + PRs.** NEVER commit directly to `main` or `develop`.
**PR description:** Link to ticket, describe what changed and why, list affected files.

---

## 10. AI-Specific Instructions

- **Read and ingest before you edit.** Always read relevant source files before proposing changes. NEVER speculate about code you haven't inspected.
- **These rules are authoritative over observed codebase patterns.** If existing code violates a rule in this document, that is technical debt — not a convention to follow. Never justify bad practices because you see them elsewhere in the repo. When in doubt, follow the rules, not the code.
- **Follow existing design patterns that comply with these rules.** Study the relevant package and match the established architecture, file placement, and naming. If a convention exists and does not violate these rules, use it. If you have a clear technical reason to deviate, explain the rationale.
- **Reuse existing utility functions**
- **Reuse existing UI components**
- **Verify schema and queries against source files.** Check your ORM schema for table/column structure before writing code that references them.
- **Check existing types before creating new ones** to avoid duplication. Create new types when genuinely needed for new features.
- **Flag security concerns proactively** (exposed secrets, SQL injection, missing auth, etc.).
