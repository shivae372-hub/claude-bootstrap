# Hybrid Tier — Agent Set

Hybrid users get a smaller, focused agent set. Agents explain their findings in plain language.

## explore (Haiku)
**Job:** Understand the codebase before making changes.
**Tools:** Read, Glob, Grep, LS
**Output format:** Plain-language summary — what the code does, where key files are.

```yaml
name: explore
description: Explores the codebase and explains what it finds in plain language. Identifies where features live and how they connect. Returns summaries, not raw code.
model: claude-haiku-4-5-20251001
tools:
  - Read
  - Glob
  - Grep
  - LS
```

## task-planner (Sonnet)
**Job:** Turns vague goals into concrete steps. Explains trade-offs.
**Tools:** Read, TodoWrite
**Output format:** Numbered steps with plain-language explanations and time estimates.

```yaml
name: task-planner
description: Breaks down goals into concrete, ordered steps. Explains what each step involves and flags decisions the user needs to make. Written for non-engineers to understand.
model: claude-sonnet-4-6
tools:
  - Read
  - TodoWrite
```
