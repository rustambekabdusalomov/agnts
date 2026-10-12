# C# and .NET review checklist

- Async: async all the way (no `.Result`/`.Wait()` that can deadlock); `CancellationToken` passed through; `async void` only for event handlers; `ConfigureAwait` per the codebase's convention.
- Nullability: nullable reference warnings not suppressed with `!` where null is possible.
- Resources: `IDisposable`/`IAsyncDisposable` in `using`; `HttpClient` from `IHttpClientFactory`, not new per request.
- EF Core: no N+1 (`Include` or projections); `AsNoTracking` for reads; queries not materialised early (`ToList` before filtering); migrations reviewed for data loss.
- Exceptions: not used for control flow; not swallowed; context preserved (`throw;`, not `throw ex;`).
- DI: service lifetimes correct (no scoped service captured by a singleton).
- Security: parameterised SQL; authorization attributes or policies on endpoints; secrets in configuration providers, not code.
- Tests: xUnit/NUnit with clear arrange-act-assert; no real network.
