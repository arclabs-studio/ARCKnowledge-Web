# Git Branches — ARC Labs Studio

Branch naming, protection rules, and lifecycle.

---

## Branch Naming

```
<type>/<kebab-case-description>
```

**Examples:**

```
feature/contact-form-validation
feature/apps-section
bugfix/theme-flash-on-safari
bugfix/mobile-nav-close-on-outside-click
docs/add-contributing-guide
chore/update-vite-7
style/hero-mobile-layout
refactor/useTheme-extract-repository
```

---

## Branch Types

| Type | When to use |
|------|-------------|
| `feature/` | New functionality |
| `bugfix/` | Fixing a defect |
| `docs/` | Documentation only |
| `chore/` | Dependencies, config, CI |
| `style/` | CSS / visual changes only |
| `refactor/` | Internal restructuring |
| `test/` | Adding or fixing tests |
| `hotfix/` | Urgent production fix (branches from `main`) |

---

## Main Branches

| Branch | Purpose | Protection |
|--------|---------|------------|
| `main` | Production — deployed to Netlify | Requires PR + passing CI |
| `develop` | Integration branch for features | Requires PR |

**Workflow:**
- Feature branches merge into `develop`
- `develop` merges into `main` for releases
- `hotfix/` branches cut from `main` and merge back to both `main` and `develop`

---

## Branch Lifecycle

```
main
  │
  └── develop
        │
        ├── feature/contact-form      ← branch from develop
        │     (work happens here)
        │     PR → develop            ← merge via PR
        │
        └── feature/apps-section      ← branch from develop
              ...
```

```bash
# Start a new feature
git checkout develop
git pull origin develop
git checkout -b feature/my-feature

# Keep in sync with develop during long-lived branches
git fetch origin
git rebase origin/develop

# Push and open PR
git push -u origin feature/my-feature
gh pr create --base develop
```

---

## Naming Rules

- **lowercase only** — `feature/my-feature` not `Feature/MyFeature`
- **kebab-case** — `feature/contact-form` not `feature/contactForm`
- **descriptive** — `feature/theme-toggle` not `feature/fix-thing`
- **≤ 50 characters** including the type prefix
- **No ticket number in branch name** — use the commit body instead

---

## Pull Request Rules

- **Target**: `develop` (never push directly to `main`)
- **Base**: Always cut from and target `develop` for features
- **CI must pass**: `quality.yml` (lint + format + tsc) and `tests.yml` (vitest + build)
- **Self-review**: Run the `arc-check-pr` skill before requesting review
- **Squash on merge**: Prefer squash merges to keep `develop` history linear

---

## Stale Branch Cleanup

After a PR is merged, delete the branch:

```bash
# Delete remote branch (GitHub does this automatically if auto-delete is enabled)
git push origin --delete feature/my-feature

# Delete local branch
git branch -d feature/my-feature

# Prune local references to deleted remote branches
git fetch --prune
```

---

## Worktrees for Parallel Development

Use git worktrees to work on multiple branches simultaneously without stashing:

```bash
# Create a worktree for a second feature
git worktree add ../my-project-fix bugfix/nav-overflow

# List active worktrees
git worktree list

# Remove when done
git worktree remove ../my-project-fix
```

See `arc-worktrees-workflow` skill for the full workflow.

---

## Hotfix Process

For urgent production bugs:

```bash
# Branch from main (not develop)
git checkout main
git pull origin main
git checkout -b hotfix/fix-description

# ... make fix ...
git commit -m "fix(scope): fix description"

# Merge to main
gh pr create --base main --title "hotfix: fix description"

# After merge, also merge to develop (prevent regression)
git checkout develop
git merge main
git push origin develop
```

---

## Branch Protection (GitHub Settings)

`main` branch rules:
- Require pull request before merging
- Require 1 approving review
- Dismiss stale pull request approvals when new commits are pushed
- Require status checks: `lint-format-typecheck`, `test`
- Require branches to be up to date before merging
- Do not allow bypassing the above settings

`develop` branch rules:
- Require pull request before merging
- Require status checks: `lint-format-typecheck`, `test`
