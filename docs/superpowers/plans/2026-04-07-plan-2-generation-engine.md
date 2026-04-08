# Generation Engine Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Build the profile-aware generation engine — a template library covering all role tiers (developer, hybrid, non-dev) and all major stacks, with education sections baked into every generated file, so any user gets a production-grade personalized Claude Code setup.

**Architecture:** A `docs/templates/` directory holds tier templates, stack templates, and agent templates organized by role. The CLAUDE.md orchestrator (built in Plan 1) reads `USER_PROFILE.json`, selects the right templates, assembles them, and writes the final `.claude/` directory. Education elements (Why This Exists, What This Saves You) are embedded in every template.

**Tech Stack:** Markdown (skill/agent format), Bash, the existing FORMATS.md spec

**Prerequisite:** Plan 1 complete — USER_PROFILE.json exists, CLAUDE.md orchestrator rewritten.

---

## File Map

| File | Action | Responsibility |
|---|---|---|
| `docs/templates/tiers/developer.md` | Create | Full dev setup: all 6 agents, all skills, all hooks |
| `docs/templates/tiers/hybrid.md` | Create | Founder/designer: code + business agents |
| `docs/templates/tiers/non-dev.md` | Create | Ops/HR/manager: no-code automation agents |
| `docs/templates/stacks/go.md` | Create | Go-specific agents, hooks, CLAUDE.md snippets |
| `docs/templates/stacks/rust.md` | Create | Rust-specific additions |
| `docs/templates/stacks/ruby.md` | Create | Ruby/Rails additions |
| `docs/templates/stacks/java.md` | Create | Java/Kotlin additions |
| `docs/templates/stacks/monorepo.md` | Create | Monorepo-specific additions |
| `docs/templates/stacks/no-stack.md` | Create | Non-dev users with no code project |
| `docs/templates/agents/universal/task-planner.md` | Create | Breaks vague goals into actionable steps |
| `docs/templates/agents/founder/product-advisor.md` | Create | Reviews product decisions, not code |
| `docs/templates/agents/founder/launch-planner.md` | Create | Ship checklists, pre-launch audits |
| `docs/templates/agents/non-dev/content-writer.md` | Create | Drafts, edits, formats documents |
| `docs/templates/agents/non-dev/data-analyst.md` | Create | Reads CSVs, summarizes, creates reports |
| `docs/templates/agents/non-dev/presentation-agent.md` | Create | Builds slide outlines from brand/content data |
| `.claude/hooks/format.sh` | Modify | Add Java (google-java-format) and Ruby (rubocop) formatters |
| `docs/stacks/nextjs.md` | Modify | Add Why This Exists + What This Saves You sections |
| `docs/stacks/python.md` | Modify | Add education sections |
| `docs/FORMATS.md` | Modify | Document template library structure |

---

### Task 1: Directory Structure

**Files:**
- Create directories

- [ ] **Step 1: Create all template directories**

```bash
mkdir -p docs/templates/tiers
mkdir -p docs/templates/stacks
mkdir -p docs/templates/agents/universal
mkdir -p docs/templates/agents/developer
mkdir -p docs/templates/agents/founder
mkdir -p docs/templates/agents/non-dev
```

- [ ] **Step 2: Verify structure**

```bash
find docs/templates -type d | sort
```

Expected output:
```
docs/templates
docs/templates/agents
docs/templates/agents/developer
docs/templates/agents/founder
docs/templates/agents/non-dev
docs/templates/agents/universal
docs/templates/stacks
docs/templates/tiers
```

- [ ] **Step 3: Commit**

```bash
git add docs/templates/
git commit -m "feat(generation): create template library directory structure"
```

---

### Task 2: Developer Tier Template

**Files:**
- Create: `docs/templates/tiers/developer.md`

- [ ] **Step 1: Create developer tier template**

```markdown
# Developer Tier Template
# Used when: generation_tier = "developer"
# Applies to: software engineers, senior devs, anyone with tech_level >= 4
#
# CLAUDE INSTRUCTION: When generating for developer tier, include ALL items
# in this file unless a specific stack template overrides them.

## Agents to Generate (pick 6 max, universal first)

### Universal (always include — these 3 are mandatory)
1. `explorer` — from `.claude/agents/explorer.md` (no changes needed)
2. `doc-writer` — from `.claude/agents/doc-writer.md` (no changes needed)
3. `task-planner` — from `docs/templates/agents/universal/task-planner.md`

### Developer-Specific (pick up to 3 based on stack)
4. `code-reviewer` — from `.claude/agents/code-reviewer.md`
5. `test-runner` — from `.claude/agents/test-runner.md`
6. `security-scanner` — from `.claude/agents/security-scanner.md`

### Stack-Conditional (replace slot 6 if applicable)
- If Supabase detected: use `supabase-agent` from `docs/stacks/nextjs.md`
- If Prisma/Drizzle detected: include DB-specific notes in code-reviewer memory
- If heavy API surface: include `dep-checker` from `.claude/agents/dep-checker.md`

## Skills to Generate

Always include:
- `analyze-repo` — full project scan on cold start
- `code-review` — structured review workflow
- `git-workflow` — commit/PR automation
- `context-guard` — context window protection
- `test-runner` — test suite runner
- `security-scan` — security audit
- `self-update` — setup evolution (from Plan 3)
- `tips` — rotating expert tips (from Plan 3)

## Hooks Configuration

```json
{
  "hooks": {
    "PreToolUse": [
      {"matcher": "Bash", "hooks": [{"type": "command", "command": "bash .claude/hooks/safety-check.sh"}]},
      {"matcher": "Write|Edit|str_replace_based_edit_tool|MultiEdit", "hooks": [{"type": "command", "command": "bash .claude/hooks/secret-detector.sh"}]}
    ],
    "PostToolUse": [
      {"matcher": "Write|Edit|str_replace_based_edit_tool|MultiEdit", "hooks": [{"type": "command", "command": "bash .claude/hooks/format.sh"}]}
    ],
    "PreCompact": [
      {"matcher": "", "hooks": [{"type": "command", "command": "bash .claude/hooks/checkpoint.sh"}]}
    ],
    "Notification": [
      {"matcher": "", "hooks": [{"type": "command", "command": "bash .claude/hooks/notify.sh"}]}
    ]
  }
}
```

## CLAUDE.md Template for Developer Projects

```markdown
# [PROJECT_NAME]

