# Monorepo Stack — Bootstrap Configuration

## Detection
- `pnpm-workspace.yaml` or `turbo.json` or `nx.json` or `lerna.json` exists
- Or `workspaces` key in root `package.json`

## Key Commands
```yaml
# Turborepo
install_cmd: "pnpm install"
dev_cmd: "pnpm dev"
test_cmd: "pnpm turbo test"
build_cmd: "pnpm turbo build"
lint_cmd: "pnpm turbo lint"

# Nx
install_cmd: "npm install"
dev_cmd: "nx serve [app-name]"
test_cmd: "nx run-many --target=test"
build_cmd: "nx run-many --target=build"
```

## Workspace Structure Detection
Look for:
- `apps/` — individual applications
- `packages/` — shared libraries
- `services/` — backend services
- `libs/` — framework-specific libraries (Nx)

## Recommended Agent Set
- explore (Haiku) — workspace-aware search, understands package boundaries
- test-runner (Haiku) — runs tests for affected packages only
- code-reviewer (Sonnet) — cross-package dependency review
- task-planner (Sonnet) — coordinates changes across packages

## Monorepo-Specific Rules for CLAUDE.md
```
- Always scope changes to the correct package — check `package.json` name
- Use workspace commands to run scripts: `pnpm --filter <package> <script>`
- Don't add dependencies to root unless they're dev tools for all packages
- Run `turbo build` from root to verify no broken cross-package imports
- Shared code goes in packages/ — never import from apps/ in other apps/
- When changing a shared package, check all consumers with `turbo test --filter=...[HEAD]`
```
