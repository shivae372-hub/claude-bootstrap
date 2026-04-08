# claude-bootstrap Production Upgrade — Design Spec
*Date: 2026-04-07*
*Author: Claude Sonnet 4.6 via brainstorming skill*

---

## Vision

Transform claude-bootstrap from a static template generator into a universal, self-improving, education-first system that turns anyone on the planet — developer, startup founder, HR manager, student, CEO — into a Claude Code expert from their very first session. The system must save tokens, protect context windows, produce production-grade output, and teach users what it's doing so they grow alongside it.

---

## Core Goals (Non-Negotiable)

1. **Universal** — Works for any human with any purpose, not just developers
2. **Token-efficient** — Every design decision is weighed against token cost
3. **Self-improving** — Gets smarter with every session, never stagnates
4. **Educational** — Every action narrates itself so beginners become experts
5. **Production-grade** — Output quality matches a 10-year Claude Code expert
6. **Zero friction** — A non-developer must be able to run this without help

---

## Architecture: 4 Layers

```
LAYER 1: INTAKE          → USER_PROFILE.json
LAYER 2: GENERATION      → .claude/ + CLAUDE.md + SESSION_STATE.md
LAYER 3: EVOLUTION       → Memory accumulation + self-audit
LAYER 4: EDUCATION       → Narrated output, expert explanations
```

---

## Layer 1: Intake System

