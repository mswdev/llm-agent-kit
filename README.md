# llm-agent-kit

Portable configuration files, agent instructions, and coding standards for LLM-powered coding assistants. Works across Claude Code, OpenAI Codex, and other AI agents. Drop into any repo for a consistent AI-assisted dev experience.

## What's Inside

```
llm-agent-kit/
├── AGENTS.md                          # Symlink → .claude/CLAUDE.md (for OpenAI Codex)
├── .github/
│   ├── actions/
│   │   └── claude-stats/
│   │       └── action.yml             # Reusable action: parse & post Claude usage stats
│   ├── prompts/
│   │   └── review.md                  # PR review prompt (GitHub Copilot / Claude)
│   └── workflows/
│       ├── claude.yml                 # Claude assistant (@claude mentions)
│       ├── claude-review.yml          # Claude automated PR review (disabled by default)
│       ├── openai-assistant.yml       # Codex assistant (@codex mentions)
│       └── openai-review.yml         # Codex automated PR review
└── .claude/
    ├── CLAUDE.md                      # Claude Code instructions
    ├── settings.json                  # Hook registration + LSP plugin
    ├── tailwind-plus-components.md    # 639-component Tailwind Plus inventory
    ├── hooks/
    │   ├── post-tool-a11y-check.sh    # PostToolUse: a11y-lint edited frontend files
    │   ├── post-tool-a11y-check.test.sh
    │   ├── stop-a11y-check.sh         # Stop: block finishing with a11y violations
    │   └── stop-a11y-check.test.sh
    └── rules/
        ├── code-style.md              # Naming, complexity limits, documentation
        ├── testing.md                 # Test philosophy, structure, quality gates
        ├── security.md                # Security rules, input validation, money-in-cents
        ├── data-protection.md         # GDPR/CCPA, PII encryption, DSR handling
        ├── file-organization.md       # Directory caps, grouping, dependency direction
        ├── accessibility.md           # WCAG 2.1/2.2 AA (path-scoped to .tsx/.jsx)
        ├── backend/
        │   └── api.md                 # API template: validation, atomicity, authz (path-scoped)
        ├── frontend/
        │   ├── loading-states.md      # Skeleton/spinner system (path-scoped)
        │   └── webapp.md              # Web app template: Storybook, promotion path (path-scoped)
        └── shopify-app/
            └── shopify-app.md         # Shopify template: Preact, Polaris s-* a11y (path-scoped)
```

| File | Purpose | Used By |
|------|---------|---------|
| `AGENTS.md` | Symlink to `.claude/CLAUDE.md` — single source of truth for all agents | OpenAI Codex |
| `.claude/CLAUDE.md` | Project context with references to rule files | Claude Code, Codex (via symlink) |
| `.claude/rules/code-style.md` | Method size limits, naming conventions, TypeScript rules | Claude Code |
| `.claude/rules/testing.md` | Arrange/Act/Assert structure, what to test, quality gates | Claude Code |
| `.claude/rules/security.md` | Input validation, secret handling, monetary rules | Claude Code |
| `.claude/rules/file-organization.md` | Directory size caps, domain grouping, dependency direction | Claude Code |
| `.claude/rules/data-protection.md` | GDPR/CCPA compliance, PII encryption, data subject rights | Claude Code |
| `.claude/rules/accessibility.md` | WCAG 2.1/2.2 AA patterns; auto-loads only on `.tsx`/`.jsx` edits | Claude Code |
| `.claude/rules/frontend/loading-states.md` | Skeleton vs. spinner rules, zero layout shift; auto-loads on frontend edits | Claude Code |
| `.claude/rules/backend/api.md` | Backend package template: validation, atomicity, concurrency, deny-by-default authorization | Claude Code |
| `.claude/rules/frontend/webapp.md` | Web app package template: Storybook, component promotion path, resolution order | Claude Code |
| `.claude/rules/shopify-app/shopify-app.md` | Shopify app package template: Preact extensions, Polaris `s-*` accessibility, bundle limits | Claude Code |
| `.claude/settings.json` | Registers the a11y hooks + enables the TypeScript LSP plugin | Claude Code |
| `.claude/hooks/post-tool-a11y-check.sh` | PostToolUse hook: lints edited frontend files for a11y violations, feeds findings back into context | Claude Code |
| `.claude/hooks/stop-a11y-check.sh` | Stop hook: blocks the agent from finishing while touched frontend files still have a11y violations (fail-closed) | Claude Code |
| `.claude/tailwind-plus-components.md` | Full Tailwind Plus component inventory for the component resolution workflow | Both |
| `.github/prompts/review.md` | Structured PR review prompt with categories and output format | GitHub Copilot / Claude |
| `.github/actions/claude-stats/action.yml` | Reusable composite action to parse Claude execution stats and post as comment | GitHub Actions |
| `.github/workflows/claude.yml` | Claude assistant — responds to `@claude` mentions on issues/PRs | GitHub Actions |
| `.github/workflows/claude-review.yml` | Claude automated PR review (disabled by default, enable via `if` condition) | GitHub Actions |
| `.github/workflows/openai-assistant.yml` | Codex assistant — responds to `@codex` mentions on issues/PRs | GitHub Actions |
| `.github/workflows/openai-review.yml` | Codex automated PR review on non-draft PRs | GitHub Actions |

