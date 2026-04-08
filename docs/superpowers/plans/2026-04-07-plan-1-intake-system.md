# Intake System Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Build the universal intake system that interviews any user (developer, CEO, HR manager, student) and produces a `USER_PROFILE.json` that drives all downstream generation.

**Architecture:** A new `onboarding` skill drives a structured 5–8 question interview, detects project state automatically before asking anything, falls back to conversational mode for vague answers, and writes `USER_PROFILE.json` to the project root. The CLAUDE.md orchestrator is rewritten to trigger this skill as its first action.

**Tech Stack:** Bash, Python 3 (for JSON writing in hooks), Claude Code skill format (YAML frontmatter + Markdown body)

---

## File Map

| File | Action | Responsibility |
|---|---|---|
| `CLAUDE.md` | Modify | Orchestrator — triggers onboarding skill first, then generation |
| `.claude/skills/onboarding/SKILL.md` | Create | Intake interview logic, all questions, profile synthesis |
| `.claude/skills/onboarding/scripts/write-profile.py` | Create | Writes USER_PROFILE.json with validation |
| `.claude/skills/onboarding/scripts/detect-project.sh` | Create | Phase A silent project detection |
| `USER_PROFILE.json` | Create (at runtime) | Persisted user profile — written by onboarding skill |
| `scripts/validate.sh` | Modify | Add USER_PROFILE.json validation |

---

### Task 1: Project Detection Script

**Files:**
- Create: `.claude/skills/onboarding/scripts/detect-project.sh`

- [ ] **Step 1: Create the detection script**

