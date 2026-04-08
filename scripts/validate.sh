#!/bin/bash
# validate.sh
# Validates the Claude Code setup after bootstrap.
# Run from your project root: bash scripts/validate.sh
# Or Claude calls this automatically at the end of Step 4.

set -e

ERRORS=0
WARNINGS=0
PASS=0

# ─── Colors ─────────────────────────────────────────────────────
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BOLD='\033[1m'
NC='\033[0m'

pass() { echo -e "  ${GREEN}✓${NC} $1"; PASS=$((PASS+1)); }
warn() { echo -e "  ${YELLOW}⚠${NC} $1"; WARNINGS=$((WARNINGS+1)); }
fail() { echo -e "  ${RED}✗${NC} $1"; ERRORS=$((ERRORS+1)); }

echo ""
echo -e "${BOLD}Validating Claude Code setup...${NC}"
echo ""

# ─── CLAUDE.md ──────────────────────────────────────────────────
echo -e "${BOLD}CLAUDE.md${NC}"

if [ -f "CLAUDE.md" ]; then
  pass "CLAUDE.md exists"
  LINE_COUNT=$(wc -l < CLAUDE.md)
  if [ "$LINE_COUNT" -le 150 ]; then
    pass "CLAUDE.md is $LINE_COUNT lines (≤150 limit)"
  else
    warn "CLAUDE.md is $LINE_COUNT lines — exceeds 150 line recommendation. Claude's attention degrades past this point."
  fi
else
  fail "CLAUDE.md missing — Claude has no project context"
fi

echo ""

# ─── .claude/ directory ─────────────────────────────────────────
echo -e "${BOLD}.claude/ directory${NC}"

if [ -d ".claude" ]; then
  pass ".claude/ directory exists"
else
  fail ".claude/ directory missing"
fi

if [ -f ".claude/settings.json" ]; then
  pass ".claude/settings.json exists"
  # Validate JSON
  if python3 -c "import json; json.load(open('.claude/settings.json'))" 2>/dev/null; then
    pass ".claude/settings.json is valid JSON"
  else
    fail ".claude/settings.json is invalid JSON"
  fi
else
  fail ".claude/settings.json missing — hooks not configured"
fi

echo ""

# ─── Sub-agents ─────────────────────────────────────────────────
echo -e "${BOLD}Sub-agents (.claude/agents/)${NC}"

