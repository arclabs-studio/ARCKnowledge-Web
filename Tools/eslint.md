# ESLint — ARC Labs Studio

ESLint 9.x flat config with type-checked rules and the full ARC Labs plugin stack.

**Important**: Stay on **ESLint 9.x**. `eslint-plugin-react` is broken on ESLint 10 (`context.getFilename()` was removed). Upgrade only after https://github.com/jsx-eslint/eslint-plugin-react/pull/3979 ships.

---

## Plugin Stack

| Plugin | Purpose | Scope |
|--------|---------|-------|
| `@eslint/js` | Core JS rules | All files |
| `typescript-eslint` | Type-aware TS rules | All files |
| `eslint-plugin-react` | React-specific rules | `src/**/*.{tsx,jsx}` |
| `eslint-plugin-react-hooks` | Hooks rules + React Compiler | `src/**/*.{ts,tsx}` |
| `eslint-plugin-react-refresh` | Vite HMR correctness | `src/**/*.{ts,tsx}` |
| `eslint-plugin-jsx-a11y` | Static accessibility checks | `src/**/*.tsx` |
| `eslint-plugin-import-x` | Import order + no cycles | `src/**/*.{ts,tsx}` |
| `eslint-plugin-boundaries` | Clean Architecture enforcement | `src/**/*.{ts,tsx}` |
| `@vitest/eslint-plugin` | Vitest test correctness | `src/**/*.test.{ts,tsx}` |
| `eslint-plugin-testing-library` | RTL query priority | `src/**/*.test.{ts,tsx}` |
| `eslint-plugin-playwright` | Playwright test rules | `e2e/**/*.spec.{ts,tsx}` |
| `eslint-config-prettier` | Disable formatting rules | Last in config array |
| `knip` | Dead code + unused deps | Separate CLI (not ESLint plugin) |

---

## Flat Config (`eslint.config.js`)

```js
import eslint from '@eslint/js';
import tseslint from 'typescript-eslint';
import reactPlugin from 'eslint-plugin-react';
import reactHooksPlugin from 'eslint-plugin-react-hooks';
import reactRefreshPlugin from 'eslint-plugin-react-refresh';
import jsxA11yPlugin from 'eslint-plugin-jsx-a11y';
import importXPlugin from 'eslint-plugin-import-x';
import boundariesPlugin from 'eslint-plugin-boundaries';
import vitestPlugin from '@vitest/eslint-plugin';
import testingLibraryPlugin from 'eslint-plugin-testing-library';
import playwrightPlugin from 'eslint-plugin-playwright';
import prettierConfig from 'eslint-config-prettier';

export default tseslint.config(
  // ── Global ignores ──────────────────────────────────────────────────
  {
    ignores: ['dist/**', 'node_modules/**', 'coverage/**', '*.d.ts'],
  },

  // ── Base: JS + TypeScript (type-checked) ────────────────────────────
  eslint.configs.recommended,
  ...tseslint.configs.recommendedTypeChecked,
  {
    languageOptions: {
      parserOptions: {
        projectService: true,
        tsconfigRootDir: import.meta.dirname,
      },
    },
    rules: {
      // Require explicit return types on all functions
      '@typescript-eslint/explicit-function-return-type': 'error',
      // No any
      '@typescript-eslint/no-explicit-any': 'error',
      // Catch floating promises
      '@typescript-eslint/no-floating-promises': 'error',
      // Enforce import type for type-only imports
      '@typescript-eslint/consistent-type-imports': [
        'error',
        { prefer: 'type-imports', fixStyle: 'separate-type-imports' },
      ],
      // No unused variables (TS handles this better than ESLint)
      '@typescript-eslint/no-unused-vars': [
        'error',
        { argsIgnorePattern: '^_', varsIgnorePattern: '^_' },
      ],
    },
  },

  // ── React ─────────────────────────────────────────────────────────
  {
    files: ['src/**/*.{tsx,jsx}'],
    plugins: {
      react: reactPlugin,
      'react-hooks': reactHooksPlugin,
      'react-refresh': reactRefreshPlugin,
    },
    settings: {
      react: { version: 'detect' },
    },
    rules: {
      // React 19: JSX transform — no need to import React
      'react/react-in-jsx-scope': 'off',
      'react/prop-types': 'off', // TS handles this
      // Hooks rules (includes React Compiler rules)
      ...reactHooksPlugin.configs.recommended.rules,
      // HMR: only export components from entry files
      'react-refresh/only-export-components': ['warn', { allowConstantExport: true }],
      // No default exports — named only
      'react/display-name': 'off',
    },
  },

  // ── Accessibility ────────────────────────────────────────────────
  {
    files: ['src/**/*.tsx'],
    plugins: { 'jsx-a11y': jsxA11yPlugin },
    rules: {
      ...jsxA11yPlugin.configs.recommended.rules,
    },
  },

  // ── Imports ──────────────────────────────────────────────────────
  {
    files: ['src/**/*.{ts,tsx}'],
    plugins: { 'import-x': importXPlugin },
    rules: {
      // Disable rules TS already handles
      'import-x/no-unresolved': 'off',
      'import-x/named': 'off',
      'import-x/namespace': 'off',
      'import-x/default': 'off',
      // Keep: no cycles, consistent extension omission
      'import-x/no-cycle': 'error',
      'import-x/no-duplicates': 'error',
      'import-x/order': [
        'error',
        {
          groups: ['builtin', 'external', 'internal', 'parent', 'sibling', 'index'],
          pathGroups: [
            { pattern: '@domain/**', group: 'internal', position: 'before' },
            { pattern: '@data/**', group: 'internal' },
            { pattern: '@presentation/**', group: 'internal', position: 'after' },
            { pattern: '@assets/**', group: 'internal', position: 'after' },
          ],
          pathGroupsExcludedImportTypes: ['builtin'],
          'newlines-between': 'always',
          alphabetize: { order: 'asc', caseInsensitive: true },
        },
      ],
    },
  },

  // ── Clean Architecture boundaries ────────────────────────────────
  {
    files: ['src/**/*.{ts,tsx}'],
    plugins: { boundaries: boundariesPlugin },
    settings: {
      'boundaries/elements': [
        { type: 'presentation', pattern: 'src/presentation/**/*' },
        { type: 'domain', pattern: 'src/domain/**/*' },
        { type: 'data', pattern: 'src/data/**/*' },
        { type: 'assets', pattern: 'src/assets/**/*' },
      ],
    },
    rules: {
      'boundaries/element-types': [
        'error',
        {
          default: 'disallow',
          rules: [
            // Presentation can import domain and presentation
            {
              from: 'presentation',
              allow: ['presentation', 'domain'],
            },
            // Domain can only import domain (pure TS)
            {
              from: 'domain',
              allow: ['domain'],
            },
            // Data can import domain and data
            {
              from: 'data',
              allow: ['data', 'domain'],
            },
          ],
        },
      ],
    },
  },

  // ── Vitest + React Testing Library (test files only) ──────────────
  {
    files: ['src/**/*.test.{ts,tsx}'],
    plugins: {
      vitest: vitestPlugin,
      'testing-library': testingLibraryPlugin,
    },
    rules: {
      ...vitestPlugin.configs.recommended.rules,
      ...testingLibraryPlugin.configs.react.rules,
      // Enforce query priority: getByRole > getByLabelText > getByText > getByTestId
      'testing-library/prefer-by-role': 'error',
      'testing-library/no-wait-for-side-effects': 'error',
      'testing-library/no-unnecessary-act': 'error',
      // Allow explicit assertions on async queries
      'vitest/expect-expect': 'error',
    },
  },

  // ── Playwright (E2E files only — NEVER overlap with test glob) ──────
  {
    files: ['e2e/**/*.spec.{ts,tsx}'],
    plugins: { playwright: playwrightPlugin },
    rules: {
      ...playwrightPlugin.configs.recommended.rules,
    },
  },

  // ── Prettier (always last) ───────────────────────────────────────
  prettierConfig,
);
```

