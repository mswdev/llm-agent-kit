# CLAUDE.md

See @README.md for project overview and @package.json for available commands.

> **Owner:** [Your Name / Org]
> **Product:** [Brief product description]
> **Repo:** [Repo name and structure]

## Quick Reference

**Core Rules** (always loaded):
- @.claude/rules/code-style.md — Naming, complexity limits, documentation
- @.claude/rules/testing.md — Test structure, what to test, quality gates
- @.claude/rules/security.md — Security requirements
- @.claude/rules/data-protection.md — GDPR/CCPA compliance, PII encryption *(remove if the project holds no personal data)*
- @.claude/rules/file-organization.md — Directory structure, file caps, dependency direction

**Path-scoped rules** (no `@`-import — these auto-load via their `paths` frontmatter only when editing matching files, so they cost nothing on backend work):
- `.claude/rules/accessibility.md` — WCAG 2.1 AA floor / 2.2 AA for new UI; loads on `.tsx`/`.jsx` edits
- `.claude/rules/frontend/loading-states.md` — skeleton system: content-shaped, no layout shift; loads on `.tsx`/`.jsx` edits

**Package Rules** (path-scoped — load automatically when editing package files; adjust each file's `paths` frontmatter to your package directories, and delete files that don't apply):
- `.claude/rules/backend/api.md` — API layer: validation, atomicity, concurrency, authorization
- `.claude/rules/frontend/webapp.md` — Web app: components, Storybook, promotion path, resolution order
- `.claude/rules/shopify-app/shopify-app.md` — Shopify app: Preact extensions, Polaris `s-*` accessibility

## How to Use These Instructions

1. **Always follow** the core philosophy and code standards
2. **Consult package-specific rules** when working in individual packages
3. **Package rules extend, not override** shared standards (e.g., a backend package adds validation requirements but doesn't remove the 25-line method limit)

## 1. Project Overview

<!-- Replace this section with your project's domain context -->
<!-- Include: what the product does, key user flows, revenue model, and a domain terms table -->
<!-- Example:
| Term | Definition |
|------|-----------|
| **Widget** | A configurable UI element that customers embed on their site |
-->

## 2. Core Engineering Philosophy

1. **KISS** — Keep It Simple, Stupid. The simplest solution that works is the best solution.
2. **Clarity over cleverness** — No tricks, no golf, no "elegant" one-liners that require a comment to explain.
3. **Functional decomposition** — Break problems into small, named, single-purpose functions.
4. **Object-Oriented Design** — Model the domain with clear objects, well-defined boundaries, and explicit contracts.
5. **Test what matters** — Unit tests are not optional. If logic makes a decision, it gets a test. ALWAYS WRITE TESTS.
6. **SOLID Principles** — Follow SOLID programming principles.

## 3. Code Review Checklist

Before approving any PR, verify:
- [ ] **Can I understand every method without reading its callees?** If no, the names need work.
- [ ] **There are NO MAGIC NUMBERS**
- [ ] **Is every logic method ≤ 25 lines? React components/hooks ≤ 50 lines?** NO EXCEPTIONS.
- [ ] **Is nesting ≤ 2 levels deep?** Extract if not.
- [ ] **Does each class have a single, obvious responsibility?**
- [ ] **Are there tests for every decision point in the logic?**
- [ ] **Is there any cleverness that should be replaced with clarity?**
- [ ] **Would a new teammate understand this in 5 minutes?**
- [ ] **Do new API endpoints have input validation schemas?**
- [ ] **Do all exported functions/methods/classes have JSDoc documentation?**
- [ ] **Do route handlers and service methods log their outcomes?**
- [ ] **Do all catch blocks capture errors to the error monitoring service?**
- [ ] **Does async/data-loading UI ship a co-located, content-shaped skeleton (no layout shift)?** See `.claude/rules/frontend/loading-states.md`.

## 4. Infrastructure & Services

<!-- Replace with your project's infrastructure -->
<!-- Example:
| Service | Purpose | Status |
|---------|---------|--------|
| PostgreSQL | Primary database | Active |
| Redis | Caching & sessions | Active |
| Clerk | Authentication | Active |
| Sentry | Error monitoring | Active |
-->

## 5. Logging & Error Monitoring

- **Use the project logger** — NEVER `console.*` in production code (enforce via linter, e.g. Biome `noConsole`)
- **NEVER log sensitive data** — API keys, tokens, passwords, session objects
- **Logging is mandatory** — every route handler, service method, and event handler must log its outcome (success, not-found, error). Match the patterns in existing handlers.
- **Error monitoring is mandatory** — every catch block in route handlers and service boundaries must capture errors to the error monitoring service (e.g. Sentry). Never swallow errors silently.

## 6. Git Workflow

**Branch naming:** `feature/{ticket}-{short-description}` (e.g., `feature/123-user-auth`)
**Commit messages:** Reference ticket (e.g., `#123: Implement user auth flow`)
**Branch off your integration branch** (e.g. `develop`) **and PR to it** unless explicitly told otherwise. If `main` is the production branch, never target it directly.
**Always use feature branches + PRs.** NEVER commit directly to `main` or `develop`.
**ALWAYS create PRs as drafts** (`gh pr create --draft`). The author decides when to mark "Ready for review."
**PR description:** Link to ticket, describe what changed and why, list affected files.

## 7. Code Intelligence

Prefer LSP over Grep/Read for code navigation — it's faster, precise, and avoids reading entire files:
- `workspaceSymbol` to find where something is defined
- `findReferences` to see all usages across the codebase
- `goToDefinition` / `goToImplementation` to jump to source
- `hover` for type info without reading the file

Use Grep only when LSP isn't available or for text/pattern searches (comments, strings, config).

After writing or editing code, check LSP diagnostics and fix errors before proceeding.

## 8. AI-Specific Instructions

- **Read and ingest before you edit.** Always read relevant source files before proposing changes. NEVER speculate about code you haven't inspected.
- **These rules are authoritative over observed codebase patterns.** If existing code violates a rule in this document or `.claude/rules/`, that is technical debt — not a convention to follow. Never justify bad practices because you see them elsewhere in the repo. When in doubt, follow the rules, not the code.
- **Follow existing design patterns that comply with these rules.** Study the relevant package and match the established architecture, file placement, and naming. If a convention exists and does not violate these rules, use it. If you have a clear technical reason to deviate, explain the rationale.
- **Reuse existing utility functions**
- **Reuse existing UI components**
- **Verify schema and queries against source files.** Check your ORM schema for table/column structure before writing code that references them.
- **Check existing types before creating new ones** to avoid duplication. Create new types when genuinely needed for new features.
- **Flag security concerns proactively** (exposed secrets, SQL injection, missing auth, etc.).
- **Use parallel tool calls** for independent operations (e.g., reading multiple files, running lint and test simultaneously).
- **Package context awareness:** When working in a package, **read and follow** its rules file before writing code:
  - API/backend package → `.claude/rules/backend/api.md`
  - Web app package → `.claude/rules/frontend/webapp.md`
  - Shopify app package → `.claude/rules/shopify-app/shopify-app.md`
