# Rust Stack — Bootstrap Configuration

## Detection
- `Cargo.toml` exists in project root

## Key Commands
```yaml
install_cmd: "cargo fetch"
dev_cmd: "cargo run"
test_cmd: "cargo test"
build_cmd: "cargo build --release"
format_cmd: "cargo fmt"
lint_cmd: "cargo clippy"
```

## Common Frameworks
- **Axum** — `axum` in Cargo.toml
- **Actix** — `actix-web` in Cargo.toml
- **Rocket** — `rocket` in Cargo.toml
- **Tokio** — `tokio` in Cargo.toml (async runtime)

## Recommended Agent Set
- explore (Haiku) — searches Rust files, understands module structure
- test-runner (Haiku) — `cargo test` with output parsing
- code-reviewer (Sonnet) — ownership, lifetimes, unsafe usage

## Rust-Specific Rules for CLAUDE.md
```
- Never use `unwrap()` in production code — use `?` or proper error handling
- Run `cargo clippy` before committing — treat warnings as errors
- Run `cargo fmt` before committing — enforced by hook
- Prefer `cargo test` over `cargo test -- --nocapture` (cleaner output)
- Mark all `unsafe` blocks with a comment explaining why it's safe
- Use `cargo audit` periodically to check for vulnerable dependencies
```

## Hook: Auto-format
```bash
if [ "$EXT" = "rs" ]; then
  rustfmt "$FILE"
fi
```
