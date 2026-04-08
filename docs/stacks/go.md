# Go Stack — Bootstrap Configuration

## Detection
- `go.mod` exists in project root

## Key Commands
```yaml
install_cmd: "go mod download"
dev_cmd: "go run ./..."
test_cmd: "go test ./..."
build_cmd: "go build ./..."
format_cmd: "gofmt -w ."
lint_cmd: "golangci-lint run"
```

## Common Frameworks
- **Gin** — `github.com/gin-gonic/gin` in go.mod
- **Echo** — `github.com/labstack/echo` in go.mod
- **Fiber** — `github.com/gofiber/fiber` in go.mod
- **Chi** — `github.com/go-chi/chi` in go.mod
- **gRPC** — `google.golang.org/grpc` in go.mod

## Recommended Agent Set
- explore (Haiku) — fast file search, Go AST awareness
- test-runner (Haiku) — `go test ./...` with race detector
- code-reviewer (Sonnet) — Go idioms, error handling patterns

## Go-Specific Rules for CLAUDE.md
```
- Always check errors — never use `_` to discard errors silently
- Use `go test -race ./...` to catch race conditions
- Run `gofmt` before committing — enforced by hook
- Prefer table-driven tests
- Use `context.Context` as first argument in all public functions
- Never use `init()` unless absolutely necessary
```

## Hook: Auto-format
```bash
if [ "$EXT" = "go" ]; then
  gofmt -w "$FILE"
  goimports -w "$FILE" 2>/dev/null || true
fi
```
