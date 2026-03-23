# Code Review — ARC Labs Studio

Checklist for reviewing pull requests. Every PR is reviewed against these criteria.

---

## Architecture (A)

- [ ] Dependencies flow inward: Presentation → Domain ← Data
- [ ] No repository imports directly in `.tsx` files
- [ ] No business logic (async operations, validation) inside component functions
- [ ] No React imports in Domain layer entities
- [ ] Path aliases used for cross-layer imports (not `../../../`)
- [ ] Component directory pattern respected (4 files: `.tsx`, `.module.css`, `.test.tsx`, `index.ts`)

## Presentation (B)

- [ ] Components contain JSX only — no `useEffect`, no `async` functions
- [ ] Hooks defined in `presentation/hooks/` for all state/logic
- [ ] CSS Modules used — no inline styles, no Tailwind, no global class names
- [ ] All values from design tokens (`var(--token-name)`) — no hardcoded colors/spacing
- [ ] Mobile-first CSS — base styles for mobile, `@media (min-width: ...)` for larger
- [ ] Named exports only — no `export default`

## Domain (C)

- [ ] Entities are pure TypeScript — no framework imports
- [ ] Zod schemas generate types via `z.infer<typeof schema>` — no manual duplicates
- [ ] `as const` + `typeof` for constants — no `enum`
- [ ] Type guards at every external boundary (localStorage, API responses)
- [ ] No `as` type assertions — use type guards instead
- [ ] Explicit return types on all functions

## Data (D)

- [ ] Repositories abstract storage mechanism (localStorage, API, static)
- [ ] DTOs defined separately from domain entities — mapping function exists
- [ ] API errors handled and converted to `Result<T>` — no unhandled throws
- [ ] No console.log/error in production paths (use `import.meta.env.DEV` guard)

## Testing (E)

- [ ] Tests co-located with components (`Component.test.tsx`)
- [ ] Given/When/Then structure in test descriptions
- [ ] RTL queries use `getByRole` before `getByLabelText` before `getByText`
- [ ] No `getByTestId` without prior approval
- [ ] Mocks at system boundaries only (fetch, localStorage, Date)
- [ ] No `setTimeout` in tests — use `waitFor` / `findBy*`
- [ ] New features have test coverage (happy path + at least one error path)

## Code Style (F)

- [ ] No `any` types
- [ ] Explicit return types on all functions
- [ ] Event handlers named `handle*` internally, `on*` in props
- [ ] `import type` for type-only imports
- [ ] ESLint passes with zero warnings
- [ ] Prettier formatting applied

## Accessibility (G)

- [ ] All interactive elements keyboard navigable
- [ ] `focus-visible` on all interactive elements
- [ ] Images have `alt` text (or `alt=""` if decorative)
- [ ] Form inputs have associated `<label>` elements
- [ ] Error messages use `role="alert"`
- [ ] Touch targets ≥ 44×44px
- [ ] Animations respect `prefers-reduced-motion`
- [ ] No information conveyed by color alone

## Performance (H)

- [ ] No `useCallback`/`useMemo` without referential stability justification
- [ ] Dynamic imports (`React.lazy`) for large components not needed on initial load
- [ ] Images have `width` and `height` attributes (prevents layout shift)
- [ ] No blocking operations in the render path
- [ ] Bundle size impact considered for large dependencies

---

## Severity Levels

| Severity | Description | Action |
|---------|-------------|--------|
| **Blocker** | Architecture violation, security issue, broken functionality | Must fix before merge |
| **Major** | Missing test, accessibility failure, no error handling | Should fix before merge |
| **Minor** | Style inconsistency, naming deviation, minor improvement | Fix or explain before merge |
| **Note** | Suggestion, alternative approach, future consideration | No action required |

---

## Self-Review Checklist (before requesting review)

Run before pushing:
```bash
make check   # lint + format + test
```

Then manually verify:
1. Tab through any new interactive elements — focus order makes sense
2. Inspect CSS Module — are all values from tokens?
3. Read the hook in isolation — does it have one clear concern?
4. Read the component in isolation — is it JSX only?
