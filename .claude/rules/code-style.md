# Code Style

## Method Size & Complexity

These are **hard limits**, not guidelines:
- **MAXIMUM 25 lines per method** (excluding blank lines and closing braces) — applies to logic-bearing code: service methods, processors, utility functions, event handlers, and backend route handlers.
- **MAXIMUM 50 lines for React component render functions and custom hooks** — JSX markup is declarative structure, not branching logic. Line count in components reflects element hierarchy, not cognitive complexity. Extract a sub-component only when there is meaningful conditional branching or a genuine reuse opportunity — never purely to hit a line target. The same applies to custom hooks: a form hook with 5 state declarations, derived values, and callbacks is clean at 40 lines.
- **MAXIMUM 2 levels of control flow nesting** per method. If you need a third level, extract a method.
- **MAXIMUM 3 parameters** per method. Beyond that, introduce a parameter object or rethink the design.

## YOU MUST USE EARLY RETURNS OVER DEEP NESTING

Guard clauses go at the top. The happy path reads straight down.

## Naming Conventions

Names should be **descriptive and unambiguous**. A reader should never have to look at a method body to understand what it does. Avoid abbreviations.

- **Classes/Interfaces**: PascalCase — nouns (`DatabaseSDK`, `InvoiceCalculator`, `ClaimValidator`)
- **Enums**: PascalCase with UPPER_SNAKE values (`Status.IN_REVIEW`)
- **Methods/Functions**: camelCase — verbs (`getUserById`, `approveRequest`, `calculateTotal`)
- **Booleans**: prefix with `is`, `has`, `can`, `should` (`isEligible`, `hasAccess`)
- **Collections**: pluralize (`users`, `activeOrders`, `pendingItems`)
- **Constants**: UPPER_SNAKE_CASE (`ALGORITHM`, `KEY_LENGTH`, `MAX_RETRY_COUNT`)
- **Files**: PascalCase for classes (`UserService.tsx`), camelCase for utils (`format-date.ts`)

## General Rules

- **DO NOT EVER USE `any` types** — Use proper typing or `unknown` with type guards.
- **ALWAYS USE `async/await`** over raw Promises.
- **One export per file** for classes/processors; named exports for utils/types.
- **ALL MONETARY VALUES ARE IN CENTS** — see @.claude/rules/security.md for details.
- **NO MAGIC NUMBERS EVER** — ALWAYS EXTRACT TO A NAMED CONSTANT.

## Code Documentation & Comments

All code must include clear, human-readable documentation. Comments should be written so that a junior-level developer or higher can understand what is being done and why.

**JSDoc/TSDoc is required on all exported functions, methods, classes, and interfaces.** IDEs parse these for tooltips and autocomplete, and they support future automated API documentation generation (TypeDoc, API Extractor, etc.).

**Required tags:** `@param` · `@returns` · `@throws` · `@example` (non-trivial functions) · `@see` (cross-references) · `@deprecated` (with migration path)

**Inline comments** should explain "why," not "what." Comment business logic, workarounds, edge cases, and non-obvious decisions — not obvious code.

## Linting

<!-- Configure per project. Examples: -->
<!-- Biome: check `biome.json` for config -->
<!-- ESLint + Prettier: run `npm run lint` -->
