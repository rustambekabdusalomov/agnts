# TypeScript review checklist

- Types: no new `any`, `as any`, non-null `!` or `@ts-ignore` to silence a real type problem; `unknown` plus narrowing for external data; discriminated unions over optional-field soup.
- External data (API responses, `JSON.parse`, query params, env) is validated at the boundary (zod/valibot or explicit checks), not cast.
- Async: every promise is awaited, returned or deliberately handled (`void` with a comment); no `forEach(async …)`; errors from `await` reach a handler; `Promise.all` for independent work, not sequential awaits in a loop.
- Null and undefined: optional chaining does not hide a bug the code should handle; `??` vs `||` used correctly for 0 and "".
- Equality and coercion: `===`; no arithmetic on strings from inputs without parsing.
- Mutation: shared objects and arrays are not mutated when callers keep references (state, props, caches); spread or structured clones where needed.
- Errors: `catch (e)` narrows `e` before use; no empty catch; thrown values are `Error`s.
- Imports: no import of server-only modules into client code (or the reverse); no circular imports introduced.
- Security: no `innerHTML`/`dangerouslySetInnerHTML`/`v-html` with user data; no `eval`/`new Function`; URLs and redirects validated.
- Public API: exported types and function signatures stay compatible for existing callers.
- Tests: behaviour, not implementation details; no snapshot updated blindly; timers and network mocked.
