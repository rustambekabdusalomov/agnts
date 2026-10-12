# Go review checklist

Check each point against the diff and the code around it. Report only what actually goes wrong here.

- Errors: every returned error is handled or returned with context (`fmt.Errorf("load user: %w", err)`); no `_ = err`; sentinel errors compared with `errors.Is`, typed ones with `errors.As`; no string matching on `err.Error()`.
- Wrapping: `%w` (not `%v`) when callers need the cause; no double logging of an error that is also returned.
- Goroutines: each one has a way to end (context, closed channel, WaitGroup); no goroutine leak on early return; `go func()` capturing loop variables is fine since Go 1.22 but shared state is not.
- Context: passed as the first argument and down the call chain; not stored in structs; `context.Background()` only at the top of a program or in tests; cancellation and deadlines respected in loops and blocking calls.
- Concurrency: maps and slices shared between goroutines are guarded; `sync.Mutex` not copied (value receivers on structs holding one); channels closed by the sender only; no unbuffered send that can block forever.
- Resources: `defer rows.Close()`, `defer resp.Body.Close()`, `defer f.Close()` right after the error check; `rows.Err()` checked after the loop; HTTP clients have timeouts.
- Nil: nil maps written to; nil pointer dereferences after a failed type assertion (use the two-value form); interfaces holding typed nil pointers returned as non-nil errors.
- SQL: parameters, never string concatenation; transactions rolled back on error (`defer tx.Rollback()` is safe after commit).
- APIs: exported names have doc comments; zero values are useful; no breaking change to exported types or functions other packages use.
- Tests: table-driven where cases vary; `t.Helper()` in helpers; no `time.Sleep` to wait for goroutines; `-race`-safe.
- Performance: no allocation or regexp compilation inside hot loops; `strings.Builder` for repeated concatenation; slices preallocated when the size is known.
