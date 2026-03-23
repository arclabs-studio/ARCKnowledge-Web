---
name: arc-workflow
description: |
  Git workflow for ARC Labs Studio web projects: Conventional Commits, branch
  naming, PR process, Linear integration. Use when "git commit", "branch name",
  "commit message", "PR", "pull request", "workflow", "Linear ticket", or
  "release process".
user-invocable: true
metadata:
  author: ARC Labs Studio
  version: "1.0.0"
---

# ARC Labs Studio - Git Workflow

## Instructions

### Commit Message Format

```
<type>(<scope>): <description>
```

**Types**: `feat`, `fix`, `style`, `refactor`, `test`, `docs`, `chore`, `perf`, `revert`

**Rules**:
- Lowercase description
- Imperative mood (`add`, `fix`, not `added`, `fixed`)
- No trailing period
- ≤ 72 characters on first line

```bash
# Good examples
feat(contact): add react-hook-form validation
fix(theme): prevent FOUC on Safari
style(hero): increase headline font size on desktop
refactor(useTheme): extract persistence to themeRepository
test(button): add keyboard navigation coverage
docs(readme): update install instructions
chore(deps): update vite to 7.1.0
```

### Branch Naming

```
<type>/<kebab-case-description>
```

**Types**: `feature/`, `bugfix/`, `docs/`, `chore/`, `style/`, `refactor/`, `test/`, `hotfix/`

```bash
feature/contact-form-validation
bugfix/theme-flash-on-safari
docs/add-contributing-guide
chore/update-vite-7
```

### Branch Lifecycle

1. Always branch from `develop`:
```bash
git checkout develop
git pull origin develop
git checkout -b feature/my-feature
```

2. Keep in sync during long-lived branches:
```bash
git fetch origin
git rebase origin/develop
```

3. Push and open PR targeting `develop`:
```bash
git push -u origin feature/my-feature
gh pr create --base develop
```

4. After merge, delete branch:
```bash
git branch -d feature/my-feature
git push origin --delete feature/my-feature
```

### Pre-commit Checks

The pre-commit hook runs automatically via lint-staged:
- Prettier formats staged files
- ESLint --fix runs on staged `.ts`, `.tsx` files

If ESLint can't auto-fix, commit is blocked. Fix manually, re-stage, try again.

The pre-push hook runs `make test`. Failing tests block the push.

```bash
# Run all checks manually before pushing
make check   # lint + format + test
```

### PR Process

Before opening a PR:
1. Run `make check` — all must pass
2. Self-review using the `Quality/code-review.md` checklist
3. Tab through any new interactive elements manually

PR checklist:
- [ ] Target branch is `develop` (not `main`)
- [ ] `make check` passes
- [ ] Self-review completed
- [ ] Linear ticket referenced (if applicable)

### Linear Integration

Reference tickets in commits:
```bash
# In commit body
git commit -m "feat(apps): add AppCard component

Closes ARCW-15"

# Or inline for small fixes
git commit -m "fix(ARCW-23): resolve focus ring on ThemeToggle"
```

### Plan Mode — When to Use

Use Plan Mode before implementing anything that touches > 3 files or changes layer boundaries:

```
ALWAYS plan:
  ✓ New page section (3+ files)
  ✓ New domain entity + repository + hook + component
  ✓ Refactoring a layer
  ✓ Adding routing or auth

SKIP planning:
  ✗ Bug fix in single file
  ✗ CSS adjustment
  ✗ Adding a test
  ✗ Documentation update
```

See `Workflow/plan-mode.md` for the full plan structure.

### Release Process

Releases merge `develop` into `main`:
```bash
gh pr create --base main --head develop --title "Release vX.Y.Z"
```

Netlify auto-deploys on merge to `main`. Verify the deploy succeeds in the Netlify dashboard.

## Further Reading

- `Workflow/git-commits.md` — full commit message guide with body and breaking changes
- `Workflow/git-branches.md` — branch protection rules, hotfix process
- `Workflow/plan-mode.md` — Plan Mode structure and TDD workflow
