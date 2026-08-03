---
paths:
  - "shopify-app/**"
---

<!-- Adjust the `paths` above to your Shopify app package directory. -->
<!-- Delete this file (and its CLAUDE.md reference) if the project has no Shopify app. -->

# Shopify App Package Rules

## Architecture
- **Preact** for checkout UI extensions (not React — Shopify checkout extensions use Preact)
- Develop against a dedicated Shopify Partner sandbox store

## Linting

<!-- Configure per project (Biome / ESLint). -->

> Note: standard linters cannot see Polaris `s-*` web components, so they do NOT catch
> missing `accessibilityLabel` on `s-switch`/`s-button`/etc. Add a dedicated check script
> (run in CI and pre-commit) to enforce that — the linter alone is not enough.

## Error Monitoring
- **Remix/admin server:** the server-side monitoring SDK (e.g., `@sentry/remix`) captures loader/action errors automatically
- **Checkout extension:** use a lightweight browser client (e.g., `@micro-sentry/browser`) for error capture in the Shopify sandbox
  - `network_access = true` is required in the extension TOML for events to send
  - Keep the extension bundle under Shopify's 64 KB limit — pick monitoring clients measured in single-digit KB

## Accessibility
Follow @.claude/rules/accessibility.md for cross-cutting WCAG patterns. Extension-specific:

- **Use Polaris `s-*` web components** (`s-switch`, `s-button`, `s-banner`, `s-clickable`,
  `s-text-field`, etc.) for all interactive UI. Shopify renders them out-of-process, so
  keyboard, focus, ARIA, and contrast cost **zero** of the 64 KB bundle. Do NOT hand-roll
  toggles/buttons or add a11y JS libraries.
- **Every interactive `s-*` element needs an accessible name.** Standalone `s-switch`/
  `s-checkbox` and icon-only `s-clickable`/`s-button` (wrapping `s-icon`) MUST set
  `accessibilityLabel` — a nearby `s-text` is NOT programmatically associated with the
  control. Shopify logs a console warning at render when a required a11y prop is missing.
- **Contrast MUST pass WCAG 2.1 AA** — Built-for-Shopify lists failing contrast as an
  explicit rejection reason.
- **Component-level a11y ≠ flow-level a11y.** A manual keyboard + VoiceOver/NVDA pass on
  the real sandbox-store checkout is required per release — automated axe cannot fully
  see the out-of-process render.

## Testing
- **Quality gate:**
  ```bash
  npm run test
  ```
