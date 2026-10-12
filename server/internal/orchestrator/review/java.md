# Java review checklist

- Nulls: no new paths that return or pass null where callers do not expect it; `Optional` not used for fields or parameters; `Objects.requireNonNull` at boundaries.
- Exceptions: no empty catch or catch-and-log-and-continue that hides failures; checked exceptions wrapped with cause; resources in try-with-resources.
- Concurrency: shared mutable state synchronised or replaced with concurrent collections; no blocking calls on event-loop/reactive threads; executors shut down.
- Collections: no modification while iterating; `equals`/`hashCode` consistent for keys; immutable collections returned from APIs where callers should not change them.
- Streams: no side effects inside `map`/`filter`; no stream where a loop is clearer and faster.
- SQL: prepared statements/JPA parameters only; no string concatenation into queries.
- APIs: public method signatures and serialized DTOs stay compatible.
- Tests: JUnit 5 with clear names; Mockito mocks verify behaviour, not every call; no `Thread.sleep`.
