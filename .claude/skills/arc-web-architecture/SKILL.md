---
name: arc-web-architecture
description: |
  Web architecture patterns for ARC Labs Studio projects: Clean Architecture
  (Presentation, Domain, Data layers), React hook patterns, SOLID principles
  for functional React, TypeScript patterns, and error handling. Use when
  "designing a feature", "setting up layers", "creating hooks", "reviewing
  architecture", "resolving dependency issues between layers", "adding a new
  entity", "structuring a repository", or any question about layer boundaries.
user-invocable: true
metadata:
  author: ARC Labs Studio
  version: "1.0.0"
---

# ARC Labs Studio - Web Architecture Patterns

## Instructions

### Clean Architecture — Three Layers

```
┌─────────────────────────────────────────────┐
│           PRESENTATION LAYER                 │
│   React Components • Hooks • Layouts        │
│   (User Interface & State)                  │
├─────────────────────────────────────────────┤
│              DOMAIN LAYER                    │
│   Entities • Types • Zod Schemas            │
│   (Pure TypeScript — no framework)          │
├─────────────────────────────────────────────┤
│               DATA LAYER                     │
│   Repositories • API Clients • DTOs         │
│   (Storage & External Services)             │
└─────────────────────────────────────────────┘

▲ DEPENDENCY RULE: Dependencies flow INWARD only ▲
```

**Dependency direction**: Presentation → Domain ← Data
- Presentation imports from Domain and Presentation
- Domain imports nothing outside itself (pure TypeScript)
- Data imports from Domain (implements repository shapes)
- **NEVER** import a repository directly in a `.tsx` file

### Layer Directory Structure

```
src/
├── presentation/
│   ├── components/      # Shared UI building blocks (Button, Header, Footer)
│   ├── hooks/           # ViewModels and utilities (useTheme, useActiveSection)
│   ├── layouts/         # Page-level wrappers (MainLayout)
│   ├── sections/        # Page sections (HeroSection, ContactSection)
│   └── styles/          # Global CSS (tokens.css, reset.css, typography.css)
├── domain/
│   └── entities/        # Pure TypeScript types, constants, Zod schemas
└── data/
    └── repositories/    # localStorage, API, static data access
```

### Component Directory Pattern (4 files — mandatory)

```
ComponentName/
├── ComponentName.tsx          # JSX only — no useEffect, no async, no repositories
├── ComponentName.module.css   # CSS Modules — tokens only, mobile-first
├── ComponentName.test.tsx     # Co-located tests — Given/When/Then
└── index.ts                   # Barrel: export { ComponentName } from './ComponentName';
```

### Path Aliases

Always use aliases for cross-layer imports. Never use `../../..`:

```ts
import type { Theme } from '@domain/entities/Theme';       // ✓
import { themeRepository } from '@data/repositories/themeRepository';  // ✓ (in hooks only)
import styles from './Button.module.css';                   // ✓ (relative = same layer)
import { useTheme } from '../../../hooks/useTheme';        // ✗ (use alias)
```

---

## SOLID Principles for React/TypeScript

### S — Single Responsibility
One component renders one thing. One hook manages one concern.
Red flag: "And" in a name (`HeaderAndNav`, `fetchAndTransform`).

### O — Open/Closed
Extend via children/composition, not `variant` proliferation.
Adding `if (variant === 'new')` to an existing component is a violation.

### L — Liskov Substitution
Components sharing a props interface must be interchangeable.
Specialisations only add — never remove props from the base contract.

### I — Interface Segregation
Split large prop interfaces. Pass only what the component needs.
No god-props (passing the entire entity when 2 fields are used).

### D — Dependency Inversion
Components depend on hook abstractions, not concrete repositories.
Repositories live in hooks — never imported directly in `.tsx` files.

---

## TypeScript Patterns

### Discriminated Unions Over Boolean Flags

```ts
// BAD — 16 possible states, most invalid
interface FetchState { isLoading: boolean; isError: boolean; data?: T }

// GOOD — exactly 4 valid states
type FetchState<T> =
  | { status: 'idle' }
  | { status: 'loading' }
  | { status: 'error'; message: string }
  | { status: 'success'; data: T };
```

### `as const` + `typeof` (No `enum`)

