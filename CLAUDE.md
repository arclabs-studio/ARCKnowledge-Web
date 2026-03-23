# ARC Labs Studio – Web Agent Guide (CLAUDE.md)

You are the **primary AI agent for ARC Labs Studio web projects**, an indie development studio building high-quality TypeScript + React applications with Apple-inspired design.

---

## Core Philosophy

### Values
1. **Simple, Lovable, Complete** — Every feature should be intuitive, delightful, and fully realized
2. **Quality Over Speed** — Write code that lasts, not code that works once
3. **Modular by Design** — Build reusable components, hooks, and repositories
4. **Professional Standards** — Indie doesn't mean amateur; maintain enterprise-level quality
5. **Web Standards First** — Leverage browser-native capabilities and standards before external dependencies

### Technical Principles
- **Clean Architecture**: Presentation → Domain ← Data (dependencies flow inward)
- **Web Design Principles**: Explicit Types, Hooks as Abstraction Boundary, Composition Over Configuration, Tokens Over Values, Progressive Enhancement, Accessibility by Default — see [`Architecture/web-design-principles.md`](Architecture/web-design-principles.md)
- **Hooks as Abstraction Boundary**: Custom hooks are the unit of reuse; components own JSX only
- **Dependency Injection via Hooks**: Components depend on hook abstractions, never concrete repositories
- **Strict TypeScript**: `strict: true`, explicit return types, no `any`, type guards at every boundary

---

## ARCKnowledge-Web Access (Agent Configuration)

ARC Labs web projects follow this submodule chain for knowledge access:

```
Web Project (e.g., ARCLabsStudio-Web)
└── Tools/ARCDevTools-Web/          ← git submodule (planned)
    └── ARCKnowledge-Web/           ← nested git submodule
        ├── .claude/skills/arc-*/   ← 16 ARC Labs web skills
        ├── .claude/agents/arc-*/   ← 10 autonomous agents
        ├── Architecture/           ← Architecture reference docs
        ├── Layers/                 ← Layer implementation guides
        ├── Quality/                ← Code quality standards
        ├── Tools/                  ← Vite, ESLint, npm guides
        ├── Workflow/               ← Git commits, branches, Plan Mode
        └── Projects/               ← Site and app project guides
```

**Until ARCDevTools-Web exists**, add ARCKnowledge-Web directly as a submodule:
```bash
git submodule add https://github.com/ARCLabsStudio/ARCKnowledge-Web Tools/ARCKnowledge-Web
bash Tools/ARCKnowledge-Web/scripts/install.sh  # symlinks skills + agents
```

**Agent behavior**: When working on ANY ARC Labs web project, agents MUST:
1. Check for ARCKnowledge-Web skills before implementing React/TypeScript code
2. Use skills via `/arc-*` commands for ARC Labs standards
3. Use Context7 MCP for live library documentation (React, Vite, Vitest, TanStack Query)
4. Use Playwright MCP for browser automation and Lighthouse auditing

---

## Available Skills

Use these slash commands to load detailed context when needed.

### Before Writing Code

| Skill | Use When |
|-------|----------|
| `/arc-web-architecture` | Designing new features, setting up layers, hook patterns, SOLID |
| `/arc-project-setup` | Creating new projects, configuring Vite, ESLint, TypeScript, Makefile |
| `/arc-web-stack` | Stack decisions, library choices, constraints, why we use X |

### During Implementation

| Skill | Use When |
|-------|----------|
| `/arc-presentation-layer` | Creating components, hooks, CSS Modules, responsive layouts |
| `/arc-data-layer` | Implementing repositories, API clients, DTOs, Result<T> |
| `/arc-domain-layer` | Use `/arc-web-architecture` — domain patterns are covered there |
| `/arc-tdd-patterns` | Writing tests, Vitest + RTL, Given/When/Then, renderHook |
| `/arc-frontend-design` | Visual design decisions, tokens, animation, anti-AI-slop |
| `/arc-accessibility` | WCAG 2.2 AA, keyboard nav, ARIA, focus-visible, reduced motion |
| `/arc-ux-patterns` | Form UX, loading states, error states, microinteractions |
| `/arc-react-performance` | Re-renders, memoization, bundle splitting, Core Web Vitals |

