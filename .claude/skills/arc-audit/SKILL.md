---
name: arc-audit
description: |
  Comprehensive web project audit across 9 domains with A-F grading. Use when
  "audit the project", "code review", "quality check", "review everything",
  "pre-release check", or "full project audit". Covers Architecture, Presentation,
  Domain, Data, Testing, Code Style, Documentation, Accessibility, and Performance.
user-invocable: true
metadata:
  author: ARC Labs Studio
  version: "1.0.0"
---

# ARC Labs Studio - Web Project Audit

## Instructions

Conduct a comprehensive audit across all 9 domains. Grade each domain A–F.

### Domain A: Architecture

Check:
- [ ] Dependency direction: Presentation → Domain ← Data (never reversed)
- [ ] No repository imports in `.tsx` files
- [ ] No business logic (async, fetch, localStorage) in component functions
- [ ] No React/browser imports in `domain/entities/`
- [ ] Path aliases used for cross-layer imports (not `../../..`)
- [ ] Component directory pattern: 4 files (`.tsx`, `.module.css`, `.test.tsx`, `index.ts`)
- [ ] Hooks in `presentation/hooks/` — not inside component files

**Grading**:
- A: All checks pass, clean layer separation throughout
- B: 1–2 minor violations (incorrect import paths)
- C: Repository imported in component, or business logic in JSX
- D: Multiple architecture violations across layers
- F: Layer structure not followed; monolithic components

### Domain B: Presentation

Check:
- [ ] Components contain JSX only — no `useEffect`, no `async`, no repository imports
- [ ] All hooks defined in `presentation/hooks/`
- [ ] CSS Modules used — no inline styles, no global class names, no Tailwind
- [ ] All values from design tokens — no hardcoded colors/spacing
- [ ] Mobile-first CSS — base for mobile, `@media (min-width: ...)` for larger
- [ ] Named exports only — no `export default`
- [ ] `focus-visible` on all interactive elements
- [ ] Touch targets ≥ 44×44px

### Domain C: Domain

Check:
- [ ] Entities are pure TypeScript — no framework imports (React, zod in entities is OK, fetch/DOM is not)
- [ ] Zod schemas generate types via `z.infer<>` — no manual duplicates
- [ ] `as const` + `typeof` for constants — no `enum`
- [ ] Type guards at every external boundary (localStorage, API responses)
- [ ] No `as` type assertions — type guards instead
- [ ] Explicit return types on all functions

### Domain D: Data

Check:
- [ ] Repositories abstract storage mechanism
- [ ] DTOs defined separately from domain entities — mapping function exists
- [ ] API errors handled — `Result<T>` returned, no unhandled throws
- [ ] No console.log/error in production paths (requires `import.meta.env.DEV` guard)
- [ ] Netlify Forms: static HTML form in `index.html`, `data-netlify="true"`, correct encoding

### Domain E: Testing

Check:
- [ ] Tests co-located with components (`Component.test.tsx`)
- [ ] Given/When/Then structure in test descriptions
- [ ] RTL queries use `getByRole` before `getByLabelText` before `getByText`
- [ ] No `getByTestId` without prior approval
- [ ] Mocks at system boundaries only (fetch, localStorage, Date)
- [ ] No arbitrary `setTimeout` in tests — use `waitFor`/`findBy*`
- [ ] New features have test coverage (happy path + one error path minimum)
- [ ] `vitest` + `testing-library` ESLint rules scoped to `src/**/*.test.*` only
- [ ] `playwright` ESLint rules scoped to `e2e/**/*.spec.*` only

### Domain F: Code Style

Check:
- [ ] No `any` types (ESLint error)
- [ ] Explicit return types on all functions
- [ ] Event handlers: `handle*` internal, `on*` in props
- [ ] `import type` for type-only imports
- [ ] `make lint` passes with zero warnings
- [ ] `make format` passes (Prettier)
- [ ] Naming conventions: PascalCase components, camelCase hooks, UPPER_SNAKE_CASE constants
- [ ] No commented-out code
- [ ] No TODOs without Linear ticket

### Domain G: Documentation

Check:
- [ ] Exported utility functions have JSDoc (`@param`, `@returns`) where non-obvious
- [ ] Non-obvious decisions have inline comments explaining **why**
- [ ] Complex algorithms documented
- [ ] Third-party integration files have top-of-file explanation comment
- [ ] No TODOs without Linear ticket reference

### Domain H: Accessibility

Check:
- [ ] All interactive elements keyboard navigable
- [ ] `focus-visible` (not `focus`) on all interactive elements
- [ ] Skip link to `#main-content` present
- [ ] Images have `alt` text (or `alt=""` if decorative)
- [ ] All form inputs have associated `<label>`
- [ ] Error messages use `role="alert"`
- [ ] `prefers-reduced-motion` respected for all animations
- [ ] Touch targets ≥ 44×44px
- [ ] No information conveyed by color alone
- [ ] Heading hierarchy (h1 → h2 → h3, no skips)
- [ ] Color contrast ≥ 4.5:1 for normal text

### Domain I: Performance

Check:
- [ ] Lighthouse Performance score ≥ 90 (run `make lighthouse`)
- [ ] All images have `width` and `height` attributes (prevents CLS)
- [ ] Images below fold use `loading="lazy"`
- [ ] No unnecessary `useMemo`/`useCallback` without referential stability need
- [ ] Large components not on initial load use `React.lazy()`
- [ ] Bundle size reviewed — no unnecessarily large dependencies
- [ ] No blocking operations in render path
- [ ] LCP < 2.5s, CLS < 0.1, INP < 200ms

---

## Audit Report Format

```markdown
# Web Audit — [Project Name] — [Date]

## Summary

| Domain | Grade | Critical Issues |
|--------|-------|-----------------|
| A. Architecture | [A–F] | [count] |
| B. Presentation | [A–F] | [count] |
| C. Domain | [A–F] | [count] |
| D. Data | [A–F] | [count] |
| E. Testing | [A–F] | [count] |
| F. Code Style | [A–F] | [count] |
| G. Documentation | [A–F] | [count] |
| H. Accessibility | [A–F] | [count] |
| I. Performance | [A–F] | [count] |

**Overall**: [A–F]

## Findings

### Domain A: Architecture — [Grade]

**Blockers** (must fix before merge):
- [finding]

**Major** (should fix before merge):
- [finding]

**Minor** (fix or explain):
- [finding]

**Notes** (no action required):
- [finding]

[repeat for each domain]

## Priority Fix List

1. [Most critical finding]
2. ...
```

## Severity Levels

| Severity | Description | Action |
|---------|-------------|--------|
| **Blocker** | Architecture violation, security issue, broken functionality | Must fix before merge |
| **Major** | Missing test, a11y failure, unhandled error path | Should fix before merge |
| **Minor** | Style inconsistency, naming deviation | Fix or explain before merge |
| **Note** | Suggestion, future consideration | No action required |
