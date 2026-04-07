#!/bin/bash
# detect-project.sh
# Phase A of intake: silently scans the parent directory for project signals.
# Outputs a JSON object to stdout. No user interaction.
# Run from the project root (parent of claude-bootstrap/).

set -e

PROJECT_ROOT="${1:-$(pwd)}"

# ─── Detection helpers ────────────────────────────────────────────
has_file() { [ -f "$PROJECT_ROOT/$1" ] && echo "true" || echo "false"; }
has_dir()  { [ -d "$PROJECT_ROOT/$1" ] && echo "true" || echo "false"; }
has_glob() { ls "$PROJECT_ROOT"/$1 2>/dev/null | head -1 | grep -q . && echo "true" || echo "false"; }

# ─── Stack detection ─────────────────────────────────────────────
STACK="[]"
LANG="unknown"
PKG_MANAGER="unknown"
TEST_RUNNER="unknown"
HAS_PROJECT="false"
HAS_EXISTING_CLAUDE="false"

# Node / JavaScript / TypeScript
if [ -f "$PROJECT_ROOT/package.json" ]; then
  HAS_PROJECT="true"
  LANG="javascript"
  # Detect package manager
  if [ -f "$PROJECT_ROOT/pnpm-lock.yaml" ]; then PKG_MANAGER="pnpm"
  elif [ -f "$PROJECT_ROOT/yarn.lock" ]; then PKG_MANAGER="yarn"
  else PKG_MANAGER="npm"; fi
  # Detect framework
  FRAMEWORKS=$(python3 -c "
import json, sys
try:
  d = json.load(open('$PROJECT_ROOT/package.json'))
  deps = {**d.get('dependencies',{}), **d.get('devDependencies',{})}
  f = []
  if 'next' in deps: f.append('nextjs')
  if 'react' in deps and 'next' not in deps: f.append('react')
  if 'vue' in deps: f.append('vue')
  if 'svelte' in deps: f.append('svelte')
  if 'express' in deps: f.append('express')
  if 'fastify' in deps: f.append('fastify')
  if 'hono' in deps: f.append('hono')
  if '@supabase/supabase-js' in deps: f.append('supabase')
  if '@prisma/client' in deps or 'prisma' in deps: f.append('prisma')
  if 'drizzle-orm' in deps: f.append('drizzle')
  if 'jest' in deps: print('jest', end='')
  elif 'vitest' in deps: print('vitest', end='')
  print('|' + ','.join(f))
except: print('|')
" 2>/dev/null)
  TEST_RUNNER=$(echo "$FRAMEWORKS" | cut -d'|' -f1)
  STACK=$(echo "$FRAMEWORKS" | cut -d'|' -f2 | python3 -c "import sys; items=sys.stdin.read().strip().split(','); print('[' + ','.join('\"'+i+'\"' for i in items if i) + ']')")
  [ -z "$TEST_RUNNER" ] && TEST_RUNNER="unknown"
fi

# Python
if [ -f "$PROJECT_ROOT/pyproject.toml" ] || [ -f "$PROJECT_ROOT/requirements.txt" ] || [ -f "$PROJECT_ROOT/setup.py" ]; then
  HAS_PROJECT="true"
  LANG="python"
  PKG_MANAGER="pip"
  [ -f "$PROJECT_ROOT/pyproject.toml" ] && PKG_MANAGER="uv_or_poetry"
  # Detect Python frameworks
  PYSTACK=$(python3 -c "
import sys
content = ''
for f in ['$PROJECT_ROOT/pyproject.toml','$PROJECT_ROOT/requirements.txt']:
  try:
    content += open(f).read()
  except: pass
f = []
if 'fastapi' in content.lower(): f.append('fastapi')
if 'django' in content.lower(): f.append('django')
if 'flask' in content.lower(): f.append('flask')
if 'pandas' in content.lower(): f.append('pandas')
if 'numpy' in content.lower(): f.append('numpy')
if 'pytest' in content.lower(): print('pytest', end='')
print('|' + ','.join(f))
" 2>/dev/null)
  TEST_RUNNER=$(echo "$PYSTACK" | cut -d'|' -f1)
  STACK=$(echo "$PYSTACK" | cut -d'|' -f2 | python3 -c "import sys; items=sys.stdin.read().strip().split(','); print('[' + ','.join('\"'+i+'\"' for i in items if i) + ']')")
  [ -z "$TEST_RUNNER" ] && TEST_RUNNER="pytest"
fi

# Go
if [ -f "$PROJECT_ROOT/go.mod" ]; then
  HAS_PROJECT="true"; LANG="go"; PKG_MANAGER="go_modules"; TEST_RUNNER="go_test"
  STACK='["go"]'
fi

# Rust
if [ -f "$PROJECT_ROOT/Cargo.toml" ]; then
  HAS_PROJECT="true"; LANG="rust"; PKG_MANAGER="cargo"; TEST_RUNNER="cargo_test"
  STACK='["rust"]'
fi

# Ruby
if [ -f "$PROJECT_ROOT/Gemfile" ]; then
  HAS_PROJECT="true"; LANG="ruby"; PKG_MANAGER="bundler"
  grep -q "rspec" "$PROJECT_ROOT/Gemfile" 2>/dev/null && TEST_RUNNER="rspec" || TEST_RUNNER="minitest"
  STACK='["ruby"]'
fi

# Java / Kotlin
if [ -f "$PROJECT_ROOT/pom.xml" ] || [ -f "$PROJECT_ROOT/build.gradle" ] || [ -f "$PROJECT_ROOT/build.gradle.kts" ]; then
  HAS_PROJECT="true"; LANG="java"; PKG_MANAGER="maven_or_gradle"; TEST_RUNNER="junit"
  STACK='["java"]'
fi

# Existing Claude setup
[ -d "$PROJECT_ROOT/.claude" ] && HAS_EXISTING_CLAUDE="true"

# File count (rough size signal)
FILE_COUNT=$(find "$PROJECT_ROOT" -not -path '*/node_modules/*' -not -path '*/.git/*' -not -path '*/claude-bootstrap/*' -not -path '*/__pycache__/*' -type f 2>/dev/null | wc -l | tr -d ' ')

# ─── Output JSON ─────────────────────────────────────────────────
cat << EOF
{
  "has_project": $HAS_PROJECT,
  "has_existing_claude": $HAS_EXISTING_CLAUDE,
  "language": "$LANG",
  "stack": $STACK,
  "package_manager": "$PKG_MANAGER",
  "test_runner": "$TEST_RUNNER",
  "file_count": $FILE_COUNT
}
EOF
