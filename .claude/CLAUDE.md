# CLAUDE.md

See @README.md for project overview and @package.json for available commands.

> **Owner:** [Your Name / Org]
> **Product:** [Brief product description]
> **Repo:** [Repo name and structure]

## Quick Reference

**Core Rules:**
- @.claude/rules/code-style.md — Naming, complexity limits, documentation
- @.claude/rules/testing.md — Test structure, what to test, quality gates
- @.claude/rules/security.md — Security requirements
- @.claude/rules/file-organization.md — Directory structure, file caps, dependency direction

**Accessibility:** *(for projects with a frontend — loads automatically on .tsx/.jsx edits)*
<!-- Uncomment when the project has a React/Preact frontend: -->
<!-- - @.claude/rules/accessibility.md — WCAG 2.1 AA patterns for modals, forms, tables, live regions -->

**Package Rules:** *(add package-specific rule files as needed)*
<!-- Example:
- @.claude/rules/backend/api.md — API layer rules
- @.claude/rules/frontend/webapp.md — Frontend rules
-->

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

## 5. Git Workflow

**Branch naming:** `feature/{ticket}-{short-description}` (e.g., `feature/123-user-auth`)
**Commit messages:** Reference ticket (e.g., `#123: Implement user auth flow`)
**Always use feature branches + PRs.** NEVER commit directly to `main` or `develop`.
**ALWAYS create PRs as drafts** (`gh pr create --draft`). The author decides when to mark "Ready for review."
**PR description:** Link to ticket, describe what changed and why, list affected files.

## 6. Figma-to-Code Workflow

When implementing a page from a Figma mockup:
1. Create an implementation plan from the design
2. Execute the plan, loading design tokens and brand rules first
3. Use `figma:implement-design` to translate the Figma design to code
4. **ALWAYS build from the existing component library** — do NOT use Figma-generated code. Read the Figma design as a visual spec and implement using the project's components and design tokens.
5. Write tests alongside implementation

### Component Resolution Order

When a design requires a component, resolve it in this order:

1. **Check existing components** in your project's component library — use them if they exist
2. **Check the Tailwind Plus component list** in @.claude/tailwind-plus-components.md — if the needed component exists there, **ask the user to provide the code** from the Tailwind Plus website (paid license)
3. **If the component does not exist** in either the codebase or the Tailwind Plus list, **ask the user** before creating a custom component

NEVER create a new component from scratch if one already exists in the codebase or is available from Tailwind Plus.

## 7. AI-Specific Instructions

- **Read and ingest before you edit.** Always read relevant source files before proposing changes. NEVER speculate about code you haven't inspected.
- **These rules are authoritative over observed codebase patterns.** If existing code violates a rule in this document or `.claude/rules/`, that is technical debt — not a convention to follow. Never justify bad practices because you see them elsewhere in the repo. When in doubt, follow the rules, not the code.
- **Follow existing design patterns that comply with these rules.** Study the relevant package and match the established architecture, file placement, and naming. If a convention exists and does not violate these rules, use it. If you have a clear technical reason to deviate, explain the rationale.
- **Reuse existing utility functions**
- **Reuse existing UI components**
- **Verify schema and queries against source files.** Check your ORM schema for table/column structure before writing code that references them.
- **Check existing types before creating new ones** to avoid duplication. Create new types when genuinely needed for new features.
- **Flag security concerns proactively** (exposed secrets, SQL injection, missing auth, etc.).
- **Use parallel tool calls** for independent operations (e.g., reading multiple files, running lint and test simultaneously).
- **Package context awareness:** When working in a specific package, prioritize that package's rule file.
