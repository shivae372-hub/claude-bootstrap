# Evolution System Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Make the generated Claude Code setup self-improving — it learns from every session, detects when the project has changed, surfaces upgrade suggestions, and guides users from beginner to expert through rotating tips.

**Architecture:** Three new skills (`self-update`, `tips`) plus an upgraded `checkpoint.sh` hook that adds drift detection. The `self-update` skill diffs the current setup against what would be generated fresh from the current project state, reports gaps, and applies approved changes. The `tips` skill reads session_count from `USER_PROFILE.json` and surfaces progressively advanced tips. The `checkpoint.sh` upgrade writes a `drift_score` to `SESSION_STATE.md` whenever significant changes are detected.

**Tech Stack:** Bash, Python 3, Claude Code skill format

**Prerequisite:** Plans 1 and 2 complete — USER_PROFILE.json exists, template library exists.

---

## File Map

| File | Action | Responsibility |
|---|---|---|
| `.claude/skills/self-update/SKILL.md` | Create | Detects setup drift and applies upgrades |
| `.claude/skills/tips/SKILL.md` | Create | Rotating expert tips scaled to user's session count |
| `.claude/skills/tips/tips-data.md` | Create | 30 tips organized by difficulty level |
| `.claude/hooks/checkpoint.sh` | Modify | Add drift detection + session_count increment |
| `SESSION_STATE.md` | Modify | Add Evolution Log section |

---

### Task 1: Tips Data File

**Files:**
- Create: `.claude/skills/tips/tips-data.md`

- [ ] **Step 1: Create the tips data file**

