---
name: context-guard
description: "Monitors context window usage and warns when approaching limits. Auto-activates when conversation is getting long or user mentions context/tokens. Suggests compaction strategies."
triggers:
  - context window
  - running out of tokens
  - conversation too long
  - compress context
  - too many tokens
type: auto
---

# Context Guard

You are monitoring the context window. Your job is to protect the user's token budget and keep the conversation efficient.

## When This Activates

This skill activates when:
- The conversation exceeds ~50 messages
- The user mentions context, tokens, or window limits
- You notice you're losing track of earlier conversation content
- You're about to do a large exploration that will flood context

## Assessment

Before warning the user, assess:
1. **How much context is left?** Estimate based on conversation length
2. **What's consuming context?** File dumps? Long tool outputs? Repeated exploration?
3. **What's still needed?** What must stay in context to finish the task?

## Response Protocol

### Warning Level 1 (~60% full)
Mention briefly inline: "Note: context is getting long — I'll keep responses concise."

### Warning Level 2 (~80% full)
Stop and tell the user:
> "Context window is getting full. I recommend we:
> 1. Use `/compact` to compress this conversation
> 2. Or start a new session with a focused prompt
> 3. Or I can summarize what we've done so far"

### Warning Level 3 (~95% full)
Hard stop:
> "Context is nearly full. Please run `/compact` or start a new session before we continue. Here's a summary of what we've accomplished: [brief summary]"

## Prevention Strategies

When you're about to take a context-heavy action, prefer:

1. **Sub-agents** — delegate exploration to an agent whose context is isolated
2. **Targeted reads** — read specific line ranges, not whole files
3. **Structured summaries** — ask sub-agents for bullet summaries, not raw output
4. **Incremental commits** — commit completed work so it's safe to compact

## Compaction Summary Template

When recommending compaction, provide this summary first:

```
## Session Summary (for /compact)
**Goal:** [what the user was trying to accomplish]
**Completed:** [what's done]
**In progress:** [what was being worked on]
**Next steps:** [what to do after compaction]
**Key files:** [files modified or important to the task]
**Decisions made:** [any important choices]
```

## Integration with Sub-Agents

When dispatching sub-agents:
- Always ask for structured summaries, never raw output
- Tell agents: "Return a JSON summary under 20 lines, not the full file contents"
- Never let agent output exceed 500 tokens before summarizing
