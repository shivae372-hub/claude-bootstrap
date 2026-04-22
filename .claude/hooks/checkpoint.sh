#!/bin/bash
# checkpoint.sh
# PreCompact hook: saves session state before context compaction.
# Also detects CLAUDE.md drift (file growing too long).
# Receives JSON on stdin per the Claude Code hook contract.

INPUT=$(cat)

TOOL=$(echo "$INPUT" | python3 -c "
import sys, json
d = json.load(sys.stdin)
print(d.get('tool_name', ''))
" 2>/dev/null)

FILE=$(echo "$INPUT" | python3 -c "
import sys, json
d = json.load(sys.stdin)
inp = d.get('tool_input', {})
print(inp.get('file_path', inp.get('path', '')))
" 2>/dev/null)

# ─── Only act on write operations ────────────────────────────────
if [ "$TOOL" != "Write" ] && [ "$TOOL" != "Edit" ] && [ "$TOOL" != "str_replace_based_edit_tool" ]; then
  exit 0
fi

# ─── Update SESSION_STATE.md timestamp ───────────────────────────
if [ -f "SESSION_STATE.md" ]; then
  TIMESTAMP=$(date -u +%Y-%m-%dT%H:%M:%SZ)
  if sed --version 2>/dev/null | grep -q GNU; then
    sed -i "s/^## Last updated:.*/## Last updated: $TIMESTAMP/" SESSION_STATE.md 2>/dev/null || true
  else
    sed -i '' "s/^## Last updated:.*/## Last updated: $TIMESTAMP/" SESSION_STATE.md 2>/dev/null || true
  fi
fi

# ─── CLAUDE.md drift detection ───────────────────────────────────
if [ -f "CLAUDE.md" ]; then
  LINE_COUNT=$(wc -l < "CLAUDE.md")
  if [ "$LINE_COUNT" -gt 150 ]; then
    echo ""
    echo "WARNING: CLAUDE.md DRIFT DETECTED"
    echo "  CLAUDE.md is now $LINE_COUNT lines (limit: 150)"
    echo "  Claude's attention degrades past 150 lines."
    echo "  Consider running: /trim-claude-md"
    echo ""
  fi
fi

# ─── Track modified files in SESSION_STATE.md ────────────────────
if [ -n "$FILE" ] && [ -f "SESSION_STATE.md" ] && [ -f "$FILE" ]; then
  if [[ "$FILE" != /tmp/* ]] && [[ "$FILE" != /var/* ]]; then
    BASENAME=$(basename "$FILE")
    if grep -q "^## Files Modified" SESSION_STATE.md 2>/dev/null; then
      if ! grep -q "^- $BASENAME" SESSION_STATE.md 2>/dev/null; then
        if sed --version 2>/dev/null | grep -q GNU; then
          sed -i "/^## Files Modified/a\\- $BASENAME" SESSION_STATE.md 2>/dev/null || true
        else
          sed -i '' "/^## Files Modified/a\\
- $BASENAME" SESSION_STATE.md 2>/dev/null || true
        fi
      fi
    fi
  fi
fi

exit 0