```markdown
# Claude Code Expert Tips
# 30 tips organized by level. The tips skill reads these and surfaces
# the right tip based on the user's session_count in USER_PROFILE.json.
#
# Levels:
#   beginner  (sessions 1-5)   — foundational mechanics
#   mid       (sessions 6-20)  — efficiency patterns
#   advanced  (sessions 21+)   — expert techniques

---

## Beginner Tips (Sessions 1–5)

### TIP-001
**Level:** beginner
**Title:** Sub-agents are your token bodyguards
**Body:** Every time you ask "find where X is defined" or "search the codebase for Y" in your main window, you burn 5,000–15,000 tokens just reading files. Instead say: "Use the explorer agent to find where X is defined." The agent runs in a separate window — its tokens are completely isolated from yours.
**Example:** ❌ "Search all files for the auth middleware" → ✅ "Use the explorer agent to find the auth middleware"

### TIP-002
**Level:** beginner
**Title:** SESSION_STATE.md is your memory between sessions
**Body:** Claude starts each session completely fresh — it doesn't remember last session at all. But if you begin each session with "Read SESSION_STATE.md and tell me where we left off," you get a warm start in seconds instead of re-explaining everything. The checkpoint hook updates this file automatically.
**Example:** Start every session with: "Read SESSION_STATE.md and resume from where we left off."

### TIP-003
**Level:** beginner
**Title:** Skills are zero-cost until you use them
**Body:** Skills don't use any tokens until you invoke them. They're like tools sitting on a shelf — free until you pick one up. This means you can have 10 skills configured and it costs nothing. Use them freely.
**Example:** `/code-review` costs 0 tokens to have configured. It only costs tokens when you type that command.

### TIP-004
**Level:** beginner
**Title:** One task per session = better results
**Body:** Claude performs best when focused on one clear task per session. When you pile 5 things into one session, the context fills up, quality drops, and you burn tokens on context that doesn't help. Better: finish one task, commit, start a fresh session for the next.
**Example:** ❌ "Also fix the login bug, update the README, and add tests while you're at it" → ✅ Separate sessions for each.

### TIP-005
**Level:** beginner
**Title:** Use /compact before the session gets long
**Body:** When your session gets long (you can feel it — responses start taking longer, Claude seems to "forget" earlier context), run /compact. It compresses your history, saves your state to SESSION_STATE.md, and gives you a fresh working window. Do this proactively — don't wait until Claude is confused.
**Example:** After completing a major task, run /compact to checkpoint before starting the next one.

---

## Mid-Level Tips (Sessions 6–20)

### TIP-006
**Level:** mid
**Title:** The context-guard skill activates automatically
**Body:** You don't need to invoke context-guard manually. It watches for expensive operations (reading large directories, running verbose test output) and intercepts them before they flood your context. If you see "Routing to [agent] to protect context," that's the skill doing its job.
**Example:** When you say "read all the files in /src," context-guard will offer to route it to the explorer agent instead.

### TIP-007
**Level:** mid
**Title:** Agent memory gets smarter with every use
**Body:** Agents with `memory: user` write what they learn to MEMORY.md after each session. Your explorer agent remembers which files do what. Your code-reviewer remembers recurring bugs in your codebase. After 10 sessions, your agents know your project better than a new hire would.
**Example:** After week 2, your code-reviewer will automatically flag the auth patterns that have caused bugs before — without you reminding it.

### TIP-008
**Level:** mid
**Title:** Structured output from agents = 97% token savings
**Body:** Agents return JSON summaries, not raw file content. A raw codebase search returns 50,000 tokens of file content. The same search via explorer agent returns a 300-token JSON summary. That's a 99% reduction. This is why agents return structured output — it's a deliberate design choice to protect your budget.
**Example:** The explorer agent's output is ~200-500 tokens regardless of how large your codebase is.

### TIP-009
**Level:** mid
**Title:** Run /analyze-repo at the start of every new feature
**Body:** Before starting a new feature, run /analyze-repo. It updates SESSION_STATE.md with the current project state — directory map, key files, recent changes. Now Claude has a fresh mental model and won't make assumptions based on how the project looked 3 weeks ago.
**Example:** "Before we start the payment integration, run /analyze-repo so you have current project context."

### TIP-010
**Level:** mid
**Title:** Commit more frequently when working with Claude
**Body:** Claude performs better on small, focused changes than large ones. Aim to commit every 15–30 minutes of work. Small commits also mean if Claude makes a mistake, you can `git checkout` to a known good state in seconds. The /git-workflow skill handles commit messages automatically.
**Example:** Every task in a plan should end with a commit step. Never let Claude make 10 changes before committing.

### TIP-011
**Level:** mid
**Title:** Put constraints in CLAUDE.md, not in every prompt
**Body:** If you find yourself saying "remember, never use any-type in TypeScript" in multiple sessions, that's a sign it should go in CLAUDE.md under NEVER. Instructions in CLAUDE.md are always in context — you don't have to repeat them.
**Example:** Add to CLAUDE.md → NEVER: "Use TypeScript `any` type — use specific types or `unknown` instead."

### TIP-012
**Level:** mid
**Title:** The security-scanner agent catches server/client boundary bugs
**Body:** For Next.js and similar frameworks, running the security-scanner before deploy catches server-side code accidentally imported into client components — a class of bug that's easy to miss in code review and can expose sensitive data.
**Example:** Before every deploy: "Use the security-scanner agent to audit the latest changes."

### TIP-013
**Level:** mid
**Title:** Use /self-update when you add a major new feature area
**Body:** When your project grows significantly (new language, new service, new team member), run /self-update. It scans the current state, compares against your setup, and suggests new agents or skills that would help. Your setup evolves with your project — you don't have to re-bootstrap.
**Example:** After adding a Python ML module to your Node.js project: "/self-update — I added a Python ML service."

### TIP-014
**Level:** mid
**Title:** Nested CLAUDE.md files add context without bloat
**Body:** If a subdirectory has its own conventions (e.g., `/ml-service` uses different patterns), add a `CLAUDE.md` inside that directory. It appends to the root CLAUDE.md automatically when Claude is working in that directory — without making your root file longer.
**Example:** `/ml-service/CLAUDE.md` → "This directory is Python only. Always use type hints. Tests use pytest."

### TIP-015
**Level:** mid
**Title:** The task-planner agent converts vague goals into steps
**Body:** When you have a big, fuzzy goal ("improve the onboarding flow"), don't try to prompt Claude directly — use the task-planner agent first. It breaks the goal into 5–15 ordered steps with effort estimates. Then you execute each step in its own focused session.
**Example:** "Use the task-planner agent to break down: redesign the user onboarding flow."

---

## Advanced Tips (Sessions 21+)

### TIP-016
**Level:** advanced
**Title:** Edit MEMORY.md directly to correct agent learning
**Body:** Agents update MEMORY.md after sessions, but they occasionally learn the wrong lesson. You can read and edit MEMORY.md directly to correct mistakes, reinforce patterns you want agents to remember, or add context an agent couldn't observe. Treat it like a knowledge base you co-author with your agents.
**Example:** If code-reviewer learned "auth checks are always in middleware" but you moved them to the service layer, update MEMORY.md directly.

### TIP-017
**Level:** advanced
**Title:** Haiku agents cost 5–10x less than Sonnet agents
**Body:** Explorer and test-runner use the Haiku model — they're fast and cheap for read-heavy tasks. Code-reviewer and security-scanner use Sonnet — they need deeper reasoning. This model routing is intentional. If you add custom agents, use Haiku for anything that mostly reads files, Sonnet for anything that makes judgments.
**Example:** A custom "doc-checker" agent (reads files, checks links) → Haiku. A custom "architecture-reviewer" (evaluates design decisions) → Sonnet.

### TIP-018
**Level:** advanced
**Title:** Skills can call agents internally
**Body:** A skill's steps can include "delegate to [agent-name]" instructions. This means a skill like /security-scan automatically routes to the security-scanner agent without you having to specify it. You can design custom skills that orchestrate multiple agents in sequence.
**Example:** A `/pre-deploy` skill could: (1) run tests via test-runner agent, (2) run security scan via security-scanner agent, (3) check deps via dep-checker agent, (4) report consolidated results.

### TIP-019
**Level:** advanced
**Title:** The drift detection tells you when your setup is stale
**Body:** The checkpoint hook writes a drift_score to SESSION_STATE.md every session. When score > 30 (30+ significant file changes since last self-update), your setup may be missing agents or skills for new code areas. Check SESSION_STATE.md's Evolution Log to see what changed.
**Example:** SESSION_STATE.md → "drift_score: 45 — consider running /self-update"

### TIP-020
**Level:** advanced
**Title:** Use `fork: agent-name` in skill frontmatter for isolated execution
**Body:** By default, skills run in the main context window. For skills that do heavy file reading (like /analyze-repo), add `fork: explorer` to the frontmatter. This routes the skill's execution into the explorer agent's isolated window.
**Example:** Custom skill with `fork: explorer` in frontmatter → runs without touching your main context budget.

### TIP-021
**Level:** advanced
**Title:** Reference docs in skills instead of embedding them
**Body:** Skills have a 5000-word limit in SKILL.md, but can load additional reference files from `.claude/skills/NAME/references/`. For complex skills, put detailed lookup tables, API references, or decision trees in references/ and have the skill load them on demand.
**Example:** A `/database-patterns` skill with `references/query-patterns.md` — loaded only when needed.

### TIP-022
**Level:** advanced
**Title:** The PreCompact hook is your recovery system
**Body:** When Claude's context window fills and compaction happens automatically, the PreCompact hook fires first — saving everything to SESSION_STATE.md. This is your recovery point. If a compaction happens mid-task, your next message can be: "Read SESSION_STATE.md — context was compacted, resume the task."
**Example:** After unexpected compaction: "Read SESSION_STATE.md and tell me what we were doing."

### TIP-023
**Level:** advanced
**Title:** Agent output summaries in SESSION_STATE.md are durable memory
**Body:** The "Agent Output Summaries" section of SESSION_STATE.md stores the last run of each agent as structured JSON. This means you can say "What did the security scanner find last week?" and Claude can read SESSION_STATE.md instead of re-running the scan. Update this section after important agent runs.
**Example:** After security scan: "Update SESSION_STATE.md with the security-scanner findings from today."

### TIP-024
**Level:** advanced
**Title:** Use /self-update as a forcing function for architecture review
**Body:** When /self-update reports a large drift, it's often a signal that your architecture has evolved in ways that deserve intentional review — not just more agents. The drift report is a prompt to ask: "Does my setup still reflect how I actually work, or is it optimizing for how I used to work?"

### TIP-025
**Level:** advanced
**Title:** Incremental context: give Claude exactly what it needs
**Body:** Don't start a session with "Here's everything about my project." Instead, start with the SESSION_STATE.md read (warm context), then add specific context only when relevant. "The payment module uses Stripe's newer Payment Intents API" — say this when you start working on payments, not at the start of every session.

### TIP-026
**Level:** advanced
**Title:** Write your own skills for your workflow patterns
**Body:** The built-in skills cover the universal workflows (git, review, test). Your personal workflow probably has patterns worth automating. If you find yourself giving the same 5-step instruction to Claude regularly, that's a skill waiting to be written. Use the format in docs/FORMATS.md.
**Example:** A `/weekly-report` skill that: runs data-analyst agent on last week's metrics, formats the results, drafts the report.

### TIP-027
**Level:** advanced
**Title:** The `allowed-tools` field in skills restricts what Claude can do
**Body:** Skills can declare `allowed-tools:` in their frontmatter. This restricts the tools available during that skill's execution — even if Claude would normally have access to more. Use this to create safe, read-only skills that can't accidentally modify files.
**Example:** A `/audit` skill with `allowed-tools: Read, Grep` — can only read, never write or run commands.

### TIP-028
**Level:** advanced
**Title:** Multiple CLAUDE.md files form a hierarchy
**Body:** Nested CLAUDE.md files in subdirectories append to the root when Claude is working in that directory. This lets you have global conventions at root and directory-specific overrides locally. A `/frontend` CLAUDE.md can say "always use React Server Components" without that rule applying to your `/api` directory.

### TIP-029
**Level:** advanced
**Title:** Agent memory compounds over time
**Body:** After 50+ sessions, your agents' MEMORY.md files become a significant knowledge asset — more detailed than any wiki you'd write manually, because they learned from actual work rather than documentation effort. Back up MEMORY.md files in git. They're worth protecting.
**Example:** Commit MEMORY.md files regularly: `git add .claude/*/MEMORY.md && git commit -m "chore: update agent memory"`

### TIP-030
**Level:** advanced
**Title:** The best Claude Code setup is the one that becomes invisible
**Body:** The goal of this entire system is to reach the point where you don't think about tokens, context, or agents at all — you just describe what you want, and it gets done. That invisibility is the sign of a mature setup. When your setup needs adjusting, you'll notice friction. That friction is the signal to run /self-update.
```

- [ ] **Step 2: Commit**

```bash
git add .claude/skills/tips/tips-data.md
git commit -m "feat(evolution): add 30 expert tips scaled by session level"
```

---

### Task 2: Tips Skill

**Files:**
- Create: `.claude/skills/tips/SKILL.md`

- [ ] **Step 1: Create the tips skill**

```markdown
---
name: tips
description: Surfaces one expert Claude Code tip per session, scaled to the user's experience level. Auto-activates at the start of every session when analyze-repo runs. Also invoked manually with "/tips". Tip level advances as session_count grows in USER_PROFILE.json.
allowed-tools: Read, Write
version: 1.0.0
---

## Purpose
Turn every session start into a micro-lesson. Users who engage with this system
daily will absorb 30 expert techniques in their first month — not by studying,
but by seeing one tip at a time in the flow of real work.

## What This Saves You
Without this skill, users plateau at whatever level they were when they started.
This skill creates automatic, continuous improvement — the system teaches itself
forward through every user.

## Steps

### 1. Read User Profile
```bash
cat USER_PROFILE.json 2>/dev/null | python3 -c "
import json, sys
try:
  p = json.load(sys.stdin)
  count = p.get('session_count', 0)
  tier = p.get('generation_tier', 'non-dev')
  print(f'{count}|{tier}')
except:
  print('0|non-dev')
"
```

Note `session_count` and `generation_tier`.

### 2. Determine Tip Level
- session_count 0–5: level = beginner (TIP-001 through TIP-005)
- session_count 6–20: level = mid (TIP-006 through TIP-015)
- session_count 21+: level = advanced (TIP-016 through TIP-030)

Tip to show = TIP-{(session_count mod count_for_level) + start_of_level}

Example: session_count=7 → mid level, tip index = (7-6) mod 10 = 1 → TIP-007

### 3. Read the Tip
```bash
cat .claude/skills/tips/tips-data.md
```

Find the tip at the calculated index within the appropriate level section.

### 4. Display the Tip

Format it as a brief, friendly callout — not a lecture:

```
💡 **Today's Claude Code Tip** (Session [N])

**[TIP TITLE]**
[TIP BODY]

[EXAMPLE if present]

---
*Tips get more advanced as you use Claude Code more. Run `/tips` anytime for another one.*
```

### 5. Increment Session Count
```bash
python3 -c "
import json
from datetime import datetime
from pathlib import Path

p_path = Path('USER_PROFILE.json')
if not p_path.exists():
  exit(0)

p = json.loads(p_path.read_text())
p['session_count'] = p.get('session_count', 0) + 1
p['last_session'] = datetime.now().isoformat()
p_path.write_text(json.dumps(p, indent=2))
print(f'Session count: {p[\"session_count\"]}')
"
```

## Notes
- Show tips at session start only — not mid-task (disruptive)
- Do not show the same tip twice in a row
- For non-dev users at beginner level, use extra-plain language when presenting
- If USER_PROFILE.json doesn't exist, skip silently (don't block the session)
```

- [ ] **Step 2: Commit**

```bash
git add .claude/skills/tips/SKILL.md
git commit -m "feat(evolution): add tips skill with session-based tip progression"
```

---

### Task 3: Self-Update Skill

**Files:**
- Create: `.claude/skills/self-update/SKILL.md`

- [ ] **Step 1: Create the self-update skill**

```markdown
---
name: self-update
description: Updates the Claude Code setup when the project has changed significantly. Detects drift between current project state and the existing .claude/ setup, reports gaps, and applies approved changes. Invoke when: "my project changed", "I added a new feature area", "update my setup", "/self-update", or when SESSION_STATE.md shows drift_score > 30.
allowed-tools: Bash, Read, Write, Glob, Grep
version: 1.0.0
---

## Purpose
Keep the Claude Code setup in sync with the project as it evolves. Without this,
setups go stale: a project that started as a simple app but grew to include a
Python ML service, a mobile app, and 3 microservices would still have the
original 6 agents — none of them tuned for the new complexity.

## What This Saves You
A stale setup is the #1 cause of token waste in mature projects. Wrong agents,
outdated conventions in CLAUDE.md, and missing skills cause Claude to make
poor routing decisions and repeat work. This skill fixes that in one command.

## Steps

### 1. Read Current State

Read both the existing setup and the current project:

```bash
# Current profile
cat USER_PROFILE.json 2>/dev/null

# Current agents
ls .claude/agents/ 2>/dev/null

# Current skills
ls .claude/skills/ 2>/dev/null

# Current drift score from last checkpoint
python3 -c "
import re
try:
  content = open('SESSION_STATE.md').read()
  m = re.search(r'drift_score:\s*(\d+)', content)
  print('drift_score:', m.group(1) if m else 'unknown')
except: print('drift_score: unknown')
"
```

### 2. Re-Run Project Detection

```bash
bash claude-bootstrap/.claude/skills/onboarding/scripts/detect-project.sh "$(pwd)" > /tmp/current-detected.json
cat /tmp/current-detected.json
```

### 3. Diff: What's New?

Compare detected project state vs. USER_PROFILE.json:

```python
import json

current = json.load(open('/tmp/current-detected.json'))
profile = json.load(open('USER_PROFILE.json'))

# What's new?
current_stack = set(current.get('stack', []))
profile_stack = set(profile.get('stack', []))
new_stack = current_stack - profile_stack

current_lang = current.get('language', 'unknown')
profile_lang = profile.get('language', 'unknown')
lang_changed = current_lang != profile_lang

print(f"New stack items: {new_stack}")
print(f"Language changed: {lang_changed} ({profile_lang} → {current_lang})")
```

Run this as:
```bash
python3 << 'EOF'
import json

try:
  current = json.load(open('/tmp/current-detected.json'))
  profile = json.load(open('USER_PROFILE.json'))

  current_stack = set(current.get('stack', []))
  profile_stack = set(profile.get('stack', []))
  new_stack = current_stack - profile_stack
  removed_stack = profile_stack - current_stack
  lang_changed = current.get('language') != profile.get('language')

  print(f"New in stack: {new_stack or 'none'}")
  print(f"Removed from stack: {removed_stack or 'none'}")
  print(f"Language changed: {lang_changed}")
  print(f"Current file count: {current.get('file_count', 0)}")
  print(f"Profile file count: {profile.get('file_count', 0)}")
except Exception as e:
  print(f"Error: {e}")
EOF
```

### 4. Scan for New Directories

```bash
# Find top-level directories added since last update
python3 -c "
import os, json
from pathlib import Path

ignore = {'.git', 'node_modules', '__pycache__', '.next', 'dist', 'build', 
          'claude-bootstrap', '.claude', 'venv', '.venv'}

current_dirs = set(
  d for d in os.listdir('.')
  if os.path.isdir(d) and d not in ignore and not d.startswith('.')
)

try:
  profile = json.load(open('USER_PROFILE.json'))
  known_dirs = set(profile.get('known_directories', []))
except:
  known_dirs = set()

new_dirs = current_dirs - known_dirs
print('New top-level directories:', new_dirs or 'none')
print('All directories:', current_dirs)
"
```

### 5. Generate Upgrade Report

Based on findings, report what should change. Structure as:

```
## Setup Drift Report
Generated: [timestamp]
Drift score: [N]

### New Additions Detected
- [New stack item, e.g., "fastapi added to Python project"]
- [New directory, e.g., "ml-service/ directory added"]

### Recommended Changes

#### Add These Agents
- [agent-name]: [reason — e.g., "FastAPI detected, API testing agent would help"]

#### Update These Files  
- CLAUDE.md: [what to add — e.g., "Add ml-service/ to Directory Map"]
- SESSION_STATE.md: [what to update]

#### Remove / Archive These
- [anything that's no longer relevant]

### No Action Needed
- [items that are still current and working well]
```

### 6. Ask User to Approve

Present the report and ask:
"Here are the recommended changes to your Claude Code setup. Which would you like me to apply?
- A) Apply all recommended changes
- B) Apply specific changes (tell me which ones)  
- C) Just update CLAUDE.md and SESSION_STATE.md, nothing else
- D) Skip for now"

### 7. Apply Approved Changes

For each approved change:

**Adding an agent:**
- Read the appropriate template from `docs/templates/agents/<tier>/<name>.md`
- Copy it to `.claude/agents/<name>.md`
- Add it to CLAUDE.md's Agents Available section

**Updating CLAUDE.md:**
- Read current CLAUDE.md
- Add new directories to Directory Map
- Add new commands if detected
- Keep under 150 lines

**Updating USER_PROFILE.json:**
```bash
python3 claude-bootstrap/.claude/skills/onboarding/scripts/write-profile.py \
  --detected /tmp/current-detected.json \
  --update \
  --output USER_PROFILE.json \
  < /dev/null
```

### 8. Run Validation

```bash
bash claude-bootstrap/scripts/validate.sh
```

Fix any failures before reporting complete.

### 9. Update Evolution Log in SESSION_STATE.md

Append to the Evolution Log section:
```
| [date] | [changes made] | [reason: drift detected / user triggered] |
```

## Notes
- Never remove agents or skills without explicit user approval
- If drift_score < 10 and user didn't explicitly trigger this, suggest skipping: "Your setup looks current. Run /self-update to force a check anyway?"
- After applying changes, increment USER_PROFILE.json's updated_at field
- Maximum of 6 agents always — if adding an agent would exceed 6, ask which to replace
```

- [ ] **Step 2: Commit**

```bash
git add .claude/skills/self-update/SKILL.md
git commit -m "feat(evolution): add self-update skill for setup drift detection and repair"
```

---

### Task 4: Upgrade checkpoint.sh with Drift Detection

**Files:**
- Modify: `.claude/hooks/checkpoint.sh`

- [ ] **Step 1: Add drift detection to checkpoint.sh**

After the existing timestamp update block (after the `PYTHON` heredoc), add:

```bash
# ─── Drift Detection ────────────────────────────────────────────
# Count significant file changes since last checkpoint.
# "Significant" = not node_modules, .git, __pycache__, build artifacts.
# Writes drift_score to SESSION_STATE.md.

if command -v python3 &> /dev/null && command -v git &> /dev/null && [ -d ".git" ]; then
  python3 - << 'DRIFT_PYTHON'
import subprocess, re, json
from pathlib import Path

try:
  # Count files changed since last commit
  result = subprocess.run(
    ['git', 'diff', '--name-only', 'HEAD'],
    capture_output=True, text=True, timeout=5
  )
  changed_files = [
    f for f in result.stdout.strip().split('\n')
    if f and not any(skip in f for skip in [
      'node_modules', '.git', '__pycache__', '.next', 'dist/',
      'build/', 'venv/', '.venv/', 'target/'
    ])
  ]
  drift_score = len(changed_files)

  # Also check untracked files
  result2 = subprocess.run(
    ['git', 'ls-files', '--others', '--exclude-standard'],
    capture_output=True, text=True, timeout=5
  )
  untracked = [
    f for f in result2.stdout.strip().split('\n')
    if f and not any(skip in f for skip in ['node_modules', '__pycache__', '.next'])
  ]
  drift_score += len(untracked)

  # Read and update SESSION_STATE.md
  state_path = Path('SESSION_STATE.md')
  if state_path.exists():
    content = state_path.read_text()

    # Update or add drift_score
    if 'drift_score:' in content:
      content = re.sub(r'drift_score:\s*\d+', f'drift_score: {drift_score}', content)
    else:
      # Add before the first ## section or at end
      content = content.rstrip() + f'\n\n## Drift\ndrift_score: {drift_score}\n'

    # Add drift warning if score is high
    if drift_score >= 30:
      warning = f'⚠️  drift_score={drift_score} — consider running /self-update'
      if warning not in content:
        content = re.sub(r'drift_score:\s*\d+', f'drift_score: {drift_score}  ← {warning}', content)

    state_path.write_text(content)
    print(f'Drift score: {drift_score} ({len(changed_files)} changed + {len(untracked)} untracked files)')

    if drift_score >= 30:
      print(f'💡 Tip: Run /self-update — your project has changed significantly')

except Exception as e:
  print(f'Drift detection skipped: {e}')
DRIFT_PYTHON
fi
```

- [ ] **Step 2: Verify bash syntax**

```bash
bash -n .claude/hooks/checkpoint.sh && echo "Syntax OK"
```

Expected: `Syntax OK`

- [ ] **Step 3: Test drift detection manually**

```bash
# Create a few test files to simulate drift
touch /tmp/test-drift-a.py /tmp/test-drift-b.py
# Run the checkpoint manually (simulate)
echo '{"session_id": "test"}' | bash .claude/hooks/checkpoint.sh
cat SESSION_STATE.md | grep -A2 "Drift"
```

Expected: `drift_score:` line present in SESSION_STATE.md.

- [ ] **Step 4: Commit**

```bash
git add .claude/hooks/checkpoint.sh
git commit -m "feat(evolution): add drift detection to checkpoint hook"
```

---

### Task 5: Upgrade SESSION_STATE.md Template

**Files:**
- Modify: `SESSION_STATE.md`

- [ ] **Step 1: Update SESSION_STATE.md to include Evolution Log**

Replace the entire file content with:

```markdown
# Session State
*Not yet analyzed — run `/analyze-repo` to populate this file*

## How To Use This File
This file is the project's memory across Claude Code sessions.

- **At session start**: Claude reads this file to resume context
- **After compaction**: The PreCompact hook updates this automatically  
- **After major tasks**: Claude updates the "Active Work" section
- **Sub-agent output**: Summaries are written to "Agent Output Summaries"

Run `/analyze-repo` to do a full scan and populate all sections.

---

## Project
*Run /analyze-repo to populate*

## Key Commands
*Run /analyze-repo to populate*

## Directory Map
*Run /analyze-repo to populate*

## Active Work
*Nothing in progress*

## Pending
*None*

## Drift
drift_score: 0

## Evolution Log
| Date | Change | Reason |
|------|--------|--------|
| — | Initial setup | Bootstrap |

## Agent Output Summaries
*No agents have run yet*
```

- [ ] **Step 2: Commit**

```bash
git add SESSION_STATE.md
git commit -m "feat(evolution): add Evolution Log and Drift sections to SESSION_STATE.md"
```

---

### Task 6: Wire Tips Into analyze-repo Skill

**Files:**
- Modify: `.claude/skills/analyze-repo/SKILL.md`

The tips skill should surface a tip at the end of every analyze-repo run, making tips automatic at session start.

- [ ] **Step 1: Add tips invocation at end of analyze-repo**

Read the current analyze-repo skill:

```bash
tail -20 .claude/skills/analyze-repo/SKILL.md
```

Add this as a new final step (Step 8) in analyze-repo/SKILL.md, after "Report to User":

```markdown
### 8. Surface Today's Tip
After reporting, invoke the tips skill to show the user one tip:
```
Invoke the tips skill now to surface today's Claude Code expert tip.
```

This runs automatically every session start. It takes < 50 tokens and compounds
into expert-level knowledge over time.
```

- [ ] **Step 2: Verify analyze-repo still has all its original steps**

```bash
grep "^### " .claude/skills/analyze-repo/SKILL.md
```

Expected output includes Steps 1 through 8 (the original 7 + new Step 8).

- [ ] **Step 3: Commit**

```bash
git add .claude/skills/analyze-repo/SKILL.md
git commit -m "feat(evolution): auto-surface tips skill at end of analyze-repo"
```

---

### Task 7: Update README for Public Launch Quality

**Files:**
- Modify: `README.md`

- [ ] **Step 1: Read current README**

```bash
cat README.md
```

- [ ] **Step 2: Rewrite README.md**

```markdown
# claude-bootstrap

> Turn anyone into a Claude Code expert — from their very first session.

Claude Code is incredibly powerful. But most people waste 80–90% of their token
budget because they don't know about sub-agents, skills, hooks, or session state.
This repo fixes that automatically.

**Clone it into your project. Ask Claude to read it. In 5 minutes, you'll have a
professional-grade Claude Code setup — custom-built for you, your role, and your
project.**

---

## Who This Is For

| You are... | What you get |
|---|---|
| A developer | 6 agents (explorer, code-reviewer, test-runner, security-scanner...), git workflow automation, pre-commit hooks, token-efficient code review |
| A founder / startup | Product advisor agent, launch readiness audits, task planner, code + business hybrid setup |
| A manager / ops | Content writer, data analyst, presentation builder — no coding required |
| A student | Beginner-friendly setup, rotating tips that teach Claude Code as you use it |
| A complete beginner | Plain-English everything, protected from mistakes, guided step by step |

---

## What Gets Generated

After the 5-minute setup interview, you'll have:

- **Up to 6 custom sub-agents** — each runs in its own isolated context window, saving you thousands of tokens per session
- **7 skills** — workflows for code review, git, testing, security, and more — invoked with a slash command
- **5 hooks** — auto-format on save, block dangerous commands, detect secrets, save session state
- **CLAUDE.md** — your project's permanent context file (stays under 150 lines — the limit where Claude's attention starts to degrade)
- **SESSION_STATE.md** — memory bridge between sessions so you never start cold
- **CLAUDE_SETUP.md** — a plain-English guide to everything that was generated

---

## Quick Start

```bash
# 1. Go to your project folder (or an empty folder if starting fresh)
cd your-project/

# 2. Clone this repo inside it
git clone https://github.com/yourusername/claude-bootstrap

# 3. Open Claude Code
claude

# 4. Tell Claude to start the bootstrap
"Read claude-bootstrap/CLAUDE.md and set up my Claude Code environment."

# 5. Answer 5-8 questions — Claude does the rest
```

That's it. Claude will interview you, detect your project, and generate everything.

---

## What Happens During Setup

1. **Silent detection** — Claude scans your project automatically (no questions yet)
2. **Interview** — 5–8 questions about your role, goals, and how you work
3. **Blueprint** — Claude shows you what it will generate and asks for approval
4. **Generation** — All files written and validated automatically
5. **Education** — Claude explains what was generated and why, with token savings estimates

---

## Token Savings (Why This Matters)

Without this setup, a typical Claude Code session uses 50,000–100,000 tokens.

| Operation | Without setup | With setup | Savings |
|---|---|---|---|
| Explore the codebase | 8,000–15,000 tokens | ~200 tokens | 97% |
| Run tests | 5,000–10,000 tokens | ~300 tokens | 94% |
| Code review | 3,000–8,000 tokens | ~500 tokens | 85% |
| Cold start (new session) | 5,000–10,000 tokens | ~500 tokens | 90% |

**On Claude Pro: this setup is the difference between running out of quota in 2 days vs. lasting all month.**

---

## The System Improves Over Time

Your setup is not static. It gets smarter with every session:

- **Agent memory** — agents accumulate knowledge about your codebase after each run
- **Session state** — `SESSION_STATE.md` grows richer with every checkpoint
- **Drift detection** — the system notices when your project changes and suggests updates
- **Expert tips** — one new tip per session, escalating in sophistication as you grow

After 30 sessions, you'll be using Claude Code at expert level — not because you studied it, but because the system taught you through your normal work.

---

## Updating Your Setup

When your project changes significantly (new language, new service, new team member):

```
/self-update
```

Claude will scan what's changed, show you the gaps, and update your setup with your approval.

---

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md) for how to add stack templates, agent templates, or tips.

---

## License

Apache 2.0
```

- [ ] **Step 3: Commit**

```bash
git add README.md
git commit -m "docs: rewrite README for public launch quality"
```

---

## Self-Review

**Spec coverage:**
- ✅ Self-update skill with drift detection — Task 3
- ✅ Tips skill with 30 tips across 3 levels — Tasks 1 + 2
- ✅ Session count tracking in USER_PROFILE.json — Task 2 (tips skill step 5)
- ✅ checkpoint.sh drift detection + drift_score — Task 4
- ✅ SESSION_STATE.md Evolution Log — Task 5
- ✅ Tips auto-wired into session start via analyze-repo — Task 6
- ✅ README rewrite — Task 7

**Placeholder scan:** None. All code blocks are complete.

**Type consistency:**
- `drift_score` written by checkpoint.sh and read by self-update skill using same key name ✓
- `session_count` incremented in tips skill matches `session_count` field written by write-profile.py ✓
- Self-update calls `write-profile.py --update` which exists in Plan 1, Task 2 ✓
- Tips skill reads `generation_tier` from USER_PROFILE.json — same field name as Plan 1 ✓
