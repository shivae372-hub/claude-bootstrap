# Developer Tier — Hook Set

Hooks run as shell scripts with zero context window cost.

## pre-tool-use: block-dangerous

Blocks destructive commands before they execute.

```bash
#!/bin/bash
# .claude/hooks/block-dangerous.sh
# Blocks dangerous commands before execution.

TOOL="$1"
INPUT="$2"

if [ "$TOOL" = "Bash" ]; then
  # Block force push to main
  if echo "$INPUT" | grep -q "push.*--force.*main\|push.*-f.*main"; then
    echo "BLOCKED: Force push to main is not allowed."
    exit 1
  fi
  
  # Block rm -rf on important directories
  if echo "$INPUT" | grep -qE "rm -rf \./?\s*$|rm -rf (src|app|lib|pages|components)"; then
    echo "BLOCKED: Destructive rm -rf detected. Confirm with user first."
    exit 1
  fi
  
  # Block dropping databases
  if echo "$INPUT" | grep -qi "DROP DATABASE\|DROP TABLE.*CASCADE"; then
    echo "BLOCKED: Destructive database operation. Confirm with user first."
    exit 1
  fi
fi

exit 0
```

## post-tool-use: auto-format

Runs formatter after file edits.

```bash
#!/bin/bash
# .claude/hooks/auto-format.sh
# Auto-formats files after edits.

TOOL="$1"
FILE="$2"

if [ "$TOOL" = "Edit" ] || [ "$TOOL" = "Write" ]; then
  EXT="${FILE##*.}"
  
  case "$EXT" in
    js|jsx|ts|tsx|json|css|md)
      if command -v prettier &>/dev/null; then
        prettier --write "$FILE" 2>/dev/null
      fi
      ;;
    py)
      if command -v black &>/dev/null; then
        black "$FILE" 2>/dev/null
      fi
      ;;
    go)
      gofmt -w "$FILE" 2>/dev/null
      ;;
    rs)
      rustfmt "$FILE" 2>/dev/null
      ;;
  esac
fi

exit 0
```

## post-tool-use: checkpoint

Saves session state after significant actions.

```bash
#!/bin/bash
# .claude/hooks/checkpoint.sh
# Updates SESSION_STATE.md after file writes.

TOOL="$1"

if [ "$TOOL" = "Write" ] || [ "$TOOL" = "Edit" ]; then
  if [ -f "SESSION_STATE.md" ]; then
    # Update the last-modified timestamp
    sed -i "s/^Last updated:.*/Last updated: $(date -u +%Y-%m-%dT%H:%M:%SZ)/" SESSION_STATE.md 2>/dev/null || true
  fi
fi

exit 0
```