```bash
#!/bin/bash
# detect-project.sh
# Phase A of intake: silently scans the parent directory for project signals.
# Outputs a JSON object to stdout. No user interaction.
# Run from the project root (parent of claude-bootstrap/).

set -e

PROJECT_ROOT="${1:-$(pwd)}"

# ─── Detection helpers ────────────────────────────────────────────
has_file() { [ -f "$PROJECT_ROOT/$1" ] && echo "true" || echo "false"; }
has_dir()  { [ -d "$PROJECT_ROOT/$1" ] && echo "true" || echo "false"; }
has_glob() { ls "$PROJECT_ROOT"/$1 2>/dev/null | head -1 | grep -q . && echo "true" || echo "false"; }

# ─── Stack detection ─────────────────────────────────────────────
STACK="[]"
LANG="unknown"
PKG_MANAGER="unknown"
TEST_RUNNER="unknown"
HAS_PROJECT="false"
HAS_EXISTING_CLAUDE="false"

# Node / JavaScript / TypeScript
if [ -f "$PROJECT_ROOT/package.json" ]; then
  HAS_PROJECT="true"
  LANG="javascript"
  # Detect package manager
  if [ -f "$PROJECT_ROOT/pnpm-lock.yaml" ]; then PKG_MANAGER="pnpm"
  elif [ -f "$PROJECT_ROOT/yarn.lock" ]; then PKG_MANAGER="yarn"
  else PKG_MANAGER="npm"; fi
  # Detect framework
  FRAMEWORKS=$(python3 -c "
import json, sys
try:
  d = json.load(open('$PROJECT_ROOT/package.json'))
  deps = {**d.get('dependencies',{}), **d.get('devDependencies',{})}
  f = []
  if 'next' in deps: f.append('nextjs')
  if 'react' in deps and 'next' not in deps: f.append('react')
  if 'vue' in deps: f.append('vue')
  if 'svelte' in deps: f.append('svelte')
  if 'express' in deps: f.append('express')
  if 'fastify' in deps: f.append('fastify')
  if 'hono' in deps: f.append('hono')
  if '@supabase/supabase-js' in deps: f.append('supabase')
  if '@prisma/client' in deps or 'prisma' in deps: f.append('prisma')
  if 'drizzle-orm' in deps: f.append('drizzle')
  if 'jest' in deps: print('jest', end=''); 
  elif 'vitest' in deps: print('vitest', end='')
  print('|' + ','.join(f))
except: print('|')
" 2>/dev/null)
  TEST_RUNNER=$(echo "$FRAMEWORKS" | cut -d'|' -f1)
  STACK=$(echo "$FRAMEWORKS" | cut -d'|' -f2 | python3 -c "import sys; items=sys.stdin.read().strip().split(','); print('[' + ','.join('\"'+i+'\"' for i in items if i) + ']')")
  [ -z "$TEST_RUNNER" ] && TEST_RUNNER="unknown"
fi

# Python
if [ -f "$PROJECT_ROOT/pyproject.toml" ] || [ -f "$PROJECT_ROOT/requirements.txt" ] || [ -f "$PROJECT_ROOT/setup.py" ]; then
  HAS_PROJECT="true"
  LANG="python"
  PKG_MANAGER="pip"
  [ -f "$PROJECT_ROOT/pyproject.toml" ] && PKG_MANAGER="uv_or_poetry"
  # Detect Python frameworks
  PYSTACK=$(python3 -c "
import sys
content = ''
for f in ['$PROJECT_ROOT/pyproject.toml','$PROJECT_ROOT/requirements.txt']:
  try:
    content += open(f).read()
  except: pass
f = []
if 'fastapi' in content.lower(): f.append('fastapi')
if 'django' in content.lower(): f.append('django')
if 'flask' in content.lower(): f.append('flask')
if 'pandas' in content.lower(): f.append('pandas')
if 'numpy' in content.lower(): f.append('numpy')
if 'pytest' in content.lower(): print('pytest', end='')
print('|' + ','.join(f))
" 2>/dev/null)
  TEST_RUNNER=$(echo "$PYSTACK" | cut -d'|' -f1)
  STACK=$(echo "$PYSTACK" | cut -d'|' -f2 | python3 -c "import sys; items=sys.stdin.read().strip().split(','); print('[' + ','.join('\"'+i+'\"' for i in items if i) + ']')")
  [ -z "$TEST_RUNNER" ] && TEST_RUNNER="pytest"
fi

# Go
if [ -f "$PROJECT_ROOT/go.mod" ]; then
  HAS_PROJECT="true"; LANG="go"; PKG_MANAGER="go_modules"; TEST_RUNNER="go_test"
  STACK='["go"]'
fi

# Rust
if [ -f "$PROJECT_ROOT/Cargo.toml" ]; then
  HAS_PROJECT="true"; LANG="rust"; PKG_MANAGER="cargo"; TEST_RUNNER="cargo_test"
  STACK='["rust"]'
fi

# Ruby
if [ -f "$PROJECT_ROOT/Gemfile" ]; then
  HAS_PROJECT="true"; LANG="ruby"; PKG_MANAGER="bundler"
  grep -q "rspec" "$PROJECT_ROOT/Gemfile" 2>/dev/null && TEST_RUNNER="rspec" || TEST_RUNNER="minitest"
  STACK='["ruby"]'
fi

# Java / Kotlin
if [ -f "$PROJECT_ROOT/pom.xml" ] || [ -f "$PROJECT_ROOT/build.gradle" ] || [ -f "$PROJECT_ROOT/build.gradle.kts" ]; then
  HAS_PROJECT="true"; LANG="java"; PKG_MANAGER="maven_or_gradle"; TEST_RUNNER="junit"
  STACK='["java"]'
fi

# Existing Claude setup
[ -d "$PROJECT_ROOT/.claude" ] && HAS_EXISTING_CLAUDE="true"

# File count (rough size signal)
FILE_COUNT=$(find "$PROJECT_ROOT" -not -path '*/node_modules/*' -not -path '*/.git/*' -not -path '*/claude-bootstrap/*' -not -path '*/__pycache__/*' -type f 2>/dev/null | wc -l | tr -d ' ')

# ─── Output JSON ─────────────────────────────────────────────────
cat << EOF
{
  "has_project": $HAS_PROJECT,
  "has_existing_claude": $HAS_EXISTING_CLAUDE,
  "language": "$LANG",
  "stack": $STACK,
  "package_manager": "$PKG_MANAGER",
  "test_runner": "$TEST_RUNNER",
  "file_count": $FILE_COUNT
}
EOF
```

- [ ] **Step 2: Make it executable**

```bash
chmod +x .claude/skills/onboarding/scripts/detect-project.sh
```

- [ ] **Step 3: Test detection on a Node project**

Create a temp directory and test:
```bash
mkdir -p /tmp/test-node-project
echo '{"dependencies":{"next":"14.0.0","@supabase/supabase-js":"2.0.0"},"devDependencies":{"jest":"29.0.0"}}' > /tmp/test-node-project/package.json
bash .claude/skills/onboarding/scripts/detect-project.sh /tmp/test-node-project
```