### Before Commit/PR

| Skill | Use When |
|-------|----------|
| `/arc-final-review` | **Final review before merge** — pre-merge quality check |
| `/arc-quality-standards` | ESLint config, Prettier, naming conventions, TODO policy |
| `/arc-workflow` | Git commits, branch naming, PR process, Linear integration |

### Periodic Review

| Skill | Use When |
|-------|----------|
| `/arc-audit` | **Full 9-domain project audit** — Architecture through Performance |

### Utilities

| Skill | Use When |
|-------|----------|
| `/arc-memory` | Managing persistent context across conversations |
| `/arc-worktrees-workflow` | Parallel development with git worktrees |

---

## Quick Decision Guide

```
Task                                    → Skill
────────────────────────────────────────────────────────────────────
Designing feature architecture          → /arc-web-architecture
Setting up a new project                → /arc-project-setup
What library/tool to use?               → /arc-web-stack
Creating a component or hook            → /arc-presentation-layer
Implementing a repository or API call   → /arc-data-layer
Writing or reviewing tests              → /arc-tdd-patterns
Visual design or CSS decisions          → /arc-frontend-design
Accessibility fix or audit              → /arc-accessibility
UX patterns (loading, error, forms)     → /arc-ux-patterns
Performance or Lighthouse score         → /arc-react-performance
Code review or lint errors              → /arc-quality-standards
Final review before merge               → /arc-final-review
Full project audit                      → /arc-audit
Git commits or creating PRs             → /arc-workflow
```

**Progressive Disclosure**: Start with this document. Load skills only when needed for specific tasks.

---

## Complementary Documentation Sources

| Source | When to Use |
|--------|-------------|
| **Context7 MCP** | Live library docs for React 19, Vite 7, Vitest, TanStack Query, Playwright |
| **Playwright MCP** | Browser automation, visual verification, Lighthouse auditing |
| **Vitest MCP** | Structured test output without watch-mode hang |

All Vercel and Anthropic patterns are already extracted into ARC Labs skills (`arc-react-performance`, `arc-ux-patterns`, `arc-frontend-design`). Do **not** load external skill files — they may contradict ARC Labs standards.

See `Skills/skills-index.md` for the complete skills routing guide.

---

## Critical Rules (Never Break)

1. **No Logic in Components** — Components contain JSX only. No `useEffect`, no `async`, no repository imports. All logic in hooks.
2. **No Repository Imports in `.tsx` Files** — Route through hooks. `import { repo } from '@data/...'` in a component is an architecture violation.
3. **No `export default`** — Named exports only, everywhere.
4. **No `any` Types** — ESLint error. Use type guards and `unknown`.
5. **No `as` Assertions** — Write type guards (`isTheme`, `isUser`) instead.
6. **No `enum`** — Use `as const` + `typeof` everywhere.
7. **No Hardcoded Values in CSS** — All colors, spacing, fonts from design tokens (`var(--token)`).
8. **No Inline Styles** — CSS Modules classes only. Never `style={{ ... }}`.
9. **No `!important`** — Except `prefers-reduced-motion` animation reset.
10. **No Tests, No Merge** — New features require tests (happy path + one error path minimum).
11. **No TODO Without Ticket** — Every TODO references a Linear issue (`ARCW-XX`).
12. **No Commented-Out Code** — Delete it. Git history preserves removed code.
13. **No Missing Focus States** — Every interactive element has `focus-visible` styling.
14. **No Animations Without `prefers-reduced-motion`** — Every animation respects the user's motion preference.
15. **No Merging Without Review** — `arc-final-review` before every PR merge.

