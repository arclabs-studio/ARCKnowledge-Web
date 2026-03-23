# npm — ARC Labs Studio

npm scripts, lockfile discipline, dependency management, and the Makefile interface.

---

## Makefile (Primary Interface)

All common operations run through `make`. The Makefile is the single source of truth — don't run raw npm scripts directly in daily work.

```makefile
# Makefile

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
	@echo "✓ All checks passed"

knip:
	npm run knip

setup:
	npm install
	npm run prepare  # Install git hooks (husky)
```

---

## package.json Scripts

```json
{
  "scripts": {
    "dev": "vite",
    "build": "tsc -b && vite build",
    "preview": "vite preview",
    "lint": "eslint src e2e",
    "format": "prettier --check src e2e index.html",
    "fix": "prettier --write src e2e index.html && eslint src e2e --fix",
    "test": "vitest run",
    "test:watch": "vitest",
    "test:coverage": "vitest run --coverage",
    "knip": "knip",
    "prepare": "husky"
  }
}
```

### Script intent

| Script | When to use |
|--------|-------------|
| `make dev` | Local development (Vite HMR server) |
| `make build` | TypeScript type check + production bundle |
| `make lint` | ESLint check (read-only) |
| `make format` | Prettier dry-run (read-only) |
| `make fix` | Prettier write + ESLint --fix (auto-format) |
| `make test` | Vitest single run (CI-equivalent) |
| `npx vitest` | Vitest watch mode (dev feedback loop) |
| `make check` | Full pre-commit gate: lint + format + test |
| `make knip` | Dead code + unused dependency check |
| `make setup` | First-time: install deps + git hooks |

---

## Lockfile Discipline

- **Always commit `package-lock.json`**. Never `.gitignore` it.
- **Never delete `package-lock.json`** to "fix" install issues. Diagnose the real problem.
- The lockfile pins exact versions including transitive dependencies.

```bash
# Install with exact lockfile (CI + production)
npm ci

# Install and update lockfile (development)
npm install
```

`npm ci` is faster and safer in CI because it validates the lockfile and fails if it's out of date.

---

## Adding Dependencies

```bash
# Runtime dependency
npm install zod

# Development-only dependency
npm install --save-dev vitest @testing-library/react

# Check what you're adding before committing
npm ls zod  # Verify it installed correctly
```

Before adding any dependency:
1. Check bundle size impact: https://bundlephobia.com
2. Check maintenance: last publish date, open issues, weekly downloads
3. Prefer packages with TypeScript types included (not `@types/` packages)
4. Run `make build` to confirm no tree-shaking issues

---

## Updating Dependencies

Use the `arc-update-dependencies` skill for structured updates. Manual process:

```bash
# See outdated packages
npm outdated

# Update patch + minor versions (usually safe)
npm update

# Update a specific package to latest (may be breaking)
npm install react@latest react-dom@latest

# After any update
make check  # Ensure nothing broke
```

**Never** run `npm update --save` on all packages blindly before a release. Update packages one at a time or in related groups.

---

## Removing Dependencies

```bash
npm uninstall package-name

# Verify no other package depends on it first
npm ls package-name
```

Run `make knip` after removing — Knip will flag if the package is still imported somewhere.

---

## Security Auditing

```bash
npm audit             # Check for known vulnerabilities
npm audit --fix       # Auto-fix where possible (safe upgrades only)
npm audit --fix --force  # Force upgrades (may break — review changes)
```

CI automatically runs `npm audit` on PRs. Blockers:
- **Critical** and **High** severity vulnerabilities must be resolved before merge
- **Moderate** requires justification (document in PR if accepting)
- **Low** can be accepted with a comment

---

## Workspace / Monorepo

This project is a single-package repo. Workspaces are not used. If the project evolves to a monorepo:

```json
{
  "workspaces": ["packages/*", "apps/*"]
}
```

Use `npm -w packages/ui build` to scope commands to a workspace.

---

## Node Version

Pin Node.js version in `.node-version` (read by `fnm`, `nvm`, `mise`):

```
22
```

The CI matrix uses this version. Ensure your local `node --version` matches.

---

## Git Hooks (Husky + lint-staged)

Pre-commit hook runs Prettier + ESLint on staged files only (fast):

```json
// package.json
{
  "lint-staged": {
    "*.{ts,tsx}": ["prettier --write", "eslint --fix"],
    "*.{css,json,md}": ["prettier --write"]
  }
}
```

Pre-push hook runs the full test suite (blocks broken pushes):

```bash
# .husky/pre-push
npm run test
```

Install hooks: `make setup` (runs `husky` which reads `.husky/` directory).

---

## Common Issues

### `npm ci` fails with "package-lock.json out of date"

Regenerate: `npm install` then commit the updated `package-lock.json`.

### Peer dependency warnings

Read the warning carefully. Most peer dependency warnings from `@types/*` packages are harmless. For actual peer conflicts, install the required version explicitly.

### `npm audit` flags a transitive dependency

Check if the vulnerable package is actually reachable in production:
```bash
npm ls vulnerable-package  # Shows the dependency tree
```

If it's only in `devDependencies` and not bundled, document it and accept for now.