Expected output (exact fields, values may vary):
```json
{
  "has_project": true,
  "has_existing_claude": false,
  "language": "javascript",
  "stack": ["nextjs","supabase"],
  "package_manager": "npm",
  "test_runner": "jest",
  "file_count": 1
}
```

- [ ] **Step 4: Test detection on empty directory**

```bash
mkdir -p /tmp/test-empty
bash .claude/skills/onboarding/scripts/detect-project.sh /tmp/test-empty
```

Expected:
```json
{
  "has_project": false,
  "has_existing_claude": false,
  "language": "unknown",
  "stack": [],
  "package_manager": "unknown",
  "test_runner": "unknown",
  "file_count": 0
}
```

- [ ] **Step 5: Commit**

```bash
git add .claude/skills/onboarding/scripts/detect-project.sh
git commit -m "feat(intake): add project detection script"
```

---

### Task 2: Profile Writer Script

**Files:**
- Create: `.claude/skills/onboarding/scripts/write-profile.py`

- [ ] **Step 1: Create the profile writer**

```python
#!/usr/bin/env python3
"""
write-profile.py
Reads intake answers from stdin (JSON) and writes USER_PROFILE.json.
Also merges detected project data if passed as argument.

Usage:
  python3 write-profile.py --detected detected.json < answers.json
  python3 write-profile.py --update < partial_answers.json  (merge into existing)
"""

import json
import sys
import argparse
from datetime import datetime
from pathlib import Path

def infer_generation_tier(profile: dict) -> str:
    """Determine which template tier to use based on profile."""
    tech_level = profile.get("tech_level", 3)
    role = profile.get("role_type", "other")
    domain = profile.get("domain", "unknown")

    # Developers always get developer tier
    if role == "developer" or domain == "software":
        return "developer"

    # High tech level with any role gets developer tier
    if tech_level >= 4:
        return "developer"

    # Founders, designers, product people get hybrid
    if role in ("founder", "designer", "product"):
        return "hybrid"

    # Tech level 3 with software domain gets hybrid
    if tech_level == 3 and domain == "software":
        return "hybrid"

    # Everyone else: non-dev tier
    return "non-dev"

def infer_workflow_style(profile: dict) -> str:
    """Infer how autonomous Claude should be."""
    tech_level = profile.get("tech_level", 3)
    if tech_level >= 4:
        return "autonomous"   # Senior devs want Claude to just do it
    elif tech_level >= 2:
        return "collaborative" # Mid-level wants to stay in the loop
    else:
        return "supervised"   # Beginners want to understand each step

def validate_profile(profile: dict) -> list:
    """Return list of validation errors. Empty = valid."""
    errors = []
    required = ["role_type", "tech_level", "primary_goals", "generation_tier"]
    for field in required:
        if field not in profile:
            errors.append(f"Missing required field: {field}")
    if "tech_level" in profile:
        if not isinstance(profile["tech_level"], int) or not (1 <= profile["tech_level"] <= 5):
            errors.append("tech_level must be integer 1-5")
    if "generation_tier" in profile:
        if profile["generation_tier"] not in ("developer", "hybrid", "non-dev"):
            errors.append("generation_tier must be developer|hybrid|non-dev")
    return errors

def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--detected", help="Path to detected project JSON", default=None)
    parser.add_argument("--update", action="store_true", help="Merge into existing USER_PROFILE.json")
    parser.add_argument("--output", help="Output path", default="USER_PROFILE.json")
    args = parser.parse_args()

    # Read answers from stdin
    try:
        answers = json.load(sys.stdin)
    except json.JSONDecodeError as e:
        print(f"ERROR: Invalid JSON on stdin: {e}", file=sys.stderr)
        sys.exit(1)

    # Load detected project data if provided
    detected = {}
    if args.detected:
        try:
            detected = json.loads(Path(args.detected).read_text())
        except Exception as e:
            print(f"WARNING: Could not read detected project data: {e}", file=sys.stderr)

    # Load existing profile if updating
    existing = {}
    if args.update and Path(args.output).exists():
        try:
            existing = json.loads(Path(args.output).read_text())
        except Exception:
            pass

    # Build profile
    profile = {
        **existing,
        # Identity
        "role_type": answers.get("role_type", existing.get("role_type", "other")),
        "tech_level": answers.get("tech_level", existing.get("tech_level", 3)),
        "team_size": answers.get("team_size", existing.get("team_size", "solo")),
        "domain": answers.get("domain", existing.get("domain", "unknown")),

        # Goals
        "primary_goals": answers.get("primary_goals", existing.get("primary_goals", [])),
        "success_in_30_days": answers.get("success_in_30_days", existing.get("success_in_30_days", "")),

        # Project data (from detection)
        "project_detected": detected.get("has_project", existing.get("project_detected", False)),
        "has_existing_claude": detected.get("has_existing_claude", existing.get("has_existing_claude", False)),
        "stack": detected.get("stack", existing.get("stack", [])),
        "language": detected.get("language", existing.get("language", "unknown")),
        "package_manager": detected.get("package_manager", existing.get("package_manager", "unknown")),
        "test_runner": detected.get("test_runner", existing.get("test_runner", "unknown")),

        # Metadata
        "created_at": existing.get("created_at", datetime.now().isoformat()),
        "updated_at": datetime.now().isoformat(),
        "session_count": existing.get("session_count", 0),
        "bootstrap_version": "2.0.0",
    }

    # Infer derived fields
    profile["generation_tier"] = infer_generation_tier(profile)
    profile["workflow_style"] = infer_workflow_style(profile)

    # Validate
    errors = validate_profile(profile)
    if errors:
        print("ERROR: Profile validation failed:", file=sys.stderr)
        for e in errors:
            print(f"  - {e}", file=sys.stderr)
        sys.exit(1)

    # Write
    Path(args.output).write_text(json.dumps(profile, indent=2))
    print(f"USER_PROFILE.json written to {args.output}")
    print(f"  tier: {profile['generation_tier']}")
    print(f"  workflow: {profile['workflow_style']}")
    print(f"  stack: {profile['stack']}")

if __name__ == "__main__":
    main()
```