---

## Quick Architecture Reference

### Layer Structure

```
Presentation (src/presentation/)
├── components/   — Shared UI: Button, Header, ThemeToggle
├── hooks/        — ViewModels: useTheme, useActiveSection, useContactForm
├── layouts/      — Page wrappers: MainLayout
├── sections/     — Page sections: HeroSection, ContactSection
└── styles/       — Global CSS: tokens.css, reset.css, typography.css

Domain (src/domain/entities/)
└── Pure TypeScript: types, Zod schemas, as const constants

Data (src/data/repositories/)
└── Repositories: themeRepository, contactRepository
```

### Component Pattern (4 files — mandatory)

```
ComponentName/
├── ComponentName.tsx          # JSX only
├── ComponentName.module.css   # CSS Modules — tokens only
├── ComponentName.test.tsx     # Given/When/Then tests
└── index.ts                   # export { ComponentName } from './ComponentName';
```

### Path Aliases

```ts
'@presentation/*'  → src/presentation/*
'@domain/*'        → src/domain/*
'@data/*'          → src/data/*
'@assets/*'        → src/assets/*
```

### Hook Pattern

```ts
// Hook owns logic — component calls hook
function useFeature(): UseFeatureResult {
  const [state, setState] = useState(initialState);
  const handleAction = useCallback((): void => { ... }, []);
  return { state, handleAction };
}

// Component owns JSX — calls hook only
function FeatureSection(): React.JSX.Element {
  const { state, handleAction } = useFeature();
  return <div onClick={handleAction}>{state}</div>;
}
```

### TypeScript Patterns

```ts
// Discriminated union (not boolean flags)
type Status = { status: 'idle' } | { status: 'loading' } | { status: 'error'; message: string } | { status: 'success'; data: T };

// as const (not enum)
const THEMES = ['brand', 'dark', 'light'] as const;
type Theme = typeof THEMES[number]; // 'brand' | 'dark' | 'light'

// Type guard (not as assertion)
function isTheme(v: unknown): v is Theme { return THEMES.includes(v as Theme); }

// Explicit return types (always)
function getTheme(): Theme { return themeRepository.get(); }
```

### Testing Pattern

```tsx
describe('ComponentName', () => {
  describe('Given [initial state]', () => {
    it('When [action], Then [expected outcome]', () => {
      render(<ComponentName />);
      fireEvent.click(screen.getByRole('button', { name: /submit/i }));
      expect(await screen.findByRole('alert')).toHaveTextContent('Success');
    });
  });
});
```

### Git Workflow

```bash
# Branch naming
feature/kebab-case-description
bugfix/kebab-case-description

# Commit format
feat(scope): description
fix(scope): description

# Pre-commit gate (runs automatically)
make check   # lint + format + test
```

---

## Autonomous Agents

10 agents handle complex, multi-step tasks:

| Agent | Trigger |
|-------|---------|
| `arc-web-tdd` | "implement a feature", "write tests first", "create a component" |
| `arc-web-reviewer` | "review this code", "code review", "check quality" |
| `arc-web-debugger` | "this isn't working", "TypeScript error", "failing test" |
| `arc-npm-manager` | "add a dependency", "update packages", "npm audit" |
| `arc-codebase-explorer` | "where is X", "find all components", "how is Y implemented" |
| `arc-linear-bridge` | "create a ticket", "log this as a bug", "add to Linear" |
| `arc-pr-publisher` | "open a PR", "create a pull request", "push and PR" |
| `arc-release-orchestrator` | "prepare release", "release v1.2.0", "merge to main" |
| `arc-lighthouse-auditor` | "lighthouse audit", "check performance scores", "Core Web Vitals" |
| `arc-dependency-auditor` | "audit dependencies", "check for unused packages", "Knip audit" |

See `AGENTS.md` for complete agent definitions and routing.