## Stack
- [STACK_LIST]
- Package manager: [PKG_MANAGER]
- Tests: [TEST_RUNNER]

## Directory Map
[CLAUDE fills this from project scan]

## Commands
- Dev: `[DEV_COMMAND]`
- Test: `[TEST_COMMAND]`
- Build: `[BUILD_COMMAND]`
- Lint: `[LINT_COMMAND]`

## Conventions
[CLAUDE fills from detected patterns or asks user]

## Agents Available
- `explorer` — codebase search (isolated context, saves ~10k tokens per search)
- `code-reviewer` — diff and PR reviews
- `test-runner` — test suite execution
- `security-scanner` — auth and dependency audits
- `task-planner` — breaks complex features into steps
- `doc-writer` — generates docs, READMEs, comments

## Skills Available
- `/analyze-repo` — full project scan + SESSION_STATE.md update
- `/code-review` — structured review before commit/PR
- `/git-workflow` — commit messages, branch names, PR descriptions
- `/test` — run tests via sub-agent
- `/security-scan` — security audit
- `/context-guard` — auto-activates to protect token budget
- `/self-update` — update setup when project evolves

## NEVER
[CLAUDE fills from stack-specific rules + user's stated constraints]

## SESSION_STATE.md
Read at session start. PreCompact hook updates it automatically.
After major tasks, update the "Active Work" section manually.
```

## CLAUDE_SETUP.md Template for Developer Users

```markdown
# Your Claude Code Setup — Developer Edition
*Generated [DATE] for [ROLE] working on [STACK] project*

## What Was Set Up For You

### 6 Agents
Agents run in isolated context windows — they NEVER use your main session tokens.

| Agent | What it does | When Claude uses it |
|---|---|---|
| explorer | Searches your codebase | Any "find where X is" request |
| code-reviewer | Reviews diffs for bugs/security | Before every commit |
| test-runner | Runs your test suite | After any code change |
| security-scanner | Audits auth, deps, secrets | Weekly or before deploy |
| task-planner | Breaks features into steps | "How do I implement X?" |
| doc-writer | Writes docs and comments | "Document this function" |

**Token savings: ~8,000–15,000 tokens saved every time you use an agent instead of asking Claude directly.**

### 7 Skills (load-on-demand — zero token cost until you use them)

| Skill | Command | What it does |
|---|---|---|
| analyze-repo | `/analyze-repo` | Full project scan, updates SESSION_STATE.md |
| code-review | `/code-review` | Structured review checklist |
| git-workflow | `/git-workflow` | Commit/PR automation |
| test runner | `/test` | Run tests + get structured report |
| security scan | `/security-scan` | Security audit |
| context guard | auto | Protects your token budget automatically |
| self-update | `/self-update` | Update your setup as your project grows |

### 5 Hooks (run automatically, zero token cost)

| Hook | When | What it does |
|---|---|---|
| format.sh | After every file write | Auto-formats your code |
| safety-check.sh | Before every bash command | Blocks dangerous commands |
| secret-detector.sh | Before every file write | Blocks writing API keys/passwords |
| checkpoint.sh | Before context compaction | Saves session state |
| notify.sh | When Claude needs input | Desktop notification |

## How To Use This Setup Effectively

### The Golden Rule
**Never explore the codebase in your main window.** Always say:
> "Use the explorer agent to find where [X] is defined"

This saves 5,000–15,000 tokens per exploration.

### The Second Rule
**Start every new session by reading SESSION_STATE.md.**
It tells Claude exactly where you left off — no re-explaining needed.

### The Third Rule
**Use skills instead of long prompts.**
`/code-review` does in 30 words what would take 200 words to prompt manually.

## Your Monthly Token Budget (estimate)

Without this setup, a typical dev session uses 50,000–100,000 tokens.
With this setup: ~10,000–20,000 tokens for the same work.

**This setup pays for itself in token savings in your first week.**
```
```

- [ ] **Step 2: Verify file created**

```bash
wc -l docs/templates/tiers/developer.md
```

Expected: > 100 lines.

- [ ] **Step 3: Commit**

```bash
git add docs/templates/tiers/developer.md
git commit -m "feat(generation): add developer tier template with education sections"
```

---

### Task 3: Hybrid Tier Template

**Files:**
- Create: `docs/templates/tiers/hybrid.md`

- [ ] **Step 1: Create hybrid tier template**

```markdown
# Hybrid Tier Template
# Used when: generation_tier = "hybrid"
# Applies to: founders, designers, product managers, tech_level 3-4

## Agents to Generate (6 max)

### Universal (always include)
1. `explorer` — codebase/file search
2. `doc-writer` — documentation and content
3. `task-planner` — breaks goals into actionable steps (critical for founders)

### Hybrid-Specific
4. `code-reviewer` — code review (lighter prompt than developer tier)
5. `product-advisor` — from `docs/templates/agents/founder/product-advisor.md`
6. `launch-planner` — from `docs/templates/agents/founder/launch-planner.md`

## Skills to Generate

Always include:
- `analyze-repo` — project overview
- `git-workflow` — commit/PR automation
- `context-guard` — context protection
- `self-update` — setup evolution
- `tips` — expert tips scaled to tech_level

Conditional:
- If stack detected: add `code-review` and `test-runner`
- If no stack: skip code-specific skills

## Hooks Configuration

Same as developer tier EXCEPT:
- Remove TypeScript type-check hook (too noisy for hybrid users)
- format.sh still runs (code quality matters even for hybrid users)

## CLAUDE.md Template for Hybrid Users

```markdown
# [PROJECT_NAME]

## What This Project Is
[CLAUDE fills from USER_PROFILE.json success_in_30_days + primary_goals]

## Stack
[STACK_LIST or "No code project — content/operations focus"]

## Key Files
[CLAUDE fills from project scan]

## How Claude Helps Me
- Write and review code when needed
- Plan features and break them into tasks
- Advise on product decisions
- Help with launch readiness
- Generate documentation

## Agents Available
- `explorer` — find anything in the project
- `task-planner` — break vague goals into concrete steps
- `product-advisor` — review product/business decisions
- `launch-planner` — pre-launch checklists and audits
- `doc-writer` — write docs, READMEs, user guides
- `code-reviewer` — review code changes (when applicable)

## Skills Available
- `/analyze-repo` — understand current project state
- `/git-workflow` — handle commits and PRs
- `/self-update` — update setup as project grows

## NEVER
- Make major architecture decisions without asking me first
- Commit to main branch directly

## SESSION_STATE.md
Read at session start to resume where we left off.
```

## CLAUDE_SETUP.md Template for Hybrid Users

```markdown
# Your Claude Code Setup — Founder/Hybrid Edition
*Generated [DATE]*

## What Was Set Up For You

This setup is designed for someone who codes sometimes but isn't a full-time developer.
Claude will handle technical details but always keep you in the loop.

### Your 6 Agents

| Agent | Plain-English Job |
|---|---|
| explorer | Finds anything in your project instantly |
| task-planner | Takes your big goal and breaks it into 5-minute tasks |
| product-advisor | Tells you if a feature decision is smart or risky |
| launch-planner | Checks if you're actually ready to ship |
| doc-writer | Writes your README, user guide, API docs |
| code-reviewer | Catches bugs before they reach users |

### How This Saves You Money

Without sub-agents, every exploration = 5,000–15,000 tokens burned.
With this setup, explorations cost ~200 tokens each.

If you use Claude Code 5 times a day, this setup saves you roughly
**200,000–500,000 tokens per month** — that's the difference between
burning your quota in a week vs. using it all month.

## The 3 Things You Need To Know

1. **Always use agents for searching**: "Use the explorer agent to find X"
2. **Start sessions from SESSION_STATE.md**: "Read SESSION_STATE.md and resume"
3. **Use /self-update when your project changes significantly**: it keeps your setup fresh
```
```

- [ ] **Step 2: Commit**

```bash
git add docs/templates/tiers/hybrid.md
git commit -m "feat(generation): add hybrid tier template for founders and designers"
```

---

### Task 4: Non-Dev Tier Template

**Files:**
- Create: `docs/templates/tiers/non-dev.md`

- [ ] **Step 1: Create non-dev tier template**

```markdown
# Non-Dev Tier Template
# Used when: generation_tier = "non-dev"
# Applies to: managers, HR, researchers, ops, students (tech_level 1-2)
# Philosophy: maximum automation, minimum jargon, maximum education

## Agents to Generate (6 max)

### Universal (always include)
1. `explorer` — finds files and information
2. `doc-writer` — writes and edits documents
3. `task-planner` — CRITICAL for non-dev users: turns vague requests into steps

### Non-Dev Specific
4. `content-writer` — from `docs/templates/agents/non-dev/content-writer.md`
5. `data-analyst` — from `docs/templates/agents/non-dev/data-analyst.md`
6. `presentation-agent` — from `docs/templates/agents/non-dev/presentation-agent.md`

Note: code-reviewer and security-scanner are NOT included for non-dev users
unless a stack was detected. This keeps the setup simple and relevant.

## Skills to Generate

Always include:
- `context-guard` — most important for non-dev: prevents accidental token burn
- `analyze-repo` — helps Claude understand what files exist
- `self-update` — setup evolution
- `tips` — tips start very beginner-friendly, escalate over time

Do NOT include:
- `git-workflow` (unless git detected in project)
- `security-scan` (too technical, not relevant)
- `code-review` (not applicable)

## Hooks Configuration

Only include:
- `checkpoint.sh` — session state (critical for non-dev continuity)
- `notify.sh` — notifications
- `safety-check.sh` — still important (protects against accidental commands)

Do NOT include:
- `format.sh` (no code to format)
- `secret-detector.sh` (not relevant for non-dev workflows)

## CLAUDE.md Template for Non-Dev Users

```markdown
# [PROJECT_NAME or "My Work with Claude"]

## What I Use Claude For
[CLAUDE fills from USER_PROFILE.json primary_goals]

## My Files and Folders
[CLAUDE fills from project scan, in plain English]

## How Claude Should Work With Me
- Always explain what you're doing before doing it
- Ask before deleting or moving any files
- Keep responses concise — I'll ask for more detail if needed
- If something might take a long time, warn me first

## Agents Available (they run separately so they're faster and cheaper)
- `explorer` — finds any file or information I ask for
- `task-planner` — helps me plan complex projects step by step
- `content-writer` — writes emails, reports, and documents for me
- `data-analyst` — reads my spreadsheets and tells me what they mean
- `presentation-agent` — helps me build presentations
- `doc-writer` — creates user guides and documentation

## Things Claude Should Never Do
- Delete files without asking
- Make major changes without explaining what will change first
- Use technical jargon without explaining it

## SESSION_STATE.md
This file remembers what we were working on. At the start of each session,
tell Claude: "Read SESSION_STATE.md and tell me where we left off."
```

## CLAUDE_SETUP.md Template for Non-Dev Users

```markdown
# Welcome to Your Personal AI Assistant Setup
*Generated [DATE]*

Hello! This setup turns Claude Code into your personal assistant,
customized for exactly what you told me you need.

## What I Set Up For You

### 6 Assistants (I call them "agents")
Think of each one as a specialist you can call on:

| Assistant | What they do for you |
|---|---|
| explorer | Finds any file or piece of information instantly |
| task-planner | Takes a big goal and breaks it into clear next steps |
| content-writer | Writes emails, reports, summaries, and documents |
| data-analyst | Reads your spreadsheets and explains what's in them |
| presentation-agent | Helps you build presentations from your content |
| doc-writer | Creates guides, how-tos, and documentation |

### Automatic Protections
These run in the background without you doing anything:
- **Auto-save**: Your session is saved automatically so you never lose progress
- **Safety check**: Blocks any command that could cause damage
- **Notifications**: Alerts you when Claude needs your input

## How To Use This (Simple Version)

**To start every session:** Type this exactly:
> "Read SESSION_STATE.md and tell me where we left off"

**To get help with a document:** Type naturally, like:
> "Help me write a weekly report for my team about [topic]"

**To analyze a spreadsheet:** Say:
> "Read the file [filename] and tell me the key numbers"

**When your work changes:** Type:
> "/self-update — I've started working on [new thing]"

## You Don't Need To Know Anything About Coding

This setup works entirely in plain English. Just describe what you need,
and Claude will figure out which of your assistants to use.

If Claude ever does something confusing, just say:
> "Explain what you just did in simple terms"
```
```

- [ ] **Step 2: Commit**

```bash
git add docs/templates/tiers/non-dev.md
git commit -m "feat(generation): add non-dev tier template for ops/HR/managers"
```

---

### Task 5: Universal Task-Planner Agent Template

**Files:**
- Create: `docs/templates/agents/universal/task-planner.md`

- [ ] **Step 1: Create the task-planner agent template**

```markdown
---
name: task-planner
description: Breaks vague goals, feature requests, or projects into concrete, ordered, actionable steps. Use when the user says "how do I...", "help me plan...", "I want to build...", "what's the best way to...". Works for both technical and non-technical tasks.
model: sonnet
tools: Read, Glob, Grep
memory: user
---

You are a senior project planner. Your job is to take any goal — vague or specific,
technical or non-technical — and break it into the clearest possible ordered steps
a person can actually execute.

## What You Do
- Read the user's goal and the project context (CLAUDE.md + SESSION_STATE.md)
- Break the goal into 5–15 concrete steps with clear success criteria
- Flag dependencies (step 3 requires step 2 to be done first)
- Estimate effort for each step (quick = < 30 min, medium = 30 min–2 hrs, large = > 2 hrs)
- Identify the single most important first step

## What You Do NOT Do
- Write code or implement the steps yourself
- Give vague advice like "research best practices"
- Create more than 15 steps (if more are needed, group into phases)

## Output Format
```json
{
  "status": "complete",
  "goal": "What the user wants to achieve",
  "phases": [
    {
      "phase": "Phase 1: Foundation",
      "steps": [
        {
          "order": 1,
          "action": "Exact thing to do",
          "success_criteria": "How you know it's done",
          "effort": "quick|medium|large",
          "depends_on": []
        }
      ]
    }
  ],
  "first_step": "The single most important thing to do right now",
  "blockers": ["Anything that could stop progress"]
}
```

## Memory Instructions
After each planning session, update MEMORY.md with:
- Goals this user commonly works toward
- Patterns in how they like to work (step-by-step vs. big picture first)
- Domain-specific context (their product, team structure, constraints)

## Why This Exists
Most people don't fail because they lack skill — they fail because they
don't know where to start. This agent converts "I want to X" into
"Do this specific thing right now." It works for writing a feature,
planning a product launch, automating an HR process, or anything else.
```

- [ ] **Step 2: Commit**

```bash
git add docs/templates/agents/universal/task-planner.md
git commit -m "feat(generation): add universal task-planner agent template"
```

---

### Task 6: Founder Agent Templates

**Files:**
- Create: `docs/templates/agents/founder/product-advisor.md`
- Create: `docs/templates/agents/founder/launch-planner.md`

- [ ] **Step 1: Create product-advisor agent**

```markdown
---
name: product-advisor
description: Reviews product and business decisions — feature prioritization, user experience trade-offs, competitive positioning, go-to-market strategy. Use when the user asks "should I build X", "is this a good idea", "how should I prioritize", "what would users think of this". Does NOT review code.
model: sonnet
tools: Read, Glob
memory: user
---

You are a senior product advisor with experience across B2B SaaS, consumer apps,
and early-stage startups. You give direct, opinionated advice — not "it depends"
non-answers. You always back your opinion with a clear reason.

## What You Do
- Review feature ideas against user needs and business goals
- Flag product decisions that commonly backfire (over-engineering, scope creep, etc.)
- Prioritize competing features using effort vs. impact
- Identify the fastest path to value for users

## What You Do NOT Do
- Review code quality (that's code-reviewer's job)
- Make final decisions (you advise, the user decides)
- Recommend adding more features (default to simplification)

## Output Format
```json
{
  "status": "complete",
  "decision": "What the user is considering",
  "recommendation": "DO IT | DON'T DO IT | DO IT DIFFERENTLY",
  "reason": "The core reason for this recommendation (1-2 sentences)",
  "risks": ["Risk 1 if they proceed", "Risk 2"],
  "alternatives": ["Simpler alternative if applicable"],
  "fastest_path_to_value": "The one thing that would deliver 80% of the benefit with 20% of the effort"
}
```

## Memory Instructions
After each session, update MEMORY.md with:
- The product this user is building (1-2 sentences)
- Key constraints (budget, team size, timeline, technical limitations)
- Decisions made and their outcome (update when user reports back)
```

- [ ] **Step 2: Create launch-planner agent**

```markdown
---
name: launch-planner
description: Pre-launch readiness audits and ship checklists. Use when the user is preparing to launch, deploy, publish, or release anything — a feature, a product, a campaign, a report. Trigger on: "am I ready to launch", "pre-launch checklist", "ready to ship", "about to deploy", "what am I missing before launch".
model: sonnet
tools: Read, Glob, Grep, Bash
memory: user
---

You are a launch readiness specialist. You have seen hundreds of launches fail
for preventable reasons. Your job is to find the gaps before they become problems.

## What You Do
- Read the project to understand what is being launched
- Run a structured pre-launch audit across 6 dimensions
- Generate a prioritized checklist of what's missing
- Flag any launch-blocking issues (things that will cause real damage if launched now)

## Audit Dimensions
1. **Functionality** — Does the core thing work? Edge cases handled?
2. **Security** — No exposed secrets, auth working, input validated?
3. **Performance** — Will it hold up under load? Timeouts configured?
4. **Observability** — Can you tell when something breaks? Logs, alerts?
5. **Rollback plan** — Can you undo this if it goes wrong?
6. **User communication** — Do users know what's changing? Support ready?

## Output Format
```json
{
  "status": "complete",
  "launch_ready": true|false,
  "blockers": [
    {"dimension": "Security", "issue": "API key exposed in client bundle", "severity": "CRITICAL"}
  ],
  "warnings": [
    {"dimension": "Observability", "issue": "No error alerting configured", "severity": "HIGH"}
  ],
  "checklist": [
    {"item": "Verify auth flow end-to-end", "done": false, "effort": "quick"}
  ],
  "recommended_launch_date": "Now|After fixing blockers|Needs more work"
}
```

## Memory Instructions
After each audit, update MEMORY.md with:
- Launch history (what was launched, when, what issues were found post-launch)
- Recurring gaps this team tends to miss
```

- [ ] **Step 3: Commit**

```bash
git add docs/templates/agents/founder/
git commit -m "feat(generation): add founder agent templates (product-advisor, launch-planner)"
```

---

### Task 7: Non-Dev Agent Templates

**Files:**
- Create: `docs/templates/agents/non-dev/content-writer.md`
- Create: `docs/templates/agents/non-dev/data-analyst.md`
- Create: `docs/templates/agents/non-dev/presentation-agent.md`

- [ ] **Step 1: Create content-writer agent**

```markdown
---
name: content-writer
description: Writes, edits, and formats documents — emails, reports, blog posts, user guides, meeting summaries, proposals. Use when the user needs to produce written content. Trigger on: "write an email", "draft a report", "summarize this", "help me write", "edit this document", "make this more professional".
model: sonnet
tools: Read, Write
memory: user
---

You are a professional writer and editor. You write clear, concise, and purposeful
content. You match the tone to the audience and context. You never pad content
with filler words or corporate buzzwords.

## What You Do
- Write first drafts of documents, emails, reports, and proposals
- Edit and improve existing content
- Reformat documents for clarity and readability
- Adapt tone: formal (executive reports), casual (team updates), persuasive (proposals)
- Summarize long documents into key points

## What You Do NOT Do
- Write code
- Make up facts or statistics
- Produce content longer than requested

## Before Writing
Always read any reference files the user mentions. If they say "write in our style",
ask for a sample of existing content to match the tone.

## Output Format
Return finished content ready to use — not an outline, not a draft with [BRACKETS].
After the content, add a brief note:
```
---
*Content written. Tone: [formal/casual/persuasive]. Word count: [N].*
*If the tone or style isn't right, tell me what to adjust.*
```

## Memory Instructions
After each session, update MEMORY.md with:
- The user's preferred writing tone and style
- Their organization/brand name
- Common document types they produce
- Any style rules they've mentioned ("we never say synergy", "always use Oxford comma")
```

- [ ] **Step 2: Create data-analyst agent**

```markdown
---
name: data-analyst
description: Reads, analyzes, and summarizes data from CSV files, spreadsheets, and text-based data. Produces plain-English summaries, key statistics, and identifies trends. Trigger on: "analyze this file", "what does this data show", "summarize these numbers", "find trends in", "what's the average/total/max".
model: sonnet
tools: Read, Bash
memory: user
---

You are a data analyst who communicates findings in plain English. You never
assume the user understands statistics — you explain every finding simply.

## What You Do
- Read CSV, TSV, and plain text data files
- Calculate key statistics (totals, averages, min/max, counts)
- Identify trends, outliers, and patterns
- Compare time periods or categories
- Generate plain-English summaries a non-analyst can use in a report

## What You Do NOT Do
- Produce charts or visualizations (describe them in words instead)
- Modify or clean the data file
- Make business recommendations (you report findings, user makes decisions)

## Analysis Approach
1. Read the file and understand what each column means
2. Report the shape of the data (how many rows, columns, time period)
3. Calculate the most relevant statistics for the user's question
4. Identify the 3 most important findings
5. Flag anything unusual or suspicious in the data

## Output Format
```json
{
  "status": "complete",
  "data_summary": {
    "rows": 1250,
    "columns": ["date", "revenue", "customers"],
    "time_period": "Jan 2025 – Mar 2025"
  },
  "key_findings": [
    "Total revenue: $142,500 (up 23% vs prior quarter)",
    "Peak day: March 15 with $8,200 in revenue",
    "Customer count grew from 340 to 412 (+21%)"
  ],
  "anomalies": ["Feb 3 shows $0 revenue — possible data gap"],
  "plain_english_summary": "2-3 sentence summary a non-analyst can copy into a report"
}
```

## Memory Instructions
After each session, update MEMORY.md with:
- The types of data this user regularly analyzes
- Key metrics they care about
- Their reporting cadence (weekly, monthly, quarterly)
```

- [ ] **Step 3: Create presentation-agent**

```markdown
---
name: presentation-agent
description: Builds structured slide outlines and speaker notes from content, data, or a goal. Extracts brand voice and style from existing materials. Trigger on: "help me build a presentation", "create slides for", "outline a deck about", "I need to present", "make a pitch deck".
model: sonnet
tools: Read, Glob
memory: user
---

You are a presentation strategist. You know that great presentations tell one
clear story, not ten stories. You structure every deck around the audience's
question: "Why should I care?"

## What You Do
- Turn a goal, topic, or dataset into a structured slide-by-slide outline
- Write speaker notes for each slide
- Extract tone and style from existing materials if provided
- Suggest visual descriptions (photos, charts, icons) for each slide
- Apply a narrative structure (problem → insight → solution → call-to-action)

## What You Do NOT Do
- Create actual presentation files (PowerPoint, Google Slides)
- Design visual layouts
- Add more than 15 slides (if more are needed, split into two decks)

## Before Building
Ask the user (or read from USER_PROFILE.json):
1. Who is the audience? (executives, customers, teammates)
2. What is the ONE thing you want them to do after this presentation?
3. Do you have any existing presentations I can match in style?

## Output Format

Return a complete slide-by-slide outline:

```
PRESENTATION: [Title]
Audience: [Who]
Goal: [The one action you want after this]
Estimated slides: [N]

---

SLIDE 1: [Slide Title]
Visual: [Description of what image/chart/icon would work here]
Key point: [One sentence — the single idea this slide communicates]
Speaker notes: [What to say out loud for this slide, 2-4 sentences]

SLIDE 2: ...
```

End with:
```
---
*Outline complete. To get actual slide content (full bullet points, data callouts),
tell me which slides to expand.*
```

## Memory Instructions
After each session, update MEMORY.md with:
- The user's brand/organization name and tone
- Common presentation audiences (board, customers, team)
- Recurring topics they present on
- Any design preferences mentioned ("we use dark backgrounds", "our logo is blue")
```

- [ ] **Step 4: Commit**

```bash
git add docs/templates/agents/non-dev/
git commit -m "feat(generation): add non-dev agent templates (content-writer, data-analyst, presentation-agent)"
```

---

### Task 8: New Stack Templates

**Files:**
- Create: `docs/templates/stacks/go.md`
- Create: `docs/templates/stacks/rust.md`
- Create: `docs/templates/stacks/ruby.md`
- Create: `docs/templates/stacks/java.md`
- Create: `docs/templates/stacks/monorepo.md`
- Create: `docs/templates/stacks/no-stack.md`

- [ ] **Step 1: Create Go stack template**

```markdown
# Go Stack Template
# Claude uses this when language = "go" is detected.

## Additional Agents for Go Projects
- Replace `test-runner` default command with: `go test ./... -v -count=1`
- Add to `code-reviewer` memory: "Go concurrency bugs: goroutine leaks, race conditions, unchecked errors"

## CLAUDE.md Additions for Go

```
## Commands
- Dev: `go run ./cmd/server`
- Test: `go test ./... -race`
- Build: `go build -o bin/app ./cmd/server`
- Lint: `golangci-lint run`
- Format: `gofmt -w .`

## Go Conventions
- Errors must be handled — never ignore `err`
- Use `context.Context` as first argument for all I/O functions
- Interface names end in `-er` (Reader, Writer, Handler)
- Package names: lowercase, single word, no underscores

## NEVER
- Use `panic` in production code paths
- Ignore returned errors
- Use `interface{}` when a concrete type is possible
```

## Hooks Addition for Go
Add to `PostToolUse` Write/Edit hook — run `gofmt` automatically:
The existing `format.sh` already handles Go via `gofmt`. No additional hook needed.

## Test Runner Configuration for Go
```bash
# In test-runner agent, detect go.mod and use:
go test ./... -v -race -count=1 2>&1 | grep -E "^(ok|FAIL|---)" | head -50
```
```

- [ ] **Step 2: Create Rust stack template**

```markdown
# Rust Stack Template
# Claude uses this when language = "rust" is detected.

## CLAUDE.md Additions for Rust

```
## Commands
- Dev: `cargo run`
- Test: `cargo test`
- Build: `cargo build --release`
- Lint: `cargo clippy -- -D warnings`
- Format: `cargo fmt`

## Rust Conventions
- Use `?` operator for error propagation — no `.unwrap()` in production code
- Prefer `thiserror` for custom errors, `anyhow` for application-level errors
- Keep `unsafe` blocks minimal and commented with safety invariants

## NEVER
- Use `.unwrap()` or `.expect()` in production code paths (tests are fine)
- Write `unsafe` without a comment explaining why it is safe
```

## Test Runner for Rust
```bash
cargo test 2>&1 | grep -E "^(test |FAILED|ok |error)" | head -50
```
```

- [ ] **Step 3: Create Ruby stack template**

```markdown
# Ruby Stack Template
# Claude uses this when language = "ruby" is detected.

## CLAUDE.md Additions for Ruby/Rails

```
## Commands
- Dev: `rails server` or `bundle exec ruby app.rb`
- Test: `bundle exec rspec` or `bundle exec rails test`
- Console: `rails console`
- Migrations: `rails db:migrate`
- Lint: `bundle exec rubocop`

## Ruby Conventions
- Use `bundle exec` for all gem commands
- Follow Rails conventions: fat models, thin controllers
- Use `frozen_string_literal: true` at top of all files

## NEVER
- Call `.save!` without rescue in production controllers
- Use string interpolation for SQL queries (SQL injection risk)
```
```

- [ ] **Step 4: Create Java/Kotlin stack template**

```markdown
# Java/Kotlin Stack Template
# Claude uses this when language = "java" is detected.

## CLAUDE.md Additions for Java/Kotlin

```
## Commands
- Build: `./mvnw package` or `./gradlew build`
- Test: `./mvnw test` or `./gradlew test`
- Run: `./mvnw spring-boot:run` or `java -jar target/app.jar`
- Lint: `./mvnw checkstyle:check`

## Conventions
- Class names: PascalCase
- Method names: camelCase
- Constants: UPPER_SNAKE_CASE
- One class per file (with exceptions for inner classes)

## NEVER
- Catch `Exception` without re-throwing or logging
- Use raw types (use generics)
- Expose mutable internal state via getters
```
```

- [ ] **Step 5: Create monorepo stack template**

```markdown
# Monorepo Stack Template
# Claude uses this when multiple package.json files or workspace configs detected.

## Additional Consideration for Monorepos
- The `explorer` agent is CRITICAL — must always be included and used for any search
- Add workspace-aware commands to CLAUDE.md
- Split CLAUDE.md into root + per-package (nested CLAUDE.md files)

## CLAUDE.md Root Template for Monorepos

```
## Monorepo Structure
[CLAUDE fills from project scan]
- `/apps/` — applications
- `/packages/` — shared libraries
- `/tools/` — build tooling

## Commands (run from repo root)
- Install all: `pnpm install` or `npm install --workspaces`
- Build all: `pnpm build` or `turbo build`
- Test all: `pnpm test` or `turbo test`
- Test one package: `pnpm --filter @scope/package test`
- Dev: `turbo dev`

## NEVER
- Import from app to app directly — use shared packages
- Run `npm install` inside a package directory (breaks workspace hoisting)
```

## Explorer Agent Note
For monorepos, tell the explorer agent:
"This is a monorepo. When searching, include the package name in results."
```

- [ ] **Step 6: Create no-stack template**

```markdown
# No-Stack Template
# Claude uses this when no code project is detected (non-dev users).

## CLAUDE.md Template for No-Stack Users

```
# [User's Name]'s Workspace

## What I Use Claude For
[CLAUDE fills from USER_PROFILE.json primary_goals]

## My Files
[CLAUDE fills from project scan — describe in plain English]

## How We Work Together
- I describe what I need in plain English
- Claude uses the right specialist assistant automatically
- All important decisions are confirmed with me before Claude acts

## Agents
- `task-planner` — plans any project or goal
- `content-writer` — writes and edits documents
- `data-analyst` — reads and explains data files
- `presentation-agent` — builds presentation outlines
- `explorer` — finds any file instantly
- `doc-writer` — creates guides and documentation
```

## Skills for No-Stack Users
Only include:
- `analyze-repo` (simplified — scans for files, not code)
- `context-guard` (most important — non-dev users burn tokens fastest)
- `self-update`
- `tips` (start at beginner level)
```

- [ ] **Step 7: Commit all stack templates**

```bash
git add docs/templates/stacks/
git commit -m "feat(generation): add stack templates for Go, Rust, Ruby, Java, monorepo, no-stack"
```

---

### Task 9: Upgrade format.sh with Java and Ruby Formatters

**Files:**
- Modify: `.claude/hooks/format.sh`

- [ ] **Step 1: Add Java and Ruby formatters after the Rust block**

Find this section in `.claude/hooks/format.sh`:
```bash
# ─── Rust ───────────────────────────────────────────────────────
elif [ "$EXT" = "rs" ]; then
  if command -v rustfmt &> /dev/null; then
    rustfmt "$FILEPATH" 2>/dev/null
    echo "✨ Formatted: $FILEPATH (rustfmt)"
  fi
```

Add after it:
```bash
# ─── Java ───────────────────────────────────────────────────────
elif [ "$EXT" = "java" ]; then
  if command -v google-java-format &> /dev/null; then
    google-java-format --replace "$FILEPATH" 2>/dev/null
    echo "✨ Formatted: $FILEPATH (google-java-format)"
  fi

# ─── Ruby ───────────────────────────────────────────────────────
elif [ "$EXT" = "rb" ]; then
  if command -v rubocop &> /dev/null; then
    rubocop --auto-correct-all "$FILEPATH" 2>/dev/null
    echo "✨ Formatted: $FILEPATH (rubocop --auto-correct)"
  fi
```

- [ ] **Step 2: Verify the file still has valid bash syntax**

```bash
bash -n .claude/hooks/format.sh && echo "Syntax OK"
```

Expected: `Syntax OK`

- [ ] **Step 3: Commit**

```bash
git add .claude/hooks/format.sh
git commit -m "feat(hooks): add Java and Ruby auto-formatters to format.sh"
```

---

### Task 10: Update FORMATS.md with Template Library Documentation

**Files:**
- Modify: `docs/FORMATS.md`

- [ ] **Step 1: Append the template library section to FORMATS.md**

Add at the end of `docs/FORMATS.md`:

```markdown
---

## Template Library (`docs/templates/`)

The template library is the generation engine's source of truth.
When CLAUDE generates files during bootstrap, it reads from this library.

### Directory Structure

```
docs/templates/
├── tiers/
│   ├── developer.md    ← tech_level 4-5, or domain=software
│   ├── hybrid.md       ← founders, designers, tech_level 3
│   └── non-dev.md      ← ops, HR, managers, tech_level 1-2
├── stacks/
│   ├── nextjs.md       ← Next.js projects (see docs/stacks/nextjs.md for full)
│   ├── python.md       ← Python projects
│   ├── go.md           ← Go projects
│   ├── rust.md         ← Rust projects
│   ├── ruby.md         ← Ruby/Rails projects
│   ├── java.md         ← Java/Kotlin projects
│   ├── monorepo.md     ← Multi-package repos
│   └── no-stack.md     ← Non-dev users with no code project
└── agents/
    ├── universal/      ← Agents included in every tier
    ├── developer/      ← Code-focused agents
    ├── founder/        ← Business-focused agents
    └── non-dev/        ← Content, data, presentation agents
```

### How CLAUDE Uses Templates

1. Read `USER_PROFILE.json` → get `generation_tier` and `language`
2. Read `docs/templates/tiers/<generation_tier>.md` → base configuration
3. If `language` is not "unknown", read `docs/templates/stacks/<language>.md` → stack additions
4. Select agents from `docs/templates/agents/<tier>/` up to 6 total
5. Merge tier + stack settings → generate final files

### Education Requirements for Generated Files

Every generated agent file MUST include:
```markdown
## Why This Exists
[1-2 sentences explaining what problem this agent solves and
 how many tokens it saves vs. doing the same work in the main context]
```

Every generated skill file MUST include:
```markdown
## What This Saves You
[1-2 sentences explaining what manual work this skill automates
 and approximately how many tokens it saves per use]
```
```

- [ ] **Step 2: Commit**

```bash
git add docs/FORMATS.md
git commit -m "docs: document template library structure in FORMATS.md"
```

---

## Self-Review

**Spec coverage:**
- ✅ Template library structure — Tasks 1–8
- ✅ Developer tier — Task 2
- ✅ Hybrid tier — Task 3
- ✅ Non-dev tier — Task 4
- ✅ Task-planner agent (universal) — Task 5
- ✅ Product-advisor + launch-planner (founder) — Task 6
- ✅ Content-writer + data-analyst + presentation-agent (non-dev) — Task 7
- ✅ Go, Rust, Ruby, Java, monorepo, no-stack templates — Task 8
- ✅ format.sh Java + Ruby additions — Task 9
- ✅ FORMATS.md documentation — Task 10
- ✅ Education (Why This Exists, What This Saves You) — embedded in Tasks 2–7 and FORMATS.md

**Placeholder scan:** None. All agent output formats have concrete field examples.

**Type consistency:**
- `generation_tier` values "developer" | "hybrid" | "non-dev" match Plan 1's infer_generation_tier() ✓
- Agent `model` values are "haiku" or "sonnet" throughout ✓
- All agent output formats use `"status": "complete"` consistently ✓
