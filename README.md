# ARCKnowledge-Web

Skills, agents, and standards for ARC Labs Studio web projects.

---

## Overview

ARCKnowledge-Web is a documentation-only knowledge base. It provides Claude Code skills, autonomous agents, architectural standards, and a visual design system that are symlinked into downstream TypeScript + React projects. It is not a runnable application — there is no `package.json` or build step.

Downstream projects install it as a git submodule and run `scripts/install.sh` to wire it up.

---

## What's Inside

| Contents | Count | Description |
|----------|-------|-------------|
| Claude Code skills | 16 | `/arc-*` slash commands for architecture, testing, design, accessibility, and more |
| Autonomous agents | 10 | Haiku/Sonnet agents for TDD, debugging, PR publishing, Lighthouse audits, and more |
| Knowledge base docs | 26 | Architecture, Layers, Projects, Quality, Tools, Workflow |
| Visual design system | 1 | `DESIGN.md` — Google Stitch format, 9 sections |
| MCP configuration | 1 | `.mcp.json` — Context7, Playwright, Vitest |
| GitHub Actions | 2 | `@claude` mention handler, auto PR review |

---

## Installation

### As a git submodule (primary)

Run from the downstream project root:

```bash
git submodule add https://github.com/ARCLabsStudio/ARCKnowledge-Web Tools/ARCKnowledge-Web
git submodule update --init --recursive
bash Tools/ARCKnowledge-Web/scripts/install.sh
```

`install.sh` will:
- Symlink all 16 `arc-*` skill directories into `.claude/skills/`
- Symlink all 10 `arc-*.md` agent files into `.claude/agents/`
- Symlink `DESIGN.md` to the project root
- Copy `.mcp.json` if not already present
- Update `.gitignore` to exclude the symlinked files

### Custom submodule path

If ARCKnowledge-Web is nested inside another submodule (e.g., `Tools/ARCDevTools-Web/ARCKnowledge-Web`):

```bash
ARCKNOWLEDGE_WEB_PATH=Tools/ARCDevTools-Web/ARCKnowledge-Web bash scripts/install.sh
```

---

## Repository Structure

```
ARCKnowledge-Web/
├── .claude/
│   ├── skills/arc-*/          16 Claude Code skill definitions
│   └── agents/arc-*.md        10 autonomous agent definitions
├── Architecture/              Clean architecture, React patterns, SOLID, TypeScript, error handling
├── Layers/                    Presentation, Domain, Data layer implementation guides
├── Projects/                  Site and app project guides, marketing positioning
├── Quality/                   Code style, testing, accessibility, design tokens, code review
├── Tools/                     Vite, ESLint, npm, ARCDevTools-Web
├── Workflow/                  Git commits, branches, Plan Mode
├── Skills/
│   └── skills-index.md        Complete task → skill routing guide
├── scripts/
│   └── install.sh             Downstream project installer
├── CLAUDE.md                  AI agent guide — skills, rules, architecture reference
├── AGENTS.md                  Agent roster and routing
├── DESIGN.md                  Visual design system (Google Stitch format)
├── CHANGELOG.md               Version history
└── LICENSE                    MIT
```

---

## Skills

16 skills available via `/arc-*` slash commands. See [`Skills/skills-index.md`](Skills/skills-index.md) for full routing.

| Skill | Description |
|-------|-------------|
| `arc-web-architecture` | Clean Architecture, React patterns, SOLID, TypeScript, error handling |
| `arc-project-setup` | New project setup — Vite, ESLint, TypeScript, Makefile, git hooks |
| `arc-web-stack` | Approved stack, rejected packages, library decision guide |
| `arc-presentation-layer` | Components (JSX only), CSS Modules, hooks as ViewModels |
| `arc-data-layer` | Repository pattern, localStorage, API clients, DTOs, `Result<T>` |
| `arc-tdd-patterns` | Vitest + RTL, Given/When/Then, `renderHook`, async testing |
| `arc-frontend-design` | Brand aesthetic, design tokens, animation, anti-AI-slop rules |
| `arc-accessibility` | WCAG 2.2 AA, `focus-visible`, skip link, ARIA, reduced motion |
| `arc-react-performance` | Re-renders, `useMemo`, code splitting, Core Web Vitals, bundles |
| `arc-ux-patterns` | Form UX, loading/error/empty states, microinteractions |
| `arc-quality-standards` | ESLint 9, Prettier, naming conventions, TODO policy, Knip |
| `arc-workflow` | Conventional Commits, branch naming, PR process, Linear integration |
| `arc-audit` | 9-domain project audit (A–F grading, severity levels) |
| `arc-final-review` | Pre-merge checklist — automated and manual verification |
| `arc-memory` | Persistent context management across conversations |
| `arc-worktrees-workflow` | Git worktrees for parallel branch development |

---

## Agents

10 autonomous agents auto-discovered by Claude Code from `.claude/agents/`. See [`AGENTS.md`](AGENTS.md) for full definitions.

| Agent | Model | Trigger |
|-------|-------|---------|
| `arc-web-tdd` | Sonnet | "implement a feature", "write tests first", "create a component" |
| `arc-web-reviewer` | Sonnet | "review this code", "code review", "check quality" |
| `arc-web-debugger` | Sonnet | "this isn't working", "TypeScript error", "failing test" |
| `arc-npm-manager` | Haiku | "add a dependency", "update packages", "npm audit" |
| `arc-codebase-explorer` | Haiku | "where is X", "find all components", "how is Y implemented" |
| `arc-linear-bridge` | Haiku | "create a ticket", "log this as a bug", "add to Linear" |
| `arc-pr-publisher` | Sonnet | "open a PR", "create a pull request", "push and PR" |
| `arc-release-orchestrator` | Sonnet | "prepare release", "release v1.x.x", "merge to main" |
| `arc-lighthouse-auditor` | Sonnet | "lighthouse audit", "check performance", "Core Web Vitals" |
| `arc-dependency-auditor` | Haiku | "audit dependencies", "check for unused packages", "Knip audit" |

---

## Key Documents

| Document | Description |
|----------|-------------|
| [`CLAUDE.md`](CLAUDE.md) | Primary AI agent guide — philosophy, skills, rules, architecture reference, installation |
| [`AGENTS.md`](AGENTS.md) | Agent roster — models, triggers, skills used, tools, design principles |
| [`DESIGN.md`](DESIGN.md) | Visual design system — color, typography, components, layout, responsive (Google Stitch format) |
| [`Skills/skills-index.md`](Skills/skills-index.md) | Complete task → skill routing, MCP sources, common workflow scenarios |

---

## License

MIT — see [LICENSE](LICENSE).