---

## Key Rules Explained

### `@typescript-eslint/explicit-function-return-type`

Every function must declare its return type. Catches accidental `undefined` returns and makes intent clear.

```ts
// Error — no return type
const getTheme = () => localStorage.getItem('theme') ?? 'brand';

// OK
const getTheme = (): Theme => {
  const raw = localStorage.getItem('theme');
  return isTheme(raw) ? raw : 'brand';
};
```

### `boundaries/element-types`

Enforces Clean Architecture dependency direction. The presentation layer cannot import from data; domain cannot import anything outside itself.

```ts
// Error — direct repository import in component file
import { themeRepository } from '@data/repositories/themeRepository'; // in .tsx

// OK — through hook abstraction
import { useTheme } from '@presentation/hooks/useTheme'; // in .tsx
```

### `import-x/no-cycle`

Catches circular imports which cause runtime initialization issues in ES modules.

### Scoping Rules

**Critical**: Do NOT let Playwright and Vitest/RTL rules overlap globs:
- `src/**/*.test.{ts,tsx}` → Vitest + RTL rules
- `e2e/**/*.spec.{ts,tsx}` → Playwright rules

Overlap causes rule conflicts and false positives for `expect`, `describe`, and `test`.

---

## Knip (Dead Code Detection)

Knip runs separately from ESLint. It finds:
- Unused exports (functions, components, types)
- Unused dependencies in `package.json`
- Unlisted dependencies (used but not declared)
- Untracked TODO comments (zero tolerance in production code)

```bash
make knip          # Check for dead code
make knip-fix      # Auto-remove some unused exports
```

`knip.config.ts`:
```ts
import type { KnipConfig } from 'knip';

const config: KnipConfig = {
  entry: ['src/main.tsx', 'e2e/**/*.spec.ts'],
  project: ['src/**/*.{ts,tsx}'],
  ignore: ['src/test/setup.ts'],
  ignoreDependencies: ['@testing-library/jest-dom'], // loaded via setup.ts
};

export default config;
```

---

## Make Targets

```bash
make lint     # ESLint check (no fix)
make format   # Prettier dry-run
make fix      # Prettier write + ESLint --fix
make knip     # Knip dead code check
make check    # lint + format + test (pre-commit gate)
```

---

## Upgrading

When `eslint-plugin-react` ships support for ESLint 10:
1. `npm install eslint@10 --save-dev`
2. Remove the version pin comment from `package.json`
3. Run `make lint` and fix any new violations
4. Update this file

Track: https://github.com/jsx-eslint/eslint-plugin-react/pull/3979