- [ ] **Step 2: Test developer profile**

```bash
echo '{
  "role_type": "developer",
  "tech_level": 5,
  "team_size": "small",
  "domain": "software",
  "primary_goals": ["ship faster", "save tokens"],
  "success_in_30_days": "deploy v2 with CI/CD"
}' | python3 .claude/skills/onboarding/scripts/write-profile.py --output /tmp/test-profile.json
cat /tmp/test-profile.json
```

Expected — `generation_tier` must be `"developer"`, `workflow_style` must be `"autonomous"`.

- [ ] **Step 3: Test non-dev profile**

```bash
echo '{
  "role_type": "manager",
  "tech_level": 1,
  "team_size": "large",
  "domain": "ops",
  "primary_goals": ["automate reports", "save time"],
  "success_in_30_days": "weekly report automated"
}' | python3 .claude/skills/onboarding/scripts/write-profile.py --output /tmp/test-nondev.json
cat /tmp/test-nondev.json
```

Expected — `generation_tier` must be `"non-dev"`, `workflow_style` must be `"supervised"`.

- [ ] **Step 4: Test merge/update mode**

```bash
# First write
echo '{"role_type":"developer","tech_level":4,"team_size":"solo","domain":"software","primary_goals":["test"],"success_in_30_days":"done"}' \
  | python3 .claude/skills/onboarding/scripts/write-profile.py --output /tmp/test-merge.json

# Update — should preserve session_count and created_at
echo '{"tech_level":5}' \
  | python3 .claude/skills/onboarding/scripts/write-profile.py --update --output /tmp/test-merge.json

# Verify created_at unchanged, tech_level updated
python3 -c "
import json
p = json.load(open('/tmp/test-merge.json'))
assert p['tech_level'] == 5, 'tech_level not updated'
print('merge test passed — created_at:', p['created_at'])
"
```

Expected: `merge test passed` with a timestamp printed.

- [ ] **Step 5: Commit**

```bash
git add .claude/skills/onboarding/scripts/write-profile.py
git commit -m "feat(intake): add profile writer with tier inference"
```

---

### Task 3: Onboarding Skill

**Files:**
- Create: `.claude/skills/onboarding/SKILL.md`

- [ ] **Step 1: Create the onboarding skill**

