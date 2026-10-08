<script setup lang="ts">
// A checkbox in the panel's style. The native input stays (visually
// hidden) so keyboard, screen readers and forms work as before; the box
// is drawn over it. The label is the slot, or `label` when there is no
// visible text.
defineProps<{ label?: string; disabled?: boolean }>()
const model = defineModel<boolean>({ required: true })
</script>

<template>
  <label class="cbx" :class="{ dis: disabled }">
    <input v-model="model" class="cbx-in" type="checkbox" :disabled="disabled" :aria-label="label">
    <span class="cbx-box" aria-hidden="true">
      <svg viewBox="0 0 16 16"><path d="M3.5 8.5l3 3 6-7" /></svg>
    </span>
    <span v-if="$slots.default" class="cbx-lbl"><slot /></span>
  </label>
</template>

<style scoped>
.cbx { display: inline-flex; align-items: center; gap: 8px; font-size: 14.5px; cursor: pointer; position: relative; user-select: none; }
.cbx.dis { cursor: not-allowed; opacity: 0.55; }
.cbx-in { position: absolute; opacity: 0; width: 1px; height: 1px; margin: 0; pointer-events: none; }
.cbx-box {
  flex: none; width: 18px; height: 18px; border-radius: 5px; display: grid; place-items: center;
  border: 1.5px solid var(--line-3); background: var(--field);
  transition: background-color 0.15s, border-color 0.15s, box-shadow 0.15s;
}
.cbx-box svg { width: 14px; height: 14px; fill: none; stroke: var(--on-primary); stroke-width: 2.2; stroke-linecap: round; stroke-linejoin: round; stroke-dasharray: 16; stroke-dashoffset: 16; transition: stroke-dashoffset 0.18s ease; }
.cbx:not(.dis):hover .cbx-box { border-color: var(--primary); }
.cbx-in:checked + .cbx-box { background: var(--primary); border-color: var(--primary); }
.cbx-in:checked + .cbx-box svg { stroke-dashoffset: 0; }
.cbx-in:focus-visible + .cbx-box { box-shadow: 0 0 0 3px var(--ring); border-color: var(--primary); }
@media (prefers-reduced-motion: reduce) {
  .cbx-box, .cbx-box svg { transition: none; }
}
</style>
