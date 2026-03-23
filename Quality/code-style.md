# Code Style — ARC Labs Studio

Naming conventions, file structure, and formatting rules.

---

## TypeScript Conventions

| Item | Convention | Example |
|------|-----------|---------|
| Components | PascalCase | `ThemeToggle`, `AppCard` |
| Hooks | camelCase + `use` prefix | `useTheme`, `useActiveSection` |
| Constants | UPPER_SNAKE_CASE | `SECTION_IDS`, `THEMES`, `NAV_LINKS` |
| Types / Interfaces | PascalCase | `Theme`, `NavLink`, `ButtonProps` |
| Functions | camelCase | `getTheme`, `isTheme`, `mapToApp` |
| CSS Module classes | camelCase | `.primaryButton`, `.isActive`, `.hasError` |
| Files (components) | PascalCase | `Button.tsx`, `ThemeToggle.tsx` |
| Files (hooks/utils) | camelCase | `useTheme.ts`, `themeRepository.ts` |
| Files (CSS Modules) | PascalCase | `Button.module.css` |

---

## File Structure

### Component files

```tsx
// 1. External imports
import { useState, useCallback } from 'react';

// 2. Internal imports (domain/data layers)
import type { Theme } from '@domain/entities/Theme';
import { THEMES } from '@domain/entities/Theme';

// 3. Relative imports (CSS Module)
import styles from './ThemeToggle.module.css';

// 4. Type definitions
interface ThemeToggleProps {
  defaultTheme?: Theme;
}

// 5. Component definition
function ThemeToggle({ defaultTheme = 'brand' }: ThemeToggleProps): React.JSX.Element {
  // hook calls first
  const { theme, setTheme } = useTheme();

  // derived values
  const isActive = (t: Theme): boolean => theme === t;

  // JSX
  return (
    <div role="group" aria-label="Theme" className={styles.toggle}>
      {THEMES.map(t => (
        <button
          key={t}
          className={`${styles.option} ${isActive(t) ? styles.active : ''}`}
          onClick={() => setTheme(t)}
          aria-pressed={isActive(t)}
        >
          {t}
        </button>
      ))}
    </div>
  );
}

// 6. Export (named, not default)
export { ThemeToggle };
```

### Hook files

```ts
// 1. External imports
import { useState, useCallback } from 'react';

// 2. Internal imports
import { themeRepository } from '@data/repositories/themeRepository';
import type { Theme } from '@domain/entities/Theme';

// 3. Return type interface
interface UseThemeResult {
  theme: Theme;
  setTheme: (theme: Theme) => void;
}

// 4. Hook definition
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

## Named Exports Only

Never use default exports. Named exports are searchable, refactor-safe, and consistent.

```ts
// BAD
export default function Button() { ... }

// GOOD
export function Button() { ... }
// or
export { Button };
```

---

## Event Handler Naming

```ts
// Props: on + EventName (what happened, not what to do)
interface CardProps {
  onClose: () => void;
  onSelect: (id: string) => void;
}

// Internal handlers: handle + What
const handleClose = (): void => { ... };
const handleSelect = (id: string): void => { ... };
```

---

## ESLint + Prettier

All code is auto-formatted by Prettier. ESLint enforces logic-level rules.

```bash
make lint    # eslint check
make format  # prettier check (dry run)
make fix     # prettier write (auto-fix)
make check   # lint + format + test (pre-commit gate)
```

Key ESLint rules (from `@typescript-eslint/eslint-plugin`):
- `@typescript-eslint/explicit-function-return-type` — explicit return types required
- `@typescript-eslint/no-explicit-any` — `any` is an error
- `@typescript-eslint/no-floating-promises` — unhandled promises caught
- `@typescript-eslint/consistent-type-imports` — `import type` for type-only imports

---

## Import Organization

Imports are ordered by Prettier/ESLint rules:
1. External packages (`react`, `zod`, etc.)
2. Internal aliases (`@domain/`, `@data/`, `@presentation/`)
3. Relative imports (`./styles`, `../hooks`)

```ts
// 1. External
import { useState } from 'react';
import { z } from 'zod';

// 2. Internal (by alias)
import type { Theme } from '@domain/entities/Theme';
import { themeRepository } from '@data/repositories/themeRepository';

// 3. Relative
import styles from './Component.module.css';
```

Type-only imports always use `import type`:

```ts
import type { Theme } from '@domain/entities/Theme';    // ✓
import { Theme } from '@domain/entities/Theme';          // ✗ (unless re-used as value)
```

---

## Comments

Comments explain *why*, not *what*. The code explains what.

```ts
// BAD — explains what (obvious from the code)
// Set the theme in localStorage
localStorage.setItem('arc-theme', theme);

// GOOD — explains why (not obvious from the code)
// Apply data-theme before React hydrates to prevent flash of unstyled content
document.documentElement.setAttribute('data-theme', storedTheme);
```

No TODO comments without a Linear ticket:

```ts
// BAD
// TODO: implement GitHub API integration

// GOOD
// TODO(ARCW-42): integrate GitHub API for live repo data
```
