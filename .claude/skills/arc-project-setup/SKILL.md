---
name: arc-project-setup
description: |
  Project setup for ARC Labs Studio web projects: Vite config, ESLint flat
  config, path aliases, Makefile, git hooks, TypeScript strict mode, project
  scaffold. Use when "new project", "project setup", "configure ESLint",
  "path aliases", "configure Vite", "tsconfig", "git hooks", or "Makefile".
user-invocable: true
metadata:
  author: ARC Labs Studio
  version: "1.0.0"
---

# ARC Labs Studio - Project Setup

## Instructions

### First-Time Setup

```bash
# Clone and install
git clone <repo>
cd <project>
make setup   # npm install + git hooks
make dev     # Vite dev server at localhost:5173
```

### New Project Scaffold

**Directory structure**:
```
src/
├── presentation/
│   ├── components/
│   ├── hooks/
│   ├── layouts/MainLayout/
│   ├── sections/
│   └── styles/
│       ├── tokens.css
│       ├── reset.css
│       └── typography.css
├── domain/entities/
├── data/repositories/
├── assets/
├── test/setup.ts
└── main.tsx
e2e/
public/
```

### `vite.config.ts`

```ts
import { defineConfig } from 'vite';
import react from '@vitejs/plugin-react';
import { resolve } from 'path';

export default defineConfig({
  plugins: [react()],
  resolve: {
    alias: {
      '@presentation': resolve(__dirname, 'src/presentation'),
      '@domain': resolve(__dirname, 'src/domain'),
      '@data': resolve(__dirname, 'src/data'),
      '@assets': resolve(__dirname, 'src/assets'),
    },
  },
  server: { port: 5173, strictPort: true },
  build: { target: 'es2022', sourcemap: true },
  test: {
    environment: 'jsdom',
    globals: true,
    setupFiles: ['./src/test/setup.ts'],
    include: ['src/**/*.test.{ts,tsx}'],
  },
});
```

### `tsconfig.app.json`

```json
{
  "compilerOptions": {
    "target": "ES2022",
    "lib": ["ES2022", "DOM", "DOM.Iterable"],
    "module": "ESNext",
    "moduleResolution": "Bundler",
    "jsx": "react-jsx",
    "strict": true,
    "noUncheckedIndexedAccess": true,
    "noUnusedLocals": true,
    "noUnusedParameters": true,
    "noImplicitReturns": true,
    "exactOptionalPropertyTypes": true,
    "paths": {
      "@presentation/*": ["src/presentation/*"],
      "@domain/*": ["src/domain/*"],
      "@data/*": ["src/data/*"],
      "@assets/*": ["src/assets/*"]
    }
  },
  "include": ["src"]
}
```

### `Makefile`

```makefile
.PHONY: dev build lint format fix test check setup knip

dev:
	npm run dev

build:
	npm run build

lint:
	npm run lint

format:
	npm run format

fix:
	npm run fix

test:
	npm run test

check: lint format test

knip:
	npm run knip

setup:
	npm install
	npm run prepare
```

### `package.json` Scripts

```json
{
  "scripts": {
    "dev": "vite",
    "build": "tsc -b && vite build",
    "lint": "eslint src e2e",
    "format": "prettier --check src e2e index.html",
    "fix": "prettier --write src e2e index.html && eslint src e2e --fix",
    "test": "vitest run",
    "test:watch": "vitest",
    "knip": "knip",
    "prepare": "husky"
  }
}
```

### `src/test/setup.ts`

```ts
import '@testing-library/jest-dom';
```

### Git Hooks (Husky + lint-staged)

```bash
# Install husky
npm install --save-dev husky lint-staged
npx husky init
```

`.husky/pre-commit`:
```bash
npx lint-staged
```

`.husky/pre-push`:
```bash
npm run test
```

`package.json` (lint-staged config):
```json
{
  "lint-staged": {
    "*.{ts,tsx}": ["prettier --write", "eslint --fix"],
    "*.{css,json,md}": ["prettier --write"]
  }
}
```

### Essential Dependencies

```bash
# Core
npm install react react-dom
npm install --save-dev typescript @types/react @types/react-dom

# Vite + build
npm install --save-dev vite @vitejs/plugin-react

# Forms + validation
npm install react-hook-form zod @hookform/resolvers

# Testing
npm install --save-dev vitest @vitest/coverage-v8
npm install --save-dev @testing-library/react @testing-library/jest-dom @testing-library/user-event
npm install --save-dev jsdom

# Playwright (E2E)
npm install --save-dev @playwright/test

# ESLint + Prettier (use ESLint 9.x, not 10)
npm install --save-dev eslint@9 @eslint/js typescript-eslint
npm install --save-dev eslint-plugin-react eslint-plugin-react-hooks eslint-plugin-react-refresh
npm install --save-dev eslint-plugin-jsx-a11y eslint-plugin-import-x
npm install --save-dev eslint-plugin-boundaries @vitest/eslint-plugin
npm install --save-dev eslint-plugin-testing-library eslint-plugin-playwright
npm install --save-dev eslint-config-prettier prettier

# Git hooks
npm install --save-dev husky lint-staged

# Dead code
npm install --save-dev knip
```

### `.gitignore`

```gitignore
node_modules/
dist/
coverage/
.env.local
.env.*.local

# Editor
.DS_Store
*.swp
.idea/
.vscode/settings.json

# Never commit local settings
.claude/settings.local.json
```

### First Commit

```bash
git add .
git commit -m "chore: initial project setup"
```

## Further Reading

- `Tools/vite.md` — full Vite config reference
- `Tools/eslint.md` — full ESLint 9 flat config with all 12 plugins
- `Tools/npm.md` — npm scripts, lockfile, dependency management
- `Projects/sites.md` — marketing site structure
- `Projects/apps.md` — full app structure
