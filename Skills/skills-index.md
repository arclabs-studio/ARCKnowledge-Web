# Skills Index — ARC Labs Studio Web

Complete routing guide for all ARC Labs web skills, agents, and documentation sources.

---

## Authoritative Source: ARC Labs Web Skills

All patterns are self-contained in ARC Labs skills. Do **not** load external skill files from Vercel, Anthropic, or other sources — they use incompatible stacks (Next.js, Tailwind, shadcn) and may contradict ARC Labs standards.

Vercel patterns → extracted into `arc-react-performance`
Vercel design guidelines → extracted into `arc-ux-patterns`
Anthropic frontend-design → merged into `arc-frontend-design`

---

## Quick Task → Skill Routing

| Task | Primary Skill | Secondary |
|------|--------------|-----------|
| Visual design system reference | `DESIGN.md` (root file) | `arc-frontend-design` |
| Designing feature architecture | `arc-web-architecture` | — |
| New project setup | `arc-project-setup` | `arc-web-stack` |
| Stack/library decisions | `arc-web-stack` | — |
| Creating component | `arc-presentation-layer` | `arc-tdd-patterns` |
| Writing a hook | `arc-presentation-layer` | `arc-web-architecture` |
| CSS Modules styling | `arc-presentation-layer` | `arc-frontend-design` |
| Design tokens | `arc-frontend-design` | — |
| Repository / API call | `arc-data-layer` | `arc-web-architecture` |
| Domain types / Zod | `arc-web-architecture` | — |
| Writing tests (Vitest + RTL) | `arc-tdd-patterns` | — |
| Accessibility (WCAG) | `arc-accessibility` | — |
| UX patterns | `arc-ux-patterns` | — |
| Performance (Lighthouse) | `arc-react-performance` | — |
| Pre-commit / lint | `arc-quality-standards` | — |
| Final PR review | `arc-final-review` | `arc-quality-standards` |
| Full project audit | `arc-audit` | — |
| Git commits / branches | `arc-workflow` | — |
| Plan Mode | `arc-workflow` | — |
| Memory management | `arc-memory` | — |
| Parallel development | `arc-worktrees-workflow` | — |

---

## All 16 Skills

| Skill | Description |
|-------|-------------|
| `arc-web-architecture` | Clean Architecture, React patterns, SOLID, TypeScript, error handling |
| `arc-presentation-layer` | Components (JSX only), CSS Modules, hooks as ViewModels |
| `arc-data-layer` | Repository pattern, localStorage, API clients, DTOs, Result<T> |
| `arc-tdd-patterns` | Vitest + RTL, Given/When/Then, renderHook, async testing |
| `arc-quality-standards` | ESLint 9, Prettier, naming, TODO policy, Knip |
| `arc-web-stack` | Approved stack, rejected packages, dependency checklist |
| `arc-frontend-design` | Brand aesthetic, tokens, animation, layout, anti-AI-slop |
| `arc-accessibility` | WCAG 2.2 AA, focus-visible, skip link, ARIA, reduced motion |
| `arc-react-performance` | Re-renders, useMemo, code splitting, Core Web Vitals, bundles |
| `arc-ux-patterns` | Form UX, loading/error/empty states, microinteractions |
| `arc-workflow` | Conventional Commits, branch naming, PR process, Linear |
| `arc-project-setup` | Vite config, tsconfig, Makefile, git hooks, dependencies |
| `arc-audit` | 9-domain audit (A–I), A–F grading, severity levels |
| `arc-final-review` | Pre-merge checklist, automated + manual verification |
| `arc-memory` | Persistent context management across conversations |
| `arc-worktrees-workflow` | Git worktrees for parallel branch development |

---

## All 10 Agents

