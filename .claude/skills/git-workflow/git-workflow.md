---
name: git-workflow
description: "Git workflow assistant. Handles commits, branches, PRs, and merge conflict resolution. Follows conventional commits format. Invoked when user wants to commit, branch, or manage PRs."
triggers:
  - commit
  - branch
  - pull request
  - merge conflict
  - git
  - push
  - /commit
  - /pr
type: manual
---

# Git Workflow Skill

You are assisting with Git operations. Follow these conventions exactly.

## Commit Message Format

Always use Conventional Commits:
```
<type>(<scope>): <short description>

[optional body]

[optional footer]
```

**Types:** feat, fix, docs, style, refactor, perf, test, chore, ci, build

**Examples:**
- `feat(auth): add OAuth2 login flow`
- `fix(api): handle null response from upstream`
- `chore(deps): update tailwind to v4`

## Before Committing

Run this checklist:
1. `git status` — confirm what's staged
2. `git diff --staged` — review what will be committed
3. Check for: secrets, debug logs, TODO comments that shouldn't ship
4. If tests exist: confirm they pass before committing

## Branch Naming

Format: `<type>/<short-description>`
- `feat/user-auth`
- `fix/null-pointer-on-login`
- `chore/update-deps`

## PR Description Template

When creating a PR, always include:

```markdown
## What
[1-2 sentences: what changed]

## Why
[1-2 sentences: motivation or linked issue]

## How
[Optional: non-obvious implementation details]

## Testing
[How to verify this works]
```

## Merge Conflict Resolution

When resolving conflicts:
1. Read both sides carefully — understand the intent of each change
2. Don't just pick one side blindly
3. If unclear, ask the user which intent should win
4. After resolving: run tests before committing the merge

## Dangerous Operations

Before running any of these, ALWAYS confirm with the user:
- `git push --force` or `git push -f`
- `git reset --hard`
- `git clean -fd`
- Deleting a branch that has unmerged commits

## Common Workflows

### Feature Branch Workflow
```bash
git checkout -b feat/my-feature
# ... make changes ...
git add <specific files>
git commit -m "feat(scope): description"
git push -u origin feat/my-feature
# Create PR via gh pr create
```

### Fixup Workflow (amending last commit)
```bash
git add <files>
git commit --amend --no-edit  # Only if not yet pushed
```

### Stash Workflow
```bash
git stash push -m "WIP: description"
# ... do other work ...
git stash pop
```

## Signs to Stop and Ask

Stop and check with the user if:
- You're about to push to `main` or `master` directly
- There are untracked files that might be important
- The diff is larger than expected
- Merge conflicts touch files you don't fully understand