```markdown
---
name: onboarding
description: Universal intake interview. Run automatically at bootstrap start. Asks 5-8 structured questions to understand the user's role, goals, and project, then writes USER_PROFILE.json. Falls into conversational mode if answers are vague. Triggers on: first-time bootstrap, "re-run onboarding", "update my profile".
allowed-tools: Bash, Read, Write
version: 2.0.0
---

## Purpose

Interview any user — developer, CEO, HR manager, student — and produce a
`USER_PROFILE.json` that drives the entire generation engine. This skill
is the first thing that runs at bootstrap. It takes 3–5 minutes and
ensures every generated file is personalized to the exact user and project.

## Why This Exists (Education)

Most people waste 70–90% of their Claude token budget because they use
Claude Code like a chat interface — asking questions and getting answers
in the same window. This skill builds your personal profile so Claude can:
- Route expensive operations to sub-agents (saves 90%+ tokens per exploration)
- Generate agents matched to your actual role (not generic ones)
- Set up hooks that protect you from your own mistakes
- Start every session knowing your project cold

## Steps

### Phase A — Silent Project Detection (no user interaction)

Run the detection script from the project root:

```bash
bash claude-bootstrap/.claude/skills/onboarding/scripts/detect-project.sh "$(pwd)" > /tmp/detected-project.json
cat /tmp/detected-project.json
```

Read the output. Note:
- `has_project`: whether an existing codebase was found
- `has_existing_claude`: whether `.claude/` already exists (merge mode)
- `language`, `stack`, `test_runner`: detected tech

### Phase B — Structured Interview

Present this message to the user exactly:

---
👋 **Welcome to claude-bootstrap!**

I'm going to ask you 5–8 quick questions so I can build a Claude Code
setup that's 100% tailored to you. Vague or long answers are totally fine —
I'll figure out what you need from what you tell me.

Let's start:

**Question 1 of 6:**
What is this project for? (Describe it in your own words — a sentence or a paragraph, whatever feels natural.)
---

Wait for the user's response. Then continue:

**Question 2:** What best describes your role?
- A) Software developer / engineer
- B) Founder / startup / entrepreneur
- C) Manager / team lead / operations
- D) Designer / creative professional
- E) Researcher / analyst / data scientist
- F) Student / learning to code
- G) Something else (describe briefly)

**Question 3:** On a scale of 1–5, how technical are you?
- 1 = Never written code
- 2 = Basic scripts, no professional experience
- 3 = Some coding, learning as I go
- 4 = Comfortable developer
- 5 = Senior engineer / expert

**Question 4:** Do you work alone or with others?
- A) Solo — just me
- B) Small team (2–10 people)
- C) Larger organization

**Question 5:** What do you most want Claude to help you with?
- A) Write and review code
- B) Automate repetitive tasks
- C) Generate and manage documents
- D) Analyze data and create reports
- E) Plan and manage projects
- F) All of the above / not sure yet

**Question 6:** What would success look like in 30 days? (Free text — anything goes.)

### Conditional Questions

Ask **Question 7 only if**:
- User answered Q3 with 1 or 2 (non-technical), OR
- User's Q1/Q6 answers are vague or unclear

**Question 7:** Tell me more about a typical workday. What tasks take the most time?
(This helps me configure agents that handle exactly those tasks.)

Ask **Question 8 only if** `has_project` is false (blank slate):

**Question 8:** What kind of project will you be working on?
- A) A new software application
- B) Content, writing, or media
- C) Data analysis or research
- D) Business operations or automation
- E) I don't know yet — help me figure it out

### Conversational Fallback

If any answer is very vague (less than 5 words for a free-text question,
or "I don't know", "not sure", "help me"), enter conversational mode:

Ask ONE follow-up question based on what they said. Examples:
- "You mentioned you want to automate tasks — what's one task you do every week that feels repetitive?"
- "You said you're a founder — what stage is your company? Early idea, building, or scaling?"
- "You mentioned you're not sure — that's completely fine. Let me ask differently: what made you install Claude Code?"

Continue conversationally until you have enough to fill all required profile fields.

### Phase C — Profile Synthesis

After all questions are answered, synthesize the profile:

1. Map user answers to profile fields:
   - Q2 answer → `role_type`: A=developer, B=founder, C=manager, D=designer, E=researcher, F=student, G=other
   - Q3 answer → `tech_level`: 1–5 directly
   - Q4 answer → `team_size`: A=solo, B=small, C=large
   - Q5 answer → `domain`: A=software, B=ops, C=content, D=data, E=software, F=infer from Q1
   - Q6 answer → `success_in_30_days`: verbatim
   - Q1+Q5+Q6 → `primary_goals`: extract 2–3 specific goals

2. Write answers JSON to a temp file:

```bash
cat > /tmp/intake-answers.json << 'EOF'
{
  "role_type": "<derived from Q2>",
  "tech_level": <derived from Q3>,
  "team_size": "<derived from Q4>",
  "domain": "<derived from Q5 + Q1>",
  "primary_goals": ["<goal 1>", "<goal 2>", "<goal 3>"],
  "success_in_30_days": "<Q6 verbatim>"
}
EOF
```

3. Run the profile writer:

```bash
python3 claude-bootstrap/.claude/skills/onboarding/scripts/write-profile.py \
  --detected /tmp/detected-project.json \
  --output USER_PROFILE.json \
  < /tmp/intake-answers.json
