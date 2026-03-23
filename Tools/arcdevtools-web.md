# ARCDevTools-Web — ARC Labs Studio

**Status: Planned (not yet implemented)**

ARCDevTools-Web is the planned distribution layer between ARC Labs web projects and ARCKnowledge-Web. It mirrors the iOS `ARCDevTools` submodule pattern.

---

## Planned Architecture

```
Web Project (e.g., ARCLabsStudio-Web)
└── Tools/ARCDevTools-Web/              ← git submodule (planned)
    ├── ARCKnowledge-Web/               ← nested git submodule
    │   ├── .claude/skills/arc-*/       ← 16 ARC skills
    │   └── .claude/agents/arc-*/       ← 10 ARC agents
    └── scripts/
        ├── install.sh                  ← symlinks skills + agents
        └── update.sh                   ← pulls latest from ARCKnowledge-Web
```

---

## Current State (Until ARCDevTools-Web Exists)

ARCKnowledge-Web is added directly as a submodule to downstream projects:

```bash
# Add ARCKnowledge-Web directly (interim approach)
git submodule add https://github.com/ARCLabsStudio/ARCKnowledge-Web Tools/ARCKnowledge-Web
git submodule update --init --recursive

# Run the install script to symlink skills and agents
bash Tools/ARCKnowledge-Web/scripts/install.sh
```

---

## What ARCDevTools-Web Will Provide

When ARCDevTools-Web is built, it will add:

1. **Shared tooling config packages**:
   - `@arclabs/eslint-config` — Published npm package with the audited ESLint 9 flat config
   - `@arclabs/tsconfig` — Base TypeScript config (strict, `noUncheckedIndexedAccess`)
   - `@arclabs/prettier-config` — Shared Prettier config

2. **Project scaffolding** (`arc-create` CLI):
   - `arc-create site my-project` — Scaffold a marketing site
   - `arc-create app my-project` — Scaffold a full web app
   - Both include Clean Architecture structure, all config files, git hooks

3. **Automated update path**:
   - `bash Tools/ARCDevTools-Web/scripts/update.sh` — Pulls latest skills, agents, and config packages

4. **CI/CD templates**:
   - Reusable GitHub Actions workflows (quality, tests, deploy)
   - Dependabot config for auto-updating config packages

---

## Transition Plan

When migrating a project from direct ARCKnowledge-Web to ARCDevTools-Web:

1. Remove the direct `ARCKnowledge-Web` submodule:
   ```bash
   git submodule deinit Tools/ARCKnowledge-Web
   git rm Tools/ARCKnowledge-Web
   ```

2. Add `ARCDevTools-Web`:
   ```bash
   git submodule add https://github.com/ARCLabsStudio/ARCDevTools-Web Tools/ARCDevTools-Web
   git submodule update --init --recursive
   bash Tools/ARCDevTools-Web/scripts/install.sh
   ```

3. Replace local ESLint/Prettier/TS configs with the published packages:
   ```bash
   npm install --save-dev @arclabs/eslint-config @arclabs/tsconfig @arclabs/prettier-config
   ```

4. Simplify `eslint.config.js`:
   ```js
   import arcConfig from '@arclabs/eslint-config';
   export default arcConfig;
   ```

---

## Design Principles

When ARCDevTools-Web is built, it should:

- **Zero config to adopt**: A new project runs one command and gets everything
- **Opt-out, not opt-in**: All rules active by default; projects disable what they need
- **Versioned**: Config packages use semantic versioning. Breaking changes require major bump
- **Transparent**: Every rule in every package is documented in ARCKnowledge-Web

---

## Tracking

This document will be updated when ARCDevTools-Web development begins. For now, reference `scripts/install.sh` in this repo for the interim setup process.
