# Vite — ARC Labs Studio

Vite 7 configuration: aliases, plugins, Vitest, HMR, and build optimization.

---

## Standard Config (`vite.config.ts`)

```ts
import { defineConfig } from 'vite';
import react from '@vitejs/plugin-react';
import { resolve } from 'path';

export default defineConfig({
  plugins: [
    react({
      // React Compiler (Vite 7 + React 19)
      babel: {
        plugins: [['babel-plugin-react-compiler']],
      },
    }),
  ],

  // ── Path Aliases ────────────────────────────────────────────────
  resolve: {
    alias: {
      '@presentation': resolve(__dirname, 'src/presentation'),
      '@domain': resolve(__dirname, 'src/domain'),
      '@data': resolve(__dirname, 'src/data'),
      '@assets': resolve(__dirname, 'src/assets'),
    },
  },

  // ── Dev Server ──────────────────────────────────────────────────
  server: {
    port: 5173,
    strictPort: true, // Fail if port is taken (don't silently use next port)
    open: false,
  },

  // ── Build ───────────────────────────────────────────────────────
  build: {
    target: 'es2022',
    sourcemap: true,
    rollupOptions: {
      output: {
        // Manual chunk splitting for better caching
        manualChunks: {
          vendor: ['react', 'react-dom'],
          forms: ['react-hook-form', 'zod'],
        },
      },
    },
  },

  // ── Vitest ──────────────────────────────────────────────────────
  test: {
    environment: 'jsdom',
    globals: true, // No need to import describe/it/expect
    setupFiles: ['./src/test/setup.ts'],
    include: ['src/**/*.test.{ts,tsx}'],
    exclude: ['e2e/**', 'node_modules/**'],
    coverage: {
      provider: 'v8',
      reporter: ['text', 'html'],
      exclude: [
        'src/main.tsx',
        'src/test/**',
        '**/*.d.ts',
        '**/*.config.*',
        '**/index.ts', // Barrel exports
      ],
    },
  },
});
```

---

## Path Aliases

Aliases eliminate relative import chains (`../../..`) and enforce layer boundaries.

```ts
// tsconfig.app.json — must mirror vite.config.ts aliases
{
  "compilerOptions": {
    "paths": {
      "@presentation/*": ["src/presentation/*"],
      "@domain/*": ["src/domain/*"],
      "@data/*": ["src/data/*"],
      "@assets/*": ["src/assets/*"]
    }
  }
}
```

**Rule**: Both `vite.config.ts` and `tsconfig.app.json` must be updated when adding a new alias. If only Vite has the alias, TypeScript won't resolve it; if only TypeScript has it, Vite's dev server won't resolve it.

---

## React Plugin (Vite 7)

`@vitejs/plugin-react` uses Babel. For React 19 with React Compiler:

```bash
npm install babel-plugin-react-compiler --save-dev
```

React Compiler automatically memoizes components and hooks. Remove manual `useMemo`/`useCallback` where the compiler handles it.

Without React Compiler (simpler setup):
```ts
react() // No babel config needed
```

---

## Environment Variables

Vite exposes env variables prefixed with `VITE_`:

```ts
// .env.local (never commit)
VITE_API_URL=https://api.example.com

// Usage in code
const apiUrl = import.meta.env.VITE_API_URL;
```

Dev-only guard (no VITE_ prefix needed):
```ts
if (import.meta.env.DEV) {
  console.log('[debug]', value);
}
```

Available modes: `development` (dev server), `production` (build), `test` (Vitest).

---

## HMR (Hot Module Replacement)

`eslint-plugin-react-refresh` enforces HMR compatibility. The rule `react-refresh/only-export-components` warns when a file exports both components and non-component values, which breaks HMR fast refresh.

```ts
// Warning — exports a component AND a constant
export function MyComponent() { ... }
export const MY_CONSTANT = 'value'; // breaks HMR

// OK — constant in its own file
// constants.ts
export const MY_CONSTANT = 'value';
```

Exception: `allowConstantExport: true` permits `export const` at module level.

---

## Vitest Configuration

Vitest runs in Vite's pipeline — no separate Jest config needed.

### Test setup file (`src/test/setup.ts`)

```ts
import '@testing-library/jest-dom';
```

### Running tests

```bash
make test          # Single run (CI mode)
npx vitest         # Watch mode (development)
npx vitest run src/path/to/Component.test.tsx  # Single file
npx vitest --coverage  # With coverage report
```

### Test file location

Co-locate with component:
```
ComponentName/
├── ComponentName.tsx
├── ComponentName.module.css
├── ComponentName.test.tsx  ← here
└── index.ts
```

---

## Build Optimization

### Bundle analysis

```bash
npx vite-bundle-visualizer
```

### Lazy loading large components

```tsx
import { lazy, Suspense } from 'react';

// Only loaded when the section enters the viewport
const HeavySection = lazy(() => import('./HeavySection'));

function App(): React.JSX.Element {
  return (
    <Suspense fallback={<SectionSkeleton />}>
      <HeavySection />
    </Suspense>
  );
}
```

### Image optimization

Vite handles static images automatically. For responsive images, use the `<img>` `srcset` attribute:

```tsx
<img
  src="/images/hero.jpg"
  srcSet="/images/hero@2x.jpg 2x"
  width={800}
  height={600}
  alt="Hero image"
  loading="lazy"
/>
```

Always specify `width` and `height` to prevent Cumulative Layout Shift (CLS).

---

## Common Issues

### Alias not resolving in TypeScript

Both `vite.config.ts` and `tsconfig.app.json` must have the alias. Check both files.

### Tests fail with "Cannot use import statement"

Vite's test environment transforms files differently than the dev server. Ensure `test.environment: 'jsdom'` and that external packages that ship ESM are listed in `optimizeDeps.include` if needed:

```ts
optimizeDeps: {
  include: ['some-esm-package'],
},
```

### CSS Modules not scoping

Ensure file is named `.module.css` (not `.css`). Vite only scopes `.module.css` files.

### HMR not working for a component

Check for `react-refresh/only-export-components` warnings in ESLint. Mixed exports break fast refresh.
