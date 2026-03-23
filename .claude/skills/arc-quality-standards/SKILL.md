---
name: arc-quality-standards
description: |
  Code quality standards for ARC Labs Studio: ESLint 9 flat config, Prettier,
  TypeScript strict mode, Knip dead code detection, naming conventions, import
  organization, comment policy, TODO policy. Use when "configuring ESLint",
  "fixing lint errors", "code style questions", "naming conventions", "import
  order", "TypeScript strict", or "pre-commit checks".
user-invocable: true
metadata:
  author: ARC Labs Studio
  version: "1.0.0"
---

# ARC Labs Studio - Quality Standards

## Instructions

### Pre-Commit Gate

```bash
make check   # lint + format + test — must pass before every commit
```

This runs: `eslint src e2e` → `prettier --check` → `vitest run`

### TypeScript Conventions

| Item | Convention | Example |
|------|-----------|---------|
| Components | PascalCase | `ThemeToggle`, `AppCard` |
| Hooks | camelCase + `use` | `useTheme`, `useActiveSection` |
| Constants | UPPER_SNAKE_CASE | `SECTION_IDS`, `THEMES` |
| Types / Interfaces | PascalCase | `Theme`, `ButtonProps` |
| Functions | camelCase | `getTheme`, `isTheme`, `mapToApp` |
| CSS Module classes | camelCase | `.primaryButton`, `.isActive` |
| Component files | PascalCase | `Button.tsx` |
| Hook / util files | camelCase | `useTheme.ts`, `themeRepository.ts` |
| CSS Module files | PascalCase | `Button.module.css` |

### Named Exports Only

```ts
// BAD
export default function Button() { ... }

// GOOD
export function Button() { ... }
// OR
export { Button };
```

### Explicit Return Types (ESLint-enforced)

```ts
// BAD — implicit
const getTheme = () => 'brand';

// GOOD — explicit
const getTheme = (): Theme => 'brand';

// GOOD — arrow with body
const handleSubmit = async (data: ContactFormData): Promise<void> => {
  await contactRepository.submit(data);
};
```

### No `any` Types

```ts
// BAD
const data: any = await response.json();

// GOOD
const data = (await response.json()) as unknown;
// Then validate:
const validated = userSchema.parse(data);
```

### Import Organization

```ts
// 1. External packages
import { useState } from 'react';
import { z } from 'zod';

// 2. Internal aliases
import type { Theme } from '@domain/entities/Theme';
import { themeRepository } from '@data/repositories/themeRepository';

// 3. Relative imports
import styles from './Component.module.css';
```

Type-only imports always use `import type`:
```ts
import type { Theme } from '@domain/entities/Theme';    // ✓
import { Theme } from '@domain/entities/Theme';          // ✗ (unless used as value)
```

### ESLint Plugin Stack (ESLint 9.x)

Stay on **ESLint 9.x** — `eslint-plugin-react` is broken on ESLint 10 (uses removed `context.getFilename()` API).

| Plugin | Purpose |
|--------|---------|
| `@eslint/js` | Core JS rules |
| `typescript-eslint` (type-checked) | TS strict rules |
| `eslint-plugin-react` | React-specific rules |
| `eslint-plugin-react-hooks` | Hooks rules + Compiler |
| `eslint-plugin-react-refresh` | Vite HMR correctness |
| `eslint-plugin-jsx-a11y` | Static accessibility |
| `eslint-plugin-import-x` | Import cycles + order |
| `eslint-plugin-boundaries` | Clean Architecture enforcement |
| `@vitest/eslint-plugin` | Test file rules (scoped to `*.test.*`) |
| `eslint-plugin-testing-library` | RTL rules (scoped to `*.test.*`) |
| `eslint-plugin-playwright` | E2E rules (scoped to `*.spec.*`) |
| `eslint-config-prettier` | Disable formatting rules (last) |

**Critical scoping**: Never let Playwright and Vitest/RTL globs overlap.

### Key ESLint Rules

```ts
'@typescript-eslint/explicit-function-return-type': 'error'
'@typescript-eslint/no-explicit-any': 'error'
'@typescript-eslint/no-floating-promises': 'error'
'@typescript-eslint/consistent-type-imports': 'error'
'import-x/no-cycle': 'error'
'boundaries/element-types': 'error'  // enforces layer boundaries
```

### Prettier

Prettier handles all formatting. ESLint handles logic rules.

```bash
make format  # dry-run (check)
make fix     # write + ESLint --fix
```

Common Prettier settings (`.prettierrc`):
```json
{
  "semi": true,
  "singleQuote": true,
  "tabWidth": 2,
  "trailingComma": "all",
  "printWidth": 100
}
```

### Knip (Dead Code Detection)

```bash
make knip    # find unused exports, deps, and files
```

Knip catches:
- Unused exports (components, functions, types)
- Unused dependencies in `package.json`
- Untracked TODO comments (zero tolerance in production)

### Comment Policy

Comment the **why**, not the **what**:

```ts
// BAD — explains what (obvious from code)
localStorage.setItem('arc-theme', theme);

// GOOD — explains why (non-obvious)
// Apply data-theme before React hydrates to prevent flash of unstyled content
document.documentElement.setAttribute('data-theme', storedTheme);
```

### TODO Policy

Every TODO must reference a Linear ticket:

```ts
// BAD
// TODO: add GitHub API integration

// GOOD
// TODO(ARCW-42): integrate GitHub API for live repo data
```

Untracked TODOs are flagged by Knip. Zero tolerance in production.

### No Commented-Out Code

Remove dead code — don't comment it out. Git history preserves removed code.

```ts
// BAD
// const oldHandler = async (data) => { ... };
const handler = async (data: ContactFormData): Promise<void> => { ... };
```

## Further Reading

- `Quality/code-style.md` — full naming conventions and file structure
- `Quality/code-review.md` — 8-domain PR review checklist
- `Quality/documentation.md` — JSDoc standards
- `Tools/eslint.md` — full eslint.config.js with all 12 plugins
