# PHP review checklist

- Types: declared parameter, return and property types; `declare(strict_types=1)` where the codebase uses it; no loose `==` comparisons on user input.
- SQL: prepared statements/bindings only; no string interpolation into queries.
- Output: escaping for HTML (`htmlspecialchars`/template auto-escape); no raw output of user data.
- Input: request data validated before use; file uploads checked for type and size; paths not built from input without checks.
- Errors: exceptions not swallowed; no `@` error suppression.
- Security: password hashing with `password_hash`; CSRF tokens on state-changing forms; no `unserialize` on untrusted data.
- PSR-12 style and the project's autoloading conventions.
- Tests: PHPUnit/Pest covering the changed behaviour.
