<script setup lang="ts" generic="T">
// A radio in the panel's style, the CheckBox's sibling. The native input
// stays (visually hidden) so arrow keys, screen readers and forms work;
// the dot is drawn over it. Radios sharing a `name` form one group.
// `tone` colours a checked radio as right (ok) or wrong (bad).
defineProps<{ value: T; name: string; label?: string; disabled?: boolean; tone?: 'ok' | 'bad' }>()
const model = defineModel<T>()
</script>

<template>
  <label class="rdo" :class="[{ dis: disabled }, tone && `tone-${tone}`]">
    <input v-model="model" class="rdo-in" type="radio" :name="name" :value="value" :disabled="disabled" :aria-label="label">
    <span class="rdo-dot" aria-hidden="true" />
    <span v-if="$slots.default" class="rdo-lbl"><slot /></span>
  </label>
</template>

<style scoped>
.rdo { --rdo: var(--primary); display: inline-flex; align-items: center; gap: 8px; font-size: 14.5px; cursor: pointer; position: relative; user-select: none; }
.rdo.tone-ok { --rdo: var(--ok); }
.rdo.tone-bad { --rdo: var(--bad); }
.rdo.dis { cursor: default; }
.rdo-in { position: absolute; opacity: 0; width: 1px; height: 1px; margin: 0; pointer-events: none; }
.rdo-dot {
  flex: none; width: 18px; height: 18px; border-radius: 50%; display: grid; place-items: center;
  border: 1.5px solid var(--line-3); background: var(--field);
  transition: border-color 0.15s, box-shadow 0.15s;
}
.rdo-dot::after { content: ''; width: 8px; height: 8px; border-radius: 50%; background: var(--rdo); transform: scale(0); transition: transform 0.15s ease; }
.rdo:not(.dis):hover .rdo-dot { border-color: var(--rdo); }
.rdo-in:checked + .rdo-dot { border-color: var(--rdo); }
.rdo-in:checked + .rdo-dot::after { transform: scale(1); }
.rdo-in:disabled:not(:checked) + .rdo-dot { opacity: 0.55; }
.rdo-in:focus-visible + .rdo-dot { box-shadow: 0 0 0 3px var(--ring); border-color: var(--rdo); }
@media (prefers-reduced-motion: reduce) {
  .rdo-dot, .rdo-dot::after { transition: none; }
}
</style>
