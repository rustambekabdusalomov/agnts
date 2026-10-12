# Kotlin review checklist

- Null safety: no `!!` on values that can be null; platform types from Java handled; `lateinit` only where initialisation is guaranteed.
- Coroutines: structured concurrency (no `GlobalScope`); scopes tied to lifecycle; blocking calls moved to `Dispatchers.IO`; `CancellationException` rethrown, not swallowed; `runBlocking` not in production paths.
- Flows: collected in a lifecycle-aware way; hot flows (`StateFlow`, `SharedFlow`) not recreated on every call.
- Data classes: used for values; mutable properties avoided in shared state; `copy` for changes.
- Exceptions: `runCatching` results not ignored; errors not turned into silent nulls.
- Android/Compose: no work on the main thread; state hoisted; `remember` keys correct; no leaks of Activity/Context.
- Ktor/Exposed: transactions around multi-step writes; parameters, not string SQL.
- Tests: coroutines tested with `runTest`; fakes over deep mocks.
