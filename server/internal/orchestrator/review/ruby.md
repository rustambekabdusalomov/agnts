# Ruby review checklist

- Errors: no bare `rescue` that swallows everything; `rescue => e` re-raises or handles meaningfully.
- Nil: `&.` does not hide a bug the code must handle; methods return consistent types.
- Security: no `eval`/`send` with user input; shell commands with argument arrays; no `YAML.load` on untrusted data (use `safe_load`).
- Strings: frozen string literals where the codebase uses them; no mutation of shared strings.
- Performance: no queries or heavy work inside loops; memoisation does not cache across users.
- Style: follows the project's RuboCop configuration.
- Tests: RSpec/Minitest covering the change; no network; factories not creating more records than needed.
