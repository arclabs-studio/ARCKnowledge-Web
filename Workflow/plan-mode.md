# Plan Mode — ARC Labs Studio

When to use Claude Code's Plan Mode, what to include in a plan, and how to execute it.

---

## When to Use Plan Mode

Plan Mode (Enter Plan Mode → review plan → Exit Plan Mode) is **mandatory** for:

- Implementing a new page section or major component (> 3 files)
- Refactoring a layer (touching > 5 files)
- Changing the Clean Architecture boundaries (adding/removing layers, changing aliases)
- Adding a new dependency with architectural impact (state management, routing)
- Any task where the approach is non-obvious or multiple valid paths exist

Plan Mode is **optional but recommended** for:
- Adding a feature to an existing component with side effects
- Writing a new hook that touches multiple data sources

Plan Mode is **not needed** for:
- Bug fixes in a single file
- CSS adjustments
- Adding tests to an existing component
- Documentation updates

---

## Plan Structure

A good plan for a web feature contains:

```markdown
# Plan: [Feature Name]

## Context
What problem this solves and why this approach was chosen.

## Architecture Decision
- Which layer owns this feature (Presentation / Domain / Data)
- Any new domain entities or types needed
- Repository changes required

## Files to Create
- `src/domain/entities/FeatureName.ts` — types + validators
- `src/data/repositories/featureRepository.ts` — data access
- `src/presentation/hooks/useFeatureName.ts` — ViewModel
- `src/presentation/sections/FeatureSection/FeatureSection.tsx`
- `src/presentation/sections/FeatureSection/FeatureSection.module.css`
- `src/presentation/sections/FeatureSection/FeatureSection.test.tsx`
- `src/presentation/sections/FeatureSection/index.ts`

## Files to Modify
- `src/App.tsx` — add FeatureSection
- `src/domain/entities/Navigation.ts` — add section ID

## Implementation Order
1. Domain entity + Zod schema
2. Repository
3. Hook (test-first)
4. Component + CSS Module
5. Integration in App.tsx
6. E2E test

## Tests
- Unit: hook in isolation (renderHook)
- Integration: component renders correct state on interaction
- E2E: not required for this feature

## Risks
- Any known complications or constraints
```

---

## TDD Within Plan Mode

For any feature that involves logic (hooks, repositories, domain entities), write tests **before** the implementation:

1. **Red** — Write failing tests that describe the expected behaviour
2. **Green** — Write the minimum code to make tests pass
3. **Refactor** — Improve code quality while keeping tests green

```bash
# During implementation: keep Vitest running in watch mode
npx vitest

# After each step: ensure all tests still pass
make test
```

---

## Plan Execution Checklist

After exiting Plan Mode, work through the plan in order:

- [ ] Domain entity created (pure TS, no framework imports)
- [ ] Repository created (abstracts storage/API, returns Result<T>)
- [ ] Hook test written (Given/When/Then, `renderHook`)
- [ ] Hook implementation passing tests
- [ ] Component created (JSX only, calls hook)
- [ ] CSS Module created (tokens only, mobile-first)
- [ ] Component tests written and passing
- [ ] Barrel export in `index.ts`
- [ ] Integrated into `App.tsx` or parent component
- [ ] `make check` passes (lint + format + test)
- [ ] `make build` succeeds

---

## Abandoning a Plan

If a plan's approach proves wrong mid-implementation:

1. Stop. Don't continue with a broken approach.
2. Re-enter Plan Mode and revise.
3. Document what didn't work in the revised plan's Context section.
4. Continue from the revised plan.

A revised plan is better than bad code that matches the original plan.

---

## Plan Mode and Linear

For features tracked in Linear:

1. Create the Linear issue first (or link to existing)
2. Reference the issue in the plan: `Closes ARCW-42`
3. Reference the issue in commit messages
4. The PR description includes the Linear issue link

The plan file lives in Claude Code's plan storage (`.claude/plans/`) — not committed to the repo.

---

## Quick Reference

```
User: "Add a FAQ section"
→ Plan Mode

User: "Fix the button hover color"
→ No Plan Mode needed

User: "Refactor all section components to use a new layout hook"
→ Plan Mode (touches many files)

User: "Add a test for the theme toggle"
→ No Plan Mode needed

User: "Integrate GitHub API to show live repo stats"
→ Plan Mode (new domain entity + repository + hook + component)
```
