---
name: tips
description: Surfaces contextual tips from docs/tips.json based on user's tech level and current activity. Invoked by analyze-repo, or manually with /tips. Teaches users how to get more from Claude Code.
triggers:
  - /tips
  - show me tips
  - how can I get better at this
  - what am I doing wrong
  - help me use claude better
type: manual
---

# Tips Skill

You are surfacing personalized tips to help the user get more value from Claude Code.

## Step 1 — Load Context

Read `USER_PROFILE.json` if it exists:
```bash
python3 -c "
import json, pathlib
p = pathlib.Path('USER_PROFILE.json')
if p.exists():
    d = json.loads(p.read_text())
    print(f'tech_level={d.get(\"tech_level\",3)}')
    print(f'tier={d.get(\"generation_tier\",\"developer\")}')
    print(f'goals={d.get(\"primary_goals\",[])}')
else:
    print('tech_level=3')
    print('tier=developer')
    print('goals=[]')
"
```

## Step 2 — Load Tips

Read `claude-bootstrap/docs/tips.json` (or `docs/tips.json` if in the bootstrap repo itself).

Filter tips where `min_tech_level <= user_tech_level <= max_tech_level`.

## Step 3 — Select Relevant Tips

Pick 3-5 tips using this priority:

1. **Category match** — If the user asked about a specific topic (tokens, workflow, etc.), prioritize that category
2. **Recent activity** — If Claude recently did exploration, prioritize tokens tips; if just deployed, prioritize safety tips
3. **Goals alignment** — If user's goals include "ship faster", prioritize workflow/productivity tips
4. **Novelty** — Prefer tips the user hasn't seen recently (track in SESSION_STATE.md if available)

## Step 4 — Present Tips

Format as a clean, scannable list:

```
## Tips for You

**[Category]**
💡 [tip text]
→ [example]

**[Category]**
💡 [tip text]
→ [example]

[etc.]
```

End with:
> "Want tips on a specific topic? Ask me about: tokens, workflow, quality, prompting, setup, productivity, or safety."

## Tracking Seen Tips

If SESSION_STATE.md exists, append seen tip IDs to prevent repetition:
```
## Tips Shown
[id1, id2, id3]
```

## When to Surface Tips Automatically

This skill is also called by `analyze-repo` at the end of a session analysis. In that context:
- Show only 2-3 tips (not 5)
- Focus on the most impactful category for this specific project
- Label them as "Quick wins for this setup"
