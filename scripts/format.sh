#!/bin/bash
# format.sh
# Auto-formats source files in the project.
# Usage: bash scripts/format.sh [file]
#   With no argument: formats all supported files
#   With file argument: formats just that file

set -e

# ─── Colors ─────────────────────────────────────────────────────
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BOLD='\033[1m'
NC='\033[0m'

FORMATTED=0
SKIPPED=0

format_file() {
  local FILE="$1"
  local EXT="${FILE##*.}"

  case "$EXT" in
    js|jsx|ts|tsx|json|css|scss|md|yaml|yml)
      if command -v prettier &>/dev/null; then
        prettier --write "$FILE" 2>/dev/null && FORMATTED=$((FORMATTED+1))
      else
        SKIPPED=$((SKIPPED+1))
      fi
      ;;
    py)
      if command -v black &>/dev/null; then
        black "$FILE" 2>/dev/null && FORMATTED=$((FORMATTED+1))
      elif command -v autopep8 &>/dev/null; then
        autopep8 --in-place "$FILE" 2>/dev/null && FORMATTED=$((FORMATTED+1))
      else
        SKIPPED=$((SKIPPED+1))
      fi
      ;;
    go)
      if command -v gofmt &>/dev/null; then
        gofmt -w "$FILE" && FORMATTED=$((FORMATTED+1))
        # Also run goimports if available
        command -v goimports &>/dev/null && goimports -w "$FILE" 2>/dev/null || true
      else
        SKIPPED=$((SKIPPED+1))
      fi
      ;;
    rs)
      if command -v rustfmt &>/dev/null; then
        rustfmt "$FILE" && FORMATTED=$((FORMATTED+1))
      else
        SKIPPED=$((SKIPPED+1))
      fi
      ;;
    rb)
      if command -v rubocop &>/dev/null; then
        rubocop --autocorrect "$FILE" 2>/dev/null && FORMATTED=$((FORMATTED+1))
      elif command -v standardrb &>/dev/null; then
        standardrb --fix "$FILE" 2>/dev/null && FORMATTED=$((FORMATTED+1))
      else
        SKIPPED=$((SKIPPED+1))
      fi
      ;;
    java)
      # Try google-java-format first, then spotless via Maven/Gradle
      if command -v google-java-format &>/dev/null; then
        google-java-format --replace "$FILE" && FORMATTED=$((FORMATTED+1))
      elif [ -f "pom.xml" ] && command -v mvn &>/dev/null; then
        # Spotless via Maven (formats whole project, not single file)
        echo -e "  ${YELLOW}⚠${NC}  Java: running mvn spotless:apply (formats all Java files)"
        mvn spotless:apply -q 2>/dev/null && FORMATTED=$((FORMATTED+1)) || SKIPPED=$((SKIPPED+1))
      elif [ -f "build.gradle" ] || [ -f "build.gradle.kts" ]; then
        echo -e "  ${YELLOW}⚠${NC}  Java: running gradle spotlessApply (formats all Java files)"
        ./gradlew spotlessApply -q 2>/dev/null && FORMATTED=$((FORMATTED+1)) || SKIPPED=$((SKIPPED+1))
      else
        SKIPPED=$((SKIPPED+1))
      fi
      ;;
    kt|kts)
      # Kotlin — ktlint
      if command -v ktlint &>/dev/null; then
        ktlint --format "$FILE" 2>/dev/null && FORMATTED=$((FORMATTED+1))
      else
        SKIPPED=$((SKIPPED+1))
      fi
      ;;
    sh|bash)
      if command -v shfmt &>/dev/null; then
        shfmt -w "$FILE" && FORMATTED=$((FORMATTED+1))
      else
        SKIPPED=$((SKIPPED+1))
      fi
      ;;
    *)
      # Unknown extension — skip silently
      ;;
  esac
}

# ─── Main ────────────────────────────────────────────────────────
echo ""
echo -e "${BOLD}Formatting source files...${NC}"
echo ""

if [ -n "$1" ]; then
  # Format single file
  if [ -f "$1" ]; then
    format_file "$1"
    echo -e "  ${GREEN}✓${NC} Formatted: $1"
  else
    echo "File not found: $1"
    exit 1
  fi
else
  # Format all supported files (skip node_modules, .git, vendor, target)
  while IFS= read -r -d '' file; do
    format_file "$file"
  done < <(find . \
    -not -path "./.git/*" \
    -not -path "./node_modules/*" \
    -not -path "./vendor/*" \
    -not -path "./target/*" \
    -not -path "./.next/*" \
    -not -path "./dist/*" \
    -not -path "./build/*" \
    -type f \
    \( -name "*.js" -o -name "*.jsx" -o -name "*.ts" -o -name "*.tsx" \
       -o -name "*.py" -o -name "*.go" -o -name "*.rs" -o -name "*.rb" \
       -o -name "*.java" -o -name "*.kt" -o -name "*.sh" \
       -o -name "*.json" -o -name "*.css" -o -name "*.scss" \
       -o -name "*.yaml" -o -name "*.yml" \) \
    -print0)
fi

echo ""
echo -e "${BOLD}─────────────────────────────────${NC}"
echo -e "  ${GREEN}✓${NC} Formatted: $FORMATTED files"
if [ "$SKIPPED" -gt 0 ]; then
  echo -e "  ${YELLOW}⚠${NC} Skipped:   $SKIPPED files (formatter not installed)"
fi
echo -e "${BOLD}─────────────────────────────────${NC}"
echo ""
