# Flutter and Dart review checklist

- Async: `BuildContext` not used after an `await` without checking `mounted`; futures awaited or explicitly ignored (`unawaited`); streams and controllers closed in `dispose`.
- State: state lives at the right level; `setState` only in mounted State objects; providers/blocs not recreated in `build`.
- Widgets: `const` constructors where possible; no heavy work in `build`; keys for list items that reorder; large lists use builders.
- Null safety: no `!` on values that can be null; `late` only with guaranteed initialisation.
- Errors: exceptions from platform channels and HTTP handled; no empty catch.
- Layout: no overflow on small screens; text scales; tap targets at least 48 px.
- i18n: user-facing strings through the localisation setup, not literals.
- Tests: widget tests with `pumpAndSettle` used carefully; golden tests updated only with a reason.
