# Clean Architecture — ARC Labs Studio Web

**Clean Architecture creates boundaries between business logic and external concerns, making code testable, maintainable, and independent of frameworks.**

---

## The Dependency Rule

Dependencies can only point **inward**. Source code dependencies must point only toward higher-level policies (the Domain layer).

```
┌─────────────────────────────────────────────┐
│           PRESENTATION LAYER                 │
│   React Components • Hooks • CSS Modules    │
│   (User Interface & Interaction)            │
├─────────────────────────────────────────────┤
│              DOMAIN LAYER                    │
│   Entities • Types • Validators • Schemas   │
│   (Business Logic & Rules)                  │
├─────────────────────────────────────────────┤
│               DATA LAYER                     │
│   Repositories • API Clients • DTOs         │
│   (Data Access & External Services)         │
└─────────────────────────────────────────────┘

▲ DEPENDENCY RULE: Dependencies flow INWARD only ▲
```

**Key Principle**: Inner layers NEVER depend on outer layers.
- Presentation depends on Domain ✓
- Domain NEVER depends on Presentation or Data ✓
- Data depends on Domain (implements contracts defined in Domain) ✓
- Data NEVER imports from Presentation ✓

---

## Layer Structure

```
src/
├── presentation/
│   ├── components/
│   │   └── [ComponentName]/
│   │       ├── ComponentName.tsx         # JSX only — no business logic
│   │       ├── ComponentName.module.css  # Scoped styles
│   │       ├── ComponentName.test.tsx    # Component + hook integration tests
│   │       └── index.ts                  # Barrel export
│   ├── hooks/
│   │   ├── useFeatureName.ts             # Hook = ViewModel (logic + state)
│   │   └── useFeatureName.test.ts        # Unit tests with renderHook
│   ├── layouts/
│   │   └── MainLayout/                   # Page-level wrappers
│   ├── pages/ (or sections/)
│   │   └── HeroSection/
│   └── styles/
│       ├── tokens.css                    # All design tokens
│       ├── reset.css
│       └── typography.css
│
├── domain/
│   └── entities/
│       ├── ContactFormData.ts            # Pure TypeScript types/interfaces
│       ├── Navigation.ts                 # Domain constants (SECTION_IDS etc.)
│       └── Theme.ts                      # Union types, type guards
│
└── data/
    └── repositories/
        ├── themeRepository.ts            # localStorage access
        └── contactRepository.ts          # API client wrappers
```

---

## Presentation Layer

The Presentation layer contains everything the user sees and interacts with.

**Components** own JSX only. They have no `useState` (except for purely local UI state like hover), no `useEffect`, no business logic.

**Hooks** are the ViewModel equivalent. They own all state, side effects, validation, and async operations. One hook per concern.

**CSS Modules** scope styles to the component. Never share CSS between components.

```tsx
// Correct: component is pure JSX
function ThemeToggle(): React.JSX.Element {
  const { theme, setTheme } = useTheme(); // delegate to hook
  return (
    <div role="group" aria-label="Theme selector">
      {THEMES.map(t => (
        <button
          key={t}
          className={clsx(styles.option, theme === t && styles.active)}
          onClick={() => setTheme(t)}
          aria-pressed={theme === t}
        >
          {t}
        </button>
      ))}
    </div>
  );
}
```

---

## Domain Layer

The Domain layer contains pure TypeScript — no React, no browser APIs, no external dependencies.

**Entities** are TypeScript interfaces and types that model the business domain.

**Type guards** validate external data at the boundary.

**Constants** use `as const` + `typeof` (never `enum`).

```ts
// domain/entities/Theme.ts
export type Theme = 'brand' | 'dark' | 'light';

export const THEMES = ['brand', 'dark', 'light'] as const;

export function isTheme(value: unknown): value is Theme {
  return value === 'brand' || value === 'dark' || value === 'light';
}
```

```ts
// domain/entities/ContactFormData.ts
import { z } from 'zod';

export const contactSchema = z.object({
  name: z.string().min(2, 'Name must be at least 2 characters'),
  email: z.string().email('Invalid email address'),
  message: z.string().min(10, 'Message must be at least 10 characters'),
});

export type ContactFormData = z.infer<typeof contactSchema>;
```

---

## Data Layer

The Data layer handles all external I/O: localStorage, API calls, cookies, IndexedDB.

**Repositories** abstract the storage mechanism. The Presentation layer never knows whether data comes from localStorage, an API, or memory.

```ts
// data/repositories/themeRepository.ts
import { isTheme, type Theme } from '@domain/entities/Theme';

const STORAGE_KEY = 'arc-theme';

export const themeRepository = {
  get(): Theme {
    try {
      const raw = localStorage.getItem(STORAGE_KEY);
      return isTheme(raw) ? raw : 'brand';
    } catch (error) {
      if (import.meta.env.DEV) {
        console.error('[themeRepository] failed to read theme:', error);
      }
      return 'brand';
    }
  },

  set(theme: Theme): void {
    try {
      localStorage.setItem(STORAGE_KEY, theme);
    } catch (error) {
      if (import.meta.env.DEV) {
        console.error('[themeRepository] failed to write theme:', error);
      }
    }
  },
} as const;
```

The hook in the Presentation layer calls the repository:

```ts
// presentation/hooks/useTheme.ts
import { useState, useEffect, useCallback } from 'react';
import { themeRepository } from '@data/repositories/themeRepository';
import type { Theme } from '@domain/entities/Theme';

interface UseThemeResult {
  theme: Theme;
  setTheme: (theme: Theme) => void;
}

export function useTheme(): UseThemeResult {
  const [theme, setThemeState] = useState<Theme>(() => themeRepository.get());

  const setTheme = useCallback((newTheme: Theme): void => {
    themeRepository.set(newTheme);
    setThemeState(newTheme);
    document.documentElement.setAttribute('data-theme', newTheme);
  }, []);

  return { theme, setTheme };
}
```

---

## Component Directory Pattern

Every component is a directory with exactly 4 files:

```
ComponentName/
├── ComponentName.tsx          # Implementation
├── ComponentName.module.css   # Scoped styles
├── ComponentName.test.tsx     # Tests
└── index.ts                   # Barrel export (re-exports the component)
```

**index.ts** is always:
```ts
export { ComponentName } from './ComponentName';
```

This pattern ensures:
- Imports are always `from '@presentation/components/ComponentName'`
- Tests are co-located (not in a separate `__tests__/` directory)
- Styles never leak between components

---

## Path Aliases

Always use path aliases, never relative `../../../` imports across layers.

```ts
// tsconfig.app.json + vite.config.ts
'@presentation/*' → 'src/presentation/*'
'@domain/*'       → 'src/domain/*'
'@data/*'         → 'src/data/*'
'@assets/*'       → 'src/assets/*'
```

```ts
// BAD — relative path across layers
import { Theme } from '../../../domain/entities/Theme';

// GOOD — alias respects layer boundary
import { Theme } from '@domain/entities/Theme';
```

---

## Common Violations

| Violation | Symptom | Fix |
|-----------|---------|-----|
| Business logic in component | `useState` + `useEffect` in a component that renders | Extract to a hook |
| Repository in component | `import { themeRepository }` in a `.tsx` file | Move to a hook |
| Domain importing from Presentation | `import React` in an entity file | Domain layer = pure TypeScript only |
| Inline styles | `style={{ color: '#541311' }}` in JSX | Use CSS Modules + tokens |
| Cross-layer relative imports | `import { Theme } from '../../../domain/...'` | Use path aliases |
| Logic in index.ts | Barrel re-exports with logic | index.ts re-exports only |
