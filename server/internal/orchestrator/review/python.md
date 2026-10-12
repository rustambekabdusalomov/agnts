# Python review checklist

- Errors: no bare `except:` or `except Exception: pass`; exceptions keep their cause (`raise X from e`); errors are not swallowed into `None` returns callers do not check.
- Types: new functions have type hints consistent with the codebase; `Optional` values checked before use.
- Mutable defaults: no `def f(x=[])` / `{}` defaults.
- Resources: files, connections and locks use `with`; HTTP calls have timeouts.
- Async: no blocking I/O (requests, time.sleep, sync DB drivers) inside `async def`; tasks are awaited or kept; no fire-and-forget without error handling.
- SQL and shell: parameters, never f-strings or `%` into SQL; `subprocess` with argument lists, not `shell=True` with input.
- Security: no `pickle`/`yaml.load`/`eval` on untrusted data; paths from input checked against traversal; secrets from the environment.
- Data: floats not used for money (Decimal); timezone-aware datetimes; comparisons with `is` only for None/singletons.
- Imports: no circular imports or heavy imports at module level in hot paths.
- Tests: pytest fixtures over global state; no network; parametrize for variants; assertions specific.