```

4. Read back and confirm:

```bash
cat USER_PROFILE.json
```

### Phase D — Confirm with User

Show the user a plain-English summary (not raw JSON):

---
✅ **Profile complete!** Here's what I've captured:

- **You are:** [role] with tech level [N]/5
- **Working:** [solo/with a team]
- **On:** [project description or detected stack]
- **Goal in 30 days:** [success_in_30_days]
- **I'll configure Claude for:** [generation_tier] tier
  ([developer=full code setup / hybrid=code+business / non-dev=no-code automation])

Does this look right? If anything's off, tell me and I'll adjust before generating.
---

If user confirms or says nothing needs changing, proceed to generation.
If user says something is wrong, re-ask the relevant question and re-run Phase C.

## What This Saves You (Education)

This 5-minute interview saves you:
- **Hours** of manually configuring agents and skills
- **Thousands of tokens** per session (wrong agents = wasted context)
- **Trial and error** figuring out what Claude can do

Your `USER_PROFILE.json` is a living document — it gets updated every
time you run `/self-update`, so your setup improves as your project grows.
```

- [ ] **Step 2: Verify the skill file is valid**

```bash
# Check frontmatter is parseable
python3 -c "
import re
content = open('.claude/skills/onboarding/SKILL.md').read()
fm_match = re.match(r'^---\n(.*?)\n---', content, re.DOTALL)
assert fm_match, 'No frontmatter found'
fm = fm_match.group(1)
assert 'name: onboarding' in fm, 'name field missing'
assert 'allowed-tools:' in fm, 'allowed-tools missing'
assert 'version:' in fm, 'version missing'
print('Onboarding skill frontmatter valid')
"
```

Expected: `Onboarding skill frontmatter valid`

- [ ] **Step 3: Commit**

```bash
git add .claude/skills/onboarding/
git commit -m "feat(intake): add onboarding skill with hybrid interview flow"
```

---

### Task 4: Rewrite CLAUDE.md Orchestrator

**Files:**
- Modify: `CLAUDE.md`

- [ ] **Step 1: Read current CLAUDE.md line count**

```bash
wc -l CLAUDE.md
```

Current is ~70 lines. New version must stay under 150.

- [ ] **Step 2: Rewrite CLAUDE.md**

Replace the entire file with:

```markdown
# claude-bootstrap — Master Orchestrator
*Version 2.0.0 — Universal Claude Code Setup Generator*

## What This Repo Does
You are the bootstrap orchestrator. A user has cloned this repo into their
project folder and asked you to set up their Claude Code environment.
Your job: interview them, understand their needs, and generate a complete
professional-grade Claude Code setup tailored exactly to them.

This system works for everyone: developers, founders, HR managers, students,
CEOs. The goal is to make any user a Claude Code expert by the time they're done.

## Bootstrap Process — Follow This Exactly

### Step 1 — Run the Onboarding Skill
This is the FIRST thing you do. No exceptions.

Invoke: `/onboarding`

This skill will:
- Silently detect the project (language, stack, existing setup)
- Interview the user with 5–8 structured questions
- Write `USER_PROFILE.json` to the project root
- Confirm the profile with the user before proceeding

Do NOT proceed to Step 2 until USER_PROFILE.json exists and the user has confirmed it.

### Step 2 — Read the Generation Blueprint
After USER_PROFILE.json exists, read these files:
1. `USER_PROFILE.json` — the user's profile
2. `docs/FORMATS.md` — exact file format specs
3. `docs/templates/tiers/<generation_tier>.md` — tier-specific template
4. `docs/templates/stacks/<language>.md` — stack-specific additions (if applicable)

### Step 3 — Produce Blueprint (stdout only, no files yet)
Print a JSON blueprint:
```json
{
  "project_name": "...",
  "user_tier": "developer|hybrid|non-dev",
  "stack": ["..."],
  "agents": [{"name": "...", "job": "...", "model": "haiku|sonnet"}],
  "skills": [{"name": "...", "trigger": "..."}],
  "hooks": [{"event": "...", "purpose": "..."}],
  "education_elements": ["CLAUDE_SETUP.md", "Why This Exists sections", "token savings tips"]
}
```
STOP. Ask the user: "Here's what I'll generate. Does this look right? Any changes?"

### Step 4 — Generate All Files
After user confirms, write every file following the exact formats in `docs/FORMATS.md`.

Rules:
- Max 6 agents (universal agents always included)
- Every agent file includes `## Why This Exists` section
- Every skill file includes `## What This Saves You` section
- CLAUDE.md for the project stays under 150 lines
- Write `CLAUDE_SETUP.md` — beginner guide to what was generated

