# Changelog

All notable changes to ARCKnowledge-Web are documented here.

Format: [Semantic Versioning](https://semver.org/) — `Added`, `Changed`, `Fixed`, `Removed`.

---

## [0.1.0] — 2026-03-23

### Added
- Initial repository structure
- 16 Claude Code skills: `arc-web-architecture`, `arc-presentation-layer`, `arc-data-layer`, `arc-tdd-patterns`, `arc-quality-standards`, `arc-web-stack`, `arc-frontend-design`, `arc-accessibility`, `arc-react-performance`, `arc-ux-patterns`, `arc-workflow`, `arc-project-setup`, `arc-audit`, `arc-final-review`, `arc-memory`, `arc-worktrees-workflow`
- 10 autonomous agents: `arc-web-tdd`, `arc-web-reviewer`, `arc-web-debugger`, `arc-npm-manager`, `arc-codebase-explorer`, `arc-linear-bridge`, `arc-pr-publisher`, `arc-release-orchestrator`, `arc-lighthouse-auditor`, `arc-dependency-auditor`
- Knowledge base: Architecture (6 docs), Layers (3 docs), Projects (2 docs), Quality (7 docs), Tools (4 docs), Workflow (3 docs)
- MCP configuration: Context7, Playwright, Vitest MCP
- `scripts/install.sh` for downstream project symlink setup
- GitHub Actions: `@claude` mention handler, auto PR review
