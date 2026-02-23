# llm-agent-kit

Portable configuration files, agent instructions, and coding standards for LLM-powered coding assistants. Works across Claude Code, OpenAI Codex, and other AI agents. Drop into any repo for a consistent AI-assisted dev experience.

## What's Inside

```
llm-agent-kit/
├── AGENTS.md                          # OpenAI Codex instructions
└── .claude/
    ├── CLAUDE.md                      # Claude Code instructions
    ├── tailwind-plus-components.md    # 639-component Tailwind Plus inventory
    └── rules/
        ├── code-style.md              # Naming, complexity limits, documentation
        ├── testing.md                 # Test philosophy, structure, quality gates
        └── security.md               # No-touch zones, security rules
```

| File | Purpose | Used By |
|------|---------|---------|
| `AGENTS.md` | Self-contained project context and coding standards | OpenAI Codex |
| `.claude/CLAUDE.md` | Project context with references to rule files | Claude Code |
| `.claude/rules/code-style.md` | Method size limits, naming conventions, TypeScript rules | Claude Code |
| `.claude/rules/testing.md` | Arrange/Act/Assert structure, what to test, quality gates | Claude Code |
| `.claude/rules/security.md` | No-touch zones, input validation, secret handling | Claude Code |
| `.claude/tailwind-plus-components.md` | Full Tailwind Plus component inventory for Figma-to-code workflows | Both |

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
```

### Option 2: Use as a starting point

Fork this repo and customize the placeholder sections (marked with `<!-- -->` comments) for your specific project:

1. **Project overview** — your product, domain terms, and architecture
2. **Infrastructure table** — your services and their status
3. **Git workflow** — your branch naming and ticket system
4. **Linting config** — your linter (Biome, ESLint, etc.)
5. **No-touch zones** — your critical files that need approval before editing
6. **Quality gates** — your per-package test and lint commands

## What's Included

### Engineering Philosophy
- KISS, clarity over cleverness, SOLID principles
- Functional decomposition and single-purpose functions

### Code Standards (Hard Limits)
- 25-line method maximum
- 2 levels of nesting maximum
- 3 parameters per method maximum
- No `any` types, no magic numbers, early returns over nesting

### Testing Standards
- Arrange/Act/Assert structure
- Hand-written fakes over mocking libraries
- Clear guidance on what to test vs. what to skip

### Security Rules
- No hardcoded secrets
- Input validation at system boundaries
- Monetary values in cents (integers, never floats)
- No-touch zone patterns for critical files

### Figma-to-Code Workflow
- Component resolution order: existing components > Tailwind Plus > custom
- Full inventory of 639 Tailwind Plus components (Application UI, Marketing, Ecommerce)

### AI-Specific Instructions
- Read before editing, follow existing patterns
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

## License

MIT
