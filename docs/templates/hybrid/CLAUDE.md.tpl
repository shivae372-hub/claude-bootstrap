# {{PROJECT_NAME}} — Claude Code Setup

## About This Setup
You're on the **hybrid** tier — Claude is configured to work with you collaboratively. It will explain what it's doing, ask before irreversible actions, and keep things in plain language where possible.

## Your Stack
{{STACK}}

## Key Commands (Claude knows these automatically)
- Run tests: `{{TEST_CMD}}`
- Start dev server: `{{DEV_CMD}}`
- Deploy: `{{DEPLOY_CMD}}`

## How to Work With Claude

**Starting a session:**
Tell Claude what you want to accomplish today. It will create a plan and check with you before writing code.

**Reviewing changes:**
Claude will show you what it changed and why before committing. You don't need to read diffs — just approve or ask questions.

**When stuck:**
Ask Claude: "What's blocking us?" or "Walk me through what you just did."

## What Claude Will NOT Do Without Asking
- Delete files
- Push to production
- Change database schemas
- Install new dependencies

## Skills Available
- `/plan` — Break down your goal into steps
- `/review` — Check recent changes for issues
- `/deploy` — Deploy when you're ready
- `/status` — Show what's been done this session
