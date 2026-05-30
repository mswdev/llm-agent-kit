---
paths:
  - "**/*.tsx"
  - "**/*.jsx"
---

# Accessibility (WCAG 2.1 AA)

<!-- This file loads only when editing .tsx/.jsx files — no context cost on backend work. -->
<!-- Covers patterns Claude consistently gets wrong. Basics (alt text, semantic HTML, -->
<!-- form labels) are not listed because Claude already handles them correctly. -->

All UI components MUST meet WCAG 2.1 Level AA. Automated tools (axe-core, Storybook a11y
addon) catch structural violations in CI. The patterns below are the ones tools cannot
catch — YOU MUST apply them manually.

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

YOU MUST implement ALL of the following. Missing any one item breaks the modal for
assistive technology users:

1. Container: `role="dialog"` + `aria-modal="true"` + `aria-labelledby="[title-id]"`
2. On open: move focus to the first interactive element inside the dialog
3. On open: apply `aria-hidden="true"` to all background content (`aria-modal` alone is not sufficient for NVDA/JAWS)
4. Tab key: trapped inside the dialog — cycles only within it
5. Esc key: closes the dialog
6. On close: focus returns to the element that triggered the dialog

```tsx
<div role="dialog" aria-modal="true" aria-labelledby="dialog-title">
  <h2 id="dialog-title">Confirm Action</h2>
  <button autoFocus>Confirm</button>
  <button onClick={onClose}>Cancel</button>
</div>
```

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

## Keyboard Verification Checklist

Before marking any interactive component done, YOU MUST verify keyboard-only operation:

- [ ] Tab reaches every interactive element
- [ ] Enter/Space activates buttons and controls
- [ ] Esc dismisses overlays, modals, and dropdowns
- [ ] Arrow keys navigate radio groups, menus, and list components
- [ ] Focus never disappears or becomes unexpectedly trapped
