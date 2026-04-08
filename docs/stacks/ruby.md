# Ruby Stack — Bootstrap Configuration

## Detection
- `Gemfile` exists in project root

## Key Commands
```yaml
install_cmd: "bundle install"
dev_cmd: "rails server"  # or: ruby app.rb (Sinatra)
test_cmd: "bundle exec rspec"
build_cmd: "N/A"
format_cmd: "rubocop -a"
lint_cmd: "rubocop"
```

## Common Frameworks
- **Rails** — `rails` in Gemfile
- **Sinatra** — `sinatra` in Gemfile
- **Hanami** — `hanami` in Gemfile

## Database Detection
- Check `config/database.yml` for adapter (postgresql, mysql2, sqlite3)
- Check Gemfile for `pg`, `mysql2`, `sqlite3`

## Recommended Agent Set
- explore (Haiku) — Rails convention-aware file search
- test-runner (Haiku) — RSpec/Minitest runner
- code-reviewer (Sonnet) — Rails idioms, N+1 query detection

## Ruby-Specific Rules for CLAUDE.md
```
- Follow Rails conventions — "convention over configuration"
- Always run migrations before starting server after a pull
- Use `bundle exec` for all gem commands
- Avoid `puts` in production code — use Rails logger
- Check for N+1 queries with bullet gem in development
- Run `rubocop` before committing
```

## Hook: Auto-format
```bash
if [ "$EXT" = "rb" ]; then
  rubocop --autocorrect "$FILE" 2>/dev/null || true
fi
```
