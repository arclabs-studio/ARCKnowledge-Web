# Agents — ARC Labs Studio Web

10 autonomous agents for ARC Labs Studio web projects. Agents handle complex, multi-step tasks that benefit from autonomy and focused context.

---

## Agent Roster

### arc-web-tdd
**Model**: claude-sonnet-4-6 | **Read-only**: No

Implements features using strict Test-Driven Development. Writes Vitest + RTL tests BEFORE production code, following ARC Labs Clean Architecture.

**Triggers**: "implement a feature", "write tests first", "create a component", "add a hook", "add a repository"

**Skills**: `arc-tdd-patterns`, `arc-web-architecture`, `arc-presentation-layer`, `arc-data-layer`, `arc-frontend-design`, `arc-accessibility`

**Tools**: Read, Glob, Grep, Write, Edit, Bash, Skill, mcp__context7__*

---

### arc-web-reviewer
**Model**: claude-sonnet-4-6 | **Read-only**: Yes

Reviews changed code against all 8 ARC Labs checklist domains. Produces a graded report with actionable fixes and a final verdict (APPROVED / CHANGES REQUESTED / BLOCKED).

**Triggers**: "review this code", "review PR", "check quality", "code review", "audit code"

**Skills**: `arc-audit`, `arc-quality-standards`, `arc-accessibility`

**Tools**: Read, Glob, Grep, Skill

---

### arc-web-debugger
**Model**: claude-sonnet-4-6 | **Read-only**: No

Diagnoses and fixes bugs. Always understands root cause before making any change. Never uses `@ts-ignore`, `eslint-disable`, or `as any` workarounds.

**Triggers**: "this isn't working", "something broken", "TypeScript error", "ESLint error", "failing test", "CSS not applying", "hook not updating"

**Skills**: `arc-web-architecture`, `arc-quality-standards`, `arc-tdd-patterns`

**Tools**: Read, Glob, Grep, Write, Edit, Bash, Skill, mcp__context7__*

---

### arc-npm-manager
**Model**: claude-haiku-4-5 | **Read-only**: No

Manages npm dependencies. Validates every package against the approved stack before installing. Enforces the ESLint 9.x pin and rejected package list.

**Triggers**: "add a dependency", "update packages", "remove a package", "npm audit", "package conflicts"

**Skills**: `arc-web-stack`

**Tools**: Read, Glob, Grep, Bash, Skill

---

### arc-codebase-explorer
**Model**: claude-haiku-4-5 | **Read-only**: Yes

Maps the codebase structure, finds files by pattern, and answers structural questions. Flags architecture violations found while exploring.

**Triggers**: "where is X", "find all components", "what hooks exist", "how is Y implemented", "find the repository for X"

**Skills**: `arc-web-architecture`

**Tools**: Read, Glob, Grep, Skill

---

### arc-linear-bridge
**Model**: claude-haiku-4-5 | **Read-only**: No

Creates and updates Linear tickets from development context. Uses structured templates for features, bugs, and chores. Returns ticket IDs for use in commit messages.

**Triggers**: "create a ticket", "log this as a bug", "add to Linear", "update ticket status", "create an issue for"

**Skills**: none

**Tools**: Bash, mcp__claude_ai_Linear__*, mcp__ARC_Linear_GitHub__linear_*

---

### arc-pr-publisher
**Model**: claude-sonnet-4-6 | **Read-only**: No

Prepares and publishes pull requests. Runs final quality checks, invokes arc-final-review, creates the PR with structured description targeting `develop`.

**Triggers**: "open a PR", "create a pull request", "push and PR", "submit for review"

**Skills**: `arc-final-review`, `arc-workflow`

**Tools**: Read, Glob, Grep, Bash, Skill, mcp__ARC_Linear_GitHub__github_*

---

### arc-release-orchestrator
**Model**: claude-sonnet-4-6 | **Read-only**: No

Orchestrates the full release process: quality gate, Lighthouse audit, CHANGELOG update, develop → main merge, git tag, GitHub release. Always asks for explicit confirmation before merging to main.

**Triggers**: "prepare release", "release v1.2.0", "merge to main", "tag a release"

**Skills**: `arc-audit`, `arc-workflow`

**Tools**: Read, Glob, Grep, Write, Edit, Bash, Skill, mcp__ARC_Linear_GitHub__github_*

---

### arc-lighthouse-auditor
**Model**: claude-sonnet-4-6 | **Read-only**: Yes

Audits the production build for Performance, Accessibility, Best Practices, and SEO using Playwright + Lighthouse. Produces a scored report with prioritized fixes.

**Triggers**: "lighthouse audit", "check performance", "check scores", "Core Web Vitals", "accessibility score", "SEO audit"

**Skills**: `arc-react-performance`, `arc-accessibility`

**Tools**: Read, Glob, Grep, Bash, Skill, mcp__playwright__*

---

### arc-dependency-auditor
**Model**: claude-haiku-4-5 | **Read-only**: Yes

Audits npm security (npm audit), dead code (Knip), bundle size, and stack compliance. Produces a report with prioritized fixes.

**Triggers**: "audit dependencies", "check for unused packages", "dead code", "unused exports", "check security vulnerabilities", "Knip audit"

**Skills**: `arc-web-stack`

**Tools**: Read, Glob, Grep, Bash, Skill

---

## Agent × Skills × MCPs Matrix

| Agent | Primary Skills | MCPs |
|-------|---------------|------|
| `arc-web-tdd` | tdd-patterns, presentation-layer, data-layer | context7 |
| `arc-web-reviewer` | arc-audit, quality-standards | — |
| `arc-web-debugger` | web-architecture, quality-standards | context7 |
| `arc-npm-manager` | web-stack | — |
| `arc-codebase-explorer` | web-architecture | — |
| `arc-linear-bridge` | — | linear |
| `arc-pr-publisher` | final-review, workflow | github |
| `arc-release-orchestrator` | arc-audit, workflow | github |
| `arc-lighthouse-auditor` | react-performance, accessibility | playwright |
| `arc-dependency-auditor` | web-stack | — |

---

## Agent Design Principles

1. **Single concern** — Each agent owns one workflow, not many
2. **Skills first** — Agents invoke skills for domain knowledge; they don't re-implement it
3. **Read-only where possible** — Reviewer, Explorer, Lighthouse, Dependency Auditor never write code
4. **Confirm before irreversible actions** — PR Publisher and Release Orchestrator confirm before pushing or merging
5. **Model fit** — Haiku for focused research/management; Sonnet for complex reasoning and code generation

---

## Installation

Agents are symlinked into downstream projects via `scripts/install.sh`. After installation:

```bash
.claude/agents/
├── arc-codebase-explorer.md    ← symlink
├── arc-dependency-auditor.md   ← symlink
├── arc-lighthouse-auditor.md   ← symlink
├── arc-linear-bridge.md        ← symlink
├── arc-npm-manager.md          ← symlink
├── arc-pr-publisher.md         ← symlink
├── arc-release-orchestrator.md ← symlink
├── arc-web-debugger.md         ← symlink
├── arc-web-reviewer.md         ← symlink
└── arc-web-tdd.md              ← symlink
```

Agents are automatically discovered by Claude Code from `.claude/agents/`.