## Usage

### Option 1: Copy what you need

Cherry-pick individual files into your project:

```bash
# Clone the kit
git clone https://github.com/mswdev/llm-agent-kit.git

# Copy Claude Code config into your project
cp -r llm-agent-kit/.claude/ /path/to/your-project/.claude/

# Copy Codex instructions
cp llm-agent-kit/AGENTS.md /path/to/your-project/AGENTS.md

# Copy PR review prompt
mkdir -p /path/to/your-project/.github/prompts
cp llm-agent-kit/.github/prompts/review.md /path/to/your-project/.github/prompts/review.md

# Copy GitHub Actions workflows (Claude + OpenAI Codex)
cp -r llm-agent-kit/.github/workflows/ /path/to/your-project/.github/workflows/
cp -r llm-agent-kit/.github/actions/ /path/to/your-project/.github/actions/
```

### Option 2: Use as a starting point

Fork this repo and customize the placeholder sections (marked with `<!-- -->` comments) for your specific project:

1. **Project overview** — your product, domain terms, and architecture
2. **Infrastructure table** — your services and their status
3. **Git workflow** — your branch naming and ticket system
4. **Linting config** — your linter (Biome, ESLint, etc.); the a11y hooks default to Biome — set `A11Y_LINT_CMD` or edit the hook scripts for ESLint
5. **Data protection** — replace the placeholder service/registry names in `data-protection.md` (or remove the file if you store no personal data)
6. **Package rules** — adjust the `paths` frontmatter in `rules/backend/api.md`, `rules/frontend/webapp.md`, and `rules/shopify-app/shopify-app.md` to your package directories; delete the ones that don't apply
7. **Hook scope** — set the frontend dir/extension patterns in `.claude/hooks/*-a11y-check.sh` for your repo layout
8. **Quality gates** — your per-package test and lint commands
9. **Package-specific review rules** — uncomment and fill in the review.md package rules section
10. **GitHub Actions secrets** — add `ANTHROPIC_API_KEY` and/or `OPENAI_API_KEY` to your repo secrets
11. **Workflow models** — update the `--model` and `model:` values in the workflow files to your preferred models
12. **Enable Claude PR review** — uncomment the `if` condition in `claude-review.yml` (disabled by default)

## What's Included

### Engineering Philosophy
- KISS, clarity over cleverness, SOLID principles
- Functional decomposition and single-purpose functions

### Code Standards (Hard Limits)
- 25-line method maximum for logic-bearing code; 50 lines for React component render functions and custom hooks
- 2 levels of nesting maximum
- 3 parameters per method maximum
- No `any` types, no magic numbers, early returns over nesting

### File Organization (Hard Limits)
- 15 source files per directory maximum (tests/stories excluded from count)
- Colocate tests and stories with source files
- Group subdirectories by domain/feature, not file type
- Imports flow downward only — no parent-from-child or sibling cross-imports

### Testing Standards
- Arrange/Act/Assert structure
- Hand-written fakes over mocking libraries
- Clear guidance on what to test vs. what to skip

### Security Rules
- No hardcoded secrets
- Input validation at system boundaries
- Monetary values in cents (integers, never floats)

### Data Protection (GDPR/CCPA)
- PII encrypted at rest with blind indexes for searchable fields
- Data subject rights (access/erasure) routed through a DSR processor with audit logging
- PII column registry + guard-test pattern so new PII columns can't ship unclassified
- Retention policies, cache TTLs, and log/error-monitoring scrubbing

