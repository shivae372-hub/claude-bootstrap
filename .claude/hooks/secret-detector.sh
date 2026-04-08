#!/bin/bash
# PreToolUse hook: secret-detector.sh
# Scans content being written to files for secrets/credentials.
# Fires on Write and Edit tool calls.

INPUT=$(cat)

# Extract the content being written
CONTENT=$(echo "$INPUT" | python3 -c "
import sys, json
d = json.load(sys.stdin)
tool = d.get('tool_name', '')
inp = d.get('tool_input', {})
# Handle Write tool
if tool == 'Write':
    print(inp.get('content', ''))
# Handle Edit/MultiEdit
elif tool in ('Edit', 'str_replace_based_edit_tool'):
    print(inp.get('new_str', inp.get('new_content', '')))
" 2>/dev/null)

if [ -z "$CONTENT" ]; then
  exit 0
fi

# Check for secret patterns
SECRETS_FOUND=""

check_pattern() {
  local pattern="$1"
  local label="$2"
  if echo "$CONTENT" | grep -qiE "$pattern"; then
    SECRETS_FOUND="$SECRETS_FOUND\n  - $label"
  fi
}

# API Keys
check_pattern 'sk-[a-zA-Z0-9]{20,}' 'OpenAI/Anthropic API key (sk-...)'
check_pattern 'AIza[0-9A-Za-z_-]{35}' 'Google API key'
check_pattern 'AKIA[0-9A-Z]{16}' 'AWS Access Key ID'
check_pattern '[a-z0-9]{32}_secret_[a-z0-9]{32}' 'Stripe-style secret key'
check_pattern 'ghp_[A-Za-z0-9]{36}' 'GitHub Personal Access Token'
check_pattern 'glpat-[A-Za-z0-9_-]{20}' 'GitLab Personal Access Token'

# Generic patterns (check these last - more false positives)
check_pattern '(password|passwd|pwd)\s*[:=]\s*["\x27][^"\x27]{6,}["\x27]' 'Hardcoded password'
check_pattern '(secret|api_key|apikey|auth_token)\s*[:=]\s*["\x27][A-Za-z0-9_-]{10,}["\x27]' 'Hardcoded secret/key'
check_pattern 'postgres://[^:]+:[^@]+@' 'Database connection string with credentials'
check_pattern 'mongodb\+srv://[^:]+:[^@]+@' 'MongoDB connection string with credentials'

if [ -n "$SECRETS_FOUND" ]; then
  echo "🔐 SECRET DETECTOR: Potential credentials found in content being written:"
  echo -e "$SECRETS_FOUND"
  echo ""
  echo "If these are real credentials, DO NOT write them to files."
  echo "Use environment variables instead: process.env.MY_SECRET"
  echo "If this is example/placeholder content, it's safe to proceed."
  echo ""
  echo "Blocking write. Confirm this is intentional before proceeding manually."
  exit 2
fi

exit 0