| Agent | Model | Trigger |
|-------|-------|---------|
| `arc-web-tdd` | sonnet-4-6 | "implement a feature", "write tests first" |
| `arc-web-reviewer` | sonnet-4-6 | "review this code", "code review" |
| `arc-web-debugger` | sonnet-4-6 | "something broken", "TypeScript error" |
| `arc-npm-manager` | haiku-4-5 | "add a dependency", "update packages" |
| `arc-codebase-explorer` | haiku-4-5 | "where is X", "find all hooks" |
| `arc-linear-bridge` | haiku-4-5 | "create a ticket", "add to Linear" |
| `arc-pr-publisher` | sonnet-4-6 | "open a PR", "create pull request" |
| `arc-release-orchestrator` | sonnet-4-6 | "prepare release", "release v1.x.x" |
| `arc-lighthouse-auditor` | sonnet-4-6 | "lighthouse audit", "check performance" |
| `arc-dependency-auditor` | haiku-4-5 | "audit dependencies", "Knip audit" |

---

## MCP Documentation Sources

| MCP | Purpose | When to Use |
|-----|---------|-------------|
| **Context7** | Live library docs | React 19, Vite 7, Vitest, TanStack Query, react-hook-form, zod |
| **Playwright** | Browser automation | E2E tests, visual verification, Lighthouse |
| **Vitest MCP** | Structured test output | Running tests without watch-mode hang |
| **GitHub** (claude_ai) | PR + issue management | Opening PRs, reviewing issues |
| **Figma** (claude_ai) | Design-to-code | Design handoff, component review |
| **Linear** (claude_ai) | Issue management | Creating + updating tickets |
| **Netlify** (per-project) | Deploy management | Deploy status, form submissions, env vars |

**Note**: Netlify MCP is per-project. Configure with a personal access token (PAT) — not CLI OAuth — in the project's `.mcp.json`.

---

## Common Scenarios

### Starting a New Feature

1. Enter Plan Mode
2. Load `/arc-web-architecture` — design layers and files
3. Load `/arc-tdd-patterns` — write tests first
4. Invoke `arc-web-tdd` agent for TDD execution
5. Load `/arc-final-review` before PR

### Debugging a Build Failure

1. Load `/arc-quality-standards` — check lint/type errors
2. Invoke `arc-web-debugger` agent for diagnosis
3. Use Context7 MCP for library-specific docs if needed

### Pre-Release Audit

1. Invoke `arc-lighthouse-auditor` agent — Lighthouse ≥ 90
2. Invoke `arc-dependency-auditor` agent — security + dead code
3. Load `/arc-audit` — 9-domain compliance check
4. Invoke `arc-release-orchestrator` agent

### Design Implementation from Figma

1. Read `DESIGN.md` — understand ARC Labs visual language before mapping the design
2. Use Figma MCP to read the design
3. Load `/arc-frontend-design` — CSS patterns, animation, anti-AI-slop
4. Load `/arc-accessibility` — WCAG requirements for the design
5. Load `/arc-presentation-layer` — component + CSS Module structure
6. Load `/arc-tdd-patterns` — write component tests

---

## ESLint Plugin Scoping Rules

Critical: these globs must never overlap.

```
src/**/*.test.{ts,tsx}   → @vitest/eslint-plugin + eslint-plugin-testing-library
e2e/**/*.spec.{ts,tsx}   → eslint-plugin-playwright
```

Overlap causes rule conflicts (`expect` type signatures differ between Vitest and Playwright).

---

## Knowledge Base Files

| Location | Contents |
|----------|---------|
| `DESIGN.md` (root) | Complete ARC Labs visual design system — 9-section Google Stitch format |
| `CLAUDE.md` (root) | Primary agent guide — skills, rules, architecture reference |
| `AGENTS.md` (root) | Agent roster and routing |
| `Architecture/` | 6 files: web design principles, clean architecture, react patterns, SOLID, TypeScript patterns, error handling |
| `Layers/` | 3 files: presentation, domain, data |
| `Quality/` | 7 files: code style, code review, documentation, project structure, accessibility, testing, design tokens |
| `Tools/` | 4 files: vite, eslint, npm, arcdevtools-web |
| `Workflow/` | 3 files: git commits, git branches, plan mode |
| `Projects/` | 3 files: sites (SPA marketing), apps (full web apps), web-marketing-positioning |
