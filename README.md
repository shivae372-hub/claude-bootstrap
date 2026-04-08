# claude-bootstrap

> Generate a professional Claude Code setup for any project in minutes.

Claude Code is powerful — but most users are losing 60% of its value to poor configuration, token waste, and generic prompts.

`claude-bootstrap` reads your project and generates a fully custom Claude Code setup: sub-agents, skills, hooks, CLAUDE.md, and session continuity — tailored to your exact stack and how you work.

## What Gets Generated

| Component | What it does |
|-----------|-------------|
| **CLAUDE.md** | Project context file — tells Claude your stack, rules, and workflow |
| **Sub-agents** | Isolated explorers and specialists that don't burn your main context |
| **Skills** | On-demand instruction sets for common workflows (`/test`, `/review`, `/deploy`) |
| **Hooks** | Shell scripts that auto-format, block dangerous commands, and checkpoint sessions |
| **SESSION_STATE.md** | Session continuity — Claude resumes exactly where you left off |

## Quick Start

```bash
# From your project root:
git clone https://github.com/shivae372-hub/claude-bootstrap
bash claude-bootstrap/scripts/bootstrap.sh
```

That's it. The script detects your stack, asks 6 quick questions, and generates everything.

## Who This Is For

| You are... | What you get |
|------------|-------------|
| **Developer** (tech level 4-5) | Full agent set, TDD workflow, code review, security scan, git hooks |
| **Founder / Designer** (tech level 2-3) | Simplified agents, plain-language hooks, product advisor, launch planner |
| **Non-technical** (tech level 1-2) | No agents, plain-English skills, content writer, data analyst |

## Supported Stacks

Detection is automatic. Supported out of the box:

- **Next.js** / React / Node.js
- **Python** (Django, FastAPI, Flask)
- **Go** (Gin, Echo, Fiber, Chi)
- **Rust** (Axum, Actix, Rocket)
- **Ruby** (Rails, Sinatra)
- **Java** (Spring Boot, Quarkus)
- **Monorepos** (Turborepo, Nx)
- **No stack** (scripts, docs, data projects)

## What the Setup Achieves

**Before bootstrap:**
- Claude reads entire files to answer simple questions (expensive)
- No memory between sessions — re-explain the project every time
- Dangerous commands run without guardrails
- Generic prompts get generic results

**After bootstrap:**
- Sub-agents handle exploration — main context stays clean
- SESSION_STATE.md lets Claude resume without re-explaining
- Hooks block destructive commands before they run
- Skills give Claude precise instructions for your specific workflow

## How It Works

```
bootstrap.sh
    │
    ├── 1. Onboarding (6 questions → USER_PROFILE.json)
    ├── 2. Project detection (detect-project.py → stack, language, tools)
    ├── 3. Template selection (based on generation_tier)
    ├── 4. Blueprint (JSON preview — you confirm before any files written)
    ├── 5. File generation (CLAUDE.md, agents, skills, hooks)
    ├── 6. Validation (validate.sh — checks all required fields)
    └── 7. Summary (what was created and why)
```

## After Bootstrap

```bash
# Start Claude Code in your project
claude

# Available skills (type in Claude Code)
/plan       # Break a feature into tasks
/test       # Run test suite
/review     # Code review current diff
/deploy     # Deploy to your configured target
/security   # Security audit
/tips       # Personalized tips for your setup
/update     # Check for bootstrap updates
```

## Manual Onboarding

If you want to set up your profile before bootstrapping:

```bash
# Run just the onboarding (no files written yet)
claude --print "Run the onboarding skill: Skill('onboarding')"
```

Or answer the 6 questions manually and write `USER_PROFILE.json`:

```json
{
  "role_type": "developer",
  "tech_level": 4,
  "team_size": "small",
  "domain": "software",
  "primary_goals": ["ship faster", "save tokens"],
  "success_in_30_days": "deploy v2"
}
```

Then run `bash claude-bootstrap/scripts/bootstrap.sh` — it will skip onboarding and go straight to generation.

## Updating Your Setup

Your bootstrap version is tracked in `USER_PROFILE.json`. To check for updates:

```bash
claude --print "Skill('self-update')"
```

## File Reference

```
claude-bootstrap/
├── CLAUDE.md                          # Orchestrator instructions (this file)
├── SESSION_STATE.md                   # Session continuity template
├── scripts/
│   ├── bootstrap.sh                   # Main entry point
│   ├── validate.sh                    # Setup validator
│   └── format.sh                      # Multi-language code formatter
├── docs/
│   ├── FORMATS.md                     # File format specifications
│   ├── tips.json                      # 30 contextual tips
│   ├── stacks/                        # Stack-specific configurations
│   │   ├── nextjs.md
│   │   ├── python.md
│   │   ├── go.md
│   │   ├── rust.md
│   │   ├── ruby.md
│   │   ├── java.md
│   │   ├── monorepo.md
│   │   └── no-stack.md
│   └── templates/                     # Tier-specific templates
│       ├── developer/
│       ├── hybrid/
│       ├── non-dev/
│       └── agents/                    # Reusable agent templates
└── .claude/
    ├── skills/
    │   ├── onboarding/                # First-run setup
    │   ├── analyze-repo/              # Codebase analysis
    │   ├── code-review/               # PR review
    │   ├── context-guard/             # Token budget protection
    │   ├── dep-check/                 # Dependency audit
    │   ├── git-workflow/              # Git conventions
    │   ├── security-scan/             # Security audit
    │   ├── self-update/               # Bootstrap updates
    │   ├── test-runner/               # Test suite runner
    │   └── tips/                      # Contextual tips
    └── hooks/
        └── checkpoint.sh              # Session state + drift detection
```

## Contributing

Adding a new stack template:
1. Create `docs/stacks/<name>.md` — see [docs/FORMATS.md](docs/FORMATS.md) for the schema
2. Add detection logic to `.claude/skills/onboarding/scripts/detect-project.py`
3. Test: `python3 .claude/skills/onboarding/scripts/detect-project.py --target <sample-project>`

Adding a new agent template:
1. Create `docs/templates/agents/<name>.md` with YAML frontmatter
2. Reference it in the appropriate tier's `agents.md`

## License

Apache 2.0 — See [LICENSE](LICENSE) for details.

Patent protection is provided under the Apache 2.0 patent grant. Contributors grant users a perpetual, worldwide, non-exclusive, no-charge, royalty-free, irrevocable patent license.
