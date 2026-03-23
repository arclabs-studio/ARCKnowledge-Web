---
name: arc-final-review
description: |
  Pre-merge comprehensive review for ARC Labs Studio web projects. Use before
  opening or merging a PR: "review this PR", "pre-merge review", "check before
  merge", "is this ready to merge", "final review", or "check PR readiness".
user-invocable: true
metadata:
  author: ARC Labs Studio
  version: "1.0.0"
---

# ARC Labs Studio - Final Review (Pre-Merge)

## Instructions

Run through this checklist for every PR before merging. This is a focused review of the changes in the PR — not a full project audit.

### Step 1: Run Automated Checks

```bash
make check   # lint + format + test — must all pass
make build   # TypeScript type check + production build
```

If any fail, stop and fix before continuing the review.

### Step 2: Architecture Review

For each changed file, verify:

**Changed `.tsx` files:**
- [ ] Component contains JSX only (no `useEffect`, no `async`, no repository imports)
- [ ] Props typed with explicit interface
- [ ] Named export (no `export default`)
- [ ] Imports use path aliases (no `../../../`)

**Changed hook files (`.ts` in `hooks/`):**
- [ ] Single concern — one hook does one thing
- [ ] Return type interface defined explicitly
- [ ] No direct DOM access (except `document.documentElement` for theme)
- [ ] Repository imports go through the hook (never through the component)

**Changed domain entities (`.ts` in `domain/entities/`):**
- [ ] No React imports
- [ ] No browser API imports (`fetch`, `localStorage`, `document`)
- [ ] Zod schema used if external data validation needed
- [ ] `as const` + `typeof` instead of `enum`
- [ ] Explicit return types

**Changed repository files (`.ts` in `data/repositories/`):**
- [ ] Returns `Result<T>` for operations that can fail
- [ ] No console.log in production path (DEV guard required)
- [ ] Mapping function exists if using DTOs
- [ ] Error messages are user-facing, not technical

### Step 3: CSS Module Review

For each changed `.module.css` file:

- [ ] All values reference design tokens (`var(--token)`)
- [ ] No hardcoded colors, sizes, spacing, or fonts
- [ ] Mobile-first (base = mobile, `@media (min-width: ...)` for larger)
- [ ] No `!important` (exception: `prefers-reduced-motion` reset)
- [ ] No inline styles added to JSX in the same PR
- [ ] `focus-visible` (not `focus`) for interactive elements
- [ ] `prefers-reduced-motion` handled for any new animations

### Step 4: Test Review

For each changed component or hook:

- [ ] Tests co-located (`.test.tsx` in same directory)
- [ ] Given/When/Then structure
- [ ] Happy path covered
- [ ] At least one error path covered (for components with error states)
- [ ] No `getByTestId` without sign-off
- [ ] No arbitrary `setTimeout` — uses `waitFor`/`findBy*`
- [ ] Mocks only at boundaries (fetch, localStorage)

### Step 5: Accessibility Spot-Check

For any new interactive elements:

1. **Tab through manually** — focus order is logical, all elements reachable
2. **Check focus ring** — `focus-visible` ring is visible on focused elements
3. **Check labels** — all form inputs have associated `<label>`
4. **Check buttons** — descriptive text or `aria-label`
5. **Check animations** — `prefers-reduced-motion` respected

### Step 6: PR Description

- [ ] PR title follows Conventional Commits format
- [ ] PR description explains what changed and why
- [ ] Linear ticket referenced (if applicable): `Closes ARCW-XX`
- [ ] Screenshots included if visual changes

### Step 7: Final Verification

```bash
# Run full check one more time after all fixes
make check

# Verify build succeeds
make build

# If adding/changing CSS, check tokens are defined
grep -r "var(--" src/presentation/ | grep -v tokens.css
```

---

## Common Issues Found in Reviews

**Blocker: Repository imported in component**
```ts
// Found in ContactSection.tsx — move to hook
import { contactRepository } from '@data/repositories/contactRepository';
```

**Blocker: No explicit return type**
```ts
// Missing `: UseContactFormResult` on hook definition
function useContactForm() { ... }
```

**Major: `getByTestId` used in tests**
```ts
screen.getByTestId('submit-button') // Replace with getByRole('button', { name: /send/i })
```

**Major: Hardcoded color in CSS Module**
```css
color: #541311; /* Replace with var(--color-brand-primary) */
```

**Minor: Missing `focus-visible` on new button**
```css
/* Add to new button styles */
.newButton:focus-visible {
  outline: 2px solid var(--color-focus-ring);
  outline-offset: 2px;
}
```

**Minor: TODO without Linear ticket**
```ts
// TODO: improve error message ← needs ARCW-XX ticket
```
