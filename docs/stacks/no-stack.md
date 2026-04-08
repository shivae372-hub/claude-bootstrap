# No Stack Detected — Bootstrap Configuration

## When This Applies
- No `package.json`, `requirements.txt`, `go.mod`, `Cargo.toml`, `Gemfile`, or `pom.xml`
- Could be: scripts directory, documentation repo, infrastructure-as-code, data project, or truly empty project

## Detection Approach
When no standard stack is detected, Claude should:
1. List the top-level files and directories
2. Identify the closest category:
   - **Scripts/Automation** — mostly `.sh`, `.py`, `.ps1` files
   - **Documentation** — mostly `.md`, `.rst`, `.txt` files
   - **Infrastructure** — Terraform, Ansible, Kubernetes YAML
   - **Data** — CSV, JSON, Parquet, Jupyter notebooks
   - **Empty** — truly new project, needs scaffolding

## Recommended Minimal Setup

For any undetected stack, generate a minimal setup:

```yaml
agents: []  # No agents — main context handles everything
skills:
  - context-guard  # Always include
  - git-workflow   # If git repo detected
hooks:
  - checkpoint     # Always include
```

## CLAUDE.md Template (Minimal)
```
# {{PROJECT_NAME}}

## What This Is
{{PROJECT_DESCRIPTION}}

## Key Files
{{KEY_FILES}}

## How to Work Here
{{WORKFLOW}}
```

## Rules
- Don't generate agents for a project that has nothing to explore
- Ask the user to describe their workflow before generating skills
- Suggest scaffolding if the project appears truly empty