if [ -d ".claude/agents" ]; then
  AGENT_COUNT=$(ls .claude/agents/*.md 2>/dev/null | wc -l)
  if [ "$AGENT_COUNT" -gt 0 ]; then
    pass "$AGENT_COUNT agent(s) found"
    
    for agent_file in .claude/agents/*.md; do
      AGENT_NAME=$(basename "$agent_file" .md)
      
      # Check required frontmatter fields
      HAS_NAME=$(grep -c "^name:" "$agent_file" 2>/dev/null || echo 0)
      HAS_DESC=$(grep -c "^description:" "$agent_file" 2>/dev/null || echo 0)
      HAS_MODEL=$(grep -c "^model:" "$agent_file" 2>/dev/null || echo 0)
      HAS_TOOLS=$(grep -c "^tools:" "$agent_file" 2>/dev/null || echo 0)
      
      if [ "$HAS_NAME" -gt 0 ] && [ "$HAS_DESC" -gt 0 ] && [ "$HAS_MODEL" -gt 0 ] && [ "$HAS_TOOLS" -gt 0 ]; then
        pass "  $AGENT_NAME — valid (name, description, model, tools present)"
      else
        MISSING=""
        [ "$HAS_NAME" -eq 0 ] && MISSING="$MISSING name"
        [ "$HAS_DESC" -eq 0 ] && MISSING="$MISSING description"
        [ "$HAS_MODEL" -eq 0 ] && MISSING="$MISSING model"
        [ "$HAS_TOOLS" -eq 0 ] && MISSING="$MISSING tools"
        fail "  $AGENT_NAME — missing frontmatter:$MISSING"
      fi
      
      # Check line count
      AGENT_LINES=$(wc -l < "$agent_file")
      if [ "$AGENT_LINES" -gt 400 ]; then
        warn "  $AGENT_NAME is $AGENT_LINES lines — exceeds 400 line recommendation"
      fi
    done
    
    if [ "$AGENT_COUNT" -gt 8 ]; then
      warn "More than 8 agents detected ($AGENT_COUNT) — consider using agent teams for this scale"
    fi
  else
    warn "No agent files found in .claude/agents/ — exploration tasks will use main context"
  fi
else
  warn ".claude/agents/ directory missing"
fi

echo ""

# ─── Skills ─────────────────────────────────────────────────────
echo -e "${BOLD}Skills (.claude/skills/)${NC}"

if [ -d ".claude/skills" ]; then
  SKILL_COUNT=$(find .claude/skills -name "SKILL.md" 2>/dev/null | wc -l)
  if [ "$SKILL_COUNT" -gt 0 ]; then
    pass "$SKILL_COUNT skill(s) found"
    
    for skill_md in $(find .claude/skills -name "SKILL.md"); do
      SKILL_DIR=$(dirname "$skill_md")
      SKILL_NAME=$(basename "$SKILL_DIR")
      
      HAS_NAME=$(grep -c "^name:" "$skill_md" 2>/dev/null || echo 0)
      HAS_DESC=$(grep -c "^description:" "$skill_md" 2>/dev/null || echo 0)
      
      if [ "$HAS_NAME" -gt 0 ] && [ "$HAS_DESC" -gt 0 ]; then
        pass "  $SKILL_NAME — valid"
      else
        fail "  $SKILL_NAME — missing name or description in frontmatter"
      fi
    done
  else
    warn "No SKILL.md files found — manual workflow automation not configured"
  fi
else
  warn ".claude/skills/ directory missing"
fi

echo ""

# ─── Hooks ──────────────────────────────────────────────────────
echo -e "${BOLD}Hooks (.claude/hooks/)${NC}"

if [ -d ".claude/hooks" ]; then
  HOOK_COUNT=$(ls .claude/hooks/*.sh 2>/dev/null | wc -l)
  if [ "$HOOK_COUNT" -gt 0 ]; then
    pass "$HOOK_COUNT hook script(s) found"
    
    for hook_file in .claude/hooks/*.sh; do
      HOOK_NAME=$(basename "$hook_file")
      if [ -x "$hook_file" ]; then
        pass "  $HOOK_NAME — executable"
      else
        warn "  $HOOK_NAME — not executable (run: chmod +x $hook_file)"
      fi
    done
  else
    warn "No hook scripts found"
  fi
else
  warn ".claude/hooks/ directory missing"
fi

# Check hooks are referenced in settings.json
if [ -f ".claude/settings.json" ]; then
  HAS_HOOKS=$(python3 -c "import json; d=json.load(open('.claude/settings.json')); print('yes' if d.get('hooks') else 'no')" 2>/dev/null)
  if [ "$HAS_HOOKS" = "yes" ]; then
    pass "Hooks referenced in settings.json"
  else
    warn "settings.json exists but no hooks configured"
  fi
fi

echo ""

# ─── USER_PROFILE.json ──────────────────────────────────────────
echo -e "${BOLD}User profile${NC}"

if [ -f "USER_PROFILE.json" ]; then
  pass "USER_PROFILE.json exists"
  # Validate JSON
  if python3 -c "import json; json.load(open('USER_PROFILE.json'))" 2>/dev/null; then
    pass "USER_PROFILE.json is valid JSON"
    # Check required fields
    TIER=$(python3 -c "import json; p=json.load(open('USER_PROFILE.json')); print(p.get('generation_tier','MISSING'))" 2>/dev/null)
    if [ "$TIER" = "MISSING" ]; then
      fail "USER_PROFILE.json missing required field: generation_tier"
    elif [ "$TIER" = "developer" ] || [ "$TIER" = "hybrid" ] || [ "$TIER" = "non-dev" ]; then
      pass "generation_tier is valid: $TIER"
    else
      fail "generation_tier has invalid value: $TIER (must be developer|hybrid|non-dev)"
    fi
    TECH=$(python3 -c "import json; p=json.load(open('USER_PROFILE.json')); t=p.get('tech_level',0); print(t)" 2>/dev/null)
    if [ "$TECH" -ge 1 ] && [ "$TECH" -le 5 ] 2>/dev/null; then
      pass "tech_level is valid: $TECH"
    else
      warn "USER_PROFILE.json missing or invalid tech_level"
    fi
  else
    fail "USER_PROFILE.json is invalid JSON"
  fi
else
  warn "USER_PROFILE.json missing — run onboarding first (/onboard or Skill('onboarding'))"
fi

echo ""

# ─── SESSION_STATE.md ───────────────────────────────────────────
echo -e "${BOLD}Session continuity${NC}"

if [ -f "SESSION_STATE.md" ]; then
  pass "SESSION_STATE.md exists"
else
  warn "SESSION_STATE.md missing — create it so Claude can resume sessions after compaction"
fi

echo ""

# ─── Make hooks executable ──────────────────────────────────────
if [ -d ".claude/hooks" ]; then
  chmod +x .claude/hooks/*.sh 2>/dev/null && echo -e "  ${GREEN}✓${NC} Made all hook scripts executable"
fi

# ─── Summary ────────────────────────────────────────────────────
echo ""
echo -e "${BOLD}─────────────────────────────────${NC}"
echo -e "  ${GREEN}✓${NC} Passed:   $PASS"
echo -e "  ${YELLOW}⚠${NC} Warnings: $WARNINGS"
echo -e "  ${RED}✗${NC} Errors:   $ERRORS"
echo -e "${BOLD}─────────────────────────────────${NC}"
echo ""

if [ "$ERRORS" -gt 0 ]; then
  echo -e "${RED}Setup has errors. Fix them before using Claude Code.${NC}"
  exit 1
elif [ "$WARNINGS" -gt 0 ]; then
  echo -e "${YELLOW}Setup is functional but has warnings.${NC}"
  echo "You can proceed — warnings are non-blocking."
  exit 0
else
  echo -e "${GREEN}${BOLD}Setup is valid and ready to use.${NC}"
  echo ""
  echo "Start Claude Code in your project: claude"
  exit 0
fi
