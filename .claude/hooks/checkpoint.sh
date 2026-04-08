#!/bin/bash
# checkpoint.sh
# Post-tool-use hook: updates SESSION_STATE.md after significant actions.
# Also detects CLAUDE.md drift (file growing too long).
#
# Called by Claude Code after each tool use:
#   $1 = tool name (Write, Edit, Bash, etc.)
#   $2 = file path (for Write/Edit) or command (for Bash)

TOOL="$1"
FILE="$2"

# ─── Only act on write operations ────────────────────────────────
if [ "$TOOL" != "Write" ] && [ "$TOOL" != "Edit" ]; then
  exit 0
fi

# ─── Update SESSION_STATE.md timestamp ───────────────────────────
if [ -f "SESSION_STATE.md" ]; then
  # Update the last-modified timestamp (works on both Linux and macOS)
  if sed --version 2>/dev/null | grep -q GNU; then
    # GNU sed (Linux)
    sed -i "s/^Last updated:.*/Last updated: $(date -u +%Y-%m-%dT%H:%M:%SZ)/" SESSION_STATE.md 2>/dev/null || true
  else
    # BSD sed (macOS) — requires empty string after -i
    sed -i '' "s/^Last updated:.*/Last updated: $(date -u +%Y-%m-%dT%H:%M:%SZ)/" SESSION_STATE.md 2>/dev/null || true
  fi
fi

# ─── CLAUDE.md drift detection ───────────────────────────────────
if [ -f "CLAUDE.md" ]; then
  LINE_COUNT=$(wc -l < "CLAUDE.md")

  if [ "$LINE_COUNT" -gt 150 ]; then
    echo ""
    echo "⚠  CLAUDE.md DRIFT DETECTED"
    echo "   CLAUDE.md is now $LINE_COUNT lines (limit: 150)"
    echo "   Claude's attention degrades past 150 lines."
    echo "   Run: /trim-claude-md to compact it"
    echo ""
  fi
fi

# ─── Track modified files in SESSION_STATE.md ────────────────────
if [ -n "$FILE" ] && [ -f "SESSION_STATE.md" ] && [ -f "$FILE" ]; then
  # Add to modified files list if not already there
  # Only track files in the project (not /tmp or system files)
  if [[ "$FILE" != /tmp/* ]] && [[ "$FILE" != /var/* ]]; then
    BASENAME=$(basename "$FILE")

    # Check if Files Modified section exists
    if grep -q "^## Files Modified" SESSION_STATE.md 2>/dev/null; then
      # Check if this file is already listed
      if ! grep -q "^\- $BASENAME" SESSION_STATE.md 2>/dev/null; then
        # Append to the section (simple approach: add after the header)
        if sed --version 2>/dev/null | grep -q GNU; then
          sed -i "/^## Files Modified/a\- $BASENAME" SESSION_STATE.md 2>/dev/null || true
        else
          sed -i '' "/^## Files Modified/a\\
- $BASENAME" SESSION_STATE.md 2>/dev/null || true
        fi
      fi
    fi
  fi
fi

exit 0
