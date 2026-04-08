---
name: self-update
description: "Checks for bootstrap updates and applies them safely. Compares local version against the source repo, shows what changed, and lets user apply updates selectively. Triggered by /update or when bootstrap_version in USER_PROFILE.json is outdated."
triggers:
  - /update
  - check for updates
  - update bootstrap
  - update claude setup
  - is my setup outdated
type: manual
---

# Self-Update Skill

You are checking if the user's Claude Code bootstrap setup is up to date and helping them apply updates.

## Step 1 — Check Current Version

Read `USER_PROFILE.json`:
```bash
python3 -c "
import json, pathlib
p = pathlib.Path('USER_PROFILE.json')
if p.exists():
    d = json.loads(p.read_text())
    print(f'bootstrap_version={d.get(\"bootstrap_version\",\"unknown\")}')
else:
    print('bootstrap_version=unknown')
"
```

## Step 2 — Check Bootstrap Repo

Look for the bootstrap repo in common locations:
```bash
# Check if bootstrap repo is still present
for dir in claude-bootstrap .claude-bootstrap ../claude-bootstrap; do
  if [ -d "$dir/.git" ]; then
    echo "BOOTSTRAP_DIR=$dir"
    break
  fi
done
```

If found, check its version:
```bash
python3 -c "
import json, pathlib
# Check bootstrap's own version marker
v_file = pathlib.Path('claude-bootstrap/VERSION') 
if v_file.exists():
    print(f'latest={v_file.read_text().strip()}')
else:
    print('latest=unknown')
"
```

## Step 3 — Compare and Report

Tell the user what you found:

**If bootstrap repo not found:**
> "The claude-bootstrap repo isn't in your project folder — it may have been deleted after the initial setup. To get updates, clone it again: `git clone https://github.com/your-org/claude-bootstrap`"

**If up to date:**
> "Your setup is current (v{{VERSION}}). No updates needed."

**If outdated:**
Show what changed:
```
## Available Updates

Current version: {{CURRENT}}
Latest version:  {{LATEST}}

Changes:
[list changes from bootstrap CHANGELOG or git log]
```

## Step 4 — Selective Update

Ask the user which components to update:

```
What would you like to update?
1. CLAUDE.md (orchestrator instructions)
2. Skill files (.claude/skills/)
3. Hook scripts (.claude/hooks/)
4. Stack templates (docs/stacks/)
5. All of the above
6. Nothing — just show me what changed
```

## Step 5 — Apply Updates

For each selected component:
1. Show a diff of what will change (plain language, not raw diff)
2. Ask for confirmation
3. Apply the update
4. Update `bootstrap_version` in `USER_PROFILE.json`

## Safety Rules

- NEVER overwrite `USER_PROFILE.json` during an update
- NEVER overwrite user's custom CLAUDE.md without explicit confirmation
- ALWAYS show what will change before applying
- ALWAYS back up files before overwriting: `cp file file.bak`
- If a file has been customized (differs from template), warn the user

## Conflict Detection

Before applying any update, check if the local file differs from the template:
```bash
diff "claude-bootstrap/docs/templates/developer/CLAUDE.md.tpl" "CLAUDE.md" 2>/dev/null && echo "UNCHANGED" || echo "CUSTOMIZED"
```

If customized, say:
> "Your CLAUDE.md has been customized. I'll show you what the update adds so you can merge manually."
