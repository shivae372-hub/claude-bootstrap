#!/bin/bash
# PreToolUse hook: safety-check.sh
# Blocks dangerous bash commands before they execute.
# Receives JSON on stdin. Exit 2 to block, exit 0 to allow.

INPUT=$(cat)
COMMAND=$(echo "$INPUT" | python3 -c "import sys,json; d=json.load(sys.stdin); print(d.get('tool_input',{}).get('command',''))" 2>/dev/null)

if [ -z "$COMMAND" ]; then
  exit 0
fi

# ─── Hard Blocks ───────────────────────────────────────────────
# These are blocked 100% of the time, no exceptions.

BLOCKED_PATTERNS=(
  "rm -rf /"
  "rm -rf ~"
  "rm -rf \$HOME"
  "git push --force"
  "git push -f "
  "DROP TABLE"
  "DROP DATABASE"
  "TRUNCATE TABLE"
  "DELETE FROM .* WHERE .* 1=1"
  "format c:"
  "dd if=/dev/zero"
  "> /dev/sda"
  "chmod -R 777 /"
)

for pattern in "${BLOCKED_PATTERNS[@]}"; do
  if echo "$COMMAND" | grep -qiE "$pattern"; then
    echo "🚫 BLOCKED: Dangerous command detected: '$pattern'"
    echo "If you genuinely need to run this, do it manually in your terminal."
    exit 2
  fi
done

# ─── Warnings (Allow but flag) ──────────────────────────────────
WARNING_PATTERNS=(
  "git push --force-with-lease"
  "rm -rf node_modules"
  "rm -rf .next"
  "npm install"
  "pip install"
)

for pattern in "${WARNING_PATTERNS[@]}"; do
  if echo "$COMMAND" | grep -qiE "$pattern"; then
    echo "⚠️  WARNING: '$pattern' detected. Proceeding, but verify this is intentional."
    # Exit 0 — allow, but Claude sees the warning
    exit 0
  fi
done

exit 0