### Step 5 — Validate
Run: `bash claude-bootstrap/scripts/validate.sh`
Fix any errors before continuing.

### Step 6 — Print Summary + Educate
Print a clean human-readable summary. For each component, explain:
- What it does
- Why it was chosen for this user
- How many tokens it will save per session (estimate)

## Hard Rules
- NEVER skip the onboarding skill — no profile = no personalization
- NEVER create more than 6 agents (use agent teams beyond that)
- NEVER write a project CLAUDE.md longer than 150 lines
- NEVER generate a skill that duplicates another skill's purpose
- ALWAYS route read-only tasks to Haiku (cheaper + faster)
- ALWAYS compress sub-agent output before returning to main context
- ALWAYS check for existing `.claude/` and merge, never overwrite

## If User Has No Project Yet
The onboarding skill handles this. After profile is written, ask:
"Would you like me to scaffold a starter project structure for [detected domain]?"
If yes, create a minimal directory structure + README before generating .claude/.

## Context Window Rules (Non-Negotiable)
1. Sub-agents handle all exploration — their window is isolated
2. Skills load only when invoked — zero cost until triggered
3. Hooks run as shell scripts — zero context window cost
4. Sub-agent output must be a JSON/bullet summary, never raw file dumps
5. SESSION_STATE.md is the memory bridge between sessions — always update it
```

- [ ] **Step 3: Verify line count**

```bash
wc -l CLAUDE.md
```

Expected: under 150 lines.

- [ ] **Step 4: Commit**

```bash
git add CLAUDE.md
git commit -m "feat(orchestrator): rewrite CLAUDE.md with onboarding-first flow v2.0"
```

---

### Task 5: Upgrade validate.sh for USER_PROFILE.json

**Files:**
- Modify: `scripts/validate.sh`

- [ ] **Step 1: Add USER_PROFILE.json validation block**

After the `SESSION_STATE.md` section (around line 183), add:

```bash
# ─── USER_PROFILE.json ──────────────────────────────────────────
echo -e "${BOLD}User Profile${NC}"

