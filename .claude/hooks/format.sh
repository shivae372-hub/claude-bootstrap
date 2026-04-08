#!/bin/bash
# PostToolUse hook: format.sh
# Runs the appropriate formatter after Claude writes or edits a file.
# Detects the formatter from project config — never assumes.

INPUT=$(cat)

# Extract the file path that was written
FILEPATH=$(echo "$INPUT" | python3 -c "
import sys, json
d = json.load(sys.stdin)
inp = d.get('tool_input', {})
# Write tool uses 'file_path', Edit uses 'path'
print(inp.get('file_path', inp.get('path', '')))
" 2>/dev/null)

if [ -z "$FILEPATH" ] || [ ! -f "$FILEPATH" ]; then
  exit 0
fi

EXT="${FILEPATH##*.}"

# ─── JavaScript / TypeScript ────────────────────────────────────
if [[ "$EXT" =~ ^(js|jsx|ts|tsx|mjs|cjs)$ ]]; then
  if [ -f "node_modules/.bin/prettier" ]; then
    node_modules/.bin/prettier --write "$FILEPATH" --log-level silent 2>/dev/null
    echo "✨ Formatted: $FILEPATH (prettier)"
  elif [ -f "node_modules/.bin/eslint" ]; then
    node_modules/.bin/eslint --fix "$FILEPATH" 2>/dev/null
    echo "✨ Linted: $FILEPATH (eslint --fix)"
  fi

# ─── Python ─────────────────────────────────────────────────────
elif [ "$EXT" = "py" ]; then
  if command -v ruff &> /dev/null; then
    ruff format "$FILEPATH" 2>/dev/null
    ruff check --fix "$FILEPATH" 2>/dev/null
    echo "✨ Formatted: $FILEPATH (ruff)"
  elif command -v black &> /dev/null; then
    black "$FILEPATH" -q 2>/dev/null
    echo "✨ Formatted: $FILEPATH (black)"
  fi

# ─── Go ─────────────────────────────────────────────────────────
elif [ "$EXT" = "go" ]; then
  if command -v gofmt &> /dev/null; then
    gofmt -w "$FILEPATH" 2>/dev/null
    echo "✨ Formatted: $FILEPATH (gofmt)"
  fi

# ─── Rust ───────────────────────────────────────────────────────
elif [ "$EXT" = "rs" ]; then
  if command -v rustfmt &> /dev/null; then
    rustfmt "$FILEPATH" 2>/dev/null
    echo "✨ Formatted: $FILEPATH (rustfmt)"
  fi

# ─── CSS / SCSS ─────────────────────────────────────────────────
elif [[ "$EXT" =~ ^(css|scss|sass)$ ]]; then
  if [ -f "node_modules/.bin/prettier" ]; then
    node_modules/.bin/prettier --write "$FILEPATH" --log-level silent 2>/dev/null
    echo "✨ Formatted: $FILEPATH (prettier)"
  fi

# ─── JSON ───────────────────────────────────────────────────────
elif [ "$EXT" = "json" ]; then
  if [ -f "node_modules/.bin/prettier" ]; then
    node_modules/.bin/prettier --write "$FILEPATH" --log-level silent 2>/dev/null
    echo "✨ Formatted: $FILEPATH (prettier)"
  fi
fi

exit 0
