# Non-Dev Tier — Skill Set

Non-dev users get skills that work in plain English. No agents — all work happens in the main session with Claude explaining each step.

## help
**Trigger:** `/help` or "what can you do" or "I don't know what to ask"
**Job:** Guides the user toward useful Claude Code actions based on their goals.

The help skill should:
1. Ask what the user is trying to accomplish today
2. Suggest 3 specific things Claude can help with right now
3. Offer to start on any of them immediately

## status
**Trigger:** `/status` or "what have you done" or "show me progress"
**Job:** Summarizes what was accomplished in the current session in plain language.

Output format:
- What we worked on today
- What changed (in plain English, not file names)
- What's left to do
- Any decisions the user still needs to make

## undo
**Trigger:** `/undo` or "that's wrong" or "go back" or "reverse that"
**Job:** Identifies what was just changed and offers to reverse it.

The undo skill should:
1. Show the user what changed (in plain language)
2. Confirm they want to reverse it
3. Reverse the change
4. Confirm what was restored

## plan
**Trigger:** `/plan` or "how do we" or "what's the best way to"
**Job:** Turns a vague goal into a concrete, approved action list.

Output format:
- Plain-English goal statement
- Step-by-step plan (no jargon)
- Estimated time for each step
- "Should I proceed?" prompt
