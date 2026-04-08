# Next.js Stack Template
# Claude uses this as a reference when bootstrapping Next.js projects.
# Copy relevant sections into the generated files.

## Agents to generate for Next.js projects

### Required
- `explorer` (always)
- `code-reviewer` (always)
- `test-runner` (if Jest/Vitest detected)
- `security-scanner` (especially important for Next.js — server/client boundary bugs are common)

### Conditional
- `supabase-agent` — if @supabase/supabase-js in deps
- `prisma-agent` — if @prisma/client in deps  
- `api-tester` — if many /api routes detected

---

## Supabase Sub-agent (add if Supabase detected)

```markdown
---
name: supabase-agent
description: Supabase specialist. Use for RLS policy questions, Supabase client usage, auth helpers, database queries, and storage operations. Trigger on: "check RLS", "supabase query", "auth session", "supabase storage", "is this RLS correct".
model: sonnet
tools: Read, Glob, Grep
memory: user
---

You are a Supabase expert. You know the difference between the server client and browser client, RLS policies, auth helpers for Next.js, and common pitfalls.

## Common Next.js + Supabase Pitfalls You Check For
- Using browser client in server components (must use server client)
- Missing RLS policies on tables (data exposed by default)
- Not calling `supabase.auth.getSession()` server-side before checking user
- Storing tokens in localStorage instead of using the built-in auth helpers
- Missing `cookies()` import in server-side Supabase client setup
- Using `createClient` from `@supabase/supabase-js` directly instead of `@supabase/ssr`

## Output Format
```json
{
  "status": "complete",
  "issues": [{"severity": "...", "file": "...", "issue": "...", "fix": "..."}],
  "rls_status": "enabled|disabled|partial",
  "auth_pattern": "correct|incorrect|missing"
}
```
```

---

## CLAUDE.md Template for Next.js

```markdown
# [Project Name]

## Stack
- Next.js [version] (App Router)
- TypeScript
- Tailwind CSS
- [Supabase / Prisma / Drizzle]
- [Testing: Jest / Vitest]

## Directory Map
- `/app` — App Router pages and layouts
- `/app/api` — API route handlers
- `/components` — Shared UI components
- `/lib` — Utilities, db client, helpers
- `/public` — Static assets

## Conventions
- Components: PascalCase, co-located with their test
- API routes: kebab-case directories
- Utilities: camelCase functions
- Database: Use server actions or API routes — never expose DB client to browser

## Commands
- Dev: `npm run dev`
- Test: `npm test`
- Build: `npm run build`
- Lint: `npm run lint`
- Type check: `npx tsc --noEmit`

## NEVER
- Import server-only code in client components
- Call database directly from client components
- Expose environment variables without NEXT_PUBLIC_ prefix (for non-public vars)
- Use `createClient` directly — always use the project's lib/supabase helper

## Agents Available
- `explorer` — codebase search (isolated context)
- `code-reviewer` — diff reviews
- `test-runner` — test suite
- `security-scanner` — auth and security audit
- `supabase-agent` — Supabase-specific help

## Skills Available
- `/analyze-repo` — full project scan
- `/code-review` — structured review
- `/git-workflow` — commits and PRs
- `/test` — run tests
- `/security-scan` — security audit

## SESSION_STATE.md
Read at session start. Updated automatically by PreCompact hook.
```

---

## Hooks additions for Next.js

Add to `PostToolUse` for type checking after significant changes:
```json
{
  "matcher": "Write|Edit",
  "hooks": [{
    "type": "command",
    "command": "bash -c 'FILE=$(echo $CLAUDE_TOOL_INPUT | python3 -c \"import sys,json; print(json.load(sys.stdin).get(\\\"file_path\\\",\\\"\\\"))\"); if [[ $FILE == *.ts ]] || [[ $FILE == *.tsx ]]; then npx tsc --noEmit 2>&1 | tail -5; fi'"
  }]
}
```