### Entry Point
`CLAUDE.md` (this repo's root) triggers the intake flow when Claude reads it.
The bootstrap begins immediately — no separate script required (though `bootstrap.sh` is kept as an alternative).

### Intake Flow

#### Phase A — Project Detection (automated, no user input)
Claude scans the parent directory silently:
- Is there an existing project? (check for package.json, pyproject.toml, go.mod, Cargo.toml, Makefile, any source files)
- Is there an existing `.claude/` setup? (merge mode vs fresh mode)
- What language/framework is detectable?
- Are there any docs, README, previous code that reveal domain/purpose?

#### Phase B — Smart Questionnaire (structured, 5–8 questions max)
Driven by a new `onboarding` skill (`SKILL.md` in `.claude/skills/onboarding/`).
Questions are role-neutral and designed so a CEO or student can answer them as naturally as a developer.

The questionnaire is:
```
Q1. What is this project for? (free text — vague answers are fine)
Q2. What is your role? (multiple choice + free text fallback)
    → Developer / Designer / Founder / Manager / Researcher / Student / Other
Q3. What does success look like in 30 days? (free text)
Q4. How technical are you? (scale 1–5)
    → 1: Never coded / 5: Senior engineer
Q5. Do you work alone or with a team? (solo / small team / large org)
Q6. [CONDITIONAL — only if project detected] What do you want Claude to help you with most?
    → Write code / Review code / Generate docs / Automate tasks / All of the above
Q7. [CONDITIONAL — only if blank slate] What kind of project will you build or manage?
    → Software / Content / Data/Research / Business operations / Not sure yet
Q8. [CONDITIONAL — if answers are vague or role is non-dev] 
    Tell me more about your day-to-day work. What takes the most time?
    (This unlocks conversational mode — Claude asks follow-up questions naturally)
```

All answers are written to `USER_PROFILE.json` at the project root.

#### Phase C — Profile Synthesis
Claude reads all answers + detected project data and synthesizes a profile:

```json
{
  "name": "inferred or asked",
  "role_type": "developer|founder|manager|researcher|student|other",
  "tech_level": 1-5,
  "team_size": "solo|small|large",
  "domain": "software|content|data|ops|unknown",
  "project_detected": true|false,
  "stack": ["Next.js", "Supabase"],
  "primary_goals": ["ship features faster", "save tokens", "automate reviews"],
  "workflow_style": "autonomous|collaborative|supervised",
  "generation_tier": "developer|hybrid|non-dev"
}
```

`generation_tier` determines which template library is used in Layer 2.

---

## Layer 2: Generation Engine

### Template Library Structure
```
docs/templates/
├── tiers/
│   ├── developer.md       ← full stack: all 6 agents, all skills, all hooks
│   ├── hybrid.md          ← founder/designer: code + business agents
│   └── non-dev.md         ← ops/HR/manager: no-code agents, doc/ppt/task agents
├── stacks/
│   ├── nextjs.md          ← existing (upgrade)
│   ├── python.md          ← existing (upgrade)
│   ├── go.md              ← new
│   ├── rust.md            ← new
│   ├── ruby.md            ← new
│   ├── java.md            ← new
│   ├── monorepo.md        ← new
│   └── no-stack.md        ← new (for non-dev users)
└── agents/
    ├── universal/         ← agents that work for everyone
    │   ├── explorer.md
    │   ├── doc-writer.md
    │   └── task-planner.md  ← NEW: breaks vague goals into steps
    ├── developer/
    │   ├── code-reviewer.md
    │   ├── test-runner.md
    │   ├── security-scanner.md
    │   └── dep-checker.md
    ├── founder/
    │   ├── product-advisor.md  ← NEW: reviews decisions, not code
    │   └── launch-planner.md   ← NEW: ship checklists, pre-launch audits
    └── non-dev/
        ├── content-writer.md   ← NEW: drafts, edits, formats documents
        ├── data-analyst.md     ← NEW: reads CSVs, summarizes, charts
        └── presentation-agent.md ← NEW: builds slide decks from brand data
```

### Generation Rules
- Max 6 agents per generated setup (hard limit from CLAUDE.md rules)
- Universal agents always included (explorer + doc-writer + task-planner)
- Remaining 3 slots filled by tier-specific agents
- Skills selected based on role_type + detected stack
- Hooks always include: safety-check, secret-detector, checkpoint, notify
- Additional hooks added based on stack (e.g., type-checker for TS, lint for Python)

### Education Layer in Generated Files
Every generated agent file includes a `## Why This Exists` section:
```markdown
## Why This Exists
This agent runs in an isolated context window so it never uses your main
session's token budget. Every time you ask it to search the codebase,
you save ~2,000–10,000 tokens compared to doing it in the main session.
```

Every generated skill includes a `## What This Saves You` section:
```markdown
## What This Saves You
Without this skill, you'd have to manually remember the commit format,
check for secrets, and write the PR description from scratch every time.
This skill does all three in one command.
```

---

## Layer 3: Evolution System

### Session Memory Accumulation
All memory-bearing agents (`memory: user`) write to a shared `MEMORY.md` after each session. The explorer agent accumulates:
- Files discovered and their purpose
- Patterns and conventions observed
- Recent changes it noticed

The code-reviewer agent accumulates:
- Recurring bugs found in this codebase
- Files that need extra attention
- Patterns done well (so it doesn't re-flag them)

### Self-Update Skill
New skill: `.claude/skills/self-update/SKILL.md`

Triggers: user says "update my setup", "my project changed", or Claude detects major drift (new language added, new directory structure, 50+ files changed since last update).

Steps:
1. Re-read `USER_PROFILE.json`
2. Scan current project state (via explorer agent)
3. Diff current `.claude/` against what would be generated fresh today
4. Report gaps: "You added a Python ML module but have no data-analyst agent. Want me to add one?"
5. Apply approved changes

### Project Drift Detection
The `checkpoint.sh` hook is upgraded to also:
- Count files changed since last checkpoint
- Detect new top-level directories
- Detect new languages/frameworks in dependencies
- Write a `drift_score` to SESSION_STATE.md
- When drift_score > threshold, surface the self-update suggestion

### SESSION_STATE.md Evolution
SESSION_STATE.md gains a new `## Evolution Log` section:
```markdown
## Evolution Log
| Date | Change | Reason |
|------|--------|--------|
| 2026-04-07 | Added data-analyst agent | Python ML module detected |
| 2026-04-10 | Updated code-reviewer memory | 3 recurring auth bugs found |
```

---

## Layer 4: Education System

### The Expert Narration Pattern
Every skill, after executing, prints an `## What Just Happened` block:
```
## What Just Happened
I ran your tests using the test-runner sub-agent (not in this window) to
protect your context budget. Here's what that means:

- Your main session used ~200 tokens for this request
- Without the sub-agent, running tests + reading output would cost ~8,000 tokens
- You saved approximately 7,800 tokens this run

Over 100 sessions, that's the difference between finishing your monthly quota
in 2 days vs. using it efficiently all month.
```

### The Expert Tips System
New file: `.claude/skills/tips/SKILL.md`
A rotating set of 30 tips about Claude Code — one surfaced per session start (via analyze-repo skill). Tips escalate in sophistication as the user's session count grows (tracked in USER_PROFILE.json).

Early tips (sessions 1–5):
- "Sub-agents run in a separate window — use them for any exploration task"
- "Skills load only when invoked — they don't use tokens until you call them"

Mid tips (sessions 6–20):
- "The context-guard skill auto-activates before expensive operations"
- "Your explorer agent has memory — it gets faster as it learns your codebase"

Advanced tips (sessions 21+):
- "You can nest skills: /code-review can call /security-scan automatically"
- "Edit MEMORY.md directly to correct anything your agents learned wrong"

### Onboarding README
Generated `CLAUDE_SETUP.md` at project root (not CLAUDE.md — separate beginner guide):
- What was generated and why
- How to use each agent (with example prompts)
- How to use each skill (with exact slash commands)
- Token budget tips specific to their role
- "What to do next" checklist

---

## Files to Create / Modify

### New Files
```
CLAUDE.md                          ← rewrite (orchestrator + intake trigger)
docs/templates/tiers/developer.md
docs/templates/tiers/hybrid.md
docs/templates/tiers/non-dev.md
docs/templates/stacks/go.md
docs/templates/stacks/rust.md
docs/templates/stacks/ruby.md
docs/templates/stacks/java.md
docs/templates/stacks/monorepo.md
docs/templates/stacks/no-stack.md
docs/templates/agents/universal/task-planner.md
docs/templates/agents/founder/product-advisor.md
docs/templates/agents/founder/launch-planner.md
docs/templates/agents/non-dev/content-writer.md
docs/templates/agents/non-dev/data-analyst.md
docs/templates/agents/non-dev/presentation-agent.md
.claude/skills/onboarding/SKILL.md
.claude/skills/self-update/SKILL.md
.claude/skills/tips/SKILL.md
scripts/validate.sh                ← upgrade (validate USER_PROFILE.json too)
```

### Modified Files
```
.claude/hooks/checkpoint.sh        ← add drift detection
.claude/hooks/format.sh            ← add Java, Ruby formatters
docs/FORMATS.md                    ← document new template library
docs/stacks/nextjs.md              ← add education sections
docs/stacks/python.md              ← add education sections
scripts/bootstrap.sh               ← fix interactive mode bug
SESSION_STATE.md                   ← add Evolution Log section
README.md                          ← full rewrite for public launch quality
CONTRIBUTING.md                    ← upgrade for contributors
```

### Existing Files (Keep, No Change Needed)
```
.claude/agents/explorer.md
.claude/agents/code-reviewer.md
.claude/agents/dep-checker.md
.claude/agents/doc-writer.md
.claude/agents/security-scanner.md
.claude/agents/test-runner.md
.claude/hooks/safety-check.sh
.claude/hooks/secret-detector.sh
.claude/hooks/notify.sh
.claude/skills/analyze-repo/SKILL.md
.claude/skills/code-review/SKILL.md
.claude/skills/context-guard/SKILL.md
.claude/skills/dep-check/SKILL.md
.claude/skills/git-workflow/SKILL.md
.claude/skills/security-scan/SKILL.md
.claude/skills/test-runner/SKILL.md
docs/stacks/nextjs.md (partial upgrade only)
```

---

## Token Budget Design

Every architectural decision is justified by token cost:

| Decision | Token Cost Without | Token Cost With | Savings |
|---|---|---|---|
| Explorer sub-agent | 8,000–15,000/exploration | ~200 (delegation) | 97% |
| Skills (load-on-demand) | Always in context | 0 until invoked | 100% until needed |
| SESSION_STATE.md | Cold start every session | Warm resume ~500 tokens | ~5,000/session |
| Structured agent output | Raw dumps ~10,000 tokens | JSON summary ~300 tokens | 97% |
| Self-update (not full re-bootstrap) | Re-run bootstrap ~20,000 | Diff + patch ~2,000 | 90% |

---

## Success Criteria

A user who clones this repo and runs the bootstrap should:
1. Complete intake in under 5 minutes
2. Have a fully working `.claude/` setup without touching any file manually
3. Understand what was generated (CLAUDE_SETUP.md explains it)
4. Save at least 80% of tokens vs. using Claude Code naively
5. After 10 sessions, have agents that know their codebase better than they do
6. After 30 sessions, be operating at expert Claude Code level without having studied it

---

## Out of Scope

- Building any specific application feature for users
- Hosting or cloud deployment of the bootstrap system itself
- A web UI or GUI for the intake process
- Multi-user/team shared memory (single-user focus for v1)
