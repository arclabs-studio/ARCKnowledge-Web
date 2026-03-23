---
name: arc-memory
description: |
  Persistent memory management for ARC Labs Studio web projects. Use when
  "remember this", "save context", "project memory", "what did we decide",
  "store this decision", "update memory", or managing the `.claude/memory/`
  system across conversations.
user-invocable: true
metadata:
  author: ARC Labs Studio
  version: "1.0.0"
---

# ARC Labs Studio - Memory Management

## Instructions

### Memory System Overview

Memory is stored in `~/.claude/projects/<project-path>/memory/` as individual markdown files indexed by `MEMORY.md`.

### Memory Types

| Type | What to store | When to save |
|------|--------------|--------------|
| `user` | Developer preferences, expertise level | When learning about who you're working with |
| `feedback` | Corrections and validated approaches | When user corrects approach or confirms a non-obvious choice |
| `project` | Goals, decisions, constraints, deadlines | When learning what/why/when behind the work |
| `reference` | Where to find external information | When learning about external systems (Linear, Netlify dashboard) |

### Memory File Format

```markdown
---
name: [memory name]
description: [one-line description — used to decide relevance]
type: [user | feedback | project | reference]
---

[content]
```

For `feedback` and `project` types, lead with the fact, then:
- **Why:** The reason or motivation
- **How to apply:** When this guidance applies

### When to Save

**Always save when user:**
- Corrects your approach ("no, not that", "don't do X")
- Confirms a non-obvious choice worked ("yes, exactly")
- Shares preferences about how to work together
- Explains project context, deadlines, or constraints
- References external systems (Linear project IDs, Netlify URLs)

**Don't save:**
- Code patterns derivable from current project state
- Git history (use `git log`)
- Debugging solutions in the code
- Anything in CLAUDE.md
- Ephemeral task details

### What NOT to Save

These are already captured elsewhere:
- Clean Architecture patterns → in `arc-web-architecture` skill
- ESLint configuration → in `Tools/eslint.md`
- Component patterns → in `arc-presentation-layer` skill
- Commit message format → in `arc-workflow` skill

Only save what is **surprising, non-obvious, or project-specific**.

### MEMORY.md Format

`MEMORY.md` is an index — links only, no content:

```markdown
## User
- [user_role.md](user_role.md) — Developer expertise and preferences

## Feedback
- [feedback_testing.md](feedback_testing.md) — Real DB in tests, not mocks
- [feedback_response_style.md](feedback_response_style.md) — Terse responses, no summaries

## Project
- [project_goals.md](project_goals.md) — Current sprint focus
- [project_netlify.md](project_netlify.md) — Netlify site ID and team

## Reference
- [reference_linear.md](reference_linear.md) — Linear project ID and labels
```

Keep `MEMORY.md` under 200 lines — it loads into every conversation.

### Memory Lifecycle

- **Update** stale memories when project state changes
- **Remove** memories that are no longer accurate
- **Verify** before acting on memories — check current file state first

```
Memory says "file X exists at path Y"
→ Check if file still exists before acting
→ If stale, update or remove the memory
```

### Project Memory Templates

**Project goal:**
```markdown
---
name: project_current_focus
description: Current development phase and priority
type: project
---

Working on [feature/phase].

**Why:** [User's stated goal or constraint]

**How to apply:** [How to shape suggestions — e.g., "prioritize mobile"]
```

**Feedback:**
```markdown
---
name: feedback_[topic]
description: [One-line guidance rule]
type: feedback
---

[The rule itself — lead with the actionable instruction]

**Why:** [User's reason — an incident, preference, or constraint]

**How to apply:** [When this guidance kicks in — be specific]
```

**User:**
```markdown
---
name: user_profile
description: Developer background, expertise, and preferences
type: user
---

[Expertise level, background, what they find valuable]
[Preferred communication style]
[Domain knowledge to assume]
```
