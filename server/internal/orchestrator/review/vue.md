# Vue review checklist

- Reactivity: `ref`/`reactive` not destructured into plain values (use `toRefs`/`storeToRefs`); props not mutated; computed values have no side effects.
- Watchers: `watch` sources are getters or refs; deep watchers only when needed; watchers and listeners are cleaned up (`onUnmounted`, `onScopeDispose`).
- Async: requests started in setup are cancelled or ignored when the component unmounts or the input changes; loading and error states handled.
- Templates: `v-for` has stable `:key`s; `v-if` and `v-for` not on the same element; no `v-html` with user data.
- Components: props typed and validated; emits declared (`defineEmits`); two-way binding through `v-model`/`defineModel`, not prop mutation.
- Pinia: state changed through actions or `$patch`, not from many components ad hoc; getters pure.
- Router: route params validated; navigation guards return correctly; no leaking listeners on route change.
- i18n: user-facing text goes through the project's translation setup.
- Accessibility: buttons for actions, labels for inputs, focus handling in dialogs.
- Tests: mount with the real store where it matters; assert on rendered output and emitted events.
