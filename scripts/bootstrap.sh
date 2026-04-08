#!/bin/bash
# bootstrap.sh
# Alternative entry point: runs the Claude Code bootstrap directly.
# Usage: bash claude-bootstrap/scripts/bootstrap.sh
# Must be run from your PROJECT ROOT (not from inside claude-bootstrap/).

set -e

# ─── Colors ─────────────────────────────────────────────────────
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m' # No Color

# ─── Header ─────────────────────────────────────────────────────
echo ""
echo -e "${CYAN}${BOLD}╔══════════════════════════════════════════════╗${NC}"
echo -e "${CYAN}${BOLD}║       claude-bootstrap · Project Setup       ║${NC}"
echo -e "${CYAN}${BOLD}╚══════════════════════════════════════════════╝${NC}"
echo ""

# ─── Verify location ────────────────────────────────────────────
if [ ! -d "claude-bootstrap" ]; then
  echo -e "${RED}Error: Run this from your project root.${NC}"
  echo "Expected: your-project/claude-bootstrap/scripts/bootstrap.sh"
  echo "Run from: your-project/"
  exit 1
fi

echo -e "${BLUE}Project root:${NC} $(pwd)"
echo -e "${BLUE}Detected files:${NC}"
ls -1 | head -20
echo ""

# ─── Check for Claude Code ──────────────────────────────────────
if ! command -v claude &> /dev/null; then
  echo -e "${RED}Error: Claude Code is not installed.${NC}"
  echo "Install it: https://code.claude.com"
  exit 1
fi

CLAUDE_VERSION=$(claude --version 2>/dev/null || echo "unknown")
echo -e "${GREEN}✓ Claude Code found:${NC} $CLAUDE_VERSION"
echo ""

# ─── Pre-flight checks ──────────────────────────────────────────
echo -e "${BOLD}Pre-flight checks:${NC}"

# Check for USER_PROFILE.json
if [ -f "USER_PROFILE.json" ]; then
  TIER=$(python3 -c "import json; p=json.load(open('USER_PROFILE.json')); print(p.get('generation_tier','unknown'))" 2>/dev/null || echo "unknown")
  echo -e "${GREEN}✓  User profile found${NC} (tier: $TIER)"
  NEEDS_ONBOARDING=false
else
  echo -e "${YELLOW}⚠  No USER_PROFILE.json found — onboarding will run first${NC}"
  NEEDS_ONBOARDING=true
fi

# Check if .claude already exists
if [ -d ".claude" ]; then
  echo -e "${YELLOW}⚠  .claude/ directory already exists${NC}"
  echo "   Bootstrap will extend (not overwrite) existing configuration."
  EXISTING=true
else
  echo -e "${GREEN}✓  No existing .claude/ — clean setup${NC}"
  EXISTING=false
fi

# Check for git
if command -v git &> /dev/null && [ -d ".git" ]; then
  echo -e "${GREEN}✓  Git repository detected${NC}"
  BRANCH=$(git branch --show-current 2>/dev/null || echo "unknown")
  echo "   Current branch: $BRANCH"
else
  echo -e "${YELLOW}⚠  No git repository — some features (git-workflow skill, hooks) will have limited functionality${NC}"
fi

