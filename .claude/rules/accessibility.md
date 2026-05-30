---
paths:
  - "**/*.tsx"
  - "**/*.jsx"
---

# Accessibility (WCAG 2.1 AA floor / 2.2 AA for new UI)

<!-- This file loads only when editing .tsx/.jsx files — no context cost on backend work. -->
<!-- Covers patterns Claude consistently gets wrong. Basics (alt text, semantic HTML, -->
<!-- form labels) are not listed because Claude already handles them correctly. -->

All UI components MUST meet WCAG 2.1 Level AA — the binding legal floor (EN 301 549 / ADA).
Build NEW UI to WCAG 2.2 AA, a backward-compatible superset; the only in-scope additions
are target size, focus-not-obscured, and redundant entry (see WCAG 2.2 Additions below).
Automated tools (axe-core, Storybook a11y addon) catch structural violations in CI; the
patterns below are the ones tools cannot catch — YOU MUST apply them manually.

## Live Regions & Notifications

**YOU MUST NOT mount/unmount toast or notification components per event.** Screen readers
only announce content injected into a *pre-existing* live region — dynamically inserted
elements are silently missed.

```tsx
// Correct: container exists at page load, only the content changes
<div role="status" aria-live="polite" aria-atomic="true">
  {message}
</div>

// WRONG: mounting a fresh element per notification — screen readers miss this
{showToast && <Toast message={message} />}
```

- `role="status"` (polite) — save confirmations, result counts, non-urgent updates
- `role="alert"` (assertive) — errors and warnings ONLY. Overuse trains users to ignore them.

## Modals & Dialogs

**Prefer a vetted dialog primitive** (Headless UI, Radix, React Aria, or the native
`<dialog>` element) — they handle the full contract below. Do NOT hand-roll a modal
unless unavoidable. A dialog MUST satisfy all of:

1. Container: `role="dialog"` + `aria-modal="true"` + `aria-labelledby="[title-id]"`
2. On open: move focus to the first interactive element (or the dialog itself)
3. On open: make background content `inert` via the **`inert` attribute** — NOT
   `aria-hidden`, which throws a React 19 / Chromium "Blocked aria-hidden on a focused
   descendant" error and is itself a defect
4. Tab is trapped inside; Esc closes
5. On close: focus returns to the element that triggered the dialog

## Form Validation Errors

Errors MUST be programmatically associated with their field. A red border or icon alone
fails WCAG 1.4.1 and 3.3.1.

```tsx
<input
  id="email"
  aria-describedby={hasError ? "email-error" : undefined}
  aria-invalid={hasError ? "true" : undefined}
/>
{/* Keep this span in the DOM at all times — populate text on error, empty on resolve */}
<span id="email-error" role="alert">
  {hasError ? "Enter a valid email address (e.g., user@example.com)" : ""}
</span>
```

**YOU MUST NOT** conditionally mount/unmount the error span — keep it in the DOM and
change its text content. Same live region rule applies.

## Color-Coded Status Indicators

When a badge, dot, or icon uses color to convey state:

- **Has visible text label** (e.g., "Approved", "In Review") → color is supplementary. No extra work needed.
- **Color-only** (a dot, colored border, or icon without a text label) → YOU MUST provide:
  - `aria-label="Approved"` on the element, OR
  - `<span className="sr-only">Approved</span>` as a visually-hidden sibling

## Data Tables

`scope` on header cells is REQUIRED — without it, screen readers cannot associate data
cells with their column or row headers.

```tsx
<table aria-label="Overview">  {/* or aria-labelledby pointing to a visible heading */}
  <thead>
    <tr>
      <th scope="col">Name</th>
      <th scope="col">Status</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <th scope="row">Row label</th>
      <td>Value</td>
    </tr>
  </tbody>
</table>
```

Every table MUST have an accessible name via `aria-label`, `aria-labelledby`, or `<caption>`.

## Skip Navigation

Every page layout with repeated navigation MUST start with a skip link as the first
focusable element:

```tsx
<a
  href="#main-content"
  className="sr-only focus:not-sr-only focus:absolute focus:top-4 focus:left-4 focus:z-50"
>
  Skip to main content
</a>
<nav>...</nav>
<main id="main-content">...</main>
```

## Focus Visibility

**YOU MUST NEVER** write `outline: none` or `outline: 0` globally. If overriding the
browser default, YOU MUST provide a visible replacement with at least 3:1 contrast.

```css
/* WRONG */
* { outline: none; }

/* Correct — custom but visible */
:focus-visible { outline: 2px solid var(--color-primary); outline-offset: 2px; }
```

## Custom Interactive Elements

Prefer native elements — `<button>` not `<div onClick>`. If a native element is genuinely
not possible:

- Add the matching `role` (`button`, `checkbox`, `menuitem`, `tab`, etc.)
- Add `tabIndex={0}` so it is keyboard-reachable
- Handle `onKeyDown` for Enter and Space

## WCAG 2.2 Additions (new UI)

- **Focus Not Obscured (2.4.11):** sticky headers, toolbars, and toasts MUST NOT fully
  cover the element that has keyboard focus. Add `scroll-padding-top` to scroll containers.
- **Target Size (2.5.8):** interactive targets are at least **24×24 CSS px** (NOT 44 —
  that is the stricter AAA value). Dense controls may use the 24px center-to-center
  spacing exception instead of growing the hit area.
- **Route-change focus (2.4.3, SPA routers):** client-side navigation usually does NOT
  move focus. On route change, move focus to the page `<h1>`/`<main>`. If the router has a
  built-in assertive announcer (e.g. Next.js App Router), keep custom live regions polite.

## Keyboard Verification Checklist

Before marking any interactive component done, YOU MUST verify keyboard-only operation:

- [ ] Tab reaches every interactive element
- [ ] Enter/Space activates buttons and controls
- [ ] Esc dismisses overlays, modals, and dropdowns
- [ ] Arrow keys navigate radio groups, menus, and list components
- [ ] Focus never disappears or becomes unexpectedly trapped
