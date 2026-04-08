# Python Stack Template
# Claude uses this as a reference when bootstrapping Python (Django / FastAPI / Flask) projects.

## Agents to generate for Python projects

### Required
- `explorer` (always)
- `code-reviewer` (always)
- `test-runner` (pytest)
- `security-scanner`

### Conditional
- `django-agent` — if Django detected
- `fastapi-agent` — if FastAPI detected
- `migration-agent` — if Django/Alembic/SQLAlchemy detected

---

## Django Sub-agent (add if Django detected)

```markdown
---
name: django-agent
description: Django specialist. Use for ORM queries, migrations, views, serializers, and Django security. Trigger on: "django query", "write a migration", "check this view", "DRF serializer", "django permissions".
model: sonnet
tools: Read, Bash, Glob
memory: user
---

You are a Django expert. You know Django ORM, DRF, migrations, signals, middleware, and common Django security patterns.

## Common Django Issues You Check For
- N+1 queries (missing `select_related` / `prefetch_related`)
- Missing `@login_required` or permission checks on views
- Using `raw()` SQL without parameterization
- Storing sensitive data in sessions
- Missing CSRF protection on state-changing endpoints
- `DEBUG = True` in production settings

## Migration Safety
Before suggesting a migration:
1. Check if the migration is reversible
2. Flag any operations that lock tables on large datasets
3. Suggest `RunPython` for data migrations over raw SQL

## Output Format
```json
{
  "status": "complete",
  "issues": [{"severity": "...", "file": "...", "line": 0, "issue": "...", "fix": "..."}],
  "migration_safe": true
}
```
```

---

## CLAUDE.md Template for Django/FastAPI

```markdown
# [Project Name]

## Stack
- Python [version]
- [Django X.X / FastAPI X.X / Flask X.X]
- [PostgreSQL / SQLite]
- [SQLAlchemy / Django ORM / Tortoise ORM]
- pytest

## Directory Map (Django)
- `/[app_name]/` — Main Django app
- `/[app_name]/models.py` — Database models
- `/[app_name]/views.py` — View logic
- `/[app_name]/urls.py` — URL routing
- `/[app_name]/serializers.py` — DRF serializers
- `/tests/` — Test files
- `/config/` — Settings and WSGI

## Commands
- Dev: `python manage.py runserver`
- Test: `python -m pytest`
- Migrate: `python manage.py migrate`
- Shell: `python manage.py shell`
- Lint: `ruff check .`
- Format: `ruff format .`

## Conventions
- Models: PascalCase
- Views: snake_case functions or PascalCase classes
- URLs: kebab-case
- Always use `get_object_or_404` not bare `get()`
- Always use parameterized queries — never f-strings in ORM raw()

## NEVER
- Use `DEBUG = True` in production
- Commit `.env` or `local_settings.py`
- Use `*` imports in views or models
- Store passwords in plaintext

## Agents Available
- `explorer` — codebase search
- `code-reviewer` — diff reviews
- `test-runner` — pytest
- `security-scanner` — Django security audit
- `django-agent` — ORM, migrations, views

## Skills Available
- `/analyze-repo` — full scan
- `/code-review` — structured review
- `/git-workflow` — commits and PRs
- `/test` — run pytest
- `/security-scan` — security audit
```

---

## Hook additions for Python

Auto-format with ruff after file writes:
```bash
# In format.sh, this is already handled.
# The hook detects .py extension and runs ruff.
# Make sure ruff is installed: pip install ruff
```
