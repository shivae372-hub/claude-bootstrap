# Developer Tier — Agent Set

These agents are generated for developer-tier users. Each is scoped to specific tools.

## explore (Haiku)
**Job:** Read-only codebase exploration. Never writes files.
**Tools:** Read, Glob, Grep, LS
**When dispatched:** Any time Claude needs to understand the codebase before acting.
**Output format:** Structured JSON summary — never raw file dumps.

```yaml
name: explore
description: Read-only codebase exploration agent. Searches files, maps architecture, answers questions about the codebase. Returns structured summaries, never raw content.
model: claude-haiku-4-5-20251001
tools:
  - Read
  - Glob
  - Grep
  - LS
```

## test-runner (Haiku)
**Job:** Runs the test suite and reports results.
**Tools:** Bash (restricted to test commands only)
**When dispatched:** Before committing, after making changes to tested code.
**Output format:** PASS/FAIL per test, total count, failure details.

```yaml
name: test-runner
description: Runs the project test suite and returns a structured pass/fail report. Only executes test commands — never modifies files.
model: claude-haiku-4-5-20251001
tools:
  - Bash
```

## code-reviewer (Sonnet)
**Job:** Reviews staged diffs for bugs, security issues, and style.
**Tools:** Read, Glob, Grep, Bash (git diff only)
**When dispatched:** Before committing or opening a PR.
**Output format:** Findings by severity (CRITICAL / HIGH / MEDIUM / INFO).

```yaml
name: code-reviewer
description: Reviews git diffs and recent changes for bugs, security vulnerabilities, and code quality issues. Returns findings by severity level.
model: claude-sonnet-4-6
tools:
  - Read
  - Glob
  - Grep
  - Bash
```

## task-planner (Sonnet)
**Job:** Breaks features and bugs into atomic, ordered subtasks.
**Tools:** Read, TodoWrite
**When dispatched:** At the start of any multi-step feature or bugfix.
**Output format:** Numbered task list with dependencies noted.

```yaml
name: task-planner
description: Breaks features and bugs into atomic, ordered subtasks. Creates a TodoWrite task list. Identifies dependencies and critical path.
model: claude-sonnet-4-6
tools:
  - Read
  - TodoWrite
```
