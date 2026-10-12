# Rust review checklist

- Errors: no `unwrap()`/`expect()` on values that can fail at runtime outside tests and truly impossible cases; errors carry context (`anyhow::Context`, `thiserror` variants); `?` used instead of manual matches that drop information.
- Panics: no indexing that can go out of bounds on input data; no `unreachable!` on reachable paths.
- Ownership: no needless `clone()` in hot paths; borrows instead of moves where the caller keeps the value; no `Rc<RefCell>` where ownership could be clearer.
- Unsafe: every `unsafe` block has a SAFETY comment that holds; no new unsafe without need.
- Async: no blocking calls (std fs, `std::thread::sleep`, heavy CPU) in async functions; spawned tasks are joined or their errors handled; no lock held across `.await`.
- Concurrency: `Mutex` poisoning handled; `Send`/`Sync` bounds correct.
- APIs: public types and functions stay compatible; `#[must_use]` results used.
- Numbers: integer overflow on input-driven arithmetic (`checked_*`/`saturating_*`); casts with `as` that truncate.
- Tests: unit tests next to code; property tests where invariants matter.
