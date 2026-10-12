# JavaScript review checklist

- Async: every promise is awaited or returned; no `forEach(async …)`; rejected promises are caught; no unhandled rejection in event handlers.
- Equality: `===`; `typeof`/`Array.isArray` checks before use of external data.
- Input: values from requests, query strings, storage and `JSON.parse` are validated; numbers parsed explicitly (`Number`, `parseInt(x, 10)`).
- Mutation: objects and arrays shared with callers or state are copied before changing.
- Security: no `innerHTML` with user data, `eval`, `new Function`, or building shell commands and SQL from strings; prototype pollution through merging untrusted objects.
- Errors: no empty `catch`; errors keep their cause (`new Error(msg, { cause })`).
- Node: streams and file handles closed; `fs` sync calls kept out of request paths; environment variables read once with defaults checked.
- Modules: ESM vs CommonJS consistent with the package; no default export changes that break importers.
- Tests: deterministic (time, randomness, network mocked); assertions on behaviour.