if [ -f "USER_PROFILE.json" ]; then
  pass "USER_PROFILE.json exists"
  # Validate JSON
  if python3 -c "import json; json.load(open('USER_PROFILE.json'))" 2>/dev/null; then
    pass "USER_PROFILE.json is valid JSON"
    # Check required fields
    MISSING_FIELDS=$(python3 -c "
import json
required = ['role_type','tech_level','generation_tier','workflow_style','primary_goals']
p = json.load(open('USER_PROFILE.json'))
missing = [f for f in required if f not in p]
print(','.join(missing))
" 2>/dev/null)
    if [ -z "$MISSING_FIELDS" ]; then
      TIER=$(python3 -c "import json; print(json.load(open('USER_PROFILE.json')).get('generation_tier','unknown'))" 2>/dev/null)
      pass "USER_PROFILE.json has all required fields (tier: $TIER)"
    else
      fail "USER_PROFILE.json missing fields: $MISSING_FIELDS"
    fi
  else
    fail "USER_PROFILE.json is invalid JSON"
  fi
else
  warn "USER_PROFILE.json missing — run bootstrap to create it (onboarding skill)"
fi

echo ""
```

- [ ] **Step 2: Test the validator**

```bash
# Test with valid profile
echo '{"role_type":"developer","tech_level":4,"generation_tier":"developer","workflow_style":"autonomous","primary_goals":["ship faster"]}' > /tmp/test-USER_PROFILE.json
cp /tmp/test-USER_PROFILE.json USER_PROFILE.json
bash scripts/validate.sh 2>&1 | grep -A3 "User Profile"
rm USER_PROFILE.json
```

Expected: lines containing `✓ USER_PROFILE.json exists`, `✓ valid JSON`, `✓ all required fields`.

- [ ] **Step 3: Commit**

```bash
git add scripts/validate.sh
git commit -m "feat(validate): add USER_PROFILE.json validation"
```

---

### Task 6: Update bootstrap.sh to Fix Interactive Mode

**Files:**
- Modify: `scripts/bootstrap.sh`

The current `bootstrap.sh` uses `claude --print` which is non-interactive and can't do the back-and-forth that onboarding requires. Fix it.

- [ ] **Step 1: Replace the claude invocation section**

Find this block in `bootstrap.sh` (around line 127):
```bash
# ─── Run Claude ─────────────────────────────────────────────────
claude --print "
You are the claude-bootstrap orchestrator...
```

Replace with:
```bash
# ─── Run Claude ─────────────────────────────────────────────────
echo -e "${CYAN}Launching Claude Code in interactive mode...${NC}"
echo -e "${YELLOW}Claude will interview you and then generate your setup.${NC}"
echo ""
echo -e "When Claude is done, run: ${CYAN}bash claude-bootstrap/scripts/validate.sh${NC}"
echo ""

# Launch interactive Claude session with the bootstrap instruction pre-loaded
# Claude reads CLAUDE.md and starts the onboarding skill automatically
claude --resume "
You are the claude-bootstrap orchestrator. Your instructions are in claude-bootstrap/CLAUDE.md.
Read that file now, then follow the bootstrap process exactly starting with Step 1 (onboarding skill).
Project root: $(pwd)
"
```

- [ ] **Step 2: Update the post-run instructions**

Find and replace the final echo block:
```bash
echo -e "  Run ${CYAN}bash .claude/hooks/validate.sh${NC} to verify the setup is correct."
```
Replace with:
```bash
echo -e "  Run ${CYAN}bash claude-bootstrap/scripts/validate.sh${NC} to verify the setup is correct."
echo -e "  Read ${CYAN}CLAUDE_SETUP.md${NC} to understand everything that was generated."
```

- [ ] **Step 3: Commit**

```bash
git add scripts/bootstrap.sh
git commit -m "fix(bootstrap): switch from --print to interactive mode for onboarding"
```

---

### Task 7: Add .gitignore Entry for USER_PROFILE.json

**Files:**
- Modify: `.gitignore`

- [ ] **Step 1: Read current .gitignore**

```bash
cat .gitignore
```

- [ ] **Step 2: Add entries**

Add to `.gitignore`:
```
# User-specific profile — do not commit (contains personal info)
USER_PROFILE.json

# Temp files from intake process
/tmp/detected-project.json
/tmp/intake-answers.json
```

- [ ] **Step 3: Commit**

```bash
git add .gitignore
git commit -m "chore: gitignore USER_PROFILE.json (personal data)"
```

---

## Self-Review

**Spec coverage:**
- ✅ Phase A (silent detection) — Task 1
- ✅ Phase B (structured questionnaire 5-8 questions) — Task 3
- ✅ Phase C (profile synthesis) — Tasks 2 + 3
- ✅ Conversational fallback — Task 3 (Phase B conditional questions)
- ✅ USER_PROFILE.json with all fields — Task 2
- ✅ generation_tier inference — Task 2 (infer_generation_tier)
- ✅ workflow_style inference — Task 2 (infer_workflow_style)
- ✅ CLAUDE.md rewrite with onboarding-first — Task 4
- ✅ validate.sh upgrade — Task 5
- ✅ bootstrap.sh interactive fix — Task 6
- ✅ Education elements — Task 3 (Why This Exists, What This Saves You in skill body)

**Placeholder scan:** None found.

**Type consistency:**
- `generation_tier` values: "developer" | "hybrid" | "non-dev" — consistent across write-profile.py, validate.sh, and CLAUDE.md ✓
- `workflow_style` values: "autonomous" | "collaborative" | "supervised" — consistent ✓
- Script paths use `claude-bootstrap/` prefix consistently ✓