### Accessibility Enforcement
- `accessibility.md` rule file — path-scoped, loads only on `.tsx`/`.jsx` edits (WCAG 2.1 AA floor / 2.2 AA for new UI)
- `loading-states.md` rule file — content-shaped skeletons, zero layout shift, skeleton-vs-spinner decision
- PostToolUse hook — a11y-lints every edited frontend file and injects violations back into context for same-turn fixes
- Stop hook — blocks the agent from declaring done while touched frontend files still carry a11y violations (fail-closed if the linter can't run)
- Both hooks ship with smoke tests and are pre-registered in `.claude/settings.json`

### PR Review Prompt
- Structured review across 6 categories: Code Quality, Security, Testing, Potential Bugs, PR Hygiene, File Organization
- Standardized output format: Verdict, Summary, Strengths, Category Review, Issues (by severity), Suggestions, Verification
- Grounded in the project's rule files — not invented standards

### Package Rule Templates (path-scoped)
- **Backend API** — validation schemas, transaction atomicity, concurrency/idempotency, soft-delete discipline, deny-by-default authorization with BOLA/BFLA guard-test patterns
- **Web app** — Storybook requirements, component promotion path (route → feature → app → design system), component resolution order (existing components > Tailwind Plus > custom, with the full 639-component Tailwind Plus inventory)
- **Shopify app** — Preact checkout extensions, Polaris `s-*` accessibility, 64 KB bundle limit

### GitHub Actions Workflows
- **Claude assistant** (`claude.yml`) — responds to `@claude` mentions on issues and PRs, supports assignment and label triggers
- **Claude PR review** (`claude-review.yml`) — automated PR review using Claude (disabled by default, enable via job `if` condition)
- **Codex assistant** (`openai-assistant.yml`) — responds to `@codex` mentions with read-only sandbox, split security model (read job + write job)
- **Codex PR review** (`openai-review.yml`) — automated PR review using Codex with diff context and review prompt
- **Claude stats action** (`claude-stats/action.yml`) — reusable composite action that parses Claude execution files and posts cost/token/duration stats as PR comments

### AI-Specific Instructions
- Read before editing, follow existing patterns
- Rules are authoritative over observed codebase patterns
- Reuse existing utilities and components
- Verify schemas before writing queries
- Flag security concerns proactively

## Extending

### Adding package-specific rules

The kit ships three path-scoped package rule templates (`backend/api.md`, `frontend/webapp.md`, `shopify-app/shopify-app.md`). To add more, create a rule file under `.claude/rules/` with a `paths` frontmatter scoping it to the package directory:

```markdown
---
paths:
  - "worker/**"
---

# Worker Package Rules
...
```

Then list it (as a plain path, not an `@`-import — path-scoped rules load automatically) in `CLAUDE.md`'s Package Rules section:

```markdown
**Package Rules** (path-scoped — load automatically when editing package files):
- `.claude/rules/worker/worker.md` — Queue worker rules
```

### Supporting additional LLMs

Add new top-level instruction files as needed. The `.claude/rules/` directory contains the shared standards — each LLM's instruction file should reference or inline the same rules for consistency.

## Syncing from Source Project

If you maintain a source project (e.g., your main app) and want to periodically sync its `.claude/` improvements back to this kit, copy and paste this prompt to Claude:

```
I need you to sync the llm-agent-kit repo with changes from my source project's .claude directory.

**Source project:** [path to your project]
**llm-agent-kit location:** [path to llm-agent-kit clone]

Steps:
1. Read all files in the source project's `.claude/` directory, `.github/prompts/` directory, `.github/workflows/` directory, and `.github/actions/` directory.
2. Read all files in the llm-agent-kit repo (`.claude/`, `.github/`, `AGENTS.md`, `README.md`).
3. For each file, compare the source project version with the llm-agent-kit version and identify:
   - New content that should be synced (new rules, bullets, sections)
   - Project-specific content that should be genericized or omitted
4. Update the llm-agent-kit files:
   - Replace project-specific names with generic placeholders (`[Project Name]`, etc.)
   - Replace specific package names with generic equivalents (backend, frontend, etc.)
   - Remove domain-specific terms (your product's unique concepts)
   - Keep all engineering principles, hard limits, and structural rules intact
   - Keep the same tone and format
5. `AGENTS.md` is a symlink to `.claude/CLAUDE.md` — no separate sync needed.
6. Compare `.github/workflows/` and `.github/actions/` — sync any workflow changes, genericizing project-specific references.
7. Update `README.md` if new files were added or the structure changed.
8. Commit with message: "Sync rules from source project" and push to main.
```
