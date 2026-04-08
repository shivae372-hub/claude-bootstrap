# Hybrid Tier — Hook Set

Simpler hooks for hybrid users. Focus on safety and session continuity.

## pre-tool-use: confirm-destructive

Pauses before any destructive action and shows a plain-language warning.

```bash
#!/bin/bash
# .claude/hooks/confirm-destructive.sh

TOOL="$1"
INPUT="$2"

if [ "$TOOL" = "Bash" ]; then
  # Flag force pushes
  if echo "$INPUT" | grep -q "\-\-force\|-f"; then
    echo "WARNING: This command uses --force. Claude will ask you to confirm before running."
    exit 1
  fi
  
  # Flag deletions
  if echo "$INPUT" | grep -qE "^rm |^git clean"; then
    echo "WARNING: This command deletes files. Claude will ask you to confirm."
    exit 1
  fi
fi

exit 0
```

## post-tool-use: checkpoint

```bash
#!/bin/bash
# .claude/hooks/checkpoint.sh
# Saves progress so you can resume later.

TOOL="$1"

if [ "$TOOL" = "Write" ] || [ "$TOOL" = "Edit" ]; then
  if [ -f "SESSION_STATE.md" ]; then
    sed -i "s/^Last updated:.*/Last updated: $(date -u +%Y-%m-%dT%H:%M:%SZ)/" SESSION_STATE.md 2>/dev/null || true
  fi
fi

exit 0
```
