---
paths:
  - "**/*.tsx"
  - "**/*.jsx"
---

# Loading States

<!-- Loads only when editing frontend files. Narrow the paths above (e.g. "webapp/**/*.tsx")
     for monorepos where only one package has a frontend. Replace the import paths below
     with your project's skeleton/spinner primitives. -->

Two primitives, one decision:

- **Skeleton** — content loading into a **known shape** (lists, cards, text,
  avatars). Mirror the shape so the page doesn't shift. This is the default.
- **Spinner** — an indeterminate **action** with no previewable shape (button
  submit, inline save, full-page boot).

**The test:** if you can draw the shape of what's arriving, use a **skeleton**;
if it's an action, not content, use a **spinner**.

## The rule

- **Skeleton ONLY genuinely async, data-dependent regions — never static chrome.**
  Text, headings, icons/SVGs, static controls (search / filter / buttons), nav, and
  unchanging titles render **immediately as real content**, not skeletons.
- A skeleton on static or instant (<~1s) content reads as broken and adds flicker,
  not feedback. On a list/dashboard load: the header, toolbar controls, and stat-card
  labels/icons render at once; **only** the data rows/cells and live counts/pager skeleton.
- **Never ship an async component without a loading state.** When the shape is known,
  that state is a content-shaped skeleton (see below).

## Use the project's skeleton primitives

Use the existing skeleton components (e.g., `Skeleton`, `SkeletonText`, `SkeletonAvatar`
from your component library):

- `Skeleton` — any box; shape it with `className` (e.g. `h-32 w-64`, `size-10 rounded-full`).
- `SkeletonText` — `lines={n}` text block (last line auto-shortened).
- `SkeletonAvatar` — circle; pass the same size utility as the real `Avatar`.

The primitives should already animate (shimmer or pulse, `motion-safe:`-gated).
**Don't** hand-roll grey bars, add a second animation, or create a new shape
*component* per content type — **compose** the base + atoms instead.

## Map it to the content (ZERO layout shift)

The skeleton MUST occupy the **exact box** the loaded content will. A size mismatch
is a CLS regression (hurts UX and SEO), not a cosmetic nit.

- **Match the loaded height precisely.** Account for EVERY line-box contributor of
  the real element, not just the text — inline copy buttons, icons, avatars, and
  badges set a row's height. A bare `h-4` bar under a cell whose real line is 24px
  (icon/button-driven) shifts on load. Wrap shimmer bars in fixed-height line boxes
  (e.g. `flex h-6 items-center`) equal to the real line heights.
- Reuse the **same** container / grid / gap / padding; match **row count** for
  lists/tables (a sensible first-screenful when the count is unknowable pre-fetch)
  and **line count** for text blocks.
- **Co-locate** the skeleton with the component it stands in for — same file, shared
  dimensions — so they can't drift (e.g. `OrderRow` + `OrderRowSkeleton`).
- **Verify in the browser:** toggle the loading state and confirm the page does NOT
  jump when real content arrives.

## Where to insert it

- **Route-level:** the router's route loading state (e.g., Next.js `loading.tsx` —
  the segment's Suspense fallback).
- **Section-level:** `<Suspense fallback={<XSkeleton />}>`.
- **Client/data:** the `isPending` / `isLoading` branch.

## Use the spinner

Use the existing `Spinner` primitive; size/recolor via `className` (drawn in
`currentColor`).

- **Decorative by default** (`aria-hidden`) — use it beside text that already
  states the action (a button's "Saving…", an `aria-busy` region).
- Pass **`label`** for a standalone spinner (full-page / inline) — it wraps the
  spinner in a `role="status"` region with an sr-only announcement.
- **Don't** reach for a spinner where a skeleton fits (content with a known
  shape), and don't hand-roll `animate-spin` — use the primitive.

## Accessibility

The leaf `Skeleton`/`Spinner` is decorative (`aria-hidden`). The loading **region**
owns the status semantics: wrap composed skeletons in a `role="status"` element
with an sr-only "Loading…" label (the `Spinner`'s `label` prop does this for
you). See @.claude/rules/accessibility.md.
