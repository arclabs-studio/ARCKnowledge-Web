# Git Commits — ARC Labs Studio

Commit message format, types, scopes, and best practices.

---

## Conventional Commits

All commits follow [Conventional Commits](https://www.conventionalcommits.org/):

```
<type>(<scope>): <description>

[optional body]

[optional footer(s)]
```

**Examples:**

```
feat(contact): add react-hook-form + zod validation
fix(theme): prevent flash of unstyled content on Safari
style(hero): increase headline size on desktop
refactor(useTheme): extract theme persistence to repository
docs(readme): update install instructions
chore(deps): update vite to 7.1.0
test(button): add keyboard navigation test
```

---

## Commit Types

| Type | When to use |
|------|-------------|
| `feat` | New feature or visible capability |
| `fix` | Bug fix |
| `style` | Visual/CSS changes with no logic change |
| `refactor` | Internal restructuring, no behaviour change |
| `test` | Add or fix tests |
| `docs` | Documentation only |
| `chore` | Dependencies, config, build scripts, CI |
| `perf` | Performance improvement |
| `revert` | Reverts a previous commit |

---

## Scopes

Scope identifies the area changed. Use the component, hook, layer, or feature name:

| Scope example | Use for |
|---------------|---------|
| `hero` | HeroSection component |
| `contact` | ContactSection or ContactForm |
| `useTheme` | Theme hook |
| `themeRepository` | Theme data repository |
| `header` | Header component |
| `nav` | Navigation |
| `tokens` | Design tokens |
| `deps` | Dependency updates |
| `ci` | CI/CD changes |

Scope is optional but highly recommended — it makes the git log scannable.

---

## Description Rules

- **Lowercase** — `feat(nav): add mobile menu` not `Add mobile menu`
- **Imperative mood** — `add`, `fix`, `update`, not `added`, `fixed`, `updated`
- **No period** at the end
- **≤ 72 characters** in the first line
- **Describe the change**, not the process — `fix(form): show error on invalid email` not `fix(form): work on form validation`

---

## Commit Body

Use the body for non-obvious context: **why** this change was made, not what it does (the diff shows that).

```
feat(contact): add netlify forms integration

Netlify Forms requires a static HTML form with data-netlify="true"
to exist at build time — the JavaScript form cannot be the only
submission path. Added a hidden form in index.html for build-time
detection.

See: https://docs.netlify.com/forms/setup/
```

---

## Breaking Changes

Breaking changes are marked with `!` after the type/scope and a `BREAKING CHANGE:` footer:

```
feat(api)!: rename submitForm to submitContactForm

BREAKING CHANGE: The submitForm export has been renamed to
submitContactForm for clarity. Update all call sites.
```

---

## Pre-commit Hook

The pre-commit hook runs automatically via lint-staged:
1. **Prettier** — auto-formats staged files
2. **ESLint --fix** — auto-fixes lint errors on staged files

If ESLint finds errors it cannot auto-fix, the commit is blocked. Fix manually, then re-stage.

The pre-push hook runs `make test`. If tests fail, the push is blocked.

---

## Commit Discipline

- **One logical change per commit** — small, focused commits are easier to revert and review
- **No "WIP" commits** — squash or amend before pushing to a shared branch
- **No commented-out code** — remove it; git history preserves it
- **No console.log** in committed code (except `import.meta.env.DEV` guards)

```bash
# Squash last 3 commits before pushing
git rebase -i HEAD~3

# Amend the last commit message (before pushing only)
git commit --amend -m "feat(scope): corrected description"
```

---

## Linear Integration

Reference Linear tickets in the commit body or footer when the commit closes a ticket:

```
feat(apps): add AppCard component with App Store link

Closes ARCW-15
```

Or inline in the description for smaller fixes:
```
fix(ARCW-23): resolve focus ring missing on ThemeToggle
```

---

## Commit Message Validation

Install [commitlint](https://commitlint.js.org/) to enforce the format automatically:

```bash
npm install --save-dev @commitlint/cli @commitlint/config-conventional
```

`commitlint.config.ts`:
```ts
import type { UserConfig } from '@commitlint/types';

const config: UserConfig = {
  extends: ['@commitlint/config-conventional'],
  rules: {
    'scope-case': [2, 'always', 'camel-case'],
    'subject-case': [2, 'always', 'lower-case'],
  },
};

export default config;
```

Add to husky:
```bash
# .husky/commit-msg
npx --no -- commitlint --edit "$1"
```
