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
    ├── tailwind-plus-components.md    # 639-component Tailwind Plus inventory
    └── rules/
        ├── code-style.md              # Naming, complexity limits, documentation
        ├── testing.md                 # Test philosophy, structure, quality gates
        ├── security.md               # No-touch zones, security rules
        └── file-organization.md      # Directory caps, grouping, dependency direction
```

| File | Purpose | Used By |
|------|---------|---------|
| `AGENTS.md` | Symlink to `.claude/CLAUDE.md` — single source of truth for all agents | OpenAI Codex |
| `.claude/CLAUDE.md` | Project context with references to rule files | Claude Code, Codex (via symlink) |
| `.claude/rules/code-style.md` | Method size limits, naming conventions, TypeScript rules | Claude Code |
| `.claude/rules/testing.md` | Arrange/Act/Assert structure, what to test, quality gates | Claude Code |
| `.claude/rules/security.md` | No-touch zones, input validation, secret handling | Claude Code |
| `.claude/rules/file-organization.md` | Directory size caps, domain grouping, dependency direction | Claude Code |
| `.claude/tailwind-plus-components.md` | Full Tailwind Plus component inventory for Figma-to-code workflows | Both |
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
4. **Linting config** — your linter (Biome, ESLint, etc.)
5. **No-touch zones** — your critical files that need approval before editing
6. **Quality gates** — your per-package test and lint commands
7. **Package-specific review rules** — uncomment and fill in the review.md package rules section
8. **GitHub Actions secrets** — add `ANTHROPIC_API_KEY` and/or `OPENAI_API_KEY` to your repo secrets
9. **Workflow models** — update the `--model` and `model:` values in the workflow files to your preferred models
10. **Enable Claude PR review** — uncomment the `if` condition in `claude-review.yml` (disabled by default)

## What's Included

### Engineering Philosophy
- KISS, clarity over cleverness, SOLID principles
- Functional decomposition and single-purpose functions

### Code Standards (Hard Limits)
- 25-line method maximum
- 2 levels of nesting maximum
- 3 parameters per method maximum
- No `any` types, no magic numbers, early returns over nesting

### File Organization (Hard Limits)
- 10 source files per directory maximum (tests/stories excluded from count)
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
- No-touch zone patterns for critical files

### Accessibility Enforcement (WCAG 2.1 AA floor / 2.2 for new UI)
A layered system so accessibility is enforced, not just documented:
- **Rules** — `.claude/rules/accessibility.md`, path-scoped to `*.tsx/*.jsx`, covering
  the patterns tools can't catch (live regions, modal focus/`inert`, form-error
  association, route-change focus, target size).
- **PostToolUse hook** (`hooks/post-tool-a11y-check.sh`) — after each frontend edit,
  runs the project linter's a11y rules and injects any violations back into context
  for same-turn fixing. Configurable via `A11Y_LINT_CMD` / `FRONTEND_DIRS` / `FRONTEND_EXTS`.
- **Stop hook** (`hooks/stop-a11y-check.sh`) — blocks the agent from finishing a turn
  while changed frontend files still have a11y violations (loop-safe).
- **`.claude/settings.json`** wires both hooks so they are active on clone. The
  PostToolUse hook ships with a self-test (`hooks/post-tool-a11y-check.test.sh`).

The *deterministic team-wide* gates are project-specific (they need your stack), so
wire them per project — see the source project for working patterns:
- a lefthook pre-commit job running the linter's a11y rules (hard-blocks at commit),
- a CI component gate (e.g. Storybook + `@storybook/addon-a11y` with `a11y.test: "error"`),
- a story-existence check so no component dodges the component a11y gate,
- a page-level gate (e.g. `@axe-core/playwright` on rendered pages) for the
  composition rules a component gate can't see — one `<main>`, heading order,
  `html[lang]`, skip link, composed contrast — with a per-route baseline so it
  enforces no-regression without forcing existing fixes.

### PR Review Prompt
- Structured review across 6 categories: Code Quality, Security, Testing, Potential Bugs, PR Hygiene, File Organization
- Standardized output format: Verdict, Summary, Strengths, Category Review, Issues (by severity), Suggestions, Verification
- Grounded in the project's rule files — not invented standards

### Figma-to-Code Workflow
- Component resolution order: existing components > Tailwind Plus > custom
- Full inventory of 639 Tailwind Plus components (Application UI, Marketing, Ecommerce)

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

Create rule files under `.claude/rules/` for individual packages:

```
.claude/rules/
├── code-style.md
├── testing.md
├── security.md
├── file-organization.md
├── backend/
│   └── api.md          # API-specific rules
└── frontend/
    └── webapp.md       # Frontend-specific rules
```

Then reference them from `CLAUDE.md`:

```markdown
**Package Rules:**
- @.claude/rules/backend/api.md — API layer rules
- @.claude/rules/frontend/webapp.md — Frontend rules
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
