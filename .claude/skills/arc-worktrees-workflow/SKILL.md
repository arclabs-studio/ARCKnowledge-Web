---
name: arc-worktrees-workflow
description: |
  Git worktrees workflow for parallel development in ARC Labs Studio web projects.
  Use when "worktree", "work on two features simultaneously", "parallel branches",
  "switch branches without stashing", "multiple working directories", or
  "arc-create-worktree".
user-invocable: true
metadata:
  author: ARC Labs Studio
  version: "1.0.0"
---

# ARC Labs Studio - Worktrees Workflow

## Instructions

Git worktrees let you work on multiple branches simultaneously in separate directories — no stashing, no branch switching mid-work.

### Create a Worktree

```bash
# Create worktree for a new branch (branching from current)
git worktree add ../my-project-feature feature/new-feature

# Create worktree for an existing branch
git worktree add ../my-project-fix bugfix/nav-overflow

# Create worktree in a custom path
git worktree add /tmp/arc-work/feature-x feature/feature-x
```

Convention: place worktrees in a sibling directory with a suffix:
```
my-project/          ← main worktree (develop branch)
my-project-feature/  ← feature worktree (feature/new-thing)
my-project-fix/      ← fix worktree (bugfix/overflow)
```

### List Active Worktrees

```bash
git worktree list
```

Output:
```
/path/to/my-project          HEAD  [develop]
/path/to/my-project-feature  HEAD  [feature/new-feature]
/path/to/my-project-fix      HEAD  [bugfix/nav-overflow]
```

### Work in a Worktree

Each worktree is an independent working directory. Navigate to it and work normally:

```bash
cd ../my-project-feature
make dev       # Dev server runs independently
make test      # Tests run in this worktree
git add .
git commit -m "feat(scope): add feature"
git push -u origin feature/new-feature
```

**Important**: Each worktree shares the same `.git/` directory — commits in one worktree are visible in all.

### Remove a Worktree

After a branch is merged:

```bash
# From the main worktree
git worktree remove ../my-project-feature

# Force-remove if there are uncommitted changes (use with caution)
git worktree remove --force ../my-project-feature

# Prune stale worktree references
git worktree prune
```

### Worktrees and npm

Each worktree needs its own `node_modules/`:

```bash
# After creating a worktree
cd ../my-project-feature
npm install   # Install deps in this worktree
```

If you're using `node_modules` linked from the main worktree (via symlinks), be careful — different branches may have different deps.

### Worktrees and Vite Dev Server

Each worktree runs its own dev server. If `strictPort: true`, each needs a different port:

```bash
# Main worktree
VITE_PORT=5173 make dev

# Feature worktree
VITE_PORT=5174 npx vite --port 5174
```

Or override in `vite.config.ts` locally (don't commit):
```ts
server: { port: 5174, strictPort: true }
```

### Common Workflow

1. Start a new feature while keeping current work intact:
```bash
# In main worktree (develop)
git worktree add ../project-feature feature/new-thing
cd ../project-feature
npm install
make dev
```

2. Switch back to main at any time without stashing:
```bash
cd ../project    # Back to main worktree, nothing disturbed
```

3. Keep feature in sync with develop:
```bash
cd ../project-feature
git fetch origin
git rebase origin/develop
```

4. PR is merged — clean up:
```bash
cd ../project
git worktree remove ../project-feature
git branch -d feature/new-thing
git push origin --delete feature/new-thing
```

### When to Use Worktrees

**Use worktrees when:**
- Working on a long feature while needing to fix a hotfix on main
- Reviewing a PR while continuing local development
- Running two dev servers simultaneously (comparing branches)
- Experimenting with a risky refactor without disrupting stable work

**Don't need worktrees when:**
- Quick bug fix (stash works fine)
- Less than 30 minutes of context switching
- The branches don't need their own dev server

### Worktree Status Check

```bash
# See all active worktrees and their status
git worktree list --porcelain

# Check for stale worktrees
git worktree prune --dry-run
```
