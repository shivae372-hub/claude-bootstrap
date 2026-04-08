# {{PROJECT_NAME}} — Claude Code Setup

## Stack
{{STACK}}

## Key Commands
- **Install:** `{{INSTALL_CMD}}`
- **Dev server:** `{{DEV_CMD}}`
- **Test:** `{{TEST_CMD}}`
- **Build:** `{{BUILD_CMD}}`

## Project Structure
{{PROJECT_STRUCTURE}}

## Agents Available
- **explore** — Read-only codebase exploration (Haiku, fast)
- **test-runner** — Runs test suite, reports failures (Haiku)
- **code-reviewer** — Reviews diffs for bugs and security issues (Sonnet)
- **task-planner** — Breaks work into subtasks, tracks progress (Sonnet)

## Workflow
1. New feature → `/plan` to create a task list
2. Exploration → dispatch `explore` agent (never read whole files yourself)
3. Tests → `/test` before committing
4. Review → `/review` before opening a PR

## Hard Rules
- Never read entire files when a targeted search works
- Never run `npm install` without confirming package changes
- Always check `{{TEST_CMD}}` passes before marking work done
- Commit atomically — one logical change per commit

## Skills Available
- `/test` — Run test suite
- `/review` — Code review current diff
- `/plan` — Create task breakdown
- `/deploy` — Deploy to {{DEPLOY_TARGET}}
- `/security` — Security audit
