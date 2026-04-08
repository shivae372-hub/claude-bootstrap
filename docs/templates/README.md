# Bootstrap Templates

This directory contains tier-specific templates for the bootstrap process.

## Directory Structure

```
templates/
├── developer/          # For tech_level 4-5 or role=developer
│   ├── CLAUDE.md.tpl   # CLAUDE.md template for developer tier
│   ├── agents.md       # Agent set for developer tier
│   └── hooks.md        # Hook set for developer tier
├── hybrid/             # For founders, designers, product (tech_level 2-3)
│   ├── CLAUDE.md.tpl
│   ├── agents.md
│   └── hooks.md
├── non-dev/            # For tech_level 1-2, non-software domains
│   ├── CLAUDE.md.tpl
│   └── skills.md       # No agents for non-dev, just skills
└── agents/             # Reusable agent templates (used across tiers)
    ├── task-planner.md
    ├── product-advisor.md
    ├── launch-planner.md
    ├── content-writer.md
    ├── data-analyst.md
    └── presentation-agent.md
```

## How Templates Are Used

1. Bootstrap reads `USER_PROFILE.json` → `generation_tier`
2. Selects the matching template directory
3. Combines with stack-specific config from `docs/stacks/`
4. Fills in detected project values
5. Writes final files to the user's `.claude/` directory

## Template Variables

Templates use `{{VARIABLE}}` syntax:
- `{{PROJECT_NAME}}` — detected project name
- `{{STACK}}` — detected stack (e.g., "Next.js, Supabase, Tailwind")
- `{{LANGUAGE}}` — primary language
- `{{PACKAGE_MANAGER}}` — npm/pnpm/yarn/pip/etc.
- `{{TEST_RUNNER}}` — Jest/Pytest/Vitest/etc.
- `{{TECH_LEVEL}}` — user's tech level (1-5)
- `{{ROLE}}` — user's role
- `{{GOALS}}` — user's primary goals