```ts
const SECTION_IDS = { Hero: 'hero', Contact: 'contact' } as const;
type SectionId = typeof SECTION_IDS[keyof typeof SECTION_IDS]; // 'hero' | 'contact'
```

### No `as` Type Assertions — Use Type Guards

```ts
// BAD
const theme = localStorage.getItem('theme') as Theme;

// GOOD
function isTheme(value: unknown): value is Theme {
  return value === 'brand' || value === 'dark' || value === 'light';
}
const raw = localStorage.getItem('theme');
const theme: Theme = isTheme(raw) ? raw : 'brand';
```

### Explicit Return Types on All Functions (ESLint-enforced)

```ts
// BAD — implicit return type
const getTheme = () => themeRepository.get();

// GOOD
const getTheme = (): Theme => themeRepository.get();
```

### Zod Schemas at System Boundaries

```ts
import { z } from 'zod';

const contactSchema = z.object({
  name: z.string().min(1, 'Name is required'),
  email: z.string().email('Invalid email'),
  message: z.string().min(10, 'Message too short'),
});

export type ContactFormData = z.infer<typeof contactSchema>;
export { contactSchema };
```

---

## React Hook Patterns

### Hooks Are the Unit of Reuse

Extract ALL logic to hooks. A hook can be reused across components; logic buried in JSX cannot.

```tsx
// BAD — logic and JSX mixed
function ContactSection(): React.JSX.Element {
  const [status, setStatus] = useState('idle');
  const onSubmit = async (data) => { ... };
  return <form onSubmit={onSubmit}>...</form>;
}

// GOOD — hook owns logic, component owns JSX
function ContactSection(): React.JSX.Element {
  const { status, handleSubmit } = useContactForm();
  return <form onSubmit={handleSubmit}>...</form>;
}
```

### State Colocation

Keep state as close to where it's used as possible. Lift only when siblings share it.

### Context = Global Concerns Only

Use for: theme, auth, locale.
Do NOT use for: form state, modal visibility, component-local async state.

### `useMemo`/`useCallback` Only for Referential Stability

```tsx
// BAD — wrapping everything "just in case"
const handleClick = useCallback(() => setCount(c => c + 1), []);

// GOOD — only when crossing a memo boundary or in a dep array
const sortedItems = useMemo(() => [...items].sort(compareFn), [items, compareFn]);
```

---

## Error Handling

### Two Error Boundaries

```tsx
<RootErrorBoundary>          {/* catches catastrophic failures */}
  <MainLayout>
    <SectionErrorBoundary name="Contact">
      <ContactSection />    {/* isolated — one broken section can't kill the page */}
    </SectionErrorBoundary>
  </MainLayout>
</RootErrorBoundary>
```

### Result Pattern for Predictable Failures

```ts
type Result<T> =
  | { ok: true; data: T }
  | { ok: false; error: string };

async function submitContactForm(data: ContactFormData): Promise<Result<void>> {
  try {
    await fetch('/api/contact', { ... });
    return { ok: true, data: undefined };
  } catch {
    return { ok: false, error: 'Failed to send. Please try again.' };
  }
}
```

### Never Log in Production

```ts
if (import.meta.env.DEV) {
  console.error('[ComponentName]', error);
}
```

---

## Common Violations

| Violation | Fix |
|-----------|-----|
| `import { repo } from '@data/...'` in `.tsx` | Move to a hook in `hooks/` |
| `useEffect` fetching data in component | Use hook + TanStack Query |
| Business logic in JSX | Extract to hook |
| `as Theme` assertion | Write a type guard `isTheme()` |
| `enum SectionId` | `as const` + `typeof` |
| No explicit return type | Add `: ReturnType` |
| `../../../` relative paths across layers | Use `@domain/`, `@data/`, `@presentation/` aliases |

## Further Reading

- `Architecture/clean-architecture.md` — full layer documentation
- `Architecture/react-patterns.md` — composition, context, derived state
- `Architecture/solid-principles.md` — SOLID with full BAD/GOOD examples
- `Architecture/typescript-patterns.md` — generics, utility types, exhaustive checks
- `Architecture/error-handling.md` — error boundaries, Result type, form errors
- `Layers/presentation.md` — component structure, hooks-as-VM
- `Layers/domain.md` — entity patterns, Zod
- `Layers/data.md` — repository pattern, DTOs
