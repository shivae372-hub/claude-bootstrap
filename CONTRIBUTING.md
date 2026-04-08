# Contributing to claude-bootstrap

This is a community project. The goal is to build the best possible automatic Claude Code setup generator, covering every major stack.

## What We Need

### Stack Templates
The highest-value contributions are stack-specific templates in `docs/stacks/`. Current gaps:
- `go.md` — Go projects
- `rust.md` — Rust/Cargo projects
- `ruby.md` — Rails projects
- `java.md` — Spring Boot projects
- `flutter.md` — Flutter/Dart projects
- `monorepo.md` — Turborepo/Nx monorepos

### Improved Agents
If you've found a better system prompt for an existing agent, submit a PR. Include:
- What was wrong with the old prompt
- What your version does better
- A before/after example

### Better Hooks
Shell scripts in `.claude/hooks/` that solve real problems. Good candidates:
- Auto-run type checking after TS file edits
- Slack/Discord notifications on task completion
- Auto-update `SESSION_STATE.md` on `Stop` event
- Git blame integration for code review context

## PR Format

```
## What
[One sentence: what you added or changed]

## Why
[What problem this solves]

## Stack
[Which stack(s) this applies to, or "universal"]

## Tested on
[OS, Claude Code version, project type you tested with]
```

## Rules

1. **No hallucination** — every feature must be based on actual Claude Code docs. Check `docs/FORMATS.md` for the format specs.
2. **Agents stay scoped** — don't create agents that do multiple unrelated jobs.
3. **Hooks must be safe** — blocking hooks (exit 2) must have a clear bypass path for legitimate use cases.
4. **CLAUDE.md stays lean** — the root CLAUDE.md must stay under 150 lines.
5. **Test before submitting** — clone the repo into a real project and run the bootstrap.

## Local Testing

```bash
# Clone into a test project
cd my-test-project
git clone https://github.com/YOUR_USERNAME/claude-bootstrap.git

# Run bootstrap
bash claude-bootstrap/scripts/bootstrap.sh

# Validate output
bash scripts/validate.sh
```
