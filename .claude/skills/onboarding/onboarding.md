---
name: onboarding
description: First-run user onboarding. Asks 6 questions, detects project, writes USER_PROFILE.json, then routes to the right bootstrap template.
triggers:
  - "first time"
  - "new user"
  - "who am I"
  - "set up for me"
  - "I'm new"
  - "/onboard"
type: manual
---

# Onboarding Skill

You are running the first-time onboarding flow for a new Claude Code user.

## Goal
Collect enough information to:
1. Understand who this person is and what they need
2. Detect their current project (if any)
3. Write USER_PROFILE.json
4. Route them to the right bootstrap experience

## Step 1 — Greet and Set Expectations

Say exactly this (adapt tone slightly based on context):

> "Welcome! I'm going to ask you 6 quick questions so I can set up Claude Code perfectly for how YOU work. This takes about 2 minutes and you only do it once."

## Step 2 — Ask the 6 Questions

Ask these questions ONE AT A TIME. Wait for the answer before asking the next.

**Q1 — Role**
> "What's your primary role? (e.g., developer, founder, designer, product manager, data scientist, student, other)"

**Q2 — Tech Level**
> "How comfortable are you with code and terminal? Rate yourself 1–5:
> 1 = I avoid the terminal
> 2 = I can follow instructions
> 3 = I'm comfortable with basics
> 4 = I write code regularly
> 5 = Senior engineer / I live in the terminal"

**Q3 — Team**
> "Are you working solo or with a team? (solo / small team 2-5 / larger team)"

**Q4 — Domain**
> "What's your primary domain? (software / design / ops / marketing / research / other)"

**Q5 — Goals**
> "What are your top 1-3 goals for using Claude Code? (e.g., 'ship faster', 'automate reports', 'learn to code', 'manage my team's PRs')"

**Q6 — Success**
> "What would success look like in 30 days? One sentence is fine."

## Step 3 — Detect Project

After collecting answers, run the project detection script:

```bash
python3 .claude/skills/onboarding/scripts/detect-project.py --output /tmp/detected.json
```

If the script fails or doesn't exist, set detected = `{"has_project": false}`.

## Step 4 — Write Profile

Run the profile writer with the collected answers:

```bash
echo '<answers_json>' | python3 .claude/skills/onboarding/scripts/write-profile.py \
  --detected /tmp/detected.json \
  --output USER_PROFILE.json
```

Where `<answers_json>` is a JSON object with keys:
- `role_type` (string)
- `tech_level` (integer 1-5)
- `team_size` ("solo" | "small" | "large")
- `domain` (string)
- `primary_goals` (array of strings)
- `success_in_30_days` (string)

## Step 5 — Route to Bootstrap

Read USER_PROFILE.json and check `generation_tier`:

- **developer** → Say: "Great — you're set up for developer mode. Run `/bootstrap` to generate your full Claude Code setup."
- **hybrid** → Say: "Perfect — you're set up for hybrid mode. You'll get a simplified but powerful setup. Run `/bootstrap` to continue."
- **non-dev** → Say: "You're all set! I'll set up Claude Code to work in plain English for you. Run `/bootstrap` to continue."

## Step 6 — Confirm

Show a brief summary:
> "Profile saved! Here's what I've got:
> - Role: [role_type]
> - Tech level: [tech_level]/5
> - Tier: [generation_tier]
> - Stack detected: [stack or 'none']
>
> Run `/bootstrap` when ready to generate your setup."

## Error Handling

- If a question answer is ambiguous, ask a quick clarifying follow-up
- If the profile writer fails, show the error and ask the user to fix it manually
- If USER_PROFILE.json already exists, ask: "I found an existing profile. Update it or keep it? (update/keep)"