# Detect stack
echo ""
echo -e "${BOLD}Stack detection:${NC}"
if [ -f "package.json" ]; then
  FRAMEWORK=$(python3 -c "
import json, sys
try:
  d = json.load(open('package.json'))
  deps = {**d.get('dependencies',{}), **d.get('devDependencies',{})}
  frameworks = []
  if 'next' in deps: frameworks.append('Next.js ' + deps['next'].lstrip('^~'))
  if 'react' in deps and 'next' not in deps: frameworks.append('React ' + deps['react'].lstrip('^~'))
  if 'vue' in deps: frameworks.append('Vue ' + deps['vue'].lstrip('^~'))
  if 'express' in deps: frameworks.append('Express')
  if 'fastify' in deps: frameworks.append('Fastify')
  if '@supabase/supabase-js' in deps: frameworks.append('Supabase')
  if 'prisma' in deps or '@prisma/client' in deps: frameworks.append('Prisma')
  if 'drizzle-orm' in deps: frameworks.append('Drizzle')
  print(', '.join(frameworks) if frameworks else 'Node.js')
except: print('Node.js')
" 2>/dev/null || echo "Node.js")
  echo -e "${GREEN}✓  Node.js project:${NC} $FRAMEWORK"
elif [ -f "pyproject.toml" ] || [ -f "requirements.txt" ]; then
  echo -e "${GREEN}✓  Python project detected${NC}"
elif [ -f "Cargo.toml" ]; then
  echo -e "${GREEN}✓  Rust project detected${NC}"
elif [ -f "go.mod" ]; then
  echo -e "${GREEN}✓  Go project detected${NC}"
elif [ -f "pom.xml" ] || [ -f "build.gradle" ]; then
  echo -e "${GREEN}✓  JVM project detected${NC}"
else
  echo -e "${YELLOW}⚠  Could not auto-detect stack — Claude will detect during analysis${NC}"
fi

echo ""

# ─── Confirm ────────────────────────────────────────────────────
echo -e "${BOLD}What will happen:${NC}"
echo "  1. Claude reads your entire project"
echo "  2. Claude shows you a blueprint of what it will create"
echo "  3. You confirm (or modify) the blueprint"
echo "  4. Claude generates all .claude/ files, CLAUDE.md, and SESSION_STATE.md"
echo "  5. Claude validates the output"
echo ""

read -p "$(echo -e ${BOLD})Ready to bootstrap? (y/N): $(echo -e ${NC})" CONFIRM
if [[ "$CONFIRM" != "y" && "$CONFIRM" != "Y" ]]; then
  echo "Cancelled."
  exit 0
fi

echo ""
echo -e "${CYAN}Starting bootstrap...${NC}"
echo ""

# ─── Run Claude ─────────────────────────────────────────────────
if [ "$NEEDS_ONBOARDING" = "true" ]; then
  echo -e "${CYAN}Running onboarding first (no USER_PROFILE.json found)...${NC}"
  echo ""
  claude --print "
You are the claude-bootstrap orchestrator. Your instructions are in claude-bootstrap/CLAUDE.md.

USER_PROFILE.json does not exist yet. Run the onboarding skill first:
  Skill('onboarding')

After onboarding completes and USER_PROFILE.json is written, continue with the full 7-step bootstrap process from CLAUDE.md.

Project root: $(pwd)
Bootstrap repo: $(pwd)/claude-bootstrap/
Format specs: $(pwd)/claude-bootstrap/docs/FORMATS.md
"
else
  claude --print "
You are the claude-bootstrap orchestrator. Your instructions are in claude-bootstrap/CLAUDE.md — read that file first, then follow the 7-step bootstrap process exactly.

USER_PROFILE.json already exists — skip onboarding (Step 1 is already complete).

The project to bootstrap is this directory: $(pwd)
The bootstrap repo is at: $(pwd)/claude-bootstrap/
Format specs are at: $(pwd)/claude-bootstrap/docs/FORMATS.md

Begin at Step 2.
"
fi

echo ""
echo -e "${GREEN}${BOLD}Bootstrap complete!${NC}"
echo ""
echo -e "${BOLD}Next steps:${NC}"
echo "  1. Review the generated .claude/ directory"
echo "  2. Read your new CLAUDE.md"
echo "  3. Commit the setup: git add .claude/ CLAUDE.md SESSION_STATE.md && git commit -m 'chore: add Claude Code professional setup'"
echo "  4. (Optional) Delete the claude-bootstrap/ folder — it's no longer needed"
echo ""
echo -e "  Run ${CYAN}bash claude-bootstrap/scripts/validate.sh${NC} to verify the setup is correct."
echo ""
