# React review checklist

- Hooks: called unconditionally and at the top level; dependency arrays complete (no stale closures) and free of objects recreated every render; effects clean up subscriptions, timers and listeners.
- Effects: no `useEffect` for what can be derived during render; no fetch without cancellation or race handling (AbortController, ignore flag, or the data library).
- State: no duplicated or derived state that can go out of sync; state updated immutably; updates based on the previous value use the updater form.
- Keys: stable, unique keys from data, never array indexes for lists that reorder or filter.
- Rendering: no expensive work or new object/function props on every render where it causes child re-renders that matter; memoisation only where it pays.
- Server/client: `"use client"` boundaries correct (Next.js); no browser APIs during server rendering; no secrets in client bundles.
- Accessibility: interactive elements are buttons/links (not clickable divs); images have alt text; form inputs have labels; focus is managed in dialogs.
- Security: no `dangerouslySetInnerHTML` with unsanitised data; URLs from data are not used as `javascript:` links.
- Forms: controlled inputs consistent; validation errors shown; double submission prevented.
- Tests: Testing Library queries by role/label, user-event over fireEvent, no implementation-detail assertions.
