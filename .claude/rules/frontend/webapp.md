---
paths:
  - "webapp/**"
---

<!-- Adjust the `paths` above to your frontend package directory (e.g. "apps/web/**"). -->
<!-- Assumes a React app with a component library under src/components/ui/ and Storybook; -->
<!-- trim the Storybook/Tailwind Plus sections if your project doesn't use them. -->

# Web App Package Rules

## Performance
SPEED and PERFORMANCE is CRITICAL.
- Minimize imports and bundle size
- Keep the component tree shallow
- No unnecessary re-renders
- Prefer server components where possible

## Component Standards
- **File naming**: PascalCase for components (`OrderCard.tsx`), camelCase for utils (`formatCurrency.ts`)
- ALWAYS reuse existing UI components before creating new ones
- Test behavior (user interactions, conditional rendering), not implementation details
- Test complex hooks with `renderHook` when they contain meaningful logic

## Logging
- Server-side only — **NEVER import a Node.js logger in client components**

## Linting

<!-- Configure per project. Examples: -->
<!-- Biome: check `biome.json` for config -->
<!-- ESLint + Prettier: run `npm run lint` -->

## Error Monitoring
- Errors in server components, client components, and API routes should be captured automatically by the error monitoring SDK (e.g., `@sentry/nextjs`)
- Error boundary components (`error.tsx` / `global-error.tsx`) must report to the monitoring service — do not remove the capture calls
- For manual capture in try/catch blocks, use the monitoring SDK's `captureException`

## Storybook
- **Every design-system component in `src/components/ui/` MUST have a `.stories.tsx` file.** NO EXCEPTIONS. If you create or modify a component at this level, update its story.
- **Route-colocated and feature-shared components do NOT require stories** — they live in `_components/` or `_shared/` directories and are promoted to `src/components/ui/` only when reuse becomes real. Stories are required at the design-system level only (step 4 of the promotion path).
- Stories must include: default state, all meaningful variants, disabled/interactive states, and at least one real-world usage example using the project's domain context
- Show the primary color first in color variant stories. Use semantic names (`error`, `success`, `warning`, `info`) for domain examples like status badges.
- **Interaction tests:** Add play functions for components with user interactions.
- **Accessibility:** Run the a11y addon (axe-core) on all stories and fix reported violations.
- **Visual regression:** If configured (e.g., Chromatic), review visual changes on every PR.

## Component Promotion Path

Components move **outward** as their reuse scope grows:

1. **Route-colocated** — used by one route only. Lives in the route's `_components/` directory.
2. **Feature-shared** — used by multiple routes within one feature. Lives in the feature's `_shared/` directory.
3. **App-shared** — used across features. Lives in `src/components/`.
4. **Design system** — a branded, reusable primitive. Lives in `src/components/ui/` with a `.stories.tsx` file.

**Avoid skipping levels.** A component used by one route does not belong in `components/ui/`. Promote only when reuse is real, not hypothetical. **Exception:** obvious design-system primitives (e.g., a new form input, badge variant, or tooltip) may go directly to `src/components/ui/`.

## Component Resolution Order

When a new component is needed, resolve it in this order:

1. **Check existing components** in `src/components/ui/` — use them if they exist (see Storybook stories for variants)
2. **Check the Tailwind Plus component list** in @.claude/tailwind-plus-components.md — if the needed component exists there, **ask the user to provide the code** from the Tailwind Plus website (paid license)
3. **If the component does not exist** in either the codebase or the Tailwind Plus list, **ask the user** before creating a custom component

NEVER create a new component from scratch if one already exists in the codebase or is available from Tailwind Plus.

## Adding New Components

When a new UI component is added to the codebase:
1. Create the component in `src/components/ui/`
2. Add a `.stories.tsx` file with branded examples
